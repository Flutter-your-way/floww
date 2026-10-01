import {DocumentData} from "firebase-admin/firestore";
import {numberOf, recordOf} from "../common/utils";
import {SOURCE_PRIORITY} from "../constants/health.constants";

export interface MergedHealthDay {
  steps: number;
  activeCaloriesKcal: number;
  sleepMinutes: number;
  workoutCount: number;
  restingHeartRate: number | null;
  hrvMs: number | null;
  syncedAt: string | null;
}

const MAX_FIELDS = ["steps", "activeCaloriesKcal", "workoutCount"] as const;
const HEART_FIELDS = ["restingHeartRate", "hrvMs"] as const;

const rankOf = (source: string): number => {
  const index = SOURCE_PRIORITY.indexOf(source);
  return index < 0 ? SOURCE_PRIORITY.length : index;
};

export const mergeHealthSources = (
  sources: Record<string, unknown>,
): MergedHealthDay => {
  const ranked = Object.entries(sources)
    .map(([source, value]) => [source, recordOf(value)] as const)
    .sort(([a], [b]) => rankOf(a) - rankOf(b));

  const merged: MergedHealthDay = {
    steps: 0,
    activeCaloriesKcal: 0,
    sleepMinutes: 0,
    workoutCount: 0,
    restingHeartRate: null,
    hrvMs: null,
    syncedAt: null,
  };

  for (const [, data] of ranked) {
    for (const field of MAX_FIELDS) {
      merged[field] = Math.max(merged[field], numberOf(data[field]));
    }
    if (merged.sleepMinutes === 0) {
      merged.sleepMinutes = numberOf(data.sleepMinutes);
    }
    for (const field of HEART_FIELDS) {
      const value = numberOf(data[field]);
      if (merged[field] === null && value > 0) merged[field] = value;
    }
    const syncedAt = typeof data.syncedAt === "string" ? data.syncedAt : null;
    if (syncedAt && (!merged.syncedAt || syncedAt > merged.syncedAt)) {
      merged.syncedAt = syncedAt;
    }
  }

  return merged;
};

export const matchesMerged = (
  current: DocumentData,
  merged: MergedHealthDay,
): boolean =>
  [...MAX_FIELDS, "sleepMinutes" as const, ...HEART_FIELDS].every((field) => {
    const value = merged[field];
    const existing = current[field];
    return value === null ?
      existing === undefined || existing === null :
      numberOf(existing, NaN) === value;
  });
