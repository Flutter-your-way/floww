import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

initializeApp();

export const firestore = getFirestore();
firestore.settings({ignoreUndefinedProperties: true});

export const usersCollection = firestore.collection("users");
export const aiUsageCollection = firestore.collection("ai_usage");
export const onboardingDetailsCollection =
  firestore.collection("onboarding_details");

export const foodLogsCollection = (uid: string) =>
  usersCollection.doc(uid).collection("food_logs");
