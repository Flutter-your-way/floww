import {z} from "zod";

export const WAVE_MUSCLE_GROUPS = [
  "chest",
  "back",
  "shoulders",
  "biceps",
  "triceps",
  "quadriceps",
  "glutes",
  "hamstrings",
  "calves",
  "abdominals",
  "adductors",
  "traps",
  "none",
] as const;

export const waveCardSchema = z.enum([
  "none",
  "plan",
  "mealLog",
  "dietPlan",
  "scoreReport",
  "checkIn",
  "injurySwap",
]);

export const waveMuscleSchema = z.enum(WAVE_MUSCLE_GROUPS);

export const waveActionSchema = z.enum([
  "none",
  "completeAllHabits",
  "completeHabit",
  "uncompleteHabit",
  "addHabit",
  "editHabit",
  "deleteHabit",
  "logWater",
  "unlogWater",
  "logFood",
  "unlogFood",
  "createFood",
  "startWorkout",
  "completeWorkout",
  "cancelWorkout",
]);

export const waveMetricSchema = z.enum([
  "minutes",
  "hours",
  "steps",
  "liters",
  "sessions",
]);

export const waveMealSchema = z.enum([
  "auto",
  "breakfast",
  "lunch",
  "dinner",
  "snacks",
]);

export const waveFoodDraftSchema = z.object({
  name: z.string(),
  serving: z.string(),
  weightG: z.number(),
  calories: z.number(),
  proteinG: z.number(),
  carbsG: z.number(),
  fatG: z.number(),
  fiberG: z.number(),
  sugarG: z.number(),
  sodiumMg: z.number(),
  waterMl: z.number(),
});

export const waveHabitDraftSchema = z.object({
  title: z.string(),
  target: z.number(),
  metric: waveMetricSchema,
});

export const waveAnswerSchema = z.object({
  reply: z.string(),
  card: waveCardSchema,
  injuryArea: waveMuscleSchema,
  action: waveActionSchema,
  actionTarget: z.string(),
  actionAmountMl: z.number(),
  servings: z.number(),
  meal: waveMealSchema,
  foodDraft: waveFoodDraftSchema,
  habitDraft: waveHabitDraftSchema,
});

export const waveReplySchema = waveAnswerSchema.extend({
  aiModel: z.string(),
  promptVersion: z.string(),
  createdAt: z.iso.datetime(),
});

export type WaveCard = z.infer<typeof waveCardSchema>;
export type WaveAction = z.infer<typeof waveActionSchema>;
export type WaveMeal = z.infer<typeof waveMealSchema>;
export type WaveFoodDraft = z.infer<typeof waveFoodDraftSchema>;
export type WaveHabitDraft = z.infer<typeof waveHabitDraftSchema>;
export type WaveMuscle = z.infer<typeof waveMuscleSchema>;
export type WaveAnswer = z.infer<typeof waveAnswerSchema>;
export type WaveReply = z.infer<typeof waveReplySchema>;
