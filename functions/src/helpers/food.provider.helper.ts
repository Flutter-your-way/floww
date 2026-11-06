import {logger} from "firebase-functions";
import {defineString} from "firebase-functions/params";
import {CatalogFood} from "../models/food.model";
import {USDA_PROVIDER, searchUsdaFoods} from "./usda.helper";

type FoodSearchProvider = (query: string) => Promise<CatalogFood[]>;

const FOOD_PROVIDERS: Record<string, FoodSearchProvider> = {
  [USDA_PROVIDER]: searchUsdaFoods,
};

const foodDataProvider = defineString("FOOD_DATA_PROVIDER", {
  default: USDA_PROVIDER,
});

export const activeFoodProvider = (): string => {
  const name = foodDataProvider.value().trim().toLowerCase();
  if (FOOD_PROVIDERS[name]) return name;
  logger.warn("activeFoodProvider: unknown provider, using default", {name});
  return USDA_PROVIDER;
};

export const searchProviderFoods = (query: string): Promise<CatalogFood[]> =>
  FOOD_PROVIDERS[activeFoodProvider()](query);
