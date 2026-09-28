export const USDA_SEARCH_URL = "https://api.nal.usda.gov/fdc/v1/foods/search";
export const USDA_TIMEOUT_MS = 10_000;
export const USDA_PAGE_SIZE = 25;
export const USDA_DATA_TYPES = ["Foundation", "SR Legacy"] as const;
export const USDA_SERVING = "100 g";
export const USDA_SERVING_WEIGHT_G = 100;

export const FOOD_SEARCH_VERSION = "usda-v1";
export const FOOD_SEARCH_RESULT_LIMIT = 15;
export const FOOD_SEARCH_CACHE_TTL_MS = 30 * 24 * 60 * 60 * 1000;
export const FOOD_SEARCH_DAILY_LIMIT = {premium: 300, free: 300};
export const MIN_FOOD_QUERY_LENGTH = 2;
export const MAX_FOOD_QUERY_LENGTH = 80;

export const USDA_NUTRIENT_IDS = {
  energyKcal: [1008, 2047, 2048],
  proteinG: [1003],
  fatG: [1004],
  carbsG: [1005, 1050],
  fiberG: [1079],
  sugarG: [2000, 1063],
  sodiumMg: [1093],
  waterG: [1051],
} as const;
