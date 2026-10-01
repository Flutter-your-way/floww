import {DocumentData} from "firebase-admin/firestore";
import {clamp, listOf, numberOf, recordOf} from "../common/utils";

export const FALLBACK_BODY_WEIGHT_KG = 70;
const FALLBACK_MET = 5;
const MAX_TRAINING_EFFECT = 5;
const SECONDS_PER_HOUR = 3600;
const SECONDS_PER_MINUTE = 60;
const TARGET_SETS = 20;
const TARGET_MINUTES = 60;
const TARGET_MET = 8;
const WEIGHT_PR_THRESHOLD_KG = 0.5;
const SECONDS_PER_EFFORT_REP = 3;
const WARMUP = "warmup";
const DURATION_MODE = "duration";

interface LoggedSet {
  reps: number;
  weightKg: number | null;
  durationSeconds: number | null;
  isWorking: boolean;
}

export interface WorkoutEntry {
  exerciseId: string;
  name: string;
  targetSets: number;
  met: number;
  muscleShares: Record<string, number>;
  isTimed: boolean;
  sets: LoggedSet[];
}

export interface WorkoutTotals {
  volumeKg: number;
  totalSets: number;
  totalReps: number;
  exerciseCount: number;
  weightedMet: number;
}

export interface MuscleShare {
  name: string;
  share: number;
}

export interface PersonalRecord {
  exerciseId: string;
  exercise: string;
  improvement: string;
  glyph: string;
}

export interface ExerciseBest {
  weightKg: number;
  reps: number;
  seconds: number;
}

const nullableNumber = (value: unknown): number | null =>
  typeof value === "number" && Number.isFinite(value) ? value : null;

const setOf = (value: unknown): LoggedSet => {
  const json = recordOf(value);
  return {
    reps: Math.trunc(numberOf(json.reps)),
    weightKg: nullableNumber(json.weightKg),
    durationSeconds: nullableNumber(json.durationSeconds),
    isWorking: json.type !== WARMUP,
  };
};

const sharesOf = (value: unknown): Record<string, number> => {
  const shares: Record<string, number> = {};
  for (const [key, share] of Object.entries(recordOf(value))) {
    if (typeof share === "number" && Number.isFinite(share)) {
      shares[key] = share;
    }
  }
  return shares;
};

export const entryOf = (value: unknown): WorkoutEntry => {
  const json = recordOf(value);
  const id = typeof json.id === "string" ? json.id : "";
  return {
    exerciseId: typeof json.exerciseId === "string" ? json.exerciseId : id,
    name: typeof json.name === "string" ? json.name : "",
    targetSets: Math.trunc(numberOf(json.targetSets)),
    met: numberOf(json.met, FALLBACK_MET),
    muscleShares: sharesOf(json.muscleShares),
    isTimed: json.trackingMode === DURATION_MODE,
    sets: listOf(json.sets).map(setOf),
  };
};

export const entriesOf = (value: unknown): WorkoutEntry[] =>
  listOf(value).map(entryOf);

const workingSets = (entry: WorkoutEntry): LoggedSet[] =>
  entry.sets.filter((set) => set.isWorking);

const volumeOf = (set: LoggedSet): number =>
  set.isWorking ? (set.weightKg ?? 0) * set.reps : 0;

const effortRepsOf = (set: LoggedSet): number =>
  set.reps + (set.durationSeconds ?? 0) / SECONDS_PER_EFFORT_REP;

export const totalsOf = (entries: WorkoutEntry[]): WorkoutTotals => {
  let volume = 0;
  let sets = 0;
  let reps = 0;
  let count = 0;
  let metWeighted = 0;

  for (const entry of entries) {
    const working = workingSets(entry);
    if (working.length === 0) continue;
    count++;
    sets += working.length;
    reps += working.reduce((total, set) => total + set.reps, 0);
    volume += entry.sets.reduce((total, set) => total + volumeOf(set), 0);
    metWeighted += entry.met * working.length;
  }

  return {
    volumeKg: volume,
    totalSets: sets,
    totalReps: reps,
    exerciseCount: count,
    weightedMet: sets === 0 ? FALLBACK_MET : metWeighted / sets,
  };
};

export const plannedSetsOf = (entries: WorkoutEntry[]): number =>
  entries.reduce((total, entry) => total + Math.max(0, entry.targetSets), 0);

export const caloriesOf = (
  totals: WorkoutTotals,
  durationSeconds: number,
  bodyWeightKg: number,
): number => {
  if (durationSeconds <= 0) return 0;
  return Math.round(
    totals.weightedMet * bodyWeightKg * (durationSeconds / SECONDS_PER_HOUR),
  );
};

export const trainingEffectOf = (
  totals: WorkoutTotals,
  durationSeconds: number,
): number => {
  if (totals.totalSets === 0) return 0;
  const setScore = clamp(totals.totalSets / TARGET_SETS, 0, 1) * 2;
  const minutes = durationSeconds / SECONDS_PER_MINUTE;
  const durationScore = clamp(minutes / TARGET_MINUTES, 0, 1) * 1.5;
  const intensityScore = clamp(totals.weightedMet / TARGET_MET, 0, 1) * 0.5;
  const effect = 1 + setScore + durationScore + intensityScore;
  return Number(clamp(effect, 1, MAX_TRAINING_EFFECT).toFixed(1));
};

const completionRatioOf = (entries: WorkoutEntry[]): number => {
  let planned = 0;
  let logged = 0;
  for (const entry of entries) {
    planned += entry.targetSets;
    logged += workingSets(entry).length;
  }
  if (planned === 0) return logged === 0 ? 0 : 1;
  return clamp(logged / planned, 0, 1);
};

export const muscleActivationOf = (entries: WorkoutEntry[]): MuscleShare[] => {
  const scores = new Map<string, number>();
  for (const entry of entries) {
    const working = workingSets(entry);
    if (working.length === 0) continue;
    const effort = working.reduce((total, set) => total + effortRepsOf(set), 0);
    for (const [name, share] of Object.entries(entry.muscleShares)) {
      scores.set(name, (scores.get(name) ?? 0) + share * effort);
    }
  }
  if (scores.size === 0) return [];

  const peak = Math.max(...scores.values());
  if (peak === 0) return [];

  const completion = completionRatioOf(entries);
  return [...scores.entries()]
    .map(([name, score]) => ({
      name,
      share: Number(clamp((score / peak) * completion, 0, 1).toFixed(2)),
    }))
    .sort((a, b) => b.share - a.share);
};

export const bestsOf = (
  sessions: DocumentData[],
): Map<string, ExerciseBest> => {
  const bests = new Map<string, ExerciseBest>();
  for (const session of sessions) {
    for (const entry of entriesOf(session.exercises)) {
      for (const set of workingSets(entry)) {
        const current = bests.get(entry.exerciseId) ??
          {weightKg: 0, reps: 0, seconds: 0};
        bests.set(entry.exerciseId, {
          weightKg: Math.max(set.weightKg ?? 0, current.weightKg),
          reps: Math.max(set.reps, current.reps),
          seconds: Math.max(set.durationSeconds ?? 0, current.seconds),
        });
      }
    }
  }
  return bests;
};

const weightLabel = (value: number): string =>
  value % 1 === 0 ? value.toFixed(0) : value.toFixed(1);

export const personalRecordsOf = (
  entries: WorkoutEntry[],
  previousBests: Map<string, ExerciseBest>,
): PersonalRecord[] => {
  const records: PersonalRecord[] = [];
  for (const entry of entries) {
    const working = workingSets(entry);
    if (working.length === 0) continue;
    const best = previousBests.get(entry.exerciseId) ??
      {weightKg: 0, reps: 0, seconds: 0};
    const weights = working
      .map((set) => set.weightKg)
      .filter((weight): weight is number => weight !== null);
    const weight = weights.length > 0 ? Math.max(...weights) : null;

    if (entry.isTimed) {
      const seconds = Math.max(0,
        ...working.map((set) => set.durationSeconds ?? 0));
      if (seconds > best.seconds) {
        const gain = best.seconds === 0 ? seconds : seconds - best.seconds;
        records.push({
          exerciseId: entry.exerciseId,
          exercise: entry.name,
          improvement: `+${gain}s`,
          glyph: "⏱️",
        });
      }
      continue;
    }

    if (weight !== null && weight > best.weightKg + WEIGHT_PR_THRESHOLD_KG) {
      const gain = best.weightKg === 0 ? weight : weight - best.weightKg;
      records.push({
        exerciseId: entry.exerciseId,
        exercise: entry.name,
        improvement: `+${weightLabel(gain)}kg`,
        glyph: "🏋️",
      });
      continue;
    }

    const bestReps = Math.max(0, ...working.map((set) => set.reps));
    if (weight === null && bestReps > best.reps) {
      const gain = best.reps === 0 ? bestReps : bestReps - best.reps;
      records.push({
        exerciseId: entry.exerciseId,
        exercise: entry.name,
        improvement: `+${gain} rep${gain === 1 ? "" : "s"}`,
        glyph: "💪",
      });
    }
  }
  return records;
};
