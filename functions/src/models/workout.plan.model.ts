import {z} from "zod";

export const WORKOUT_SECTIONS = [
  "warm-up",
  "main-exercises",
  "cool-down",
] as const;

export const PROGRAM_GOALS = [
  "strength",
  "muscle",
  "fat-loss",
  "cardio",
  "home",
  "mobility",
] as const;

export type WorkoutSection = typeof WORKOUT_SECTIONS[number];
export type ProgramGoalId = typeof PROGRAM_GOALS[number];

export const workoutPlanOutputSchemaOf = (
  exerciseIds: [string, ...string[]],
) => z.object({
  description: z.string(),
  goal: z.enum(PROGRAM_GOALS),
  days: z.array(z.object({
    name: z.string(),
    focus: z.string(),
    goal: z.string(),
    durationMinutes: z.number(),
    exercises: z.array(z.object({
      exerciseId: z.enum(exerciseIds),
      section: z.enum(WORKOUT_SECTIONS),
      sets: z.number(),
      reps: z.number(),
      restSeconds: z.number(),
      repsInReserve: z.number(),
    })),
  })),
});

export type WorkoutPlanOutput =
  z.infer<ReturnType<typeof workoutPlanOutputSchemaOf>>;

export interface PlannedExercise {
  exerciseId: string;
  section: WorkoutSection;
  sets: number;
  reps: number;
  restSeconds: number;
  repsInReserve: number;
}

export interface PlannedDay {
  weekday: number;
  name: string;
  focus: string;
  goal: string;
  durationMinutes: number;
  exercises: PlannedExercise[];
}

export interface GeneratedProgram {
  id: string;
  name: string;
  description: string;
  level: string;
  weeks: number;
  lengthDays: number;
  deloadEvery: number;
  goal: ProgramGoalId;
  isCustom: boolean;
  isGenerated: boolean;
  source: "ai" | "standard";
  generatedAt: string;
  days: PlannedDay[];
}
