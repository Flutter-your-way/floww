import {DocumentData} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {onDocumentWritten} from "firebase-functions/firestore";
import {dayKeyOfIso, isDayKey, numberOf} from "../common/utils";
import {COMPLETED_STATUS} from "../helpers/flow.score.helper";
import {syncActivityDays} from "../helpers/flow.sync.helper";
import {clockOf, loadActiveUser} from "../helpers/user.clock.helper";

const USER_PATH = "users/{uid}";

const loggedDaysOf = async (
  uid: string,
  documents: (DocumentData | undefined)[],
): Promise<string[]> => {
  const user = await loadActiveUser(uid);
  if (!user) return [];
  const {offsetMinutes} = clockOf(user);
  return documents
    .map((data) => dayKeyOfIso(data?.loggedAt ?? data?.createdAt,
      offsetMinutes))
    .filter((day): day is string => day !== null);
};

const sameLog = (
  before: DocumentData | undefined,
  after: DocumentData | undefined,
): boolean =>
  before !== undefined &&
  after !== undefined &&
  before.loggedAt === after.loggedAt &&
  numberOf(before.amountMl) === numberOf(after.amountMl);

export const onFoodLogWritten = onDocumentWritten(
  `${USER_PATH}/food_logs/{logId}`,
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (sameLog(before, after)) return;
    const uid = event.params.uid;
    await syncActivityDays(uid, await loggedDaysOf(uid, [before, after]));
  },
);

export const onWaterLogWritten = onDocumentWritten(
  `${USER_PATH}/water_logs/{logId}`,
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (sameLog(before, after)) return;
    const uid = event.params.uid;
    await syncActivityDays(
      uid,
      await loggedDaysOf(uid, [before, after]),
      {autoHabits: true},
    );
  },
);

const sessionChanged = (
  before: DocumentData | undefined,
  after: DocumentData | undefined,
): boolean => {
  const wasCompleted = before?.status === COMPLETED_STATUS;
  const isCompleted = after?.status === COMPLETED_STATUS;
  if (!wasCompleted && !isCompleted) return false;
  if (wasCompleted !== isCompleted) return true;
  return before?.date !== after?.date ||
    numberOf(before?.totalSets) !== numberOf(after?.totalSets) ||
    numberOf(before?.plannedSets) !== numberOf(after?.plannedSets) ||
    numberOf(before?.durationSeconds) !== numberOf(after?.durationSeconds);
};

export const onWorkoutSessionWritten = onDocumentWritten(
  `${USER_PATH}/workout_sessions/{sessionId}`,
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!sessionChanged(before, after)) return;
    const days = [before?.date, after?.date].filter(isDayKey);
    await syncActivityDays(event.params.uid, days, {autoHabits: true});
  },
);

export const onHabitLogWritten = onDocumentWritten(
  `${USER_PATH}/habit_logs/{dayId}`,
  async (event) => {
    const day = event.params.dayId;
    if (!isDayKey(day)) return;
    const before = JSON.stringify(event.data?.before.get("entries") ?? null);
    const after = JSON.stringify(event.data?.after.get("entries") ?? null);
    if (before === after) return;
    await syncActivityDays(event.params.uid, [day]);
  },
);

export const onHabitWritten = onDocumentWritten(
  `${USER_PATH}/habits/{habitId}`,
  async (event) => {
    const uid = event.params.uid;
    const user = await loadActiveUser(uid);
    if (!user) return;
    try {
      await syncActivityDays(uid, [clockOf(user).today], {autoHabits: true});
    } catch (error) {
      logger.error("onHabitWritten: sync failed", {uid, error});
    }
  },
);
