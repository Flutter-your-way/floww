export const WEARABLE_PROVIDERS = [
  "garmin",
  "whoop",
  "oura",
  "fitbit",
] as const;

export type WearableProvider = typeof WEARABLE_PROVIDERS[number];

export const isWearableProvider = (value: unknown): value is WearableProvider =>
  typeof value === "string" &&
  (WEARABLE_PROVIDERS as readonly string[]).includes(value);

export interface WearableDay {
  steps?: number;
  activeCaloriesKcal?: number;
  sleepMinutes?: number;
  workoutCount?: number;
  restingHeartRate?: number;
  hrvMs?: number;
}

export type WearableDays = Record<string, WearableDay>;

export interface WearableTokens {
  accessToken: string;
  refreshToken?: string;
  expiresAt: number;
  scope?: string;
}

export interface WearableIntegration extends WearableTokens {
  provider: WearableProvider;
  externalUserId?: string;
  connectedAt: string;
  lastSyncedAt?: string;
}

export interface WearableOAuthState {
  uid: string;
  provider: WearableProvider;
  codeVerifier?: string;
  expiresAt: number;
}

export class WearableAuthError extends Error {
  constructor(readonly provider: WearableProvider, message: string) {
    super(message);
    this.name = "WearableAuthError";
  }
}
