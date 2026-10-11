import {DocumentData} from "firebase-admin/firestore";
import {
  addDaysToKey,
  dayBoundsUtc,
  numberOf,
  recordOf,
  startOfWeekKey,
} from "../common/utils";
import {
  MAX_WAVE_CUSTOM_FOODS,
  MAX_WAVE_LIST_ITEMS,
  MAX_WAVE_LONG_LIST,
  WAVE_RECENT_FOOD_DAYS,
} from "../constants/ai.constants";
import {USER_COLLECTIONS, userCollection} from "../constants/collections";
import {CATALOG_FOOD_NAMES} from "../constants/food.catalog.constants";
import {WaveToday, waveTodayValidator} from "../validators/wave.chat.validator";
import {COMPLETED_STATUS} from "./flow.score.helper";
import {
  HabitDefinition,
  HabitLogsByDay,
  definitionOf,
  entriesOf as habitEntriesOf,
  habitsForDay,
  isCompletedEntry,
} from "./habit.day.helper";
import {statsDoc} from "./stats.helper";
import {UserClock} from "./user.clock.helper";
import {entriesOf as workoutEntriesOf} from "./workout.metrics.helper";

export const WORKOUT_IN_PROGRESS = "in progress";
export const WORKOUT_COMPLETED = "completed today";
export const WORKOUT_PLANNED = "planned, not started";
export const WORKOUT_NONE = "no session planned";

const IN_PROGRESS_STATUS = "inProgress";

export type WaveWorkoutStatus =
  | typeof WORKOUT_IN_PROGRESS
  | typeof WORKOUT_COMPLETED
  | typeof WORKOUT_PLANNED
  | typeof WORKOUT_NONE;

export interface WaveHabitFact {
  title: string;
  done: boolean;
  due: boolean;
  progress: string;
}

export interface WaveFoodFact {
  name: string;
  meal: string;
}

export interface WaveFacts {
  flowScore: number;
  streakDays: number;
  habits: WaveHabitFact[];
  loggedFoods: WaveFoodFact[];
  knownFoods: string[];
  planExercises: string[];
  activeExercises: string[];
  workoutStatus: WaveWorkoutStatus;
  calories: number;
  proteinG: number;
  carbsG: number;
  fatG: number;
  waterMl: number;
}

const text = (value: unknown): string =>
  typeof value === "string" ? value.trim() : "";

const unique = (values: string[]): string[] => {
  const seen = new Set<string>();
  return values.filter((value) => {
    const key = value.toLowerCase();
    if (value.length === 0 || seen.has(key)) return false;
    seen.add(key);
    return true;
  });
};

const amount = (value: number): string =>
  Number.isInteger(value) ? `${value}` : value.toFixed(1);

const habitFactsOf = (
  definitions: HabitDefinition[],
  logs: HabitLogsByDay,
  today: string,
): WaveHabitFact[] =>
  habitsForDay(definitions, logs, today, today).map((entry) => ({
    title: entry.title,
    done: isCompletedEntry(entry),
    due: entry.due,
    progress: `${amount(entry.value)}/${amount(entry.target)} ${entry.metric}`,
  }));

const workoutStatusOf = (
  sessions: DocumentData[],
  planExercises: string[],
): WaveWorkoutStatus => {
  if (sessions.some((session) => session.status === IN_PROGRESS_STATUS)) {
    return WORKOUT_IN_PROGRESS;
  }
  if (sessions.some((session) => session.status === COMPLETED_STATUS)) {
    return WORKOUT_COMPLETED;
  }
  return planExercises.length > 0 ? WORKOUT_PLANNED : WORKOUT_NONE;
};

const exerciseNamesOf = (value: unknown): string[] =>
  unique(workoutEntriesOf(value).map((entry) => text(entry.name)));

export const loadWaveFacts = async (
  uid: string,
  clock: UserClock,
): Promise<WaveFacts> => {
  const collection = (
    name: typeof USER_COLLECTIONS[keyof typeof USER_COLLECTIONS],
  ) => userCollection(uid, name);
  const {today, offsetMinutes} = clock;
  const {start, end} = dayBoundsUtc(today, offsetMinutes);
  const recentStart = dayBoundsUtc(
    addDaysToKey(today, -WAVE_RECENT_FOOD_DAYS),
    offsetMinutes,
  ).start;

  const [
    habits,
    habitLogs,
    foods,
    waters,
    customFoods,
    plan,
    sessions,
    flow,
    stats,
  ] = await Promise.all([
    collection(USER_COLLECTIONS.habits).get(),
    collection(USER_COLLECTIONS.habitLogs)
      .where("date", ">=", startOfWeekKey(today))
      .where("date", "<=", today)
      .get(),
    collection(USER_COLLECTIONS.foodLogs)
      .where("loggedAt", ">=", recentStart)
      .where("loggedAt", "<", end)
      .select("name", "mealType", "loggedAt", "nutrition.macros")
      .get(),
    collection(USER_COLLECTIONS.waterLogs)
      .where("loggedAt", ">=", start)
      .where("loggedAt", "<", end)
      .select("amountMl")
      .get(),
    collection(USER_COLLECTIONS.customFoods)
      .select("name")
      .limit(MAX_WAVE_CUSTOM_FOODS)
      .get(),
    collection(USER_COLLECTIONS.workoutPlans).doc(today).get(),
    collection(USER_COLLECTIONS.workoutSessions)
      .where("date", "==", today)
      .select("status", "exercises")
      .get(),
    collection(USER_COLLECTIONS.dailyFlow).doc(today).get(),
    statsDoc(uid).get(),
  ]);

  const definitions = habits.docs
    .map((doc) => definitionOf(doc.data(), offsetMinutes))
    .filter((item): item is HabitDefinition => item !== null);
  const logs: HabitLogsByDay = new Map();
  for (const doc of habitLogs.docs) {
    const date = doc.get("date");
    if (typeof date === "string") logs.set(date, habitEntriesOf(doc.data()));
  }

  const foodDocs = foods.docs
    .map((doc) => doc.data())
    .sort((a, b) => text(b.loggedAt).localeCompare(text(a.loggedAt)));
  const todayFoods = foodDocs.filter((log) => text(log.loggedAt) >= start);
  const macros = todayFoods.map((log) =>
    recordOf(recordOf(log.nutrition).macros));
  const sum = (field: string) =>
    macros.reduce((total, item) => total + numberOf(item[field]), 0);

  const planData = plan.data();
  const planExercises = planData && text(planData.rescheduledTo).length === 0 ?
    exerciseNamesOf(planData.exercises) :
    [];
  const sessionDocs = sessions.docs.map((doc) => doc.data());
  const active = sessionDocs.find((session) =>
    session.status === IN_PROGRESS_STATUS);

  return {
    flowScore: Math.round(numberOf(flow.get("score"))),
    streakDays: Math.round(numberOf(stats.get("currentStreak"))),
    habits: habitFactsOf(definitions, logs, today),
    loggedFoods: todayFoods
      .map((log) => ({name: text(log.name), meal: text(log.mealType)}))
      .filter((food) => food.name.length > 0),
    knownFoods: unique([
      ...customFoods.docs.map((doc) => text(doc.get("name"))),
      ...foodDocs.map((log) => text(log.name)),
      ...CATALOG_FOOD_NAMES,
    ]),
    planExercises,
    activeExercises: active ? exerciseNamesOf(active.exercises) : [],
    workoutStatus: workoutStatusOf(sessionDocs, planExercises),
    calories: Math.round(sum("calories")),
    proteinG: Math.round(sum("proteinG")),
    carbsG: Math.round(sum("carbsG")),
    fatG: Math.round(sum("fatG")),
    waterMl: Math.round(waters.docs.reduce(
      (total, doc) => total + numberOf(doc.get("amountMl")),
      0,
    )),
  };
};

const matchesActive = (entry: string, names: string[]): boolean => {
  const label = entry.toLowerCase();
  return names.some((name) => label.startsWith(`${name.toLowerCase()}:`));
};

export const mergeWaveToday = (
  client: WaveToday | undefined,
  facts: WaveFacts,
): WaveToday => {
  const base = client ?? waveTodayValidator.parse({});
  const due = facts.habits.filter((habit) => habit.due);
  const pending = due.filter((habit) => !habit.done);
  const active = base.activeExercises.filter((entry) =>
    matchesActive(entry, facts.activeExercises));

  return {
    ...base,
    flowScore: Math.min(facts.flowScore, 100),
    streakDays: facts.streakDays,
    planExercises: facts.planExercises.slice(0, MAX_WAVE_LIST_ITEMS),
    calories: facts.calories,
    proteinG: facts.proteinG,
    carbsG: facts.carbsG,
    fatG: facts.fatG,
    waterMl: facts.waterMl,
    loggedFoods: facts.loggedFoods
      .map((food) => food.meal ? `${food.name} (${food.meal})` : food.name)
      .slice(0, MAX_WAVE_LONG_LIST),
    knownFoods: facts.knownFoods.slice(0, MAX_WAVE_LONG_LIST),
    habitsDone: due.length - pending.length,
    habitsTotal: due.length,
    habits: facts.habits
      .map((habit) =>
        `${habit.title} (${habit.done ? "done" : habit.progress})`)
      .slice(0, MAX_WAVE_LONG_LIST),
    pendingHabits: pending
      .map((habit) => habit.title)
      .slice(0, MAX_WAVE_LIST_ITEMS),
    workoutStatus: facts.workoutStatus,
    activeExercises: facts.workoutStatus !== WORKOUT_IN_PROGRESS ? [] :
      active.length > 0 ? active :
        facts.activeExercises.slice(0, MAX_WAVE_LONG_LIST),
  };
};
