import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

initializeApp();

export const firestore = getFirestore();
firestore.settings({ignoreUndefinedProperties: true});

export const USER_COLLECTIONS = {
  foodLogs: "food_logs",
  waterLogs: "water_logs",
  weightLogs: "weight_logs",
  habits: "habits",
  habitLogs: "habit_logs",
  healthLogs: "health_logs",
  workoutSessions: "workout_sessions",
  workoutPlans: "workout_plans",
  workoutExercises: "workout_exercises",
  workoutPrograms: "workout_programs",
  workoutState: "workout_state",
  dailyFlow: "daily_flow",
  invoices: "invoices",
  settings: "settings",
  stats: "stats",
  targets: "targets",
  integrations: "integrations",
} as const;

export const STATS_DOC = "summary";
export const TARGETS_DOC = "current";
export const ONBOARDING_BLUEPRINT_DOC = "onboarding_blueprint";
export const SETTINGS_DOC = "preferences";
export const WORKOUT_STATE_DOC = "state";

export const usersCollection = firestore.collection("users");
export const aiUsageCollection = firestore.collection("ai_usage");
export const wearableStatesCollection =
  firestore.collection("wearable_oauth_states");
export const wearableLinksCollection = firestore.collection("wearable_links");
export const onboardingDetailsCollection =
  firestore.collection("onboarding_details");
export const dailyQuotesCollection = firestore.collection("daily_quotes");

export const userCollection = (
  uid: string,
  name: typeof USER_COLLECTIONS[keyof typeof USER_COLLECTIONS],
) => usersCollection.doc(uid).collection(name);

export const foodLogsCollection = (uid: string) =>
  userCollection(uid, USER_COLLECTIONS.foodLogs);
export const foodSearchCacheCollection =
  firestore.collection("food_search_cache");
export const foodDescribeCacheCollection =
  firestore.collection("food_describe_cache");
export const foodImageCacheCollection =
  firestore.collection("food_image_cache");
