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
  dailyFlow: "daily_flow",
  invoices: "invoices",
  settings: "settings",
  stats: "stats",
  targets: "targets",
} as const;

export const STATS_DOC = "summary";
export const TARGETS_DOC = "current";
export const SETTINGS_DOC = "preferences";

export const usersCollection = firestore.collection("users");
export const aiUsageCollection = firestore.collection("ai_usage");
export const onboardingDetailsCollection =
  firestore.collection("onboarding_details");

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
