import {logger} from "firebase-functions";
import {hashKey, normalizeText} from "../common/utils";
import {exerciseVideoCacheCollection} from "../constants/collections";
import {
  EXERCISE_VIDEO_MATCH_TTL_MS,
  EXERCISE_VIDEO_MISS_TTL_MS,
  EXERCISE_VIDEO_VERSION,
} from "../constants/ymove.constants";
import {
  ExerciseVideo,
  exerciseVideoSchema,
} from "../models/exercise.video.model";
import {ExerciseVideoRequest} from "../validators/exercise.video.validator";

export interface CachedExerciseVideo {
  slug: string | null;
  matchedAt: string;
  isMatchFresh: boolean;
  video: ExerciseVideo | null;
}

const keyOf = ({kind, queries}: ExerciseVideoRequest) =>
  `${EXERCISE_VIDEO_VERSION}:${kind}:${queries.map(normalizeText).join("|")}`;

const videoDoc = (request: ExerciseVideoRequest) =>
  exerciseVideoCacheCollection.doc(hashKey(keyOf(request)));

export const readCachedVideo = async (
  request: ExerciseVideoRequest,
): Promise<CachedExerciseVideo | null> => {
  const snapshot = await videoDoc(request).get();
  if (!snapshot.exists) return null;

  const slug = snapshot.get("slug");
  const matchedAt = snapshot.get("matchedAt") ?? "";
  const matchedAtMs = Date.parse(matchedAt);
  const ttl = slug ? EXERCISE_VIDEO_MATCH_TTL_MS : EXERCISE_VIDEO_MISS_TTL_MS;
  const isMatchFresh = Number.isFinite(matchedAtMs) &&
    Date.now() - matchedAtMs <= ttl;

  const parsed = exerciseVideoSchema.safeParse(snapshot.get("video"));
  const video = parsed.success &&
    Date.parse(parsed.data.expiresAt) > Date.now() ? parsed.data : null;

  return {
    slug: typeof slug === "string" ? slug : null,
    matchedAt,
    isMatchFresh,
    video,
  };
};

export const writeCachedVideo = async (
  request: ExerciseVideoRequest,
  slug: string | null,
  video: ExerciseVideo | null,
  matchedAt: string,
): Promise<void> => {
  await videoDoc(request).set({
    key: keyOf(request),
    slug,
    video,
    matchedAt,
    cachedAt: new Date().toISOString(),
  }).catch((error) =>
    logger.error("writeCachedVideo: cache write failed", {error}));
};
