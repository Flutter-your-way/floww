import {SecretParam} from "firebase-functions/params";
import {WearableProvider} from "../models/wearable.model";
import {
  fitbitClientId,
  fitbitClientSecret,
  garminClientId,
  garminClientSecret,
  ouraClientId,
  ouraClientSecret,
  whoopClientId,
  whoopClientSecret,
} from "./wearable.secrets";

export const WEARABLE_REGION = "us-central1";
export const WEARABLE_CALLBACK_FUNCTION = "wearableCallback";
export const WEARABLE_STATE_TTL_MS = 15 * 60_000;
export const WEARABLE_TOKEN_REFRESH_MARGIN_MS = 5 * 60_000;
export const WEARABLE_HTTP_TIMEOUT_MS = 15_000;
export const WEARABLE_SYNC_DAYS = 2;
export const WEARABLE_SCHEDULE_CONCURRENCY = 5;
export const KJ_PER_KCAL = 4.184;

export interface WearableProviderConfig {
  name: string;
  authorizeUrl: string;
  tokenUrl: string;
  scopes: string[];
  usesPkce: boolean;
  basicAuth: boolean;
  pullsData: boolean;
  clientId: SecretParam;
  clientSecret: SecretParam;
}

type WearableConfigs = Record<WearableProvider, WearableProviderConfig>;

export const WEARABLE_CONFIGS: WearableConfigs =
  {
    garmin: {
      name: "Garmin",
      authorizeUrl: "https://connect.garmin.com/oauth2Confirm",
      tokenUrl: "https://diauth.garmin.com/di-oauth2-service/oauth/token",
      scopes: [],
      usesPkce: true,
      basicAuth: false,
      pullsData: false,
      clientId: garminClientId,
      clientSecret: garminClientSecret,
    },
    whoop: {
      name: "WHOOP",
      authorizeUrl: "https://api.prod.whoop.com/oauth/oauth2/auth",
      tokenUrl: "https://api.prod.whoop.com/oauth/oauth2/token",
      scopes: [
        "offline",
        "read:recovery",
        "read:cycles",
        "read:sleep",
        "read:workout",
        "read:profile",
      ],
      usesPkce: false,
      basicAuth: false,
      pullsData: true,
      clientId: whoopClientId,
      clientSecret: whoopClientSecret,
    },
    oura: {
      name: "Oura",
      authorizeUrl: "https://cloud.ouraring.com/oauth/authorize",
      tokenUrl: "https://api.ouraring.com/oauth/token",
      scopes: ["personal", "daily", "heartrate", "workout", "session"],
      usesPkce: false,
      basicAuth: false,
      pullsData: true,
      clientId: ouraClientId,
      clientSecret: ouraClientSecret,
    },
    fitbit: {
      name: "Fitbit",
      authorizeUrl: "https://www.fitbit.com/oauth2/authorize",
      tokenUrl: "https://api.fitbit.com/oauth2/token",
      scopes: ["activity", "heartrate", "sleep", "profile"],
      usesPkce: true,
      basicAuth: true,
      pullsData: true,
      clientId: fitbitClientId,
      clientSecret: fitbitClientSecret,
    },
  };

export const GARMIN_API = "https://apis.garmin.com/wellness-api/rest";
export const GARMIN_BACKFILL_TYPES = ["dailies", "sleeps", "hrv", "activities"];
export const WHOOP_API = "https://api.prod.whoop.com/developer/v2";
export const WHOOP_PAGE_LIMIT = 25;
export const WHOOP_MAX_PAGES = 4;
export const OURA_API = "https://api.ouraring.com/v2/usercollection";
export const OURA_REVOKE_URL = "https://api.ouraring.com/oauth/revoke";
export const OURA_IGNORED_SLEEP_TYPES = ["deleted", "rest"];
export const FITBIT_API = "https://api.fitbit.com";
export const FITBIT_REVOKE_URL = "https://api.fitbit.com/oauth2/revoke";
