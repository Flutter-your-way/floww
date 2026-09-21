import {z} from "zod";
import {
  FOOD_SCAN_MIME_TYPES,
  MAX_FOOD_NOTE_LENGTH,
  MAX_IMAGE_BASE64_LENGTH,
} from "../constants/ai.constants";

export const scanFoodValidator = z.object({
  image: z.base64().min(1).max(MAX_IMAGE_BASE64_LENGTH),
  mimeType: z.enum(FOOD_SCAN_MIME_TYPES),
  note: z.string().trim().max(MAX_FOOD_NOTE_LENGTH).optional(),
});

export type ScanFoodRequest = z.infer<typeof scanFoodValidator>;
