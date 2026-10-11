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
  "logSet",
  "swapExercise",
  "rescheduleWorkout",
  "skipToday",
  "shiftPlan",
  "adjustIntensity",
  "regeneratePlan",
  "logWeight",
  "logSleep",
  "setFlowMode",
  "setReminder",
  "updateTargets",
  "navigate",
]);

export const waveIntensitySchema = z.enum(["none", "lighter", "harder"]);

export const waveFlowModeSchema = z.enum([
  "none",
  "flow",
  "steady",
  "restore",
  "auto",
]);

export const waveScreenSchema = z.enum([
  "none",
  "home",
  "nutrition",
  "workout",
  "habits",
  "progress",
  "todaysWorkout",
  "activeWorkout",
  "dietPlan",
  "weeklyNutritionReport",
  "habitCalendar",
  "foodScan",
  "muscleRecovery",
  "achievements",
  "profile",
  "editPersonalInfo",
  "editDailyTargets",
  "connectedApps",
  "notificationSettings",
  "units",
  "privacyData",
  "waveMemory",
  "premium",
]);

export const waveReminderSchema = z.enum([
  "none",
  "master",
  "workout_reminder",
  "habit_reminder",
  "streak_alerts",
  "water_reminder",
  "sleep_reminder",
  "wave_insights",
  "weekly_summary",
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

export const waveTargetsSchema = z.object({
  waterLiters: z.number(),
  steps: z.number(),
  sleepHours: z.number(),
});

export const waveActionItemSchema = z.object({
  action: waveActionSchema,
  target: z.string(),
  replacement: z.string(),
  value: z.number(),
  weightKg: z.number(),
  servings: z.number(),
  meal: waveMealSchema,
  date: z.string(),
  intensity: waveIntensitySchema,
  mode: waveFlowModeSchema,
  reminder: waveReminderSchema,
  enabled: z.boolean(),
  screen: waveScreenSchema,
  targets: waveTargetsSchema,
  foodDraft: waveFoodDraftSchema,
  habitDraft: waveHabitDraftSchema,
});

export const waveMemoryCategorySchema = z.enum([
  "health",
  "training",
  "nutrition",
  "schedule",
  "preference",
  "life",
]);

export const waveMemoryNoteSchema = z.object({
  text: z.string(),
  category: waveMemoryCategorySchema,
  replaces: z.string(),
});

export const waveSummarySectionSchema = z.enum(["ongoing", "agreed", "open"]);

export const waveSummaryItemSchema = z.object({
  section: waveSummarySectionSchema,
  text: z.string(),
});

export const waveSummaryOutputSchema = z.object({
  items: z.array(waveSummaryItemSchema),
});

export const waveMemoryUpdateSchema = z.object({
  remember: z.array(waveMemoryNoteSchema),
  forget: z.array(z.string()),
});

export const waveAnswerSchema = z.object({
  reply: z.string(),
  card: waveCardSchema,
  injuryArea: waveMuscleSchema,
  actions: z.array(waveActionItemSchema),
  memory: waveMemoryUpdateSchema,
});

export const waveRouteSchema = z.enum(["light", "deep"]);

export const waveIntentSchema = z.enum(["chat", "log", "review", "planEdit"]);

export const wavePremiumFeatureSchema = z.enum([
  "memory",
  "proactiveCoaching",
  "planEdits",
  "weeklyReviews",
]);

export const waveRejectReasonSchema = z.enum([
  "notFound",
  "notAvailable",
  "premium",
]);

export const waveRejectedActionSchema = z.object({
  action: waveActionSchema,
  target: z.string(),
  reason: waveRejectReasonSchema,
});

export const waveQuotaSchema = z.object({
  used: z.number().int().min(0),
  limit: z.number().int().min(0),
  remaining: z.number().int().min(0),
  premium: z.boolean(),
});

export const waveReplySchema = waveAnswerSchema.omit({memory: true}).extend({
  memorySaved: z.array(z.string()),
  memoryForgotten: z.array(z.string()),
  rejected: z.array(waveRejectedActionSchema),
  locked: z.array(wavePremiumFeatureSchema),
  quota: waveQuotaSchema,
  route: waveRouteSchema,
  aiModel: z.string(),
  promptVersion: z.string(),
  createdAt: z.iso.datetime(),
});

export type WaveCard = z.infer<typeof waveCardSchema>;
export type WaveAction = z.infer<typeof waveActionSchema>;
export type WaveActionItem = z.infer<typeof waveActionItemSchema>;
export type WaveTargets = z.infer<typeof waveTargetsSchema>;
export type WaveMeal = z.infer<typeof waveMealSchema>;
export type WaveFoodDraft = z.infer<typeof waveFoodDraftSchema>;
export type WaveHabitDraft = z.infer<typeof waveHabitDraftSchema>;
export type WaveMuscle = z.infer<typeof waveMuscleSchema>;
export type WaveMemoryCategory = z.infer<typeof waveMemoryCategorySchema>;
export type WaveMemoryNote = z.infer<typeof waveMemoryNoteSchema>;
export type WaveMemoryUpdate = z.infer<typeof waveMemoryUpdateSchema>;
export type WaveSummarySection = z.infer<typeof waveSummarySectionSchema>;
export type WaveSummaryItem = z.infer<typeof waveSummaryItemSchema>;
export type WaveAnswer = z.infer<typeof waveAnswerSchema>;
export type WaveReply = z.infer<typeof waveReplySchema>;
export type WaveRoute = z.infer<typeof waveRouteSchema>;
export type WaveIntent = z.infer<typeof waveIntentSchema>;
export type WavePremiumFeature = z.infer<typeof wavePremiumFeatureSchema>;
export type WaveRejectedAction = z.infer<typeof waveRejectedActionSchema>;
export type WaveQuota = z.infer<typeof waveQuotaSchema>;
