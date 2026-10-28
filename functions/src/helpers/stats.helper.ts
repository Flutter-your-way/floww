import {
  addDaysToKey,
  daysBetweenKeys,
  numberOf,
} from "../common/utils";
import {
  STATS_DOC,
  USER_COLLECTIONS,
  userCollection,
} from "../constants/collections";
import {UserClock} from "./user.clock.helper";

const HISTORY_DAYS = 400;
const WEEK_DAYS = 7;
const COMPLETED_DAY_SCORE = 70;

export interface FlowStats {
  currentStreak: number;
  longestStreak: number;
  weeklyAverage: number;
  monthActiveDays: number;
  completedDays: number;
  todayScore: number;
  lastActiveDay: string | null;
  today: string;
  updatedAt: string;
}

export const statsDoc = (uid: string) =>
  userCollection(uid, USER_COLLECTIONS.stats).doc(STATS_DOC);

export type StreakDay = "active" | "rest";

export const currentStreakOf = (
  days: Map<string, StreakDay>,
  today: string,
): number => {
  let cursor = days.get(today) === "active" ?
    today :
    addDaysToKey(today, -1);
  let streak = 0;
  for (let kind = days.get(cursor); kind !== undefined;
    kind = days.get(cursor)) {
    if (kind === "active") streak++;
    cursor = addDaysToKey(cursor, -1);
  }
  return streak;
};

export const longestStreakOf = (days: Map<string, StreakDay>): number => {
  let longest = 0;
  let running = 0;
  let previous: string | null = null;
  for (const day of [...days.keys()].sort()) {
    if (previous === null || daysBetweenKeys(previous, day) !== 1) running = 0;
    if (days.get(day) === "active") running++;
    longest = Math.max(longest, running);
    previous = day;
  }
  return longest;
};

export const refreshFlowStats = async (
  uid: string,
  clock: UserClock,
): Promise<FlowStats> => {
  const from = addDaysToKey(clock.today, -HISTORY_DAYS);
  const [history, stored] = await Promise.all([
    userCollection(uid, USER_COLLECTIONS.dailyFlow)
      .where("date", ">=", from)
      .get(),
    statsDoc(uid).get(),
  ]);

  const scores = new Map<string, number>();
  const streakDays = new Map<string, StreakDay>();
  let todayScore = 0;
  for (const doc of history.docs) {
    const date = doc.get("date");
    if (typeof date !== "string" || date > clock.today) continue;
    if (date === clock.today) todayScore = numberOf(doc.get("score"));
    const isActive = doc.get("isActive");
    const hasActivity = typeof isActive === "boolean" ?
      isActive :
      numberOf(doc.get("workoutScore")) > 0 ||
        numberOf(doc.get("habitScore")) > 0 ||
        numberOf(doc.get("nutritionScore")) > 0;
    if (hasActivity) scores.set(date, numberOf(doc.get("score")));
    if (hasActivity) {
      streakDays.set(date, "active");
    } else if (doc.get("isRestDay") === true) {
      streakDays.set(date, "rest");
    }
  }

  const weekFrom = addDaysToKey(clock.today, -(WEEK_DAYS - 1));
  const monthPrefix = clock.today.slice(0, 7);
  let weekTotal = 0;
  let weekDays = 0;
  let monthActiveDays = 0;
  let completedDays = 0;
  let lastActiveDay: string | null = null;
  for (const [day, score] of scores) {
    if (score <= 0) continue;
    if (day >= weekFrom) {
      weekTotal += score;
      weekDays++;
    }
    if (day.startsWith(monthPrefix)) monthActiveDays++;
    if (score >= COMPLETED_DAY_SCORE) completedDays++;
    if (lastActiveDay === null || day > lastActiveDay) lastActiveDay = day;
  }

  const stats: FlowStats = {
    currentStreak: currentStreakOf(streakDays, clock.today),
    longestStreak: Math.max(
      longestStreakOf(streakDays),
      numberOf(stored.get("longestStreak")),
    ),
    weeklyAverage: weekDays === 0 ? 0 : Math.round(weekTotal / weekDays),
    monthActiveDays,
    completedDays,
    todayScore,
    lastActiveDay,
    today: clock.today,
    updatedAt: new Date().toISOString(),
  };

  await statsDoc(uid).set(stats);
  return stats;
};
