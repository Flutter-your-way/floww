import {
  addDaysToKey,
  dayBoundsUtc,
  dayKeyAt,
  dayKeyOfIso,
  listOf,
  numberOf,
  recordOf,
} from "../common/utils";
import {
  FITBIT_API,
  KJ_PER_KCAL,
  OURA_API,
  OURA_IGNORED_SLEEP_TYPES,
  WHOOP_API,
  WHOOP_MAX_PAGES,
  WHOOP_PAGE_LIMIT,
} from "../constants/wearable.constants";
import {WearableDay, WearableDays} from "../models/wearable.model";
import {wearableGetJson} from "./wearable.http.helper";

const MS_PER_MINUTE = 60_000;
const SECONDS_PER_MINUTE = 60;

type JsonRecord = Record<string, unknown>;

const dayOf = (days: WearableDays, key: string | null): WearableDay | null =>
  key !== null && key in days ? days[key] : null;

const emptyDays = (dayKeys: string[]): WearableDays =>
  Object.fromEntries(dayKeys.map((key) => [key, {}]));

const add = (current: number | undefined, value: number): number =>
  (current ?? 0) + value;

const positive = (value: unknown): number | undefined => {
  const number = numberOf(value);
  return number > 0 ? number : undefined;
};

const whoopRecords = async (
  path: string,
  accessToken: string,
  start: string,
  end: string,
): Promise<JsonRecord[]> => {
  const records: JsonRecord[] = [];
  let nextToken: string | undefined;
  for (let page = 0; page < WHOOP_MAX_PAGES; page++) {
    const params = new URLSearchParams({
      start,
      end,
      limit: String(WHOOP_PAGE_LIMIT),
    });
    if (nextToken) params.set("nextToken", nextToken);
    const json = await wearableGetJson<JsonRecord>(
      "whoop",
      `${WHOOP_API}${path}?${params.toString()}`,
      accessToken,
    );
    records.push(...listOf(json.records).map(recordOf));
    nextToken = typeof json.next_token === "string" && json.next_token ?
      json.next_token :
      undefined;
    if (!nextToken) break;
  }
  return records;
};

const isScored = (record: JsonRecord): boolean =>
  record.score_state === undefined || record.score_state === "SCORED";

export const fetchWhoopDays = async (
  accessToken: string,
  dayKeys: string[],
  offsetMinutes: number,
): Promise<WearableDays> => {
  const days = emptyDays(dayKeys);
  const start = dayBoundsUtc(dayKeys[0], offsetMinutes).start;
  const end = dayBoundsUtc(dayKeys[dayKeys.length - 1], offsetMinutes).end;

  const [recoveries, sleeps, workouts] = await Promise.all([
    whoopRecords("/recovery", accessToken, start, end),
    whoopRecords("/activity/sleep", accessToken, start, end),
    whoopRecords("/activity/workout", accessToken, start, end),
  ]);

  for (const record of recoveries.filter(isScored)) {
    const day = dayOf(days, dayKeyOfIso(record.created_at, offsetMinutes));
    if (!day) continue;
    const score = recordOf(record.score);
    day.restingHeartRate = positive(score.resting_heart_rate) ??
      day.restingHeartRate;
    day.hrvMs = positive(score.hrv_rmssd_milli) ?? day.hrvMs;
  }

  for (const record of sleeps.filter(isScored)) {
    const day = dayOf(days, dayKeyOfIso(record.end, offsetMinutes));
    if (!day) continue;
    const stages = recordOf(recordOf(record.score).stage_summary);
    const asleepMs = numberOf(stages.total_in_bed_time_milli) -
      numberOf(stages.total_awake_time_milli);
    if (asleepMs > 0) {
      day.sleepMinutes = add(day.sleepMinutes, asleepMs / MS_PER_MINUTE);
    }
  }

  for (const record of workouts) {
    const day = dayOf(days, dayKeyOfIso(record.start, offsetMinutes));
    if (!day) continue;
    day.workoutCount = add(day.workoutCount, 1);
    const kilojoule = numberOf(recordOf(record.score).kilojoule);
    if (kilojoule > 0) {
      day.activeCaloriesKcal = add(
        day.activeCaloriesKcal,
        kilojoule / KJ_PER_KCAL,
      );
    }
  }

  return days;
};

const ouraData = async (
  path: string,
  accessToken: string,
  startDate: string,
  endDate: string,
): Promise<JsonRecord[]> => {
  const params = new URLSearchParams({
    start_date: startDate,
    end_date: endDate,
  });
  const json = await wearableGetJson<JsonRecord>(
    "oura",
    `${OURA_API}${path}?${params.toString()}`,
    accessToken,
  );
  return listOf(json.data).map(recordOf);
};

export const fetchOuraDays = async (
  accessToken: string,
  dayKeys: string[],
): Promise<WearableDays> => {
  const days = emptyDays(dayKeys);
  const startDate = dayKeys[0];
  const endDate = addDaysToKey(dayKeys[dayKeys.length - 1], 1);

  const [activities, sleeps, workouts] = await Promise.all([
    ouraData("/daily_activity", accessToken, startDate, endDate),
    ouraData("/sleep", accessToken, startDate, endDate),
    ouraData("/workout", accessToken, startDate, endDate),
  ]);

  for (const record of activities) {
    const day = dayOf(days, typeof record.day === "string" ? record.day : null);
    if (!day) continue;
    day.steps = positive(record.steps);
    day.activeCaloriesKcal = positive(record.active_calories);
  }

  const mainSleepSeconds: Record<string, number> = {};
  for (const record of sleeps) {
    const key = typeof record.day === "string" ? record.day : null;
    const day = dayOf(days, key);
    if (!day || key === null) continue;
    if (OURA_IGNORED_SLEEP_TYPES.includes(String(record.type))) continue;
    const seconds = numberOf(record.total_sleep_duration);
    if (seconds <= 0) continue;
    day.sleepMinutes = add(day.sleepMinutes, seconds / SECONDS_PER_MINUTE);
    if (seconds > (mainSleepSeconds[key] ?? 0)) {
      mainSleepSeconds[key] = seconds;
      day.restingHeartRate = positive(record.lowest_heart_rate) ??
        day.restingHeartRate;
      day.hrvMs = positive(record.average_hrv) ?? day.hrvMs;
    }
  }

  for (const record of workouts) {
    const day = dayOf(days, typeof record.day === "string" ? record.day : null);
    if (day) day.workoutCount = add(day.workoutCount, 1);
  }

  return days;
};

const fitbitJson = (path: string, accessToken: string) =>
  wearableGetJson<JsonRecord>("fitbit", `${FITBIT_API}${path}`, accessToken);

const fetchFitbitDay = async (
  accessToken: string,
  dayKey: string,
): Promise<WearableDay> => {
  const [activity, sleep, hrv] = await Promise.all([
    fitbitJson(`/1/user/-/activities/date/${dayKey}.json`, accessToken),
    fitbitJson(`/1.2/user/-/sleep/date/${dayKey}.json`, accessToken),
    fitbitJson(`/1/user/-/hrv/date/${dayKey}.json`, accessToken),
  ]);
  const summary = recordOf(activity.summary);
  const dailyRmssd = recordOf(recordOf(listOf(hrv.hrv)[0]).value).dailyRmssd;
  const workouts = listOf(activity.activities).length;

  return {
    steps: positive(summary.steps),
    activeCaloriesKcal: positive(summary.activityCalories),
    restingHeartRate: positive(summary.restingHeartRate),
    sleepMinutes: positive(recordOf(sleep.summary).totalMinutesAsleep),
    workoutCount: workouts > 0 ? workouts : undefined,
    hrvMs: positive(dailyRmssd),
  };
};

export const fetchFitbitDays = async (
  accessToken: string,
  dayKeys: string[],
): Promise<WearableDays> => {
  const entries = await Promise.all(
    dayKeys.map(async (key) => [key, await fetchFitbitDay(accessToken, key)]),
  );
  return Object.fromEntries(entries);
};

const garminDayOf = (record: JsonRecord): string | null => {
  if (typeof record.calendarDate === "string") return record.calendarDate;
  const start = numberOf(record.startTimeInSeconds, NaN);
  if (!Number.isFinite(start)) return null;
  const offsetSeconds = numberOf(record.startTimeOffsetInSeconds);
  return dayKeyAt(new Date(start * 1000), offsetSeconds / SECONDS_PER_MINUTE);
};

export const garminDaysOf = (
  payload: JsonRecord,
): Record<string, WearableDays> => {
  const byUser: Record<string, WearableDays> = {};
  const dayFor = (record: JsonRecord): WearableDay | null => {
    const userId = typeof record.userId === "string" ? record.userId : null;
    const key = garminDayOf(record);
    if (!userId || !key) return null;
    const userDays = byUser[userId] ??= {};
    return userDays[key] ??= {};
  };

  for (const record of listOf(payload.dailies).map(recordOf)) {
    const day = dayFor(record);
    if (!day) continue;
    day.steps = positive(record.steps) ?? day.steps;
    day.activeCaloriesKcal = positive(record.activeKilocalories) ??
      day.activeCaloriesKcal;
    day.restingHeartRate = positive(record.restingHeartRateInBeatsPerMinute) ??
      day.restingHeartRate;
  }

  for (const record of listOf(payload.sleeps).map(recordOf)) {
    const day = dayFor(record);
    if (!day) continue;
    const staged = numberOf(record.deepSleepDurationInSeconds) +
      numberOf(record.lightSleepDurationInSeconds) +
      numberOf(record.remSleepInSeconds);
    const seconds = staged > 0 ?
      staged :
      numberOf(record.durationInSeconds) -
        numberOf(record.awakeDurationInSeconds);
    if (seconds > 0) day.sleepMinutes = seconds / SECONDS_PER_MINUTE;
  }

  for (const record of listOf(payload.hrv).map(recordOf)) {
    const day = dayFor(record);
    if (day) day.hrvMs = positive(record.lastNightAvg) ?? day.hrvMs;
  }

  for (const record of listOf(payload.activities).map(recordOf)) {
    const day = dayFor(record);
    if (day) day.workoutCount = add(day.workoutCount, 1);
  }

  return byUser;
};
