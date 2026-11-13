export const YMOVE_BASE_URL = "https://exercise-api.ymove.app/api/v2";
export const YMOVE_TIMEOUT_MS = 10_000;
export const YMOVE_SEARCH_PAGE_SIZE = 10;
export const YMOVE_PREFERRED_TAG = "gym-shot";

export const EXERCISE_VIDEO_KINDS = ["gym", "yoga"] as const;
export const EXERCISE_VIDEO_VERSION = "ymove-v2";
export const EXERCISE_VIDEO_URL_TTL_MS = 24 * 60 * 60 * 1000;
export const EXERCISE_VIDEO_MATCH_TTL_MS = 30 * 24 * 60 * 60 * 1000;
export const EXERCISE_VIDEO_MISS_TTL_MS = 7 * 24 * 60 * 60 * 1000;
export const EXERCISE_VIDEO_DAILY_LIMIT = {premium: 300, free: 300};
export const MAX_EXERCISE_VIDEO_QUERIES = 3;
export const MIN_EXERCISE_VIDEO_QUERY_LENGTH = 2;
export const MAX_EXERCISE_VIDEO_QUERY_LENGTH = 80;
