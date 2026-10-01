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
import {
  entriesOf as workoutEntriesOf,
  plannedSetsOf,
} from "./workout.metrics.helper";

const WORKOUT_POINTS = 35;
const NUTRITION_POINTS = 25;
const HABIT_POINTS = 20;
const RECOVERY_POINTS = 20;
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
  readinessScore: number;
}

export interface DayActivity {
  workoutSets: number;
  workoutPlannedSets: number;
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
  readinessScore: 0,
});

const pointsOf = (maxPoints: number, percentValue: number): number =>
  Math.round(maxPoints * clamp(percentValue, 0, 100) / 100);

export const workoutTargetOf = (plannedSets: number): number =>
  plannedSets > 0 ? plannedSets : TARGET_SETS;

export const sessionPlannedSetsOf = (session: DocumentData): number => {
  const stored = numberOf(session.plannedSets);
  if (stored > 0) return stored;
  return plannedSetsOf(workoutEntriesOf(session.exercises));
};

export const flowEntryOf = (
  date: string,
  activity: DayActivity,
  readiness = 0,
): FlowEntry => {
  const workout = Math.round(percent(
    activity.workoutSets / workoutTargetOf(activity.workoutPlannedSets),
  ));
  const habit = Math.round(percent(activity.habitCompletion));
  const nutrition = Math.round(percent(
    clamp(activity.mealCount / TARGET_MEALS, 0, 1) * MEAL_SHARE +
      clamp(activity.waterMl / TARGET_WATER_ML, 0, 1) * WATER_SHARE,
  ));

  return {
    date,
    score: clamp(
      pointsOf(WORKOUT_POINTS, workout) +
        pointsOf(NUTRITION_POINTS, nutrition) +
        pointsOf(HABIT_POINTS, habit) +
        pointsOf(RECOVERY_POINTS, readiness),
      0,
      100,
    ),
    readinessScore: readiness,
    workoutScore: workout,
    habitScore: habit,
    nutritionScore: nutrition,
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
  numberOf(stored.nutritionScore) === entry.nutritionScore &&
  numberOf(stored.readinessScore) === entry.readinessScore;

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
    workoutPlannedSets: completed.reduce(
      (total, doc) => total + sessionPlannedSetsOf(doc.data()),
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
