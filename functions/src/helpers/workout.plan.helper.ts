import {zodTextFormat} from "openai/helpers/zod";
import {clamp} from "../common/utils";
import {
  WORKOUT_PLAN_LENGTH_DAYS,
  WORKOUT_PLAN_MODEL,
  WORKOUT_PLAN_NAME,
  WORKOUT_PLAN_PROGRAM_ID,
  WORKOUT_PLAN_REASONING_EFFORT,
} from "../constants/ai.constants";
import {
  GeneratedProgram,
  PlannedDay,
  PlannedExercise,
  ProgramGoalId,
  WORKOUT_SECTIONS,
  WorkoutPlanOutput,
  workoutPlanOutputSchemaOf,
} from "../models/workout.plan.model";
import {
  WORKOUT_PLAN_INSTRUCTIONS,
  buildWorkoutPlanUserText,
} from "../prompts/workout.plan.prompt";
import {getOpenAI} from "./openai.helper";
import {AiTokenUsage} from "./usage.helper";
import {CatalogExercise, PlanProfile} from "./workout.plan.profile.helper";
import {
  standardDaysOf,
  standardDescriptionOf,
} from "./workout.plan.template.helper";

export interface AiPlanResult {
  output: WorkoutPlanOutput;
  usage: AiTokenUsage;
}

const DAYS_PER_WEEK = 7;
const MIN_MAIN_EXERCISES = 2;
const MAX_DAY_EXERCISES = 10;
const MAX_DESCRIPTION_LENGTH = 180;
const MAX_DAY_NAME_LENGTH = 32;
const MAX_FOCUS_LENGTH = 24;
const MAX_DAY_GOAL_LENGTH = 90;
const MIN_SETS = 1;
const MAX_SETS = 5;
const MIN_REPS = 3;
const MAX_REPS = 25;
const MIN_SECONDS = 15;
const MAX_SECONDS = 300;
const MIN_REST = 30;
const MAX_REST = 240;
const MIN_RESERVE = 0;
const MAX_RESERVE = 4;
const MIN_MINUTES = 15;
const MAX_MINUTES = 120;

const SECTION_ORDER = new Map<string, number>(
  WORKOUT_SECTIONS.map((section, index) => [section, index]),
);

export const generateAiPlan = async (
  profile: PlanProfile,
  allowed: CatalogExercise[],
  draft: PlannedDay[],
): Promise<AiPlanResult> => {
  const ids = allowed.map((exercise) => exercise.id) as [string, ...string[]];
  const response = await getOpenAI().responses.parse({
    model: WORKOUT_PLAN_MODEL,
    reasoning: {effort: WORKOUT_PLAN_REASONING_EFFORT},
    instructions: WORKOUT_PLAN_INSTRUCTIONS,
    input: [
      {
        role: "user",
        content: [
          {
            type: "input_text",
            text: buildWorkoutPlanUserText(profile, allowed, draft),
          },
        ],
      },
    ],
    text: {
      format: zodTextFormat(workoutPlanOutputSchemaOf(ids), "workout_plan"),
    },
  });

  const output = response.output_parsed;
  if (!output || output.days.length === 0) {
    throw new Error("Workout plan response was empty.");
  }
  return {
    output,
    usage: {
      inputTokens: response.usage?.input_tokens ?? 0,
      outputTokens: response.usage?.output_tokens ?? 0,
    },
  };
};

const shortText = (value: string, limit: number): string | null => {
  const text = value.trim().replace(/\s+/g, " ");
  return text && text.length <= limit ? text : null;
};

const sanitizedExercise = (
  exercise: PlannedExercise,
  catalog: Map<string, CatalogExercise>,
): PlannedExercise | null => {
  const entry = catalog.get(exercise.exerciseId);
  if (!entry) return null;
  return {
    exerciseId: entry.id,
    section: exercise.section,
    sets: Math.round(clamp(exercise.sets, MIN_SETS, MAX_SETS)),
    reps: Math.round(entry.isTimed ?
      clamp(exercise.reps, MIN_SECONDS, MAX_SECONDS) :
      clamp(exercise.reps, MIN_REPS, MAX_REPS)),
    restSeconds: Math.round(clamp(exercise.restSeconds, MIN_REST, MAX_REST)),
    repsInReserve: Math.round(
      clamp(exercise.repsInReserve, MIN_RESERVE, MAX_RESERVE),
    ),
  };
};

const sanitizedDay = (
  day: WorkoutPlanOutput["days"][number],
  fallback: PlannedDay,
  catalog: Map<string, CatalogExercise>,
): PlannedDay => {
  const seen = new Set<string>();
  const exercises = day.exercises
    .map((exercise) => sanitizedExercise(exercise, catalog))
    .filter((exercise): exercise is PlannedExercise => {
      if (!exercise || seen.has(exercise.exerciseId)) return false;
      seen.add(exercise.exerciseId);
      return true;
    })
    .sort((a, b) =>
      (SECTION_ORDER.get(a.section) ?? 0) -
      (SECTION_ORDER.get(b.section) ?? 0))
    .slice(0, MAX_DAY_EXERCISES);
  const mainCount = exercises
    .filter((exercise) => exercise.section === "main-exercises").length;
  if (mainCount < MIN_MAIN_EXERCISES) return fallback;

  return {
    weekday: fallback.weekday,
    name: shortText(day.name, MAX_DAY_NAME_LENGTH) ?? fallback.name,
    focus: shortText(day.focus, MAX_FOCUS_LENGTH) ?? fallback.focus,
    goal: shortText(day.goal, MAX_DAY_GOAL_LENGTH) ?? fallback.goal,
    durationMinutes: Math.round(
      clamp(day.durationMinutes, MIN_MINUTES, MAX_MINUTES),
    ),
    exercises,
  };
};

const weeksOf = (lengthDays: number): number =>
  Math.ceil(lengthDays / DAYS_PER_WEEK);

const programOf = (
  profile: PlanProfile,
  days: PlannedDay[],
  source: GeneratedProgram["source"],
  description: string,
  goal: ProgramGoalId,
): GeneratedProgram => ({
  id: WORKOUT_PLAN_PROGRAM_ID,
  name: WORKOUT_PLAN_NAME,
  description,
  level: profile.level,
  weeks: weeksOf(WORKOUT_PLAN_LENGTH_DAYS),
  lengthDays: WORKOUT_PLAN_LENGTH_DAYS,
  deloadEvery: 0,
  goal,
  isCustom: true,
  isGenerated: true,
  source,
  generatedAt: new Date().toISOString(),
  days,
});

export const standardProgramOf = (
  profile: PlanProfile,
  draft: PlannedDay[],
): GeneratedProgram => programOf(
  profile,
  draft,
  "standard",
  standardDescriptionOf(profile),
  profile.goal,
);

export const aiProgramOf = (
  profile: PlanProfile,
  draft: PlannedDay[],
  output: WorkoutPlanOutput,
  allowed: CatalogExercise[],
): GeneratedProgram => {
  const catalog = new Map(allowed.map((exercise) => [exercise.id, exercise]));
  const days = draft.map((fallback, index) => {
    const day = output.days[index];
    return day ? sanitizedDay(day, fallback, catalog) : fallback;
  });
  return programOf(
    profile,
    days,
    "ai",
    shortText(output.description, MAX_DESCRIPTION_LENGTH) ??
      standardDescriptionOf(profile),
    output.goal,
  );
};

export const draftOf = (
  profile: PlanProfile,
  allowed: CatalogExercise[],
): PlannedDay[] => standardDaysOf(profile, allowed);

export const hasUsableDraft = (draft: PlannedDay[]): boolean =>
  draft.length > 0 &&
  draft.every((day) =>
    day.exercises.some((exercise) => exercise.section === "main-exercises"));
