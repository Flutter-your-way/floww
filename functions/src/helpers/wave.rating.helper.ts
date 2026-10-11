import {DocumentData, FieldValue} from "firebase-admin/firestore";
import {
  MAX_WAVE_REPLY_LENGTH,
  MAX_WAVE_MESSAGE_LENGTH,
  WAVE_CHAT_PROMPT_VERSION_PATTERN,
} from "../constants/ai.constants";
import {
  USER_COLLECTIONS,
  firestore,
  userCollection,
  wavePromptStatsCollection,
  waveRatingsCollection,
} from "../constants/collections";

const QUESTION_LOOKBACK = 6;
const USER_KIND = "user";
const REPLY_KIND = "reply";

export type WaveRating = "up" | "down";

const text = (value: unknown): string =>
  typeof value === "string" ? value.trim() : "";

export const ratingOf = (value: unknown): WaveRating | null =>
  value === "up" || value === "down" ? value : null;

export const isRatingChange = (
  before: DocumentData | undefined,
  after: DocumentData | undefined,
): boolean =>
  after?.kind === REPLY_KIND &&
  ratingOf(before?.rating) !== ratingOf(after?.rating);

const questionBefore = async (
  uid: string,
  createdAt: string,
): Promise<string> => {
  if (createdAt.length === 0) return "";
  const snapshot = await userCollection(uid, USER_COLLECTIONS.waveMessages)
    .where("createdAt", "<", createdAt)
    .orderBy("createdAt", "desc")
    .limit(QUESTION_LOOKBACK)
    .get();
  const question = snapshot.docs.find((doc) => doc.get("kind") === USER_KIND);
  return text(question?.get("text")).slice(0, MAX_WAVE_MESSAGE_LENGTH);
};

export const recordWaveRating = async (
  uid: string,
  messageId: string,
  message: DocumentData,
): Promise<void> => {
  const promptVersion = text(message.promptVersion);
  if (!WAVE_CHAT_PROMPT_VERSION_PATTERN.test(promptVersion)) return;

  const rating = ratingOf(message.rating);
  const question = rating ?
    await questionBefore(uid, text(message.createdAt)) :
    "";
  const ratingRef = waveRatingsCollection.doc(`${uid}_${messageId}`);
  const statsRef = wavePromptStatsCollection.doc(promptVersion);

  await firestore.runTransaction(async (transaction) => {
    const stored = await transaction.get(ratingRef);
    const previous = ratingOf(stored.get("rating"));
    if (previous === rating) return;

    const now = new Date().toISOString();
    const counts: Record<string, FieldValue> = {};
    if (previous) counts[previous] = FieldValue.increment(-1);
    if (rating) counts[rating] = FieldValue.increment(1);
    transaction.set(statsRef, {promptVersion, ...counts, updatedAt: now},
      {merge: true});

    if (!rating) {
      transaction.delete(ratingRef);
      return;
    }
    transaction.set(ratingRef, {
      userId: uid,
      messageId,
      rating,
      promptVersion,
      aiModel: text(message.aiModel),
      route: text(message.route),
      question,
      reply: text(message.text).slice(0, MAX_WAVE_REPLY_LENGTH),
      repliedAt: text(message.createdAt),
      ratedAt: now,
    });
  });
};
