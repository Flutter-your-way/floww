import {defineSecret} from "firebase-functions/params";

export const openAiApiKey = defineSecret("OPENAI_API_KEY");
export const usdaApiKey = defineSecret("USDA_API_KEY");
