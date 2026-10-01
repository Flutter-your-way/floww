import {defineSecret} from "firebase-functions/params";

export const garminClientId = defineSecret("GARMIN_CLIENT_ID");
export const garminClientSecret = defineSecret("GARMIN_CLIENT_SECRET");
export const garminWebhookKey = defineSecret("GARMIN_WEBHOOK_KEY");
export const whoopClientId = defineSecret("WHOOP_CLIENT_ID");
export const whoopClientSecret = defineSecret("WHOOP_CLIENT_SECRET");
export const ouraClientId = defineSecret("OURA_CLIENT_ID");
export const ouraClientSecret = defineSecret("OURA_CLIENT_SECRET");
export const fitbitClientId = defineSecret("FITBIT_CLIENT_ID");
export const fitbitClientSecret = defineSecret("FITBIT_CLIENT_SECRET");

export const wearableSecrets = [
  garminClientId,
  garminClientSecret,
  whoopClientId,
  whoopClientSecret,
  ouraClientId,
  ouraClientSecret,
  fitbitClientId,
  fitbitClientSecret,
];
