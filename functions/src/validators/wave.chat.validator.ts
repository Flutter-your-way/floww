import {z} from "zod";
import {
  MAX_WAVE_HISTORY_LENGTH,
  MAX_WAVE_HISTORY_TURNS,
  MAX_WAVE_LIST_ITEMS,
  MAX_WAVE_LONG_LIST,
  MAX_WAVE_MESSAGE_LENGTH,
} from "../constants/ai.constants";

const label = (max = 60) => z.string().trim().max(max);

const shortList = z.array(label()).max(MAX_WAVE_LIST_ITEMS).default([]);

export const waveHistoryTurnValidator = z.object({
  role: z.enum(["user", "wave"]),
  text: z.string().trim().min(1).max(MAX_WAVE_HISTORY_LENGTH),
});

export const waveTodayValidator = z.object({
  flowScore: z.number().int().min(0).max(100).default(0),
  mode: label(20).default(""),
  streakDays: z.number().int().min(0).max(9999).default(0),
  workoutTitle: label(80).default(""),
  workoutDetail: label(80).default(""),
  planExercises: shortList,
  calories: z.number().int().min(0).default(0),
  calorieGoal: z.number().int().min(0).default(0),
  proteinG: z.number().int().min(0).default(0),
  proteinGoalG: z.number().int().min(0).default(0),
  carbsG: z.number().int().min(0).default(0),
  fatG: z.number().int().min(0).default(0),
  waterMl: z.number().int().min(0).default(0),
  waterGoalMl: z.number().int().min(0).default(0),
  recentFoods: shortList,
  loggedFoods: z.array(label(80)).max(MAX_WAVE_LONG_LIST).default([]),
  knownFoods: z.array(label(80)).max(MAX_WAVE_LONG_LIST).default([]),
  habitsDone: z.number().int().min(0).default(0),
  habitsTotal: z.number().int().min(0).default(0),
  habits: z.array(label(80)).max(MAX_WAVE_LONG_LIST).default([]),
  pendingHabits: shortList,
  workoutStatus: label(30).default(""),
  recoveryPercent: z.number().int().min(0).max(100).default(0),
  recoveryLabel: label(30).default(""),
  musclesReady: z.number().int().min(0).default(0),
  musclesRecovering: z.number().int().min(0).default(0),
  musclesFatigued: z.number().int().min(0).default(0),
  localTime: label(30).default(""),
});

export const waveChatValidator = z.object({
  message: z.string().trim().min(1).max(MAX_WAVE_MESSAGE_LENGTH),
  history: z.array(waveHistoryTurnValidator)
    .max(MAX_WAVE_HISTORY_TURNS)
    .default([]),
  today: waveTodayValidator.optional(),
});

export type WaveHistoryTurn = z.infer<typeof waveHistoryTurnValidator>;
export type WaveToday = z.infer<typeof waveTodayValidator>;
export type WaveChatRequest = z.infer<typeof waveChatValidator>;
