import {logger} from "firebase-functions";
import {ApiError} from "../common/api.error";
import {toAmount} from "../common/utils";
import {usdaApiKey} from "../constants/secrets";
import {
  FOOD_SEARCH_RESULT_LIMIT,
  USDA_DATA_TYPES,
  USDA_NUTRIENT_IDS,
  USDA_PAGE_SIZE,
  USDA_SEARCH_URL,
  USDA_SERVING,
  USDA_SERVING_WEIGHT_G,
  USDA_TIMEOUT_MS,
} from "../constants/usda.constants";
import {CatalogFood} from "../models/food.model";

interface UsdaNutrient {
  nutrientId?: number;
  unitName?: string;
  value?: number;
}

interface UsdaFood {
  fdcId?: number;
  description?: string;
  foodNutrients?: UsdaNutrient[];
}

interface UsdaSearchResponse {
  foods?: UsdaFood[];
}

const KCAL_UNIT = "KCAL";

const nutrientValue = (
  nutrients: UsdaNutrient[],
  ids: readonly number[],
  unit?: string,
): number | null => {
  for (const id of ids) {
    const match = nutrients.find((nutrient) =>
      nutrient.nutrientId === id &&
      typeof nutrient.value === "number" &&
      (!unit || nutrient.unitName?.toUpperCase() === unit));
    if (match?.value !== undefined) return match.value;
  }
  return null;
};

const toCatalogFood = (food: UsdaFood): CatalogFood | null => {
  const name = food.description?.trim();
  const nutrients = food.foodNutrients ?? [];
  if (!food.fdcId || !name) return null;

  const calories =
    nutrientValue(nutrients, USDA_NUTRIENT_IDS.energyKcal, KCAL_UNIT);
  if (calories === null) return null;

  const amountOf = (ids: readonly number[]) =>
    toAmount(nutrientValue(nutrients, ids) ?? 0);

  return {
    id: `usda_${food.fdcId}`,
    name,
    serving: USDA_SERVING,
    weightG: USDA_SERVING_WEIGHT_G,
    calories: toAmount(calories, 0),
    proteinG: amountOf(USDA_NUTRIENT_IDS.proteinG),
    carbsG: amountOf(USDA_NUTRIENT_IDS.carbsG),
    fatG: amountOf(USDA_NUTRIENT_IDS.fatG),
    fiberG: amountOf(USDA_NUTRIENT_IDS.fiberG),
    sugarG: amountOf(USDA_NUTRIENT_IDS.sugarG),
    sodiumMg: amountOf(USDA_NUTRIENT_IDS.sodiumMg),
    waterMl: amountOf(USDA_NUTRIENT_IDS.waterG),
  };
};

export const searchUsdaFoods = async (
  query: string,
): Promise<CatalogFood[]> => {
  const url = new URL(USDA_SEARCH_URL);
  url.searchParams.set("api_key", usdaApiKey.value());

  let response: Response;
  try {
    response = await fetch(url, {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({
        query,
        dataType: USDA_DATA_TYPES,
        pageSize: USDA_PAGE_SIZE,
        requireAllWords: true,
      }),
      signal: AbortSignal.timeout(USDA_TIMEOUT_MS),
    });
  } catch (error) {
    logger.error("searchUsdaFoods: request failed", {error});
    throw new ApiError(
      "SEARCH_UNAVAILABLE",
      "Food search is unavailable right now.",
    );
  }

  if (!response.ok) {
    logger.error("searchUsdaFoods: bad response", {status: response.status});
    throw new ApiError(
      "SEARCH_UNAVAILABLE",
      "Food search is unavailable right now.",
    );
  }

  const body = await response.json() as UsdaSearchResponse;
  const seen = new Set<string>();
  const foods: CatalogFood[] = [];
  for (const item of body.foods ?? []) {
    const food = toCatalogFood(item);
    const key = food?.name.toLowerCase();
    if (!food || !key || seen.has(key)) continue;
    seen.add(key);
    foods.push(food);
    if (foods.length >= FOOD_SEARCH_RESULT_LIMIT) break;
  }
  return foods;
};
