import {z} from "zod";
import {
  MAX_FOOD_DESCRIPTION_LENGTH,
  MIN_FOOD_DESCRIPTION_LENGTH,
} from "../constants/ai.constants";

export const describeFoodValidator = z.object({
  text: z.string().trim()
    .min(MIN_FOOD_DESCRIPTION_LENGTH)
    .max(MAX_FOOD_DESCRIPTION_LENGTH),
});

export type DescribeFoodRequest = z.infer<typeof describeFoodValidator>;
