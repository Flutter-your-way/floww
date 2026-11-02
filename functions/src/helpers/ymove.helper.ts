import {logger} from "firebase-functions";
import {ApiError} from "../common/api.error";
import {normalizeText} from "../common/utils";
import {ymoveApiKey} from "../constants/secrets";
import {
  EXERCISE_VIDEO_URL_TTL_MS,
  YMOVE_BASE_URL,
  YMOVE_PREFERRED_TAG,
  YMOVE_SEARCH_PAGE_SIZE,
  YMOVE_TIMEOUT_MS,
} from "../constants/ymove.constants";
import {ExerciseVideo} from "../models/exercise.video.model";
import {ExerciseVideoRequest} from "../validators/exercise.video.validator";

interface YmoveVideo {
  videoUrl?: string;
  videoHlsUrl?: string;
  thumbnailUrl?: string;
  tag?: string;
  orientation?: string;
  isPrimary?: boolean;
}

interface YmoveExercise {
  slug?: string;
  title?: string;
  hasVideo?: boolean;
  videoUrl?: string | null;
  videoHlsUrl?: string | null;
  thumbnailUrl?: string | null;
  videos?: YmoveVideo[];
}

interface YmoveListResponse {
  data?: YmoveExercise[];
}

interface YmoveDetailResponse {
  data?: YmoveExercise;
}

const MIN_MATCH_SCORE = 0.5;
const PORTRAIT = "portrait";
const YOGA_TYPE = "yoga";

const unavailable = () => new ApiError(
  "VIDEO_UNAVAILABLE",
  "Exercise videos are unavailable right now.",
);

const tokensOf = (value: string): string[] =>
  normalizeText(value).replace(/[^a-z0-9 ]/g, " ").split(" ")
    .filter((token) => token.length > 0);

const matchScore = (query: string, title: string): number => {
  const queryTokens = tokensOf(query);
  const titleTokens = new Set(tokensOf(title));
  if (queryTokens.length === 0 || titleTokens.size === 0) return 0;
  const shared = queryTokens.filter((token) => titleTokens.has(token)).length;
  return shared / Math.max(queryTokens.length, titleTokens.size);
};

const ymoveGet = async <T>(path: string, params: Record<string, string>) => {
  const url = new URL(`${YMOVE_BASE_URL}${path}`);
  for (const [key, value] of Object.entries(params)) {
    url.searchParams.set(key, value);
  }

  let response: Response;
  try {
    response = await fetch(url, {
      headers: {"X-API-Key": ymoveApiKey.value()},
      signal: AbortSignal.timeout(YMOVE_TIMEOUT_MS),
    });
  } catch (error) {
    logger.error("ymoveGet: request failed", {path, error});
    throw unavailable();
  }

  if (response.status === 404) return null;
  if (!response.ok) {
    logger.error("ymoveGet: bad response", {path, status: response.status});
    throw unavailable();
  }
  return await response.json() as T;
};

export const findYmoveSlug = async (
  {kind, queries}: ExerciseVideoRequest,
): Promise<string | null> => {
  for (const query of queries) {
    const body = await ymoveGet<YmoveListResponse>("/exercises", {
      search: query,
      hasVideo: "true",
      excludeVideos: "1",
      pageSize: `${YMOVE_SEARCH_PAGE_SIZE}`,
      ...(kind === "yoga" ? {exerciseType: YOGA_TYPE} : {}),
    });

    let best: {slug: string; score: number; length: number} | null = null;
    for (const exercise of body?.data ?? []) {
      const slug = exercise.slug;
      const title = exercise.title ?? "";
      if (!slug || exercise.hasVideo === false) continue;
      const score = matchScore(query, title);
      if (score < MIN_MATCH_SCORE) continue;
      if (!best || score > best.score ||
        (score === best.score && title.length < best.length)) {
        best = {slug, score, length: title.length};
      }
    }
    if (best) return best.slug;
  }
  return null;
};

const pickVideo = (exercise: YmoveExercise): YmoveVideo | null => {
  const videos = (exercise.videos ?? []).filter((video) => video.videoUrl);
  const rankOf = (video: YmoveVideo) =>
    Number(video.tag === YMOVE_PREFERRED_TAG) * 2 +
    Number(video.isPrimary === true);
  const ranked = [...videos].sort((a, b) => rankOf(b) - rankOf(a));
  if (ranked.length > 0) return ranked[0];
  if (!exercise.videoUrl) return null;
  return {
    videoUrl: exercise.videoUrl,
    videoHlsUrl: exercise.videoHlsUrl ?? undefined,
    thumbnailUrl: exercise.thumbnailUrl ?? undefined,
    orientation: PORTRAIT,
  };
};

export const fetchYmoveVideo = async (
  slug: string,
): Promise<ExerciseVideo | null> => {
  const body = await ymoveGet<YmoveDetailResponse>(
    `/exercises/${encodeURIComponent(slug)}`,
    {},
  );
  const exercise = body?.data;
  if (!exercise) return null;

  const video = pickVideo(exercise);
  if (!video?.videoUrl) return null;

  return {
    slug,
    title: exercise.title ?? "",
    videoUrl: video.videoUrl,
    hlsUrl: video.videoHlsUrl ?? null,
    thumbnailUrl: video.thumbnailUrl ?? exercise.thumbnailUrl ?? null,
    isPortrait: (video.orientation ?? PORTRAIT) === PORTRAIT,
    expiresAt: new Date(Date.now() + EXERCISE_VIDEO_URL_TTL_MS).toISOString(),
  };
};
