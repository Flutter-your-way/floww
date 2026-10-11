import {DocumentData, FieldValue} from "firebase-admin/firestore";
import {zodTextFormat} from "openai/helpers/zod";
import {dayKeyOfIso, numberOf} from "../common/utils";
import {
  MAX_WAVE_HISTORY_TURNS,
  MAX_WAVE_SUMMARY_TURN_LENGTH,
  WAVE_SUMMARY_BATCH,
  WAVE_SUMMARY_LOCK_MS,
  WAVE_SUMMARY_MAX_OUTPUT_TOKENS,
  WAVE_SUMMARY_MODEL,
  WAVE_SUMMARY_PROMPT_VERSION,
  WAVE_SUMMARY_REASONING_EFFORT,
  WAVE_SUMMARY_SCAN_LIMIT,
} from "../constants/ai.constants";
import {
  USER_COLLECTIONS,
  firestore,
  userCollection,
} from "../constants/collections";
import {WaveSummaryItem, waveSummaryOutputSchema} from "../models/wave.model";
import {
  WAVE_SUMMARY_INSTRUCTIONS,
  WaveSummaryTurn,
  buildWaveSummaryInput,
} from "../prompts/wave.summary.prompt";
import {getOpenAI} from "./openai.helper";
import {hasPremiumAccess} from "./premium.helper";
import {recordAiTokens} from "./usage.helper";
import {clockOf, loadActiveUser} from "./user.clock.helper";
import {
  loadMemoryEnabled,
  renderSummaryItems,
  sanitizeSummaryItems,
  summaryDoc,
  summaryTextOf,
} from "./wave.memory.helper";

const TURN_KINDS: Record<string, WaveSummaryTurn["role"]> = {
  user: "user",
  reply: "wave",
};

interface StoredTurn extends WaveSummaryTurn {
  createdAt: string;
}

export const isConversationTurn = (data: DocumentData | undefined): boolean =>
  !!data && typeof data.kind === "string" && data.kind in TURN_KINDS;

const turnOf = (
  data: DocumentData,
  offsetMinutes: number,
): StoredTurn | null => {
  const role = TURN_KINDS[data.kind];
  const text = typeof data.text === "string" ? data.text.trim() : "";
  const createdAt = typeof data.createdAt === "string" ? data.createdAt : "";
  const day = dayKeyOfIso(createdAt, offsetMinutes);
  if (!role || text.length === 0 || !day) return null;
  return {
    role,
    text: text.slice(0, MAX_WAVE_SUMMARY_TURN_LENGTH),
    day,
    createdAt,
  };
};

const acquireLock = async (uid: string, through: string): Promise<boolean> =>
  firestore.runTransaction(async (transaction) => {
    const ref = summaryDoc(uid);
    const snapshot = await transaction.get(ref);
    const current = snapshot.get("summarizedThrough") ?? "";
    if (current !== through) return false;
    if (numberOf(snapshot.get("lockedUntil")) > Date.now()) return false;
    transaction.set(
      ref,
      {lockedUntil: Date.now() + WAVE_SUMMARY_LOCK_MS},
      {merge: true},
    );
    return true;
  });

const summarize = async (
  uid: string,
  previous: string,
  turns: StoredTurn[],
): Promise<WaveSummaryItem[] | null> => {
  const response = await getOpenAI().responses.parse({
    model: WAVE_SUMMARY_MODEL,
    reasoning: {effort: WAVE_SUMMARY_REASONING_EFFORT},
    max_output_tokens: WAVE_SUMMARY_MAX_OUTPUT_TOKENS,
    instructions: WAVE_SUMMARY_INSTRUCTIONS,
    input: buildWaveSummaryInput(previous, turns),
    text: {format: zodTextFormat(waveSummaryOutputSchema, "wave_summary")},
  });

  await recordAiTokens(uid, "waveSummary", {
    inputTokens: response.usage?.input_tokens ?? 0,
    outputTokens: response.usage?.output_tokens ?? 0,
  });

  const parsed = response.output_parsed;
  return parsed ? sanitizeSummaryItems(parsed.items) : null;
};

export const refreshWaveSummary = async (uid: string): Promise<void> => {
  const user = await loadActiveUser(uid);
  if (!user || !hasPremiumAccess(user) || !(await loadMemoryEnabled(uid))) {
    return;
  }

  const {offsetMinutes, today} = clockOf(user);
  const state = (await summaryDoc(uid).get()).data() ?? {};
  const through: string = typeof state.summarizedThrough === "string" ?
    state.summarizedThrough :
    "";

  let query = userCollection(uid, USER_COLLECTIONS.waveMessages)
    .orderBy("createdAt");
  if (through.length > 0) query = query.where("createdAt", ">", through);
  const snapshot = await query.limit(WAVE_SUMMARY_SCAN_LIMIT).get();

  const turns = snapshot.docs
    .map((doc) => isConversationTurn(doc.data()) ?
      turnOf(doc.data(), offsetMinutes) :
      null)
    .filter((turn): turn is StoredTurn => turn !== null);
  const recent = turns
    .filter((turn) => turn.day === today)
    .slice(-MAX_WAVE_HISTORY_TURNS);
  const older = recent.length > 0 ?
    turns.filter((turn) => turn.createdAt < recent[0].createdAt) :
    turns;
  const hasPastDays = older.some((turn) => turn.day !== today);
  const previous = summaryTextOf(state);
  const isOutdated = previous.length > 0 &&
    state.promptVersion !== WAVE_SUMMARY_PROMPT_VERSION;

  if (older.length === 0 && !isOutdated) return;
  if (older.length < WAVE_SUMMARY_BATCH && !hasPastDays && !isOutdated) return;
  if (!(await acquireLock(uid, through))) return;

  try {
    const items = await summarize(uid, previous, older);
    if (!items) throw new Error("wave summary returned no output");
    await summaryDoc(uid).set({
      items,
      summary: renderSummaryItems(items),
      summarizedThrough: older.length > 0 ?
        older[older.length - 1].createdAt :
        through,
      promptVersion: WAVE_SUMMARY_PROMPT_VERSION,
      updatedAt: new Date().toISOString(),
      lockedUntil: FieldValue.delete(),
    }, {merge: true});
  } catch (error) {
    await summaryDoc(uid).set(
      {lockedUntil: FieldValue.delete()},
      {merge: true},
    );
    throw error;
  }
};
