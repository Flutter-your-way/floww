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
