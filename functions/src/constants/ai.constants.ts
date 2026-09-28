export const OPENAI_TIMEOUT_MS = 60_000;
export const OPENAI_MAX_RETRIES = 1;

export const FOOD_SCAN_MODEL = "gpt-5.4-mini";
export const FOOD_SCAN_REASONING_EFFORT = "low";
export const FOOD_SCAN_PROMPT_VERSION = "food-scan-v2";
export const FOOD_SCAN_DAILY_LIMIT = {premium: 30, free: 5};

export const FOOD_SCAN_MIME_TYPES = [
  "image/jpeg",
  "image/png",
  "image/webp",
] as const;
export const MAX_IMAGE_BASE64_LENGTH = 8 * 1024 * 1024;
export const MAX_FOOD_NOTE_LENGTH = 300;

export const WAVE_CHAT_MODEL = "gpt-5.4-mini";
export const WAVE_CHAT_REASONING_EFFORT = "low";
export const WAVE_CHAT_PROMPT_VERSION = "wave-chat-v2";
export const WAVE_CHAT_DAILY_LIMIT = {premium: 60, free: 15};
export const WAVE_CHAT_MAX_OUTPUT_TOKENS = 900;

export const MAX_WAVE_MESSAGE_LENGTH = 1000;
export const MAX_WAVE_HISTORY_TURNS = 8;
export const MAX_WAVE_HISTORY_LENGTH = 360;
export const MAX_WAVE_REPLY_LENGTH = 900;
export const MAX_WAVE_LIST_ITEMS = 8;
export const MAX_WAVE_TARGET_LENGTH = 60;
export const MAX_WAVE_LONG_LIST = 30;

export const WAVE_PROFILE_CACHE_TTL_MS = 10 * 60 * 1000;
export const WAVE_PROFILE_CACHE_LIMIT = 500;

export const FOOD_DESCRIBE_MODEL = "gpt-5.4-mini";
export const FOOD_DESCRIBE_REASONING_EFFORT = "low";
export const FOOD_DESCRIBE_PROMPT_VERSION = "food-describe-v1";
export const FOOD_DESCRIBE_DAILY_LIMIT = {premium: 30, free: 5};
export const MIN_FOOD_DESCRIPTION_LENGTH = 2;
export const MAX_FOOD_DESCRIPTION_LENGTH = 300;
