import {DocumentData} from "firebase-admin/firestore";
import {clamp, listOf, numberOf, recordOf} from "../common/utils";
import {ProgramGoalId} from "../models/workout.plan.model";

export type TrainingType = "Gym" | "Calisthenics" | "Yoga";

export type SplitKind =
  | "Full Body"
  | "Upper Lower"
  | "Push Pull Legs"
  | "Bro Split"
  | "Yoga Flow";

export type EquipmentKind =
  | "barbell"
  | "dumbbell"
  | "machine"
  | "cable"
  | "bodyweight"
  | "kettlebell"
  | "band";

export interface CatalogExercise {
  id: string;
  name: string;
  group: string;
  equipment: EquipmentKind;
  isTimed: boolean;
  defaultSets: number;
  defaultReps: number;
  defaultRestSeconds: number;
  defaultRepsInReserve: number;
  isCustom: boolean;
}

export interface PlanProfile {
  firstName: string;
  trainingType: TrainingType;
  level: "Beginner" | "Intermediate" | "Advanced";
  weekdays: number[];
  sessionMinutes: number;
  goal: ProgramGoalId;
  goalLabel: string;
  primaryGoal: string;
  split: SplitKind;
  equipment: EquipmentKind[];
  equipmentLabel: string;
  focusMuscles: string[];
  injuries: string[];
  healthConditions: string[];
  wantsMeditation: boolean;
  yogaStyle: string;
  maxPushups: number;
  maxPullups: number;
  maxDips: number;
  pushIntensity: string;
  recoverySpeed: string;
}

const WEEKDAYS: Record<string, number> = {
  Monday: 1,
  Tuesday: 2,
  Wednesday: 3,
  Thursday: 4,
  Friday: 5,
  Saturday: 6,
  Sunday: 7,
};

const DEFAULT_WEEKDAYS: Record<PlanProfile["level"], number[]> = {
  Beginner: [1, 3, 5],
  Intermediate: [1, 2, 4, 5],
  Advanced: [1, 2, 4, 5, 6],
};

const MIN_DAYS = 2;
const MAX_DAYS = 6;
const DEFAULT_MINUTES = 45;
const MIN_MINUTES = 15;
const MAX_MINUTES = 120;

const ALL_EQUIPMENT: EquipmentKind[] = [
  "barbell",
  "dumbbell",
  "machine",
  "cable",
  "bodyweight",
  "kettlebell",
  "band",
];

const GYM_EQUIPMENT: Record<string, EquipmentKind[]> = {
  "Full Gym": ALL_EQUIPMENT,
  "Basic Gym": ["barbell", "dumbbell", "cable", "bodyweight", "kettlebell",
    "band"],
  "Home Gym": ["dumbbell", "kettlebell", "band", "bodyweight"],
};

const SPLITS: SplitKind[] = [
  "Full Body",
  "Upper Lower",
  "Push Pull Legs",
  "Bro Split",
];

const GYM_GOALS: Record<string, ProgramGoalId> = {
  "Strength": "strength",
  "Muscle Growth": "muscle",
  "Fat Loss": "fat-loss",
  "Endurance": "cardio",
};

const PRIMARY_GOALS: Record<string, ProgramGoalId> = {
  "Lose Fat": "fat-loss",
  "Gain Muscle": "muscle",
  "Recomposition": "muscle",
  "Lifestyle": "strength",
  "Maintain": "strength",
};

export const GOAL_LABELS: Record<ProgramGoalId, string> = {
  "strength": "Strength",
  "muscle": "Muscle",
  "fat-loss": "Fat Loss",
  "cardio": "Endurance",
  "home": "Bodyweight",
  "mobility": "Mobility",
};

const textOf = (value: unknown): string =>
  typeof value === "string" ? value.trim() : "";

const realItems = (value: unknown): string[] =>
  listOf(value)
    .map(textOf)
    .filter((item) => item && item !== "None");

const SECTION_KEYS: Record<TrainingType, string> = {
  Gym: "gymDetails",
  Calisthenics: "calisthenicsDetails",
  Yoga: "yogaDetails",
};

const trainingTypeOf = (details: DocumentData): TrainingType => {
  const type = textOf(recordOf(details.trainingSetup).trainingType);
  return type === "Calisthenics" || type === "Yoga" ? type : "Gym";
};

const levelOf = (value: string): PlanProfile["level"] =>
  value === "Advanced" || value === "Intermediate" ? value : "Beginner";

const weekdaysOf = (
  section: Record<string, unknown>,
  level: PlanProfile["level"],
): number[] => {
  const chosen = [
    ...new Set(
      listOf(section.trainingDays ?? section.practiceDays)
        .map((day) => WEEKDAYS[textOf(day)])
        .filter((day): day is number => day !== undefined),
    ),
  ].sort((a, b) => a - b);
  if (chosen.length < MIN_DAYS) return DEFAULT_WEEKDAYS[level];
  return chosen.slice(0, MAX_DAYS);
};

const minutesOf = (value: unknown): number => {
  const match = /(\d+)/.exec(textOf(value));
  const minutes = match ? Number(match[1]) : DEFAULT_MINUTES;
  return clamp(minutes, MIN_MINUTES, MAX_MINUTES);
};

const goalOf = (
  type: TrainingType,
  section: Record<string, unknown>,
  primaryGoal: string,
): ProgramGoalId => {
  if (type === "Yoga") return "mobility";
  if (type === "Calisthenics") return "home";
  for (const goal of listOf(section.goals)) {
    const mapped = GYM_GOALS[textOf(goal)];
    if (mapped) return mapped;
  }
  return PRIMARY_GOALS[primaryGoal] ?? "strength";
};

const equipmentOf = (
  type: TrainingType,
  section: Record<string, unknown>,
): EquipmentKind[] => {
  if (type === "Yoga") return ["bodyweight"];
  if (type === "Calisthenics") {
    const items = realItems(section.equipment);
    return items.includes("Bands") ? ["bodyweight", "band"] : ["bodyweight"];
  }
  return GYM_EQUIPMENT[textOf(section.equipment)] ?? ALL_EQUIPMENT;
};

const equipmentLabelOf = (
  type: TrainingType,
  section: Record<string, unknown>,
): string => {
  if (type === "Gym") return textOf(section.equipment) || "Full Gym";
  const items = realItems(section.equipment);
  return items.length ? items.join(", ") : "No equipment";
};

const splitOf = (
  type: TrainingType,
  section: Record<string, unknown>,
  blueprintSplit: string,
  days: number,
): SplitKind => {
  if (type === "Yoga") return "Yoga Flow";
  if (type === "Calisthenics") return days >= 4 ? "Upper Lower" : "Full Body";
  const preferred = textOf(section.preferredSplit);
  const chosen = SPLITS.find((split) => split === preferred) ??
    SPLITS.find((split) => split === blueprintSplit);
  if (chosen === "Push Pull Legs" && days < 3) return "Full Body";
  if (chosen === "Upper Lower" && days < 2) return "Full Body";
  if (chosen) return chosen;
  if (days >= 5) return "Push Pull Legs";
  if (days === 4) return "Upper Lower";
  return "Full Body";
};

export const planProfileOf = (details: DocumentData): PlanProfile => {
  const type = trainingTypeOf(details);
  const section = recordOf(details[SECTION_KEYS[type]]);
  const setup = recordOf(details.trainingSetup);
  const goals = recordOf(details.goalsActivity);
  const health = recordOf(details.healthDiet);
  const floState = recordOf(details.floState);
  const blueprint = recordOf(details.blueprint);
  const level = levelOf(
    textOf(section.experienceLevel) || textOf(setup.experienceLevel),
  );
  const weekdays = weekdaysOf(section, level);
  const primaryGoal = textOf(goals.primaryGoal);
  const goal = goalOf(type, section, primaryGoal);

  return {
    firstName: textOf(recordOf(details.profile).name).split(/\s+/)[0] || "",
    trainingType: type,
    level,
    weekdays,
    sessionMinutes: minutesOf(section.workoutDuration ??
      section.practiceDuration),
    goal,
    goalLabel: GOAL_LABELS[goal],
    primaryGoal,
    split: splitOf(type, section, textOf(blueprint.workoutSplit),
      weekdays.length),
    equipment: equipmentOf(type, section),
    equipmentLabel: equipmentLabelOf(type, section),
    focusMuscles: realItems(section.targetMuscleGroups),
    injuries: realItems(section.injuries),
    healthConditions: realItems(health.healthConditions),
    wantsMeditation: section.wantsMeditation === true,
    yogaStyle: textOf(section.preferredStyle),
    maxPushups: numberOf(section.maxPushups),
    maxPullups: numberOf(section.maxPullups),
    maxDips: numberOf(section.maxDips),
    pushIntensity: textOf(floState.pushIntensity),
    recoverySpeed: textOf(floState.recoverySpeed),
  };
};

const INJURY_EXCLUSIONS: Record<string, string[]> = {
  Knee: ["walking-lunge", "burpee", "leg-extension", "treadmill-intervals"],
  Back: ["barbell-back-squat", "romanian-deadlift", "barbell-row",
    "kettlebell-swing", "hanging-leg-raise"],
  Shoulder: ["overhead-press", "pike-push-up", "parallel-bar-dip",
    "dumbbell-shoulder-press"],
  Elbow: ["parallel-bar-dip", "triceps-pushdown", "barbell-curl"],
  Wrist: ["pike-push-up", "burpee"],
};

const CALISTHENICS_REQUIREMENTS: Record<string, string[]> = {
  "pull-up": ["Pull-up Bar", "Rings"],
  "hanging-leg-raise": ["Pull-up Bar"],
  "parallel-bar-dip": ["Dip Bars", "Parallettes", "Rings"],
};

const HOME_GYM = "Home Gym";
const MIN_PULL_UPS = 3;
const MIN_DIPS = 3;

export const allowedExercisesOf = (
  catalog: CatalogExercise[],
  profile: PlanProfile,
  details: DocumentData,
): CatalogExercise[] => {
  const excluded = new Set(
    profile.injuries.flatMap((injury) => INJURY_EXCLUSIONS[injury] ?? []),
  );
  if (profile.equipmentLabel === HOME_GYM) {
    for (const id of Object.keys(CALISTHENICS_REQUIREMENTS)) excluded.add(id);
  }
  if (profile.trainingType === "Calisthenics") {
    const owned = realItems(
      recordOf(details.calisthenicsDetails).equipment,
    );
    for (const [id, needs] of Object.entries(CALISTHENICS_REQUIREMENTS)) {
      if (!needs.some((item) => owned.includes(item))) excluded.add(id);
    }
    if (profile.maxPullups < MIN_PULL_UPS) excluded.add("pull-up");
    if (profile.maxDips < MIN_DIPS) excluded.add("parallel-bar-dip");
  }
  return catalog.filter((exercise) =>
    profile.equipment.includes(exercise.equipment) &&
    !excluded.has(exercise.id));
};

export const catalogExerciseOf = (
  data: DocumentData,
): CatalogExercise | null => {
  const id = textOf(data.id);
  const name = textOf(data.name);
  if (!id || !name) return null;
  const equipment = textOf(data.equipment) as EquipmentKind;
  return {
    id,
    name,
    group: textOf(data.muscleGroup) || "other",
    equipment: ALL_EQUIPMENT.includes(equipment) ? equipment : "bodyweight",
    isTimed: data.trackingMode === "duration",
    defaultSets: numberOf(data.defaultSets, 3),
    defaultReps: numberOf(data.defaultReps, 10),
    defaultRestSeconds: numberOf(data.defaultRestSeconds, 60),
    defaultRepsInReserve: numberOf(data.defaultRepsInReserve, 2),
    isCustom: data.isCustom === true,
  };
};
