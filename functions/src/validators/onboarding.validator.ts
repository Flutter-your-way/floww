import {z} from "zod";

export const submitOnboardingValidator = z.object({
  details: z.record(z.string(), z.unknown()),
});

export const completeOnboardingValidator = z.object({
  wearablesConnected: z.boolean(),
});
