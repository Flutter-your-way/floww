import {DocumentData} from "firebase-admin/firestore";
import {
  addDaysToKey,
  dayKeyOfIso,
  listOf,
  numberOf,
  recordOf,
  startOfWeekKey,
  weekdayOfKey,
} from "../common/utils";

const DAYS_PER_WEEK = 7;
const LIMIT_GOAL = "limit";
const BUILD_GOAL = "build";
const DEFAULT_METRIC = "sessions";

export type HabitSource = "manual" | "water" | "workout" | "steps" | "sleep";

export interface HabitSchedule {
  type: "daily" | "weekdays" | "weekly";
  weekdays: number[];
  timesPerWeek: number;
}

export interface HabitDefinition {
  id: string;
  title: string;
  target: number;
  metric: string;
  goal: string;
  source: HabitSource;
  schedule: HabitSchedule;
  createdDay: string;
  archivedDay: string | null;
}

export interface HabitEntry {
  id: string;
  title: string;
  value: number;
  target: number;
  metric: string;
  goal: string;
  due: boolean;
}

export type HabitLogsByDay = Map<string, HabitEntry[]>;

const LEGACY_TITLES: Record<string, string> = {"Sleep 8h": "Sleep"};
const LEGACY_SOURCES: Record<string, HabitSource> = {
  water_intake: "water",
  workout_training: "workout",
  outdoor_walk: "steps",
  sleep: "sleep",
};
const SOURCES: HabitSource[] = ["manual", "water", "workout", "steps", "sleep"];

const scheduleOf = (value: unknown): HabitSchedule => {
  const json = recordOf(value);
  const daily: HabitSchedule = {type: "daily", weekdays: [], timesPerWeek: 7};
  if (json.type === "weekdays") {
    const days = listOf(json.weekdays)
      .filter((day): day is number =>
        typeof day === "number" && day >= 1 && day <= DAYS_PER_WEEK)
      .sort((a, b) => a - b);
    return days.length === 0 || days.length === DAYS_PER_WEEK ?
      daily :
      {type: "weekdays", weekdays: days, timesPerWeek: DAYS_PER_WEEK};
  }
  if (json.type === "weekly") {
    const times = Math.trunc(numberOf(json.timesPerWeek));
    return times <= 0 || times >= DAYS_PER_WEEK ?
      daily :
      {type: "weekly", weekdays: [], timesPerWeek: times};
  }
  return daily;
};

export const definitionOf = (
  json: DocumentData,
  offsetMinutes: number,
): HabitDefinition | null => {
  const createdDay = dayKeyOfIso(json.createdAt, offsetMinutes);
  if (typeof json.id !== "string" || typeof json.title !== "string" ||
    createdDay === null) {
    return null;
  }
  const source = json.source === undefined ?
    LEGACY_SOURCES[json.id] ?? "manual" :
    SOURCES.find((item) => item === json.source) ?? "manual";
  return {
    id: json.id,
    title: LEGACY_TITLES[json.title] ?? json.title,
    target: numberOf(json.target),
    metric: typeof json.metric === "string" ? json.metric : DEFAULT_METRIC,
    goal: json.goalType === LIMIT_GOAL ? LIMIT_GOAL : BUILD_GOAL,
    source,
    schedule: scheduleOf(json.schedule),
    createdDay,
    archivedDay: dayKeyOfIso(json.archivedAt, offsetMinutes),
  };
};

export const entryOf = (json: unknown): HabitEntry | null => {
  const item = recordOf(json);
  if (typeof item.id !== "string" || typeof item.title !== "string") {
    return null;
  }
  return {
    id: item.id,
    title: item.title,
    value: numberOf(item.value),
    target: numberOf(item.target),
    metric: typeof item.metric === "string" ? item.metric : DEFAULT_METRIC,
    goal: item.goal === LIMIT_GOAL ? LIMIT_GOAL : BUILD_GOAL,
    due: typeof item.due === "boolean" ? item.due : true,
  };
};

export const entriesOf = (json: DocumentData | undefined): HabitEntry[] =>
  listOf(json?.entries)
    .map(entryOf)
    .filter((entry): entry is HabitEntry => entry !== null);

export const isLimitEntry = (entry: HabitEntry): boolean =>
  entry.goal === LIMIT_GOAL;

export const isCompletedEntry = (entry: HabitEntry): boolean => {
  if (isLimitEntry(entry)) return entry.value <= entry.target;
  return entry.target > 0 && entry.value >= entry.target;
};

export const progressOf = (entry: HabitEntry): number => {
  if (isLimitEntry(entry)) {
    if (entry.value <= entry.target) return 1;
    if (entry.target <= 0) return 0;
    return Math.min(Math.max(1 - (entry.value - entry.target) /
      entry.target, 0), 1);
  }
  return entry.target <= 0 ?
    0 :
    Math.min(Math.max(entry.value / entry.target, 0), 1);
};

const findEntry = (
  logs: HabitLogsByDay,
  day: string,
  id: string,
): HabitEntry | undefined => logs.get(day)?.find((entry) => entry.id === id);

const notArchivedOn = (definition: HabitDefinition, day: string): boolean =>
  definition.archivedDay === null || day < definition.archivedDay;

const activeOn = (definition: HabitDefinition, day: string): boolean =>
  definition.createdDay <= day && notArchivedOn(definition, day);

const isDueOn = (
  definition: HabitDefinition,
  day: string,
  isCompleted: boolean,
  logs: HabitLogsByDay,
): boolean => {
  const schedule = definition.schedule;
  if (schedule.type === "weekdays") {
    return schedule.weekdays.includes(weekdayOfKey(day));
  }
  if (schedule.type !== "weekly") return true;
  if (isCompleted) return true;

  let done = 0;
  for (let cursor = startOfWeekKey(day); cursor < day;
    cursor = addDaysToKey(cursor, 1)) {
    const entry = findEntry(logs, cursor, definition.id);
    if (entry && isCompletedEntry(entry)) done++;
  }
  if (done >= schedule.timesPerWeek) return false;

  const daysLeft = DAYS_PER_WEEK - weekdayOfKey(day) + 1;
  return daysLeft <= schedule.timesPerWeek - done;
};

export const entryFromDefinition = (
  definition: HabitDefinition,
  day: string,
  value: number,
  logs: HabitLogsByDay,
): HabitEntry => {
  const entry: HabitEntry = {
    id: definition.id,
    title: definition.title,
    value,
    target: definition.target,
    metric: definition.metric,
    goal: definition.goal,
    due: true,
  };
  return {...entry, due: isDueOn(definition, day, isCompletedEntry(entry),
    logs)};
};

export const habitsForDay = (
  definitions: HabitDefinition[],
  logs: HabitLogsByDay,
  day: string,
  today: string,
): HabitEntry[] => {
  const log = logs.get(day);

  if (day >= today) {
    return definitions
      .filter((definition) => notArchivedOn(definition, day))
      .map((definition) => entryFromDefinition(
        definition,
        day,
        log?.find((entry) => entry.id === definition.id)?.value ?? 0,
        logs,
      ));
  }

  if (log && log.length > 0) return log;

  return definitions
    .filter((definition) => activeOn(definition, day))
    .map((definition) => entryFromDefinition(definition, day, 0, logs));
};

export const completionOf = (entries: HabitEntry[]): number => {
  const due = entries.filter((entry) => entry.due);
  if (due.length === 0) return 0;
  return due.reduce((total, entry) => total + progressOf(entry), 0) /
    due.length;
};
