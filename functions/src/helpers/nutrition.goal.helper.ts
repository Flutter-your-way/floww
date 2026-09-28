import {DocumentData} from "firebase-admin/firestore";
import {listOf, numberOf, recordOf} from "../common/utils";
import {
  TARGETS_DOC,
  USER_COLLECTIONS,
  userCollection,
} from "../constants/collections";

const MIN_CALORIES = 1200;
const MAX_CALORIES = 5000;
const BASELINE_TRAINING_DAYS = 3;
const TRAINING_DAY_BONUS = 0.025;
const MAX_TRAINING_BONUS = 0.15;
const FAT_SHARE = 0.25;
const SUGAR_SHARE = 0.1;
const PROTEIN_KCAL = 4;
const CARBS_KCAL = 4;
const FAT_KCAL = 9;
const FIBER_PER_THOUSAND = 14;
const WATER_ML_PER_KG = 35;
const SODIUM_MG = 2300;
const ML_PER_LITER = 1000;

export interface NutritionTargets {
  calories: number;
  proteinG: number;
  carbsG: number;
  fatsG: number;
  fiberG: number;
  sugarG: number;
  sodiumMg: number;
  waterMl: number;
}

const DEFAULT_TARGETS: NutritionTargets = {
  calories: 2450,
  proteinG: 200,
  carbsG: 310,
  fatsG: 90,
  fiberG: 30,
  sugarG: 50,
  sodiumMg: SODIUM_MG,
  waterMl: 2500,
};

const SEX_OFFSETS: Record<string, number> = {Male: 5, Female: -161};
const NEUTRAL_OFFSET = -78;

const ACTIVITY: Record<string, number> = {
  "Sedentary": 1.2,
  "Lightly Active": 1.375,
  "Active": 1.55,
  "Very Active": 1.725,
};
const DEFAULT_ACTIVITY = 1.375;

const GOAL_FACTORS: Record<string, number> = {
  "Lose Fat": 0.8,
  "Gain Muscle": 1.12,
};

const PROTEIN_PER_KG: Record<string, number> = {
  "Lose Fat": 2.2,
  "Gain Muscle": 2.0,
  "Recomposition": 2.2,
};
const MAINTENANCE_PROTEIN_PER_KG = 1.6;

const TRAINING_SECTIONS: Record<string, string> = {
  Gym: "gymDetails",
  Calisthenics: "calisthenicsDetails",
  Yoga: "yogaDetails",
};

const positive = (value: unknown): number | null => {
  const amount = numberOf(value, NaN);
  return Number.isFinite(amount) && amount > 0 ? amount : null;
};

const ageOf = (value: unknown, now: Date): number | null => {
  if (typeof value !== "string") return null;
  const birth = new Date(value);
  if (Number.isNaN(birth.getTime())) return null;
  let age = now.getUTCFullYear() - birth.getUTCFullYear();
  const hadBirthday = now.getUTCMonth() > birth.getUTCMonth() ||
    (now.getUTCMonth() === birth.getUTCMonth() &&
      now.getUTCDate() >= birth.getUTCDate());
  if (!hadBirthday) age -= 1;
  return age;
};

const trainingDaysOf = (details: DocumentData): number | null => {
  const type = recordOf(details.trainingSetup).trainingType;
  const key = typeof type === "string" ? TRAINING_SECTIONS[type] : undefined;
  if (!key) return null;
  const section = recordOf(details[key]);
  const days = listOf(section.trainingDays ?? section.practiceDays);
  return days.length > 0 ? days.length : null;
};

const waterOf = (liters: number | null, weightKg: number): number =>
  liters !== null ?
    Math.round(liters * ML_PER_LITER) :
    Math.round(weightKg * WATER_ML_PER_KG);

export const nutritionTargetsOf = (
  details: DocumentData,
  now: Date = new Date(),
): NutritionTargets => {
  const profile = recordOf(details.profile);
  const goals = recordOf(details.goalsActivity);
  const permissions = recordOf(details.targetsPermissions);
  const waterLiters = positive(permissions.waterTargetLiters);

  const weightKg = positive(profile.weightKg);
  const heightCm = positive(profile.heightCm);
  const age = ageOf(profile.dateOfBirth, now);

  if (weightKg === null || heightCm === null || age === null) {
    return waterLiters === null ?
      DEFAULT_TARGETS :
      {...DEFAULT_TARGETS, waterMl: Math.round(waterLiters * ML_PER_LITER)};
  }

  const sex = typeof profile.biologicalSex === "string" ?
    profile.biologicalSex :
    "";
  const bmr = 10 * weightKg + 6.25 * heightCm - 5 * age +
    (SEX_OFFSETS[sex] ?? NEUTRAL_OFFSET);

  const activityLevel = typeof goals.activityLevel === "string" ?
    goals.activityLevel :
    "";
  const days = trainingDaysOf(details) ?? BASELINE_TRAINING_DAYS;
  const bonus = Math.min(
    MAX_TRAINING_BONUS,
    Math.max(0, days - BASELINE_TRAINING_DAYS) * TRAINING_DAY_BONUS,
  );
  const multiplier = (ACTIVITY[activityLevel] ?? DEFAULT_ACTIVITY) + bonus;

  const goal = typeof goals.primaryGoal === "string" ? goals.primaryGoal : "";
  const calories = Math.min(
    Math.max(Math.round(bmr * multiplier * (GOAL_FACTORS[goal] ?? 1)),
      MIN_CALORIES),
    MAX_CALORIES,
  );

  const proteinG = weightKg * (PROTEIN_PER_KG[goal] ??
    MAINTENANCE_PROTEIN_PER_KG);
  const fatG = calories * FAT_SHARE / FAT_KCAL;
  const carbsG = Math.max(
    0,
    (calories - proteinG * PROTEIN_KCAL - fatG * FAT_KCAL) / CARBS_KCAL,
  );

  return {
    calories,
    proteinG: Math.round(proteinG),
    carbsG: Math.round(carbsG),
    fatsG: Math.round(fatG),
    fiberG: Math.round(calories / 1000 * FIBER_PER_THOUSAND),
    sugarG: Math.round(calories * SUGAR_SHARE / CARBS_KCAL),
    sodiumMg: SODIUM_MG,
    waterMl: waterOf(waterLiters, weightKg),
  };
};

export const targetsDoc = (uid: string) =>
  userCollection(uid, USER_COLLECTIONS.targets).doc(TARGETS_DOC);

export const saveNutritionTargets = async (
  uid: string,
  details: DocumentData,
): Promise<NutritionTargets> => {
  const targets = nutritionTargetsOf(details);
  const ref = targetsDoc(uid);
  const stored = (await ref.get()).data();
  const unchanged = stored !== undefined &&
    (Object.keys(targets) as (keyof NutritionTargets)[])
      .every((key) => stored[key] === targets[key]);
  if (!unchanged) {
    await ref.set({...targets, updatedAt: new Date().toISOString()});
  }
  return targets;
};
