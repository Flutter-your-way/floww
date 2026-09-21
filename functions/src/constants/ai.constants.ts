export const OPENAI_TIMEOUT_MS = 60_000;
export const OPENAI_MAX_RETRIES = 1;

export const FOOD_SCAN_MODEL = "gpt-5.4-mini";
export const FOOD_SCAN_REASONING_EFFORT = "low";
export const FOOD_SCAN_PROMPT_VERSION = "food-scan-v2";
export const FOOD_SCAN_DAILY_LIMIT = 30;

export const FOOD_SCAN_MIME_TYPES = [
  "image/jpeg",
  "image/png",
  "image/webp",
] as const;
export const MAX_IMAGE_BASE64_LENGTH = 8 * 1024 * 1024;
export const MAX_FOOD_NOTE_LENGTH = 300;
