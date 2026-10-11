import {DocumentData} from "firebase-admin/firestore";
import {
  addDaysToKey,
  dayBoundsUtc,
  dayKeyOfIso,
  daysBetweenKeys,
  listOf,
  numberOf,
  recordOf,
  weekdayOfKey,
} from "../common/utils";
import {
  MAX_WAVE_HISTORY_EVENTS,
  MAX_WAVE_HISTORY_LIFTS,
  WAVE_HISTORY_DAYS,
  WAVE_WEIGHT_HISTORY_DAYS,
} from "../constants/ai.constants";
import {
  USER_COLLECTIONS,
  firestore,
  userCollection,
} from "../constants/collections";
import {COMPLETED_STATUS} from "./flow.score.helper";
import {UserClock, clockOf, loadActiveUser} from "./user.clock.helper";
import {WorkoutEntry, entriesOf} from "./workout.metrics.helper";

const WEEK_DAYS = 7;
const MINUTES_PER_HOUR = 60;
const SECONDS_PER_MINUTE = 60;
const ML_PER_LITER = 1000;

const WEEKDAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const MONTHS = [
  "Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
];

const COMPONENTS = [
  ["workout", "workoutScore"],
  ["nutrition", "nutritionScore"],
  ["habits", "habitScore"],
  ["recovery", "readinessScore"],
] as const;

export interface WaveHistoryRecords {
  flows: DocumentData[];
  health: DocumentData[];
  sessions: DocumentData[];
  plans: DocumentData[];
  foods: DocumentData[];
  waters: DocumentData[];
  weights: DocumentData[];
}

interface FoodDay {
  calories: number;
  proteinG: number;
  logs: number;
}

interface HistoryIndex {
  clock: UserClock;
  flows: Map<string, DocumentData>;
  health: Map<string, DocumentData>;
  sessions: Map<string, DocumentData[]>;
  plans: Map<string, DocumentData>;
  foods: Map<string, FoodDay>;
  waters: Map<string, number>;
  weights: DocumentData[];
}

const text = (value: unknown): string =>
  typeof value === "string" ? value.trim() : "";

const sum = (values: number[]): number =>
  values.reduce((total, value) => total + value, 0);

const average = (values: number[]): number =>
  values.length === 0 ? 0 : sum(values) / values.length;

const whole = (value: number): string =>
  Math.round(value).toLocaleString("en-US");

const signed = (value: number, digits = 0): string =>
  `${value > 0 ? "+" : ""}${value.toFixed(digits)}`;

const plural = (count: number, noun: string): string =>
  `${count} ${noun}${count === 1 ? "" : "s"}`;

const dayLabel = (day: string): string =>
  `${WEEKDAYS[weekdayOfKey(day) - 1]} ${day.slice(8, 10)} ` +
  `${MONTHS[Number(day.slice(5, 7)) - 1]}`;

const sleepLabel = (minutes: number): string => {
  const rounded = Math.round(minutes);
  const hours = Math.floor(rounded / MINUTES_PER_HOUR);
  const rest = `${rounded % MINUTES_PER_HOUR}`.padStart(2, "0");
  return `${hours}h${rest}m`;
};

const litersLabel = (ml: number): string =>
  `${(ml / ML_PER_LITER).toFixed(1)}L`;

const section = (title: string, rows: (string | null)[]): string => {
  const body = rows.filter((row): row is string => !!row && row.length > 0);
  return body.length > 0 ? `${title}\n${body.join("\n")}` : "";
};

const daysFrom = (from: string, count: number): string[] =>
  Array.from({length: count}, (_, index) => addDaysToKey(from, index));

const isCompleted = (session: DocumentData): boolean =>
  session.status === COMPLETED_STATUS;

const hasExercises = (plan: DocumentData): boolean =>
  listOf(plan.exercises).length > 0;

const groupBy = <T>(items: T[], keyOf: (item: T) => string | null) => {
  const groups = new Map<string, T[]>();
  for (const item of items) {
    const key = keyOf(item);
    if (key === null) continue;
    groups.set(key, [...(groups.get(key) ?? []), item]);
  }
  return groups;
};

const byDate = (items: DocumentData[]): Map<string, DocumentData> =>
  new Map(items
    .filter((item) => typeof item.date === "string")
    .map((item) => [item.date as string, item]));

const indexOf = (
  records: WaveHistoryRecords,
  clock: UserClock,
): HistoryIndex => {
  const dayOf = (item: DocumentData) =>
    dayKeyOfIso(item.loggedAt, clock.offsetMinutes);

  const foods = new Map<string, FoodDay>();
  for (const [day, logs] of groupBy(records.foods, dayOf)) {
    const macros = logs.map((log) =>
      recordOf(recordOf(log.nutrition).macros));
    foods.set(day, {
      calories: sum(macros.map((item) => numberOf(item.calories))),
      proteinG: sum(macros.map((item) => numberOf(item.proteinG))),
      logs: logs.length,
    });
  }

  const waters = new Map<string, number>();
  for (const [day, logs] of groupBy(records.waters, dayOf)) {
    waters.set(day, sum(logs.map((log) => numberOf(log.amountMl))));
  }

  return {
    clock,
    flows: byDate(records.flows),
    health: byDate(records.health),
    sessions: groupBy(
      records.sessions.filter(isCompleted),
      (session) => typeof session.date === "string" ? session.date : null,
    ),
    plans: byDate(records.plans),
    foods,
    waters,
    weights: records.weights
      .filter((log) => numberOf(log.weightKg) > 0 &&
        typeof log.loggedAt === "string")
      .sort((a, b) => a.loggedAt.localeCompare(b.loggedAt)),
  };
};

const scoreOf = (flow: DocumentData | undefined): number =>
  numberOf(flow?.score);

const scorePart = (flow: DocumentData | undefined): string | null => {
  if (!flow || scoreOf(flow) <= 0) return null;
  const parts = COMPONENTS
    .map(([label, field]) => `${label} ${Math.round(numberOf(flow[field]))}%`)
    .join(", ");
  return `score ${Math.round(scoreOf(flow))} (${parts})`;
};

const healthParts = (health: DocumentData | undefined): string[] => {
  if (!health) return [];
  const sleep = numberOf(health.sleepMinutes);
  const hrv = numberOf(health.hrvMs);
  const rhr = numberOf(health.restingHeartRate);
  const steps = numberOf(health.steps);
  return [
    sleep > 0 ? `slept ${sleepLabel(sleep)}` : "",
    hrv > 0 ? `HRV ${Math.round(hrv)}ms` : "",
    rhr > 0 ? `resting HR ${Math.round(rhr)}` : "",
    steps > 0 ? `${whole(steps)} steps` : "",
  ].filter((part) => part.length > 0);
};

const trainingPart = (index: HistoryIndex, day: string): string | null => {
  const sessions = index.sessions.get(day) ?? [];
  if (sessions.length > 0) {
    const names = sessions.map((session) => text(session.name)).join(", ");
    const sets = sum(sessions.map((session) => numberOf(session.totalSets)));
    return `trained ${names} (${plural(sets, "set")})`;
  }

  const plan = index.plans.get(day);
  if (!plan || !hasExercises(plan)) return null;
  const moved = text(plan.rescheduledTo);
  return moved.length > 0 ?
    `moved ${text(plan.name)} to ${dayLabel(moved)}` :
    `missed planned ${text(plan.name)}`;
};

const dayParts = (index: HistoryIndex, day: string): string[] => {
  const food = index.foods.get(day);
  const water = index.waters.get(day) ?? 0;
  return [
    scorePart(index.flows.get(day)),
    food ?
      `${whole(food.calories)} kcal, ${Math.round(food.proteinG)}g protein ` +
        `(${plural(food.logs, "food log")})` :
      null,
    water > 0 ? `${litersLabel(water)} water` : null,
    ...healthParts(index.health.get(day)),
    trainingPart(index, day),
  ].filter((part): part is string => !!part);
};

const dayRows = (index: HistoryIndex, week: string[]): string[] => {
  const days = week.map((day) => ({day, parts: dayParts(index, day)}));
  if (days.every(({parts}) => parts.length === 0)) {
    return ["Nothing logged in the last 7 days."];
  }
  return days.map(({day, parts}) => `${dayLabel(day)}: ${parts.length > 0 ?
    parts.join(" · ") :
    "nothing logged"}`);
};

const todayRow = (index: HistoryIndex): string | null => {
  const today = index.clock.today;
  const parts = [
    scorePart(index.flows.get(today)),
    ...healthParts(index.health.get(today)),
  ].filter((part): part is string => !!part);
  return parts.length > 0 ? `Today so far: ${parts.join(" · ")}` : null;
};

const activeScores = (index: HistoryIndex, days: string[]): number[] =>
  days.map((day) => scoreOf(index.flows.get(day))).filter((score) => score > 0);

const scoreTrend = (
  index: HistoryIndex,
  week: string[],
  previous: string[],
): string | null => {
  const current = activeScores(index, week);
  if (current.length === 0) return null;
  const before = activeScores(index, previous);
  const comparison = before.length > 0 ?
    `; the 7 days before averaged ${Math.round(average(before))} ` +
      `over ${before.length} active` :
    "";
  return `Flow Score: avg ${Math.round(average(current))} over ` +
    `${current.length} of 7 active days${comparison}`;
};

const componentTrend = (index: HistoryIndex, week: string[]) => {
  const flows = week
    .map((day) => index.flows.get(day))
    .filter((flow): flow is DocumentData => scoreOf(flow) > 0);
  if (flows.length === 0) return null;
  const ranked = COMPONENTS
    .map(([label, field]) => ({
      label,
      value: Math.round(average(flows.map((flow) => numberOf(flow[field])))),
    }))
    .sort((a, b) => a.value - b.value);
  const weakest = ranked[0];
  const strongest = ranked[ranked.length - 1];
  return `Weakest score part this week: ${weakest.label} ` +
    `(avg ${weakest.value}%); strongest: ${strongest.label} ` +
    `(avg ${strongest.value}%)`;
};

const healthValues = (
  index: HistoryIndex,
  days: string[],
  field: string,
): number[] =>
  days
    .map((day) => numberOf(index.health.get(day)?.[field]))
    .filter((value) => value > 0);

const sleepTrend = (index: HistoryIndex, week: string[]): string | null => {
  const nights = healthValues(index, week, "sleepMinutes");
  if (nights.length === 0) return null;
  return `Sleep: avg ${sleepLabel(average(nights))} over ` +
    `${plural(nights.length, "night")}, shortest ` +
    `${sleepLabel(Math.min(...nights))}`;
};

const heartTrend = (
  index: HistoryIndex,
  week: string[],
  all: string[],
): string | null => {
  const hrv = healthValues(index, week, "hrvMs");
  const hrvBaseline = healthValues(index, all, "hrvMs");
  const rhr = healthValues(index, week, "restingHeartRate");
  const rhrBaseline = healthValues(index, all, "restingHeartRate");
  const parts = [
    hrv.length > 0 ?
      `HRV avg ${Math.round(average(hrv))}ms (14-day avg ` +
        `${Math.round(average(hrvBaseline))}ms)` :
      "",
    rhr.length > 0 ?
      `resting HR avg ${Math.round(average(rhr))} (14-day avg ` +
        `${Math.round(average(rhrBaseline))})` :
      "",
  ].filter((part) => part.length > 0);
  return parts.length > 0 ? `Heart: ${parts.join(" · ")}` : null;
};

const stepsTrend = (index: HistoryIndex, week: string[]): string | null => {
  const steps = healthValues(index, week, "steps");
  if (steps.length === 0) return null;
  return `Steps: avg ${whole(average(steps))}/day over ` +
    `${plural(steps.length, "day")}`;
};

const nutritionTrend = (index: HistoryIndex, week: string[]) => {
  const days = week
    .map((day) => index.foods.get(day))
    .filter((day): day is FoodDay => day !== undefined);
  const water = week.map((day) => index.waters.get(day) ?? 0);
  const rows = [
    days.length > 0 ?
      `Food logged on ${days.length} of 7 days: avg ` +
        `${whole(average(days.map((day) => day.calories)))} kcal and ` +
        `${Math.round(average(days.map((day) => day.proteinG)))}g protein ` +
        "on logged days" :
      "No food logged in the last 7 days",
    sum(water) > 0 ?
      `Water: avg ${litersLabel(average(water))}/day across all 7 days` :
      null,
  ];
  return rows.filter((row): row is string => row !== null).join("\n");
};

const weightTrend = (index: HistoryIndex): string | null => {
  const weights = index.weights;
  if (weights.length === 0) return null;
  const first = weights[0];
  const latest = weights[weights.length - 1];
  const latestDay = dayKeyOfIso(latest.loggedAt, index.clock.offsetMinutes);
  const firstDay = dayKeyOfIso(first.loggedAt, index.clock.offsetMinutes);
  const latestKg = numberOf(latest.weightKg);
  const base = `Weight: ${latestKg.toFixed(1)}kg` +
    (latestDay ? ` on ${dayLabel(latestDay)}` : "");
  if (weights.length === 1 || !firstDay) return base;
  const change = latestKg - numberOf(first.weightKg);
  return `${base}, ${signed(change, 1)}kg since ${dayLabel(firstDay)} ` +
    `(${plural(weights.length, "log")} in 30 days)`;
};

const sessionsIn = (index: HistoryIndex, days: string[]): DocumentData[] =>
  days.flatMap((day) => index.sessions.get(day) ?? []);

const volumeLabel = (sessions: DocumentData[]): string =>
  `${whole(sum(sessions.map((session) => numberOf(session.volumeKg))))}kg ` +
  `volume, ${plural(sum(sessions.map((s) => numberOf(s.totalSets))), "set")}`;

const sessionTrend = (
  index: HistoryIndex,
  week: string[],
  previous: string[],
): string => {
  const current = sessionsIn(index, week);
  const before = sessionsIn(index, previous);
  return `Sessions: ${current.length} in the last 7 days` +
    (current.length > 0 ? ` (${volumeLabel(current)})` : "") +
    `; ${before.length} the 7 days before` +
    (before.length > 0 ? ` (${volumeLabel(before)})` : "");
};

const adherenceOf = (index: HistoryIndex, days: string[]): string | null => {
  const planned = days.filter((day) => {
    const plan = index.plans.get(day);
    return plan !== undefined && hasExercises(plan);
  });
  if (planned.length === 0) return null;

  const missed = planned.filter((day) =>
    (index.sessions.get(day) ?? []).length === 0);
  const done = planned.length - missed.length;
  const list = missed
    .slice(-MAX_WAVE_HISTORY_EVENTS)
    .map((day) => {
      const plan = index.plans.get(day) ?? {};
      const moved = text(plan.rescheduledTo);
      return `${text(plan.name)} (${dayLabel(day)}` +
        `${moved.length > 0 ? `, moved to ${dayLabel(moved)}` : ""})`;
    })
    .join(", ");

  return `Plan adherence, last 14 days: ${done} of ${planned.length} ` +
    "planned sessions done on their day" +
    (missed.length > 0 ? `; not done: ${list}` : "");
};

const sessionsNewestFirst = (index: HistoryIndex): DocumentData[] =>
  [...index.sessions.values()].flat().sort((a, b) =>
    `${b.date}${text(b.completedAt)}`.localeCompare(
      `${a.date}${text(a.completedAt)}`));

const recordsOf = (sessions: DocumentData[]): string | null => {
  const records = sessions.flatMap((session) =>
    listOf(session.personalRecords).map((record) => {
      const json = recordOf(record);
      return `${text(json.exercise)} ${text(json.improvement)} ` +
        `(${dayLabel(session.date)})`;
    }));
  if (records.length === 0) return null;
  return `Recent PRs: ${records.slice(0, MAX_WAVE_HISTORY_EVENTS).join(", ")}`;
};

const lastSessionOf = (sessions: DocumentData[]): string | null => {
  const last = sessions[0];
  if (!last) return null;
  const minutes = Math.round(
    numberOf(last.durationSeconds) / SECONDS_PER_MINUTE,
  );
  const mood = text(last.recoveryMood);
  const parts = [
    `${text(last.name)} on ${dayLabel(last.date)}`,
    minutes > 0 ? `${minutes} min` : "",
    plural(numberOf(last.totalSets), "set"),
    numberOf(last.volumeKg) > 0 ? `${whole(numberOf(last.volumeKg))}kg` : "",
    mood.length > 0 ? `felt ${mood}` : "",
  ].filter((part) => part.length > 0);
  return `Last session: ${parts.join(" · ")}`;
};

const topSetOf = (entry: WorkoutEntry): string | null => {
  const sets = entry.sets.filter((set) =>
    set.isWorking && (set.reps > 0 || (set.durationSeconds ?? 0) > 0));
  if (sets.length === 0) return null;

  if (entry.isTimed) {
    return `${Math.max(...sets.map((set) => set.durationSeconds ?? 0))}s`;
  }

  const weighted = sets.filter((set) => (set.weightKg ?? 0) > 0);
  if (weighted.length > 0) {
    const top = weighted.reduce((best, set) =>
      (set.weightKg ?? 0) > (best.weightKg ?? 0) ||
        ((set.weightKg ?? 0) === (best.weightKg ?? 0) && set.reps > best.reps) ?
        set :
        best);
    return `${top.weightKg}kg x ${top.reps} ` +
      `(${plural(weighted.length, "working set")})`;
  }

  return `${Math.max(...sets.map((set) => set.reps))} reps`;
};

const recentLiftsOf = (sessions: DocumentData[]): string | null => {
  const lifts = new Map<string, string>();
  for (const session of sessions) {
    for (const entry of entriesOf(session.exercises)) {
      if (lifts.size >= MAX_WAVE_HISTORY_LIFTS) break;
      const key = entry.exerciseId || entry.name;
      if (key.length === 0 || lifts.has(key)) continue;
      const top = topSetOf(entry);
      if (!top) continue;
      lifts.set(key, `- ${entry.name}: ${top}, ${dayLabel(session.date)}`);
    }
  }
  if (lifts.size === 0) return null;
  return "Recent lifts, best set of the latest session per exercise:\n" +
    [...lifts.values()].join("\n");
};

export const buildWaveHistory = (
  records: WaveHistoryRecords,
  clock: UserClock,
): string => {
  const index = indexOf(records, clock);
  const week = daysFrom(addDaysToKey(clock.today, -WEEK_DAYS), WEEK_DAYS);
  const previous = daysFrom(
    addDaysToKey(clock.today, -WAVE_HISTORY_DAYS),
    WAVE_HISTORY_DAYS - WEEK_DAYS,
  );
  const all = [...previous, ...week];
  const sessions = sessionsNewestFirst(index);

  return [
    section(
      "[LAST 7 DAYS] logged history, oldest first. Score parts are % of " +
        "each part's maximum.",
      [...dayRows(index, week), todayRow(index)],
    ),
    section("[TRENDS]", [
      scoreTrend(index, week, previous),
      componentTrend(index, week),
      sleepTrend(index, week),
      heartTrend(index, week, all),
      stepsTrend(index, week),
      nutritionTrend(index, week),
      weightTrend(index),
    ]),
    section("[TRAINING]", [
      sessionTrend(index, week, previous),
      adherenceOf(index, all),
      lastSessionOf(sessions),
      recordsOf(sessions),
      recentLiftsOf(sessions),
    ]),
  ].filter((part) => part.length > 0).join("\n\n");
};

const readHistory = async (
  uid: string,
  clock: UserClock,
): Promise<WaveHistoryRecords> => {
  const collection = (
    name: typeof USER_COLLECTIONS[keyof typeof USER_COLLECTIONS],
  ) => userCollection(uid, name);
  const from = addDaysToKey(clock.today, -WAVE_HISTORY_DAYS);
  const logsFrom = dayBoundsUtc(
    addDaysToKey(clock.today, -WEEK_DAYS),
    clock.offsetMinutes,
  ).start;
  const logsTo = dayBoundsUtc(clock.today, clock.offsetMinutes).start;
  const weightFrom = dayBoundsUtc(
    addDaysToKey(clock.today, -WAVE_WEIGHT_HISTORY_DAYS),
    clock.offsetMinutes,
  ).start;
  const healthRefs = daysFrom(from, daysBetweenKeys(from, clock.today) + 1)
    .map((day) => collection(USER_COLLECTIONS.healthLogs).doc(day));

  const [flows, health, sessions, plans, foods, waters, weights] =
    await Promise.all([
      collection(USER_COLLECTIONS.dailyFlow)
        .where("date", ">=", from)
        .where("date", "<=", clock.today)
        .get(),
      firestore.getAll(...healthRefs),
      collection(USER_COLLECTIONS.workoutSessions)
        .where("date", ">=", from)
        .where("date", "<=", clock.today)
        .select(
          "date", "status", "name", "completedAt", "durationSeconds",
          "totalSets", "volumeKg", "personalRecords", "recoveryMood",
          "exercises",
        )
        .get(),
      collection(USER_COLLECTIONS.workoutPlans)
        .where("date", ">=", from)
        .where("date", "<", clock.today)
        .select("date", "name", "exercises", "rescheduledTo")
        .get(),
      collection(USER_COLLECTIONS.foodLogs)
        .where("loggedAt", ">=", logsFrom)
        .where("loggedAt", "<", logsTo)
        .select("loggedAt", "nutrition.macros")
        .get(),
      collection(USER_COLLECTIONS.waterLogs)
        .where("loggedAt", ">=", logsFrom)
        .where("loggedAt", "<", logsTo)
        .select("loggedAt", "amountMl")
        .get(),
      collection(USER_COLLECTIONS.weightLogs)
        .where("loggedAt", ">=", weightFrom)
        .select("loggedAt", "weightKg")
        .get(),
    ]);

  return {
    flows: flows.docs.map((doc) => doc.data()),
    health: health
      .filter((doc) => doc.exists)
      .map((doc) => ({...doc.data(), date: doc.id})),
    sessions: sessions.docs.map((doc) => doc.data()),
    plans: plans.docs.map((doc) => doc.data()),
    foods: foods.docs.map((doc) => doc.data()),
    waters: waters.docs.map((doc) => doc.data()),
    weights: weights.docs.map((doc) => doc.data()),
  };
};

export const loadWaveHistory = async (uid: string): Promise<string> => {
  const user = await loadActiveUser(uid);
  if (!user) return "";
  const clock = clockOf(user);
  return buildWaveHistory(await readHistory(uid, clock), clock);
};
