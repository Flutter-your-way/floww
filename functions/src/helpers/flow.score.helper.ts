import {DocumentData, Transaction} from "firebase-admin/firestore";
import {
  clamp,
  dayBoundsUtc,
  numberOf,
  startOfWeekKey,
} from "../common/utils";
import {USER_COLLECTIONS, userCollection} from "../constants/collections";
import {
  HabitLogsByDay,
  completionOf,
  definitionOf,
  entriesOf,
  habitsForDay,
} from "./habit.day.helper";
import {UserClock} from "./user.clock.helper";

const WORKOUT_WEIGHT = 0.4;
const HABIT_WEIGHT = 0.35;
const NUTRITION_WEIGHT = 0.25;
const TARGET_SETS = 20;
const TARGET_MEALS = 3;
const TARGET_WATER_ML = 2500;
const MEAL_SHARE = 0.7;
const WATER_SHARE = 0.3;

export const COMPLETED_STATUS = "completed";

export interface FlowEntry {
  date: string;
  score: number;
  workoutScore: number;
  habitScore: number;
  nutritionScore: number;
}

export interface DayActivity {
  workoutSets: number;
  habitCompletion: number;
  mealCount: number;
  waterMl: number;
  sessionIds: string[];
}

const percent = (ratio: number): number => clamp(ratio, 0, 1) * 100;

export const emptyFlowEntry = (date: string): FlowEntry => ({
  date,
  score: 0,
  workoutScore: 0,
  habitScore: 0,
  nutritionScore: 0,
});

export const flowEntryOf = (date: string, activity: DayActivity): FlowEntry => {
  const isEmpty = activity.workoutSets === 0 &&
    activity.habitCompletion === 0 &&
    activity.mealCount === 0 &&
    activity.waterMl === 0;
  if (isEmpty) return emptyFlowEntry(date);

  const workout = percent(activity.workoutSets / TARGET_SETS);
  const habit = percent(activity.habitCompletion);
  const nutrition = percent(
    clamp(activity.mealCount / TARGET_MEALS, 0, 1) * MEAL_SHARE +
      clamp(activity.waterMl / TARGET_WATER_ML, 0, 1) * WATER_SHARE,
  );

  return {
    date,
    score: Math.round(
      workout * WORKOUT_WEIGHT +
        habit * HABIT_WEIGHT +
        nutrition * NUTRITION_WEIGHT,
    ),
    workoutScore: Math.round(workout),
    habitScore: Math.round(habit),
    nutritionScore: Math.round(nutrition),
  };
};

export const sameFlowValues = (
  stored: DocumentData | undefined,
  entry: FlowEntry,
): boolean =>
  stored !== undefined &&
  numberOf(stored.score) === entry.score &&
  numberOf(stored.workoutScore) === entry.workoutScore &&
  numberOf(stored.habitScore) === entry.habitScore &&
  numberOf(stored.nutritionScore) === entry.nutritionScore;

export const flowDocOf = (entry: FlowEntry): DocumentData => ({
  ...entry,
  updatedAt: new Date().toISOString(),
});

export const loadHabitLogs = async (
  transaction: Transaction,
  uid: string,
  from: string,
  to: string,
): Promise<HabitLogsByDay> => {
  const snapshot = await transaction.get(
    userCollection(uid, USER_COLLECTIONS.habitLogs)
      .where("date", ">=", from)
      .where("date", "<=", to),
  );
  const logs: HabitLogsByDay = new Map();
  for (const doc of snapshot.docs) {
    const date = doc.get("date");
    if (typeof date === "string") logs.set(date, entriesOf(doc.data()));
  }
  return logs;
};

export const loadHabitDefinitions = async (
  transaction: Transaction,
  uid: string,
  clock: UserClock,
) => {
  const snapshot = await transaction.get(
    userCollection(uid, USER_COLLECTIONS.habits),
  );
  return snapshot.docs
    .map((doc) => definitionOf(doc.data(), clock.offsetMinutes))
    .filter((item) => item !== null);
};

export const readDayActivity = async (
  transaction: Transaction,
  uid: string,
  day: string,
  clock: UserClock,
): Promise<DayActivity> => {
  const {start, end} = dayBoundsUtc(day, clock.offsetMinutes);

  const [sessions, foods, waters, definitions, logs] = await Promise.all([
    transaction.get(
      userCollection(uid, USER_COLLECTIONS.workoutSessions)
        .where("date", "==", day),
    ),
    transaction.get(
      userCollection(uid, USER_COLLECTIONS.foodLogs)
        .where("loggedAt", ">=", start)
        .where("loggedAt", "<", end),
    ),
    transaction.get(
      userCollection(uid, USER_COLLECTIONS.waterLogs)
        .where("loggedAt", ">=", start)
        .where("loggedAt", "<", end),
    ),
    loadHabitDefinitions(transaction, uid, clock),
    loadHabitLogs(transaction, uid, startOfWeekKey(day), day),
  ]);

  const completed = sessions.docs.filter(
    (doc) => doc.get("status") === COMPLETED_STATUS,
  );

  return {
    workoutSets: completed.reduce(
      (total, doc) => total + numberOf(doc.get("totalSets")),
      0,
    ),
    habitCompletion: completionOf(
      habitsForDay(definitions, logs, day, clock.today),
    ),
    mealCount: foods.size,
    waterMl: waters.docs.reduce(
      (total, doc) => total + numberOf(doc.get("amountMl")),
      0,
    ),
    sessionIds: completed.map((doc) => doc.id),
  };
};
