import {z} from "zod";

const MAX_EXERCISES = 100;
const MAX_HEART_RATE_SAMPLES = 50;
const MAX_DURATION_SECONDS = 24 * 60 * 60;
const MAX_ID_LENGTH = 128;

const sessionId = z.string().trim().min(1).max(MAX_ID_LENGTH);

export const completeWorkoutValidator = z.object({
  sessionId,
  durationSeconds: z.number().int().min(0).max(MAX_DURATION_SECONDS),
  exercises: z.array(z.record(z.string(), z.unknown())).max(MAX_EXERCISES),
  heartRate: z.object({
    average: z.number().int().positive().optional(),
    peak: z.number().int().positive().optional(),
    samples: z.array(z.number().int().min(0)).max(MAX_HEART_RATE_SAMPLES),
  }).optional(),
});

export const unlogWorkoutValidator = z.object({sessionId});
