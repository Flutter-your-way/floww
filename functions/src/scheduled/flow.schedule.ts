import {logger} from "firebase-functions";
import {onSchedule} from "firebase-functions/scheduler";
import {addDaysToKey, dayKeyAt} from "../common/utils";
import {
  USER_COLLECTIONS,
  userCollection,
  usersCollection,
} from "../constants/collections";
import {syncActivityDays} from "../helpers/flow.sync.helper";
import {offsetsAtLocalTime} from "../helpers/notification.helper";
import {isActiveUser, offsetOf} from "../helpers/user.clock.helper";

const ROLLOVER_MINUTE = 0;
const WINDOW_MINUTES = 30;
const MAX_OFFSETS_PER_QUERY = 30;
const BACKFILL_DAYS = 60;

const staleDaysOf = async (uid: string, today: string): Promise<string[]> => {
  const snapshot = await userCollection(uid, USER_COLLECTIONS.dailyFlow)
    .where("date", ">=", addDaysToKey(today, -BACKFILL_DAYS))
    .get();
  return snapshot.docs
    .filter((doc) => typeof doc.get("isActive") !== "boolean" ||
      typeof doc.get("isRestDay") !== "boolean")
    .map((doc) => doc.get("date"))
    .filter((date): date is string => typeof date === "string");
};

export const rolloverFlowDays = onSchedule(
  {schedule: "0,30 * * * *", timeZone: "UTC", timeoutSeconds: 540},
  async () => {
    const now = new Date();
    const offsets = offsetsAtLocalTime(now, ROLLOVER_MINUTE, WINDOW_MINUTES);
    let synced = 0;

    for (let index = 0; index < offsets.length;
      index += MAX_OFFSETS_PER_QUERY) {
      const users = await usersCollection
        .where("utcOffsetMinutes", "in",
          offsets.slice(index, index + MAX_OFFSETS_PER_QUERY))
        .get();

      for (const doc of users.docs) {
        if (!isActiveUser(doc.data())) continue;
        try {
          const today = dayKeyAt(now, offsetOf(doc.data()));
          const stale = await staleDaysOf(doc.id, today);
          await syncActivityDays(
            doc.id,
            [addDaysToKey(today, -1), today, ...stale],
            {restDaysOnly: true},
          );
          synced++;
        } catch (error) {
          logger.error("rolloverFlowDays: user failed", {uid: doc.id, error});
        }
      }
    }
    logger.info("rolloverFlowDays: done", {synced});
  },
);
