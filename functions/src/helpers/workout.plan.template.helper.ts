import {clamp} from "../common/utils";
import {
  PlannedDay,
  PlannedExercise,
  ProgramGoalId,
  WorkoutSection,
} from "../models/workout.plan.model";
import {CatalogExercise, PlanProfile} from "./workout.plan.profile.helper";

type Slot =
  | "squat" | "hinge" | "lunge" | "quad" | "calf"
  | "hpush" | "ipush" | "fly" | "vpush" | "delt"
  | "vpull" | "hpull" | "rear" | "biceps" | "biceps2" | "triceps"
  | "core" | "core2" | "conditioning"
  | "warmUpper" | "warmLower" | "warmFull"
  | "coolUpper" | "coolLower"
  | "yogaOpen" | "yogaStand" | "yogaBalance" | "yogaHip" | "yogaBack"
  | "yogaStrength" | "yogaRest" | "meditation";

const SLOT_CANDIDATES: Record<Slot, string[]> = {
  squat: ["barbell-back-squat", "leg-press", "goblet-squat",
    "bodyweight-squat"],
  hinge: ["romanian-deadlift", "kettlebell-swing", "glute-bridge"],
  lunge: ["walking-lunge", "goblet-squat", "glute-bridge"],
  quad: ["leg-extension", "goblet-squat", "bodyweight-squat"],
  calf: ["standing-calf-raise"],
  hpush: ["barbell-bench-press", "incline-db-press", "push-up"],
  ipush: ["incline-db-press", "parallel-bar-dip", "push-up"],
  fly: ["chest-fly", "push-up"],
  vpush: ["overhead-press", "dumbbell-shoulder-press", "pike-push-up"],
  delt: ["lateral-raise", "band-pull-apart", "face-pull"],
  vpull: ["pull-up", "lat-pulldown", "inverted-row"],
  hpull: ["barbell-row", "seated-cable-row", "dumbbell-row", "inverted-row"],
  rear: ["face-pull", "band-pull-apart"],
  biceps: ["barbell-curl", "hammer-curl"],
  biceps2: ["hammer-curl", "barbell-curl"],
  triceps: ["triceps-pushdown", "parallel-bar-dip", "push-up"],
  core: ["hanging-leg-raise", "plank", "dead-bug"],
  core2: ["plank", "dead-bug"],
  conditioning: ["rowing-machine", "kettlebell-swing", "treadmill-intervals",
    "burpee", "mountain-climber"],
  warmUpper: ["band-pull-apart", "face-pull", "cat-cow", "push-up"],
  warmLower: ["bodyweight-squat", "hip-flexor-stretch"],
  warmFull: ["bodyweight-squat", "mountain-climber", "cat-cow"],
  coolUpper: ["childs-pose", "cobra-pose", "hamstring-stretch"],
  coolLower: ["hamstring-stretch", "foam-roll-quads", "pigeon-pose"],
  yogaOpen: ["sun-salutation", "cat-cow"],
  yogaStand: ["warrior-two", "chair-pose"],
  yogaBalance: ["tree-pose", "warrior-two"],
  yogaHip: ["pigeon-pose", "hip-flexor-stretch"],
  yogaBack: ["cobra-pose", "downward-dog"],
  yogaStrength: ["plank", "chair-pose"],
  yogaRest: ["childs-pose", "hamstring-stretch"],
  meditation: ["seated-meditation"],
};

interface DayTemplate {
  name: string;
  focus?: string;
  goal: string;
  warmUp: Slot[];
  main: Slot[];
  coolDown: Slot[];
}

const FULL_A: DayTemplate = {
  name: "Full Body A",
  goal: "Own every rep of your main squat and press.",
  warmUp: ["warmFull"],
  main: ["squat", "hpush", "hpull", "hinge", "vpush", "core", "biceps",
    "triceps"],
  coolDown: ["coolLower"],
};

const FULL_B: DayTemplate = {
  name: "Full Body B",
  goal: "Hinge with a flat back and pull with control.",
  warmUp: ["warmFull"],
  main: ["hinge", "vpull", "ipush", "lunge", "delt", "core2", "biceps2",
    "calf"],
  coolDown: ["coolUpper"],
};

const FULL_C: DayTemplate = {
  name: "Full Body C",
  goal: "Single-leg strength and a strong upper back.",
  warmUp: ["warmFull"],
  main: ["lunge", "hpush", "hpull", "quad", "rear", "core", "triceps",
    "conditioning"],
  coolDown: ["coolLower"],
};

const UPPER_A: DayTemplate = {
  name: "Upper Body A",
  goal: "Add a rep or a little load to your main press.",
  warmUp: ["warmUpper"],
  main: ["hpush", "hpull", "vpush", "vpull", "triceps", "biceps", "rear"],
  coolDown: ["coolUpper"],
};

const UPPER_B: DayTemplate = {
  name: "Upper Body B",
  goal: "Lead with the pull and keep the shoulders healthy.",
  warmUp: ["warmUpper"],
  main: ["vpull", "ipush", "hpull", "delt", "fly", "biceps2", "triceps"],
  coolDown: ["coolUpper"],
};

const LOWER_A: DayTemplate = {
  name: "Lower Body A",
  goal: "Hit depth on every squat.",
  warmUp: ["warmLower"],
  main: ["squat", "hinge", "lunge", "quad", "calf", "core"],
  coolDown: ["coolLower"],
};

const LOWER_B: DayTemplate = {
  name: "Lower Body B",
  goal: "Strong hips: hinge first, then single-leg work.",
  warmUp: ["warmLower"],
  main: ["hinge", "squat", "lunge", "calf", "core2", "conditioning"],
  coolDown: ["coolLower"],
};

const PUSH: DayTemplate = {
  name: "Push Day",
  goal: "Press with a tight upper back and full lockout.",
  warmUp: ["warmUpper"],
  main: ["hpush", "vpush", "ipush", "delt", "fly", "triceps"],
  coolDown: ["coolUpper"],
};

const PULL: DayTemplate = {
  name: "Pull Day",
  goal: "Start every pull from the shoulder blades.",
  warmUp: ["warmUpper"],
  main: ["vpull", "hpull", "rear", "biceps", "biceps2", "core"],
  coolDown: ["coolUpper"],
};

const LEGS: DayTemplate = {
  name: "Leg Day",
  goal: "Drive through the full foot on every rep.",
  warmUp: ["warmLower"],
  main: ["squat", "hinge", "lunge", "quad", "calf", "core2"],
  coolDown: ["coolLower"],
};

const CHEST: DayTemplate = {
  name: "Chest Day",
  goal: "Controlled lowering, explosive press.",
  warmUp: ["warmUpper"],
  main: ["hpush", "ipush", "fly", "triceps", "core"],
  coolDown: ["coolUpper"],
};

const BACK: DayTemplate = {
  name: "Back Day",
  goal: "Full range on every pull.",
  warmUp: ["warmUpper"],
  main: ["vpull", "hpull", "hinge", "rear", "biceps"],
  coolDown: ["coolUpper"],
};

const SHOULDERS: DayTemplate = {
  name: "Shoulder Day",
  goal: "Stable shoulders through every press and raise.",
  warmUp: ["warmUpper"],
  main: ["vpush", "delt", "rear", "core2", "conditioning"],
  coolDown: ["coolUpper"],
};

const ARMS: DayTemplate = {
  name: "Arm Day",
  goal: "No swinging — make the target muscle do the work.",
  warmUp: ["warmUpper"],
  main: ["biceps", "triceps", "biceps2", "ipush", "core"],
  coolDown: ["coolUpper"],
};

const YOGA_STRENGTH: DayTemplate = {
  name: "Strength Flow",
  focus: "Strength",
  goal: "Hold every pose with steady breath.",
  warmUp: ["yogaOpen"],
  main: ["yogaStand", "yogaStrength", "yogaBalance", "yogaBack", "yogaHip"],
  coolDown: ["yogaRest", "meditation"],
};

const YOGA_MOBILITY: DayTemplate = {
  name: "Mobility Flow",
  focus: "Mobility",
  goal: "Ease deeper into each stretch, never force it.",
  warmUp: ["yogaOpen"],
  main: ["yogaBack", "yogaHip", "yogaStand", "yogaRest", "yogaBalance"],
  coolDown: ["yogaRest", "meditation"],
};

const YOGA_BALANCE: DayTemplate = {
  name: "Balance Flow",
  focus: "Balance",
  goal: "Find a still point in every balance.",
  warmUp: ["yogaOpen"],
  main: ["yogaBalance", "yogaStand", "yogaStrength", "yogaHip", "yogaBack"],
  coolDown: ["yogaRest", "meditation"],
};

const SPLIT_TEMPLATES: Record<PlanProfile["split"], DayTemplate[]> = {
  "Full Body": [FULL_A, FULL_B, FULL_C],
  "Upper Lower": [UPPER_A, LOWER_A, UPPER_B, LOWER_B],
  "Push Pull Legs": [PUSH, PULL, LEGS],
  "Bro Split": [CHEST, BACK, LEGS, SHOULDERS, ARMS],
  "Yoga Flow": [YOGA_STRENGTH, YOGA_MOBILITY, YOGA_BALANCE],
};

const FIVE_DAY_PPL = [PUSH, PULL, LEGS, UPPER_A, LOWER_B];

const FOCUS_LABELS: Record<ProgramGoalId, string> = {
  "strength": "Strength",
  "muscle": "Hypertrophy",
  "fat-loss": "Conditioning",
  "cardio": "Endurance",
  "home": "Bodyweight",
  "mobility": "Mobility",
};

interface Prescription {
  sets: number;
  reps: number;
  restSeconds: number;
  repsInReserve: number;
}

const PRIMARY: Record<ProgramGoalId, Prescription> = {
  "strength": {sets: 4, reps: 5, restSeconds: 150, repsInReserve: 2},
  "muscle": {sets: 4, reps: 8, restSeconds: 120, repsInReserve: 2},
  "fat-loss": {sets: 3, reps: 10, restSeconds: 75, repsInReserve: 2},
  "cardio": {sets: 3, reps: 12, restSeconds: 60, repsInReserve: 2},
  "home": {sets: 4, reps: 10, restSeconds: 90, repsInReserve: 2},
  "mobility": {sets: 2, reps: 10, restSeconds: 30, repsInReserve: 3},
};

const ACCESSORY: Record<ProgramGoalId, Prescription> = {
  "strength": {sets: 3, reps: 8, restSeconds: 90, repsInReserve: 2},
  "muscle": {sets: 3, reps: 12, restSeconds: 75, repsInReserve: 1},
  "fat-loss": {sets: 3, reps: 12, restSeconds: 45, repsInReserve: 2},
  "cardio": {sets: 3, reps: 15, restSeconds: 45, repsInReserve: 2},
  "home": {sets: 3, reps: 12, restSeconds: 60, repsInReserve: 2},
  "mobility": {sets: 2, reps: 10, restSeconds: 30, repsInReserve: 3},
};

const PRIMARY_COUNT = 2;
const MIN_SETS = 2;
const MAX_SETS = 5;
const PREP_SETS = 1;
const PREP_REST_SECONDS = 30;
const PREP_RESERVE = 4;
const MIN_REPS = 3;
const MAX_REPS = 25;
const MAX_REPS_RATIO = 0.6;
const BEGINNER_EXTRA_REPS = 2;
const BEGINNER_MAX_SETS = 3;

const MAIN_COUNT_BY_MINUTES: [number, number][] = [
  [30, 4],
  [45, 5],
  [60, 6],
  [90, 7],
];
const MAX_MAIN_COUNT = 8;

const CONDITIONING_GOALS: ProgramGoalId[] = ["fat-loss", "cardio"];

export const mainCountOf = (minutes: number): number => {
  for (const [limit, count] of MAIN_COUNT_BY_MINUTES) {
    if (minutes <= limit) return count;
  }
  return MAX_MAIN_COUNT;
};

const maxRepsOf = (
  exerciseId: string,
  profile: PlanProfile,
): number | null => {
  const max = exerciseId === "push-up" ?
    profile.maxPushups :
    exerciseId === "pull-up" ?
      profile.maxPullups :
      exerciseId === "parallel-bar-dip" ? profile.maxDips : 0;
  return max > 0 ? Math.round(max * MAX_REPS_RATIO) : null;
};

const prescriptionOf = (
  exercise: CatalogExercise,
  section: WorkoutSection,
  isPrimary: boolean,
  profile: PlanProfile,
): PlannedExercise => {
  if (section !== "main-exercises") {
    return {
      exerciseId: exercise.id,
      section,
      sets: PREP_SETS,
      reps: exercise.defaultReps,
      restSeconds: PREP_REST_SECONDS,
      repsInReserve: PREP_RESERVE,
    };
  }
  const base = (isPrimary ? PRIMARY : ACCESSORY)[profile.goal];
  const levelSets = profile.level === "Beginner" ?
    base.sets > BEGINNER_MAX_SETS ? -1 : 0 :
    profile.level === "Advanced" && isPrimary ? 1 : 0;
  const sets = clamp(base.sets + levelSets, MIN_SETS, MAX_SETS);
  const reserve = base.repsInReserve +
    (profile.level === "Beginner" ? 1 : 0);
  if (exercise.isTimed) {
    return {
      exerciseId: exercise.id,
      section,
      sets: clamp(exercise.defaultSets, MIN_SETS, MAX_SETS),
      reps: exercise.defaultReps,
      restSeconds: exercise.defaultRestSeconds,
      repsInReserve: reserve,
    };
  }
  const tested = maxRepsOf(exercise.id, profile);
  const reps = tested ??
    base.reps + (profile.level === "Beginner" && isPrimary ?
      BEGINNER_EXTRA_REPS :
      0);
  return {
    exerciseId: exercise.id,
    section,
    sets,
    reps: clamp(reps, MIN_REPS, MAX_REPS),
    restSeconds: base.restSeconds,
    repsInReserve: reserve,
  };
};

const pick = (
  slot: Slot,
  allowed: Map<string, CatalogExercise>,
  used: Set<string>,
): CatalogExercise | null => {
  for (const id of SLOT_CANDIDATES[slot]) {
    const exercise = allowed.get(id);
    if (exercise && !used.has(id)) return exercise;
  }
  return null;
};

const templatesOf = (profile: PlanProfile): DayTemplate[] => {
  const count = profile.weekdays.length;
  if (profile.split === "Push Pull Legs" && count === 5) return FIVE_DAY_PPL;
  const cycle = SPLIT_TEMPLATES[profile.split];
  return Array.from({length: count}, (_, index) => cycle[index % cycle.length]);
};

const dayOf = (
  template: DayTemplate,
  weekday: number,
  profile: PlanProfile,
  allowed: Map<string, CatalogExercise>,
): PlannedDay => {
  const used = new Set<string>();
  const exercises: PlannedExercise[] = [];
  const add = (slot: Slot, section: WorkoutSection, isPrimary: boolean) => {
    const exercise = pick(slot, allowed, used);
    if (!exercise) return false;
    used.add(exercise.id);
    exercises.push(prescriptionOf(exercise, section, isPrimary, profile));
    return true;
  };

  for (const slot of template.warmUp) add(slot, "warm-up", false);

  const wanted = mainCountOf(profile.sessionMinutes);
  const wantsConditioning = CONDITIONING_GOALS.includes(profile.goal) ||
    template.main.includes("conditioning");
  const limit = wantsConditioning ? wanted - 1 : wanted;
  let mainCount = 0;
  for (const slot of template.main) {
    if (slot === "conditioning") continue;
    if (mainCount >= limit) break;
    if (add(slot, "main-exercises", mainCount < PRIMARY_COUNT)) mainCount++;
  }
  if (wantsConditioning) add("conditioning", "main-exercises", false);

  for (const slot of template.coolDown) {
    if (slot === "meditation" && !profile.wantsMeditation) continue;
    add(slot, "cool-down", false);
  }

  return {
    weekday,
    name: template.name,
    focus: template.focus ?? FOCUS_LABELS[profile.goal],
    goal: template.goal,
    durationMinutes: profile.sessionMinutes,
    exercises,
  };
};

export const standardDaysOf = (
  profile: PlanProfile,
  allowed: CatalogExercise[],
): PlannedDay[] => {
  const byId = new Map(allowed.map((exercise) => [exercise.id, exercise]));
  return templatesOf(profile).map((template, index) =>
    dayOf(template, profile.weekdays[index], profile, byId));
};

export const standardDescriptionOf = (profile: PlanProfile): string =>
  `${profile.weekdays.length}x/week ${profile.split.toLowerCase()} built ` +
  `from your onboarding: ${profile.goalLabel.toLowerCase()} focus, ` +
  `${profile.sessionMinutes}-minute sessions.`;
