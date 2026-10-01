import {DocumentData} from "firebase-admin/firestore";
import {clamp, hashKey, listOf, numberOf, recordOf} from "../common/utils";
import {
  CALORIE_FACTOR_RANGE,
  NutritionTargets,
  PROTEIN_PER_KG_RANGE,
  baselineProteinPerKgOf,
  referenceWeightKgOf,
} from "./nutrition.goal.helper";

export interface OnboardingBlueprint {
  flowScore: number;
  flowScoreReason: string;
  workoutSplit: string;
  sleepHours: number;
  calorieFactor: number;
  proteinPerKg: number;
  waterMl: number;
}

export interface ProposedBlueprint {
  flowScore: number;
  flowScoreReason: string;
  workoutSplit: string;
  calories: number;
  proteinG: number;
  waterMl: number;
  sleepHours: number;
}

interface Range {
  min: number;
  max: number;
}

export interface BlueprintRanges {
  flowScore: Range;
  calories: Range;
  proteinG: Range;
  waterMl: Range;
  sleepHours: Range;
  lockedSplit: string | null;
}

const MIN_FLOW_SCORE = 15;
const MAX_FLOW_SCORE = 96;
const NEUTRAL = 0.6;

const RECOVERY_WEIGHT = 0.35;
const SLEEP_WEIGHT = 0.15;
const TRAINING_BASE_WEIGHT = 0.2;
const CONSISTENCY_WEIGHT = 0.15;
const HEALTH_WEIGHT = 0.15;

const IDEAL_SLEEP_HOURS = 8;
const MIN_HEALTHY_SLEEP_HOURS = 7;
const MAX_HEALTHY_SLEEP_HOURS = 9;
const SLEEP_PENALTY_PER_HOUR = 0.18;
const DEFAULT_SLEEP_HOURS = 8;
const MINUTES_PER_DAY = 24 * 60;
const MINUTES_PER_HOUR = 60;

const COMMITTED_TRAINING_DAYS = 4;
const MISS_REASON_PENALTY = 0.12;
const MIN_CONSISTENCY = 0.35;
const CONDITION_PENALTY = 0.15;
const INJURY_PENALTY = 0.12;
const MIN_HEALTH = 0.4;

const SLEEP_QUALITY: Record<string, number> = {
  "Poor": 0.2,
  "Fair": 0.5,
  "Good": 0.8,
  "Excellent": 1,
};

const RECOVERY_SPEED: Record<string, number> = {
  "Very Slow": 0.2,
  "Slow": 0.4,
  "Average": 0.65,
  "Fast": 0.85,
  "Very Fast": 1,
};

const STRESS: Record<string, number> = {
  "Very Low": 1,
  "Low": 0.85,
  "Moderate": 0.6,
  "High": 0.35,
  "Very High": 0.15,
};

const MORNING_ENERGY: Record<string, number> = {
  "Very Low": 0.2,
  "Low": 0.4,
  "Average": 0.65,
  "High": 0.85,
  "Very High": 1,
};

const ACTIVITY: Record<string, number> = {
  "Sedentary": 0.3,
  "Lightly Active": 0.55,
  "Active": 0.8,
  "Very Active": 1,
};

const EXPERIENCE: Record<string, number> = {
  Beginner: 0.5,
  Intermediate: 0.75,
  Advanced: 1,
};

const BAD_DAY_BEHAVIOUR: Record<string, number> = {
  "Reduce Intensity": 1,
  "Push Through": 0.7,
  "Skip Workout": 0.4,
};

const TRAINING_SECTIONS: Record<string, string> = {
  Gym: "gymDetails",
  Calisthenics: "calisthenicsDetails",
  Yoga: "yogaDetails",
};

const RECOMMENDED_SPLIT = "Recommended";
const DEFAULT_SPLIT = "Full Body";

const FLOW_SCORE_SWING = 15;
const WATER_RANGE = {min: 0.8, max: 1.3};
const MIN_WATER_ML = 1500;
const MAX_WATER_ML = 5000;
const WATER_STEP_ML = 100;
const SLEEP_RANGE = {min: 7, max: 9.5};
const SLEEP_STEP = 0.5;
const MAX_REASON_LENGTH = 180;
const MAX_SPLIT_LENGTH = 24;
const ML_PER_LITER = 1000;
const WATER_ML_PER_KG = 35;
const DEFAULT_WATER_ML = 2500;
const HASH_OMITTED_KEYS = [
  "uid",
  "startedAt",
  "completedAt",
  "updatedAt",
  "blueprint",
];

const FACTOR_LABELS = {
  recovery: "recovery",
  sleep: "sleep",
  trainingBase: "training base",
  consistency: "consistency",
  wellbeing: "overall health",
} as const;

type FactorKey = keyof typeof FACTOR_LABELS;

const textOf = (value: unknown): string =>
  typeof value === "string" ? value.trim() : "";

const scoreOf = (table: Record<string, number>, value: unknown): number =>
  table[textOf(value)] ?? NEUTRAL;

const average = (values: number[]): number =>
  values.reduce((sum, value) => sum + value, 0) / values.length;

const realItems = (value: unknown): string[] =>
  listOf(value)
    .map(textOf)
    .filter((item) => item && item !== "None");

const minutesOf = (value: unknown): number | null => {
  const match = /^(\d{1,2}):(\d{2})$/.exec(textOf(value));
  if (!match) return null;
  return Number(match[1]) * MINUTES_PER_HOUR + Number(match[2]);
};

const sleptHoursOf = (goals: Record<string, unknown>): number | null => {
  const sleep = minutesOf(goals.sleepTime);
  const wake = minutesOf(goals.wakeTime);
  if (sleep === null || wake === null) return null;
  const minutes =
    ((wake - sleep) % MINUTES_PER_DAY + MINUTES_PER_DAY) % MINUTES_PER_DAY;
  return minutes / MINUTES_PER_HOUR;
};

const sleepDurationScore = (hours: number | null): number => {
  if (hours === null) return NEUTRAL;
  if (hours >= MIN_HEALTHY_SLEEP_HOURS && hours <= MAX_HEALTHY_SLEEP_HOURS) {
    return 1 - Math.abs(hours - IDEAL_SLEEP_HOURS) * 0.05;
  }
  const gap = hours < MIN_HEALTHY_SLEEP_HOURS ?
    MIN_HEALTHY_SLEEP_HOURS - hours :
    hours - MAX_HEALTHY_SLEEP_HOURS;
  return clamp(0.9 - gap * SLEEP_PENALTY_PER_HOUR, 0, 1);
};

const trainingSectionOf = (details: DocumentData): Record<string, unknown> => {
  const type = textOf(recordOf(details.trainingSetup).trainingType);
  return recordOf(details[TRAINING_SECTIONS[type] ?? ""]);
};

const trainingDaysOf = (section: Record<string, unknown>): number =>
  listOf(section.trainingDays ?? section.practiceDays).length;

const factorsOf = (details: DocumentData): Record<FactorKey, number> => {
  const goals = recordOf(details.goalsActivity);
  const health = recordOf(details.healthDiet);
  const setup = recordOf(details.trainingSetup);
  const floState = recordOf(details.floState);
  const section = trainingSectionOf(details);
  const days = trainingDaysOf(section);
  const missReasons = realItems(floState.missWorkoutReasons).length;
  const conditions = realItems(health.healthConditions).length;
  const injuries = realItems(section.injuries).length;

  return {
    recovery: average([
      scoreOf(SLEEP_QUALITY, floState.sleepQuality),
      scoreOf(RECOVERY_SPEED, floState.recoverySpeed),
      scoreOf(STRESS, floState.stressLevel),
      scoreOf(MORNING_ENERGY, floState.morningEnergy),
    ]),
    sleep: sleepDurationScore(sleptHoursOf(goals)),
    trainingBase: average([
      scoreOf(ACTIVITY, goals.activityLevel),
      scoreOf(EXPERIENCE, setup.experienceLevel ?? section.experienceLevel),
      days > 0 ? clamp(days / COMMITTED_TRAINING_DAYS, 0, 1) : NEUTRAL,
    ]),
    consistency: average([
      scoreOf(BAD_DAY_BEHAVIOUR, floState.badDayBehaviour),
      Math.max(MIN_CONSISTENCY, 1 - missReasons * MISS_REASON_PENALTY),
    ]),
    wellbeing: Math.max(
      MIN_HEALTH,
      1 - conditions * CONDITION_PENALTY - injuries * INJURY_PENALTY,
    ),
  };
};

const FACTOR_WEIGHTS: Record<FactorKey, number> = {
  recovery: RECOVERY_WEIGHT,
  sleep: SLEEP_WEIGHT,
  trainingBase: TRAINING_BASE_WEIGHT,
  consistency: CONSISTENCY_WEIGHT,
  wellbeing: HEALTH_WEIGHT,
};

const flowScoreOf = (factors: Record<FactorKey, number>): number => {
  const weighted = (Object.keys(factors) as FactorKey[]).reduce(
    (sum, key) => sum + factors[key] * FACTOR_WEIGHTS[key],
    0,
  );
  return Math.round(clamp(weighted * 100, MIN_FLOW_SCORE, MAX_FLOW_SCORE));
};

const flowScoreReasonOf = (factors: Record<FactorKey, number>): string => {
  const ranked = (Object.keys(factors) as FactorKey[])
    .sort((a, b) => factors[b] - factors[a]);
  const best = FACTOR_LABELS[ranked[0]];
  const weakest = FACTOR_LABELS[ranked[ranked.length - 1]];
  return `Your ${best} is your strongest area. ` +
    `WAVE will start by building up your ${weakest}.`;
};

const splitForDays = (days: number): string => {
  if (days >= 5) return "Push Pull Legs";
  if (days === 4) return "Upper Lower";
  return DEFAULT_SPLIT;
};

const lockedSplitOf = (details: DocumentData): string | null => {
  const type = textOf(recordOf(details.trainingSetup).trainingType);
  if (type !== "Gym") return null;
  const preferred = textOf(trainingSectionOf(details).preferredSplit);
  return preferred && preferred !== RECOMMENDED_SPLIT ? preferred : null;
};

const workoutSplitOf = (details: DocumentData): string => {
  const type = textOf(recordOf(details.trainingSetup).trainingType);
  const section = trainingSectionOf(details);
  const days = trainingDaysOf(section);

  if (type === "Yoga") {
    const style = textOf(section.preferredStyle);
    return style ? `${style} Flow` : "Yoga Flow";
  }
  if (type === "Calisthenics") {
    return days >= 4 ? "Upper Lower" : DEFAULT_SPLIT;
  }
  return lockedSplitOf(details) ?? splitForDays(days);
};

const roundTo = (value: number, step: number): number =>
  Math.round(value / step) * step;

const sleepHoursOf = (details: DocumentData): number => {
  const target = numberOf(
    recordOf(details.targetsPermissions).sleepTargetHours,
    NaN,
  );
  const hours = Number.isFinite(target) && target > 0 ?
    target :
    DEFAULT_SLEEP_HOURS;
  return clamp(roundTo(hours, SLEEP_STEP), SLEEP_RANGE.min, SLEEP_RANGE.max);
};

const waterMlOf = (details: DocumentData): number => {
  const liters = numberOf(
    recordOf(details.targetsPermissions).waterTargetLiters,
    NaN,
  );
  if (Number.isFinite(liters) && liters > 0) {
    return Math.round(liters * ML_PER_LITER);
  }
  const weightKg = referenceWeightKgOf(details);
  return weightKg === null ?
    DEFAULT_WATER_ML :
    roundTo(weightKg * WATER_ML_PER_KG, WATER_STEP_ML);
};

export const baselineBlueprintOf = (
  details: DocumentData,
): OnboardingBlueprint => {
  const factors = factorsOf(details);
  return {
    flowScore: flowScoreOf(factors),
    flowScoreReason: flowScoreReasonOf(factors),
    workoutSplit: workoutSplitOf(details),
    sleepHours: sleepHoursOf(details),
    calorieFactor: 1,
    proteinPerKg: baselineProteinPerKgOf(details),
    waterMl: waterMlOf(details),
  };
};

export const blueprintRangesOf = (
  details: DocumentData,
  baseline: OnboardingBlueprint,
  targets: NutritionTargets,
): BlueprintRanges => {
  const referenceKg = referenceWeightKgOf(details);
  return {
    flowScore: {
      min: Math.max(MIN_FLOW_SCORE, baseline.flowScore - FLOW_SCORE_SWING),
      max: Math.min(MAX_FLOW_SCORE, baseline.flowScore + FLOW_SCORE_SWING),
    },
    calories: {
      min: Math.round(targets.calories * CALORIE_FACTOR_RANGE.min),
      max: Math.round(targets.calories * CALORIE_FACTOR_RANGE.max),
    },
    proteinG: referenceKg === null ?
      {min: targets.proteinG, max: targets.proteinG} :
      {
        min: Math.round(referenceKg * PROTEIN_PER_KG_RANGE.min),
        max: Math.round(referenceKg * PROTEIN_PER_KG_RANGE.max),
      },
    waterMl: {
      min: Math.max(
        MIN_WATER_ML,
        roundTo(baseline.waterMl * WATER_RANGE.min, WATER_STEP_ML),
      ),
      max: Math.min(
        MAX_WATER_ML,
        roundTo(baseline.waterMl * WATER_RANGE.max, WATER_STEP_ML),
      ),
    },
    sleepHours: SLEEP_RANGE,
    lockedSplit: lockedSplitOf(details),
  };
};

const within = (value: number, range: Range): number =>
  clamp(Number.isFinite(value) ? value : range.min, range.min, range.max);

const shortText = (value: string, limit: number): string | null => {
  const text = value.trim().replace(/\s+/g, " ");
  return text && text.length <= limit ? text : null;
};

export const resolveBlueprint = (
  details: DocumentData,
  baseline: OnboardingBlueprint,
  targets: NutritionTargets,
  proposed: ProposedBlueprint | null,
): OnboardingBlueprint => {
  if (!proposed) return baseline;
  const ranges = blueprintRangesOf(details, baseline, targets);
  const referenceKg = referenceWeightKgOf(details);
  const calories = within(proposed.calories, ranges.calories);
  const proteinG = within(proposed.proteinG, ranges.proteinG);

  return {
    flowScore: Math.round(within(proposed.flowScore, ranges.flowScore)),
    flowScoreReason:
      shortText(proposed.flowScoreReason, MAX_REASON_LENGTH) ??
      baseline.flowScoreReason,
    workoutSplit: ranges.lockedSplit ??
      shortText(proposed.workoutSplit, MAX_SPLIT_LENGTH) ??
      baseline.workoutSplit,
    sleepHours: roundTo(
      within(proposed.sleepHours, ranges.sleepHours),
      SLEEP_STEP,
    ),
    calorieFactor: targets.calories > 0 ?
      calories / targets.calories :
      baseline.calorieFactor,
    proteinPerKg: referenceKg === null ?
      baseline.proteinPerKg :
      proteinG / referenceKg,
    waterMl: roundTo(within(proposed.waterMl, ranges.waterMl), WATER_STEP_ML),
  };
};

export const detailsWithBlueprint = (
  details: DocumentData,
  blueprint: OnboardingBlueprint,
): DocumentData => ({
  ...details,
  blueprint,
  targetsPermissions: {
    ...recordOf(details.targetsPermissions),
    waterTargetLiters: blueprint.waterMl / ML_PER_LITER,
    sleepTargetHours: blueprint.sleepHours,
  },
});

const stableJson = (value: unknown): string => {
  if (Array.isArray(value)) return `[${value.map(stableJson).join(",")}]`;
  if (value !== null && typeof value === "object") {
    const entries = Object.entries(value as Record<string, unknown>)
      .filter(([, item]) => item !== undefined)
      .sort(([a], [b]) => a.localeCompare(b));
    return `{${entries
      .map(([key, item]) => `${JSON.stringify(key)}:${stableJson(item)}`)
      .join(",")}}`;
  }
  return JSON.stringify(value);
};

export const answersHashOf = (details: DocumentData): string =>
  hashKey(stableJson(Object.fromEntries(
    Object.entries(details)
      .filter(([key]) => !HASH_OMITTED_KEYS.includes(key)),
  )));
