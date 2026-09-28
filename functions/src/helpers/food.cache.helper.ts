import {logger} from "firebase-functions";
import {hashKey, normalizeText} from "../common/utils";
import {FOOD_DESCRIBE_PROMPT_VERSION} from "../constants/ai.constants";
import {
  foodDescribeCacheCollection,
  foodSearchCacheCollection,
} from "../constants/collections";
import {
  FOOD_SEARCH_CACHE_TTL_MS,
  FOOD_SEARCH_VERSION,
} from "../constants/usda.constants";
import {
  CatalogFood,
  FoodAnalysis,
  catalogFoodSchema,
  foodAnalysisSchema,
} from "../models/food.model";

const searchDoc = (query: string) => foodSearchCacheCollection.doc(
  hashKey(`${FOOD_SEARCH_VERSION}:${normalizeText(query)}`));

const describeDoc = (text: string) => foodDescribeCacheCollection.doc(
  hashKey(`${FOOD_DESCRIBE_PROMPT_VERSION}:${normalizeText(text)}`));

export const readCachedSearch = async (
  query: string,
): Promise<CatalogFood[] | null> => {
  const snapshot = await searchDoc(query).get();
  if (!snapshot.exists) return null;

  const cachedAt = Date.parse(snapshot.get("cachedAt") ?? "");
  if (!Number.isFinite(cachedAt) ||
    Date.now() - cachedAt > FOOD_SEARCH_CACHE_TTL_MS) {
    return null;
  }

  const parsed = catalogFoodSchema.array().safeParse(snapshot.get("foods"));
  return parsed.success ? parsed.data : null;
};

export const writeCachedSearch = async (
  query: string,
  foods: CatalogFood[],
): Promise<void> => {
  await searchDoc(query).set({
    query: normalizeText(query),
    version: FOOD_SEARCH_VERSION,
    foods,
    cachedAt: new Date().toISOString(),
  }).catch((error) =>
    logger.error("writeCachedSearch: cache write failed", {error}));
};

export const readCachedDescription = async (
  text: string,
): Promise<FoodAnalysis | null> => {
  const snapshot = await describeDoc(text).get();
  if (!snapshot.exists) return null;

  const parsed = foodAnalysisSchema.safeParse(snapshot.get("analysis"));
  return parsed.success ? parsed.data : null;
};

export const writeCachedDescription = async (
  text: string,
  analysis: FoodAnalysis,
): Promise<void> => {
  await describeDoc(text).set({
    text: normalizeText(text),
    promptVersion: FOOD_DESCRIBE_PROMPT_VERSION,
    analysis,
    cachedAt: new Date().toISOString(),
  }).catch((error) =>
    logger.error("writeCachedDescription: cache write failed", {error}));
};
