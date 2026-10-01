export const DEVICE_SOURCES = ["apple_health", "health_connect"] as const;

export const SOURCE_PRIORITY: readonly string[] = [
  "oura",
  "whoop",
  "garmin",
  "fitbit",
  ...DEVICE_SOURCES,
];
