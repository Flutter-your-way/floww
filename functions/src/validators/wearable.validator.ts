import {z} from "zod";
import {WEARABLE_PROVIDERS} from "../models/wearable.model";

export const wearableProviderValidator = z.object({
  provider: z.enum(WEARABLE_PROVIDERS),
});
