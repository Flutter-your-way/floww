import {
  dayBoundsUtc,
  numberOf,
  startOfWeekKey,
} from "../common/utils";
import {
  USER_COLLECTIONS,
  firestore,
  userCollection,
} from "../constants/collections";
import {
  COMPLETED_STATUS,
  loadHabitDefinitions,
  loadHabitLogs,
} from "./flow.score.helper";
import {
  HabitDefinition,
  completionOf,
  habitsForDay,
} from "./habit.day.helper";
import {clockOf, loadActiveUser} from "./user.clock.helper";

const TOLERANCE = 0.01;
const ML_PER_LITER = 1000;
const SECONDS_PER_MINUTE = 60;
const SECONDS_PER_HOUR = 3600;

interface SourceValues {
  waterLiters: number;
  workoutSeconds: number;
  workoutSessions: number;
}

const valueFor = (
  definition: HabitDefinition,
  values: SourceValues,
): number | null => {
  if (definition.goal === "limit") return null;
  if (definition.source === "water") return values.waterLiters;
  if (definition.source !== "workout") return null;
  if (definition.metric === "minutes") {
    return values.workoutSeconds / SECONDS_PER_MINUTE;
  }
  if (definition.metric === "hours") {
    return values.workoutSeconds / SECONDS_PER_HOUR;
  }
  return values.workoutSessions;
};

export const syncAutoHabits = async (
  uid: string,
  day: string,
): Promise<boolean> => firestore.runTransaction(async (transaction) => {
  const user = await loadActiveUser(uid, transaction);
  if (!user) return false;

  const clock = clockOf(user);
  if (day !== clock.today) return false;

  const definitions = await loadHabitDefinitions(transaction, uid, clock);
  const autoIds = new Set(
    definitions
      .filter((definition) =>
        definition.source === "water" || definition.source === "workout")
      .map((definition) => definition.id),
  );
  if (autoIds.size === 0) return false;

  const {start, end} = dayBoundsUtc(day, clock.offsetMinutes);
  const [logs, waters, sessions] = await Promise.all([
    loadHabitLogs(transaction, uid, startOfWeekKey(day), day),
    transaction.get(
      userCollection(uid, USER_COLLECTIONS.waterLogs)
        .where("loggedAt", ">=", start)
        .where("loggedAt", "<", end),
    ),
    transaction.get(
      userCollection(uid, USER_COLLECTIONS.workoutSessions)
        .where("date", "==", day),
    ),
  ]);

  const completed = sessions.docs.filter(
    (doc) => doc.get("status") === COMPLETED_STATUS,
  );
  const values: SourceValues = {
    waterLiters: waters.docs.reduce(
      (total, doc) => total + numberOf(doc.get("amountMl")),
      0,
    ) / ML_PER_LITER,
    workoutSeconds: completed.reduce(
      (total, doc) => total + numberOf(doc.get("durationSeconds")),
      0,
    ),
    workoutSessions: completed.length,
  };

  const byId = new Map(definitions.map((item) => [item.id, item]));
  let changed = false;
  const entries = habitsForDay(definitions, logs, day, clock.today)
    .map((entry) => {
      const definition = byId.get(entry.id);
      if (!definition || !autoIds.has(entry.id)) return entry;
      const synced = valueFor(definition, values);
      if (synced === null || synced <= entry.value + TOLERANCE) return entry;
      changed = true;
      return {...entry, value: synced};
    });
  if (!changed) return false;

  transaction.set(
    userCollection(uid, USER_COLLECTIONS.habitLogs).doc(day),
    {
      date: day,
      entries,
      completion: completionOf(entries),
      updatedAt: new Date().toISOString(),
    },
  );
  return true;
});
