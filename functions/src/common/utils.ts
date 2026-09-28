import {createHash} from "crypto";

export const todayKey = (date: Date = new Date()): string =>
  date.toISOString().slice(0, 10);

export const roundTo = (value: number, digits: number): number => {
  const factor = 10 ** digits;
  return Math.round(value * factor) / factor;
};

export const clamp = (value: number, min: number, max: number): number =>
  Math.min(Math.max(value, min), max);

export const toAmount = (value: number, digits = 1): number =>
  roundTo(Number.isFinite(value) ? Math.max(value, 0) : 0, digits);

export const toAmounts = <T extends Record<string, number>>(
  values: T,
  digits = 1,
): T => {
  const entries = Object.entries(values).map(
    ([key, value]) => [key, toAmount(value, digits)],
  );
  return Object.fromEntries(entries) as T;
};

export const normalizeText = (value: string): string =>
  value.trim().toLowerCase().replace(/\s+/g, " ");

export const hashKey = (value: string): string =>
  createHash("sha256").update(value).digest("hex");

const MS_PER_MINUTE = 60_000;
const MS_PER_DAY = 86_400_000;

export const dayKeyAt = (date: Date, offsetMinutes: number): string =>
  new Date(date.getTime() + offsetMinutes * MS_PER_MINUTE)
    .toISOString()
    .slice(0, 10);

export const dayKeyOfIso = (
  iso: unknown,
  offsetMinutes: number,
): string | null => {
  if (typeof iso !== "string") return null;
  const time = Date.parse(iso);
  return Number.isNaN(time) ? null : dayKeyAt(new Date(time), offsetMinutes);
};

export const dayBoundsUtc = (
  dayKey: string,
  offsetMinutes: number,
): {start: string; end: string} => {
  const start = Date.parse(`${dayKey}T00:00:00.000Z`) -
    offsetMinutes * MS_PER_MINUTE;
  return {
    start: new Date(start).toISOString(),
    end: new Date(start + MS_PER_DAY).toISOString(),
  };
};

export const addDaysToKey = (dayKey: string, days: number): string =>
  new Date(Date.parse(`${dayKey}T00:00:00.000Z`) + days * MS_PER_DAY)
    .toISOString()
    .slice(0, 10);

export const daysBetweenKeys = (from: string, to: string): number =>
  Math.round(
    (Date.parse(`${to}T00:00:00.000Z`) - Date.parse(`${from}T00:00:00.000Z`)) /
      MS_PER_DAY,
  );

export const weekdayOfKey = (dayKey: string): number => {
  const day = new Date(`${dayKey}T00:00:00.000Z`).getUTCDay();
  return day === 0 ? 7 : day;
};

export const startOfWeekKey = (dayKey: string): string =>
  addDaysToKey(dayKey, 1 - weekdayOfKey(dayKey));

export const isDayKey = (value: unknown): value is string =>
  typeof value === "string" && /^\d{4}-\d{2}-\d{2}$/.test(value);

export const numberOf = (value: unknown, fallback = 0): number =>
  typeof value === "number" && Number.isFinite(value) ? value : fallback;

export const recordOf = (value: unknown): Record<string, unknown> =>
  value !== null && typeof value === "object" && !Array.isArray(value) ?
    value as Record<string, unknown> :
    {};

export const listOf = (value: unknown): unknown[] =>
  Array.isArray(value) ? value : [];
