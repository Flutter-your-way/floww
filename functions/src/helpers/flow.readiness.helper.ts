import {Transaction} from "firebase-admin/firestore";
import {clamp, numberOf, recordOf} from "../common/utils";
import {
  USER_COLLECTIONS,
  onboardingDetailsCollection,
  userCollection,
} from "../constants/collections";

const SLEEP_WEIGHT = 0.6;
const HRV_WEIGHT = 0.4;
const DEFAULT_SLEEP_TARGET_HOURS = 8;
const HRV_FLOOR_MS = 20;
const HRV_RANGE_MS = 60;
const MINUTES_PER_HOUR = 60;

export const readinessOf = (
  baseline: number,
  sleepMinutes: number,
  hrvMs: number,
  sleepTargetHours: number,
): number => {
  let total = 0;
  let weight = 0;

  if (sleepMinutes > 0) {
    const target = (sleepTargetHours > 0 ?
      sleepTargetHours :
      DEFAULT_SLEEP_TARGET_HOURS) * MINUTES_PER_HOUR;
    total += clamp(sleepMinutes / target, 0, 1) * SLEEP_WEIGHT;
    weight += SLEEP_WEIGHT;
  }

  if (hrvMs > 0) {
    total += clamp((hrvMs - HRV_FLOOR_MS) / HRV_RANGE_MS, 0, 1) * HRV_WEIGHT;
    weight += HRV_WEIGHT;
  }

  if (weight > 0) return Math.round(clamp(total / weight * 100, 0, 100));
  return Math.round(clamp(baseline, 0, 100));
};

export const readDayReadiness = async (
  transaction: Transaction,
  uid: string,
  day: string,
): Promise<number> => {
  const [details, health] = await Promise.all([
    transaction.get(onboardingDetailsCollection.doc(uid)),
    transaction.get(userCollection(uid, USER_COLLECTIONS.healthLogs).doc(day)),
  ]);
  return readinessOf(
    numberOf(recordOf(details.get("blueprint")).flowScore),
    numberOf(health.get("sleepMinutes")),
    numberOf(health.get("hrvMs")),
    numberOf(recordOf(details.get("targetsPermissions")).sleepTargetHours),
  );
};
