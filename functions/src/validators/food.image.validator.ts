import {z} from "zod";
import {
  MAX_FOOD_IMAGE_NAME_LENGTH,
  MIN_FOOD_IMAGE_NAME_LENGTH,
} from "../constants/food.image.constants";

export const foodImageValidator = z.object({
  name: z.string().trim()
    .min(MIN_FOOD_IMAGE_NAME_LENGTH)
    .max(MAX_FOOD_IMAGE_NAME_LENGTH),
});

export type FoodImageRequest = z.infer<typeof foodImageValidator>;
