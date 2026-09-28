import {logger} from "firebase-functions";
import {
  USER_COLLECTIONS,
  firestore,
  userCollection,
} from "../constants/collections";
import {
  FlowEntry,
  flowDocOf,
  flowEntryOf,
  readDayActivity,
  sameFlowValues,
} from "./flow.score.helper";
import {syncAutoHabits} from "./habit.source.helper";
import {refreshFlowStats} from "./stats.helper";
import {UserClock, clockOf, loadActiveUser} from "./user.clock.helper";

export const flowDoc = (uid: string, day: string) =>
  userCollection(uid, USER_COLLECTIONS.dailyFlow).doc(day);

export const recomputeDailyFlow = async (
  uid: string,
  day: string,
): Promise<{entry: FlowEntry; clock: UserClock} | null> =>
  firestore.runTransaction(async (transaction) => {
    const user = await loadActiveUser(uid, transaction);
    if (!user) return null;

    const clock = clockOf(user);
    const activity = await readDayActivity(transaction, uid, day, clock);
    const ref = flowDoc(uid, day);
    const stored = await transaction.get(ref);
    const entry = flowEntryOf(day, activity);

    const shouldWrite = stored.exists ?
      !sameFlowValues(stored.data(), entry) :
      entry.score > 0;
    if (shouldWrite) transaction.set(ref, flowDocOf(entry));

    return {entry, clock};
  });

export interface SyncOptions {
  autoHabits?: boolean;
}

export const syncActivityDays = async (
  uid: string,
  days: Iterable<string>,
  options: SyncOptions = {},
): Promise<void> => {
  let clock: UserClock | null = null;
  for (const day of new Set(days)) {
    try {
      if (options.autoHabits) await syncAutoHabits(uid, day);
      const result = await recomputeDailyFlow(uid, day);
      if (result) clock = result.clock;
    } catch (error) {
      logger.error("syncActivityDays: day sync failed", {uid, day, error});
    }
  }

  if (!clock) return;
  try {
    await refreshFlowStats(uid, clock);
  } catch (error) {
    logger.error("syncActivityDays: stats refresh failed", {uid, error});
  }
};
