import {Request, Response} from "express";
import {logger} from "firebase-functions";
import {ApiError, sendData} from "../common/api.error";
import {
  WAVE_CHAT_DAILY_LIMIT,
  WAVE_CHAT_PROMPT_VERSION,
} from "../constants/ai.constants";
import {WaveAccess, intentFeatureOf} from "../helpers/wave.access.helper";
import {answerWaveChat} from "../helpers/wave.chat.helper";
import {
  WaveFacts,
  loadWaveFacts,
  mergeWaveToday,
} from "../helpers/wave.facts.helper";
import {WaveGrounding, groundWaveActions} from "../helpers/wave.ground.helper";
import {loadWaveHistory} from "../helpers/wave.history.helper";
import {
  WaveMemory,
  WaveMemoryChanges,
  applyMemoryUpdate,
  loadWaveMemory,
  selectMemories,
} from "../helpers/wave.memory.helper";
import {loadWaveProfile} from "../helpers/wave.profile.helper";
import {
  asksToRemember,
  classifyWaveIntent,
  routeConfigOf,
  routeOf,
} from "../helpers/wave.route.helper";
import {toAiApiError} from "../helpers/openai.helper";
import {
  readAiQuota,
  recordAiTokens,
  releaseAiQuota,
  reserveAiQuota,
} from "../helpers/usage.helper";
import {clockOf, loadActiveUser} from "../helpers/user.clock.helper";
import {
  WaveActionItem,
  WaveAnswer,
  WavePremiumFeature,
  WaveReply,
  waveQuotaSchema,
  waveReplySchema,
} from "../models/wave.model";
import {waveChatValidator} from "../validators/wave.chat.validator";

const NO_MEMORY: WaveMemory = {enabled: false, notes: [], summary: ""};

const NO_CHANGES: WaveMemoryChanges = {saved: [], forgotten: []};

const ungrounded = (actions: WaveActionItem[]): WaveGrounding => ({
  actions,
  rejected: [],
  locked: [],
});

const lockedOf = (
  access: WaveAccess,
  grounding: WaveGrounding,
  answer: WaveAnswer,
  intentFeature: WavePremiumFeature | null,
  wantsMemory: boolean,
): WavePremiumFeature[] => {
  if (access.premium) return [];
  const locked = new Set(grounding.locked);
  if (intentFeature) locked.add(intentFeature);
  if (wantsMemory || answer.memory.remember.length > 0) locked.add("memory");
  return [...locked];
};

export const handleWaveChat = async (req: Request, res: Response) => {
  const body = waveChatValidator.parse(req.body);
  const uid = req.user.uid;

  const quota = await reserveAiQuota(uid, "waveChat", WAVE_CHAT_DAILY_LIMIT);
  const access: WaveAccess = {premium: quota.premium};
  const intent = classifyWaveIntent(body.message);
  const route = routeOf(intent, access.premium);

  let result;
  let facts: WaveFacts | null = null;
  let memory = NO_MEMORY;
  let labeled: ReturnType<typeof selectMemories> = [];
  try {
    const user = await loadActiveUser(uid);
    if (!user) throw new ApiError("UNAUTHORIZED", "Please sign in again.");

    const [profile, history, loadedMemory, loadedFacts] = await Promise.all([
      loadWaveProfile(uid),
      loadWaveHistory(uid).catch((historyError) => {
        logger.error("handleWaveChat: history load failed", {historyError});
        return "";
      }),
      access.premium ?
        loadWaveMemory(uid).catch((memoryError) => {
          logger.error("handleWaveChat: memory load failed", {memoryError});
          return NO_MEMORY;
        }) :
        Promise.resolve(NO_MEMORY),
      loadWaveFacts(uid, clockOf(user)).catch((factsError) => {
        logger.error("handleWaveChat: facts load failed", {factsError});
        return null;
      }),
    ]);
    memory = loadedMemory;
    facts = loadedFacts;
    labeled = selectMemories(
      memory.notes,
      [...body.history.map((turn) => turn.text), body.message].join(" "),
    );
    result = await answerWaveChat({
      uid,
      message: body.message,
      turns: body.history,
      today: facts ? mergeWaveToday(body.today, facts) : body.today,
      profile,
      history,
      memory: {
        enabled: memory.enabled,
        premium: access.premium,
        notes: labeled,
        summary: memory.summary,
      },
      access,
      route: routeConfigOf(route),
    });
  } catch (error) {
    await releaseAiQuota(uid, "waveChat").catch((releaseError) =>
      logger.error("handleWaveChat: quota release failed", {releaseError}));
    throw toAiApiError(error, "handleWaveChat");
  }

  await recordAiTokens(uid, "waveChat", result.usage).catch((usageError) =>
    logger.error("handleWaveChat: token usage write failed", {usageError}));

  const grounding = facts ?
    groundWaveActions(result.answer.actions, facts, access) :
    ungrounded(result.answer.actions);
  if (grounding.rejected.length > 0) {
    logger.info("handleWaveChat: actions rejected", {
      rejected: grounding.rejected,
      promptVersion: WAVE_CHAT_PROMPT_VERSION,
    });
  }

  const changes = await applyMemoryUpdate(
    uid,
    memory,
    labeled,
    result.answer.memory,
  ).catch((memoryError) => {
    logger.error("handleWaveChat: memory write failed", {memoryError});
    return NO_CHANGES;
  });

  const reply: WaveReply = waveReplySchema.parse({
    ...result.answer,
    actions: grounding.actions,
    rejected: grounding.rejected,
    locked: lockedOf(
      access,
      grounding,
      result.answer,
      intentFeatureOf(intent),
      asksToRemember(body.message),
    ),
    memorySaved: changes.saved,
    memoryForgotten: changes.forgotten,
    quota,
    route,
    aiModel: routeConfigOf(route).model,
    promptVersion: WAVE_CHAT_PROMPT_VERSION,
    createdAt: new Date().toISOString(),
  });

  sendData(res, reply);
};

export const handleWaveQuota = async (req: Request, res: Response) => {
  const quota = await readAiQuota(
    req.user.uid,
    "waveChat",
    WAVE_CHAT_DAILY_LIMIT,
  );
  sendData(res, waveQuotaSchema.parse(quota));
};
