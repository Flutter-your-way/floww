import {logger} from "firebase-functions";
import {hashKey, normalizeText} from "../common/utils";
import {foodImageCacheCollection} from "../constants/collections";
import {
  FOOD_IMAGE_HIT_TTL_MS,
  FOOD_IMAGE_MISS_TTL_MS,
  FOOD_IMAGE_SEARCH_URL,
  FOOD_IMAGE_THUMB_SIZE,
  FOOD_IMAGE_TIMEOUT_MS,
  FOOD_IMAGE_USER_AGENT,
  FOOD_IMAGE_VERSION,
} from "../constants/food.image.constants";

interface WikiPage {
  index?: number;
  thumbnail?: {source?: string};
}

interface WikiSearchResponse {
  query?: {pages?: Record<string, WikiPage>};
}

export interface CachedFoodImage {
  url: string | null;
}

export const foodImageQueryOf = (name: string): string =>
  normalizeText(name.split(/[,(]/)[0] ?? name);

const cacheDoc = (query: string) => foodImageCacheCollection.doc(
  hashKey(`${FOOD_IMAGE_VERSION}:${query}`));

export const readCachedFoodImage = async (
  query: string,
): Promise<CachedFoodImage | null> => {
  const snapshot = await cacheDoc(query).get();
  if (!snapshot.exists) return null;

  const url: string | null = snapshot.get("url") ?? null;
  const cachedAt = Date.parse(snapshot.get("cachedAt") ?? "");
  const ttl = url ? FOOD_IMAGE_HIT_TTL_MS : FOOD_IMAGE_MISS_TTL_MS;
  if (!Number.isFinite(cachedAt) || Date.now() - cachedAt > ttl) return null;
  return {url};
};

export const writeCachedFoodImage = async (
  query: string,
  url: string | null,
): Promise<void> => {
  await cacheDoc(query).set({
    query,
    version: FOOD_IMAGE_VERSION,
    url,
    cachedAt: new Date().toISOString(),
  }).catch((error) =>
    logger.error("writeCachedFoodImage: cache write failed", {error}));
};

const withoutTracking = (source: string): string => {
  const url = new URL(source);
  url.search = "";
  return url.toString();
};

export const searchFoodImage = async (
  query: string,
): Promise<string | null> => {
  const url = new URL(FOOD_IMAGE_SEARCH_URL);
  url.search = new URLSearchParams({
    action: "query",
    format: "json",
    generator: "search",
    gsrsearch: query,
    gsrlimit: "3",
    prop: "pageimages",
    piprop: "thumbnail",
    pithumbsize: `${FOOD_IMAGE_THUMB_SIZE}`,
    redirects: "1",
  }).toString();

  try {
    const response = await fetch(url, {
      headers: {"User-Agent": FOOD_IMAGE_USER_AGENT},
      signal: AbortSignal.timeout(FOOD_IMAGE_TIMEOUT_MS),
    });
    if (!response.ok) {
      logger.warn("searchFoodImage: bad response", {status: response.status});
      return null;
    }

    const body = await response.json() as WikiSearchResponse;
    const pages = Object.values(body.query?.pages ?? {})
      .sort((a, b) => (a.index ?? 0) - (b.index ?? 0));
    const source = pages.find((page) => page.thumbnail?.source)
      ?.thumbnail?.source;
    return source ? withoutTracking(source) : null;
  } catch (error) {
    logger.warn("searchFoodImage: request failed", {error});
    return null;
  }
};
