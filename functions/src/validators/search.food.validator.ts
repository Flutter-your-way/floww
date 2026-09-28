import {z} from "zod";
import {
  MAX_FOOD_QUERY_LENGTH,
  MIN_FOOD_QUERY_LENGTH,
} from "../constants/usda.constants";

export const searchFoodValidator = z.object({
  query: z.string().trim()
    .min(MIN_FOOD_QUERY_LENGTH)
    .max(MAX_FOOD_QUERY_LENGTH),
});

export type SearchFoodRequest = z.infer<typeof searchFoodValidator>;
