export const USDA_SEARCH_URL = "https://api.nal.usda.gov/fdc/v1/foods/search";
export const USDA_TIMEOUT_MS = 10_000;
export const USDA_PAGE_SIZE = 25;
export const USDA_DATA_TYPES = ["Foundation", "SR Legacy"] as const;
export const USDA_SERVING = "100 g";
export const USDA_SERVING_WEIGHT_G = 100;

export const FOOD_SEARCH_VERSION = "v2";
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
  addedSugarG: [1235],
  saturatedFatG: [1258],
  transFatG: [1257],
  monounsaturatedFatG: [1292],
  polyunsaturatedFatG: [1293],
  cholesterolMg: [1253],
  sodiumMg: [1093],
  waterG: [1051],
} as const;

export const USDA_VITAMIN_IDS = {
  vitaminAMcg: [1106],
  vitaminB1Mg: [1165],
  vitaminB2Mg: [1166],
  vitaminB3Mg: [1167],
  vitaminB5Mg: [1170],
  vitaminB6Mg: [1175],
  vitaminB7Mcg: [1176],
  vitaminB9Mcg: [1190, 1177],
  vitaminB12Mcg: [1178],
  vitaminCMg: [1162],
  vitaminDMcg: [1114],
  vitaminEMg: [1109],
  vitaminKMcg: [1185],
  cholineMg: [1180],
} as const;

export const USDA_MINERAL_IDS = {
  calciumMg: [1087],
  ironMg: [1089],
  magnesiumMg: [1090],
  phosphorusMg: [1091],
  potassiumMg: [1092],
  sodiumMg: [1093],
  zincMg: [1095],
  copperMg: [1098],
  manganeseMg: [1101],
  seleniumMcg: [1103],
  iodineMcg: [1100],
} as const;
