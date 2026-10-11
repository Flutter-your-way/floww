import {FieldValue} from "firebase-admin/firestore";
import {ApiError} from "../common/api.error";
import {todayKey} from "../common/utils";
import {
  aiUsageCollection,
  firestore,
  usersCollection,
} from "../constants/collections";
import {hasPremiumAccess} from "./premium.helper";

export type AiFeature =
  | "foodScan"
  | "foodDescribe"
  | "foodSearch"
  | "foodImage"
  | "waveChat"
  | "waveSummary"
  | "onboardingAnalysis"
  | "workoutPlan";

export interface AiDailyLimits {
  premium: number;
  free: number;
}

export interface AiQuota {
  used: number;
  limit: number;
  remaining: number;
  premium: boolean;
}

export interface AiTokenUsage {
  inputTokens: number;
  outputTokens: number;
}

const usageDoc = (uid: string) =>
  aiUsageCollection.doc(`${uid}_${todayKey()}`);

const quotaOf = (
  used: number,
  limits: AiDailyLimits,
  premium: boolean,
): AiQuota => {
  const limit = premium ? limits.premium : limits.free;
  return {
    used,
    limit,
    remaining: Math.max(limit - used, 0),
    premium,
  };
};

export const readAiQuota = async (
  uid: string,
  feature: AiFeature,
  limits: AiDailyLimits,
): Promise<AiQuota> => {
  const [snapshot, user] = await Promise.all([
    usageDoc(uid).get(),
    usersCollection.doc(uid).get(),
  ]);
  const used: number = snapshot.get(`${feature}.requests`) ?? 0;
  return quotaOf(used, limits, hasPremiumAccess(user.data()));
};

export const reserveAiQuota = async (
  uid: string,
  feature: AiFeature,
  limits: AiDailyLimits,
): Promise<AiQuota> => {
  const ref = usageDoc(uid);
  return firestore.runTransaction(async (transaction) => {
    const [snapshot, user] = await Promise.all([
      transaction.get(ref),
      transaction.get(usersCollection.doc(uid)),
    ]);
    const premium = hasPremiumAccess(user.data());
    const used: number = snapshot.get(`${feature}.requests`) ?? 0;
    const quota = quotaOf(used, limits, premium);
    if (quota.remaining <= 0) {
      throw new ApiError(
        "QUOTA_EXCEEDED",
        `Daily limit of ${quota.limit} reached. Try again tomorrow.`,
      );
    }
    transaction.set(ref, {
      userId: uid,
      day: todayKey(),
      [feature]: {requests: FieldValue.increment(1)},
      updatedAt: new Date().toISOString(),
    }, {merge: true});
    return quotaOf(used + 1, limits, premium);
  });
};

export const releaseAiQuota = async (
  uid: string,
  feature: AiFeature,
): Promise<void> => {
  await usageDoc(uid).set({
    [feature]: {requests: FieldValue.increment(-1)},
    updatedAt: new Date().toISOString(),
  }, {merge: true});
};

export const recordAiTokens = async (
  uid: string,
  feature: AiFeature,
  usage: AiTokenUsage,
): Promise<void> => {
  await usageDoc(uid).set({
    [feature]: {
      inputTokens: FieldValue.increment(usage.inputTokens),
      outputTokens: FieldValue.increment(usage.outputTokens),
    },
    updatedAt: new Date().toISOString(),
  }, {merge: true});
};
