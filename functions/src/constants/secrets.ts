import {defineSecret} from "firebase-functions/params";

export const openAiApiKey = defineSecret("OPENAI_API_KEY");
export const usdaApiKey = defineSecret("USDA_API_KEY");
export const ymoveApiKey = defineSecret("YMOVE_API_KEY");
export const revenueCatSecretKey = defineSecret("REVENUECAT_SECRET_KEY");
export const revenueCatWebhookAuth = defineSecret("REVENUECAT_WEBHOOK_AUTH");
