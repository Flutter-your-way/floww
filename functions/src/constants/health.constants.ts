export const DEVICE_SOURCES = ["apple_health", "health_connect"] as const;

export const MANUAL_SOURCE = "manual";

export const SOURCE_PRIORITY: readonly string[] = [
  MANUAL_SOURCE,
  "oura",
  "whoop",
  "garmin",
  "fitbit",
  ...DEVICE_SOURCES,
];
