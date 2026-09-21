import {FieldValue} from "firebase-admin/firestore";
import {ApiError} from "../common/api.error";
import {todayKey} from "../common/utils";
import {aiUsageCollection, firestore} from "../constants/collections";

export type AiFeature = "foodScan";

export interface AiTokenUsage {
  inputTokens: number;
  outputTokens: number;
}

const usageDoc = (uid: string) =>
  aiUsageCollection.doc(`${uid}_${todayKey()}`);

export const reserveAiQuota = async (
  uid: string,
  feature: AiFeature,
  dailyLimit: number,
): Promise<void> => {
  const ref = usageDoc(uid);
  await firestore.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const used: number = snapshot.get(`${feature}.requests`) ?? 0;
    if (used >= dailyLimit) {
      throw new ApiError(
        "QUOTA_EXCEEDED",
        `Daily limit of ${dailyLimit} reached. Try again tomorrow.`,
      );
    }
    transaction.set(ref, {
      userId: uid,
      day: todayKey(),
      [feature]: {requests: FieldValue.increment(1)},
      updatedAt: new Date().toISOString(),
    }, {merge: true});
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
