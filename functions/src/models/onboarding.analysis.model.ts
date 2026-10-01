import {z} from "zod";

export const onboardingInsightSchema = z.object({
  title: z.string(),
  body: z.string(),
});

export const proposedBlueprintSchema = z.object({
  flowScore: z.number(),
  flowScoreReason: z.string(),
  workoutSplit: z.string(),
  calories: z.number(),
  proteinG: z.number(),
  waterMl: z.number(),
  sleepHours: z.number(),
});

export const onboardingAnalysisOutputSchema = z.object({
  headline: z.string(),
  summary: z.string(),
  insights: z.array(onboardingInsightSchema),
  blueprint: proposedBlueprintSchema,
});

export const onboardingAnalysisSchema = onboardingAnalysisOutputSchema.omit({
  blueprint: true,
});

export type OnboardingInsight = z.infer<typeof onboardingInsightSchema>;
export type OnboardingAnalysis = z.infer<typeof onboardingAnalysisSchema>;
export type OnboardingAnalysisOutput =
  z.infer<typeof onboardingAnalysisOutputSchema>;
