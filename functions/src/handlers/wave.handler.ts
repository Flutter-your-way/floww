import {Request, Response} from "express";
import {logger} from "firebase-functions";
import {sendData} from "../common/api.error";
import {
  WAVE_CHAT_DAILY_LIMIT,
  WAVE_CHAT_MODEL,
  WAVE_CHAT_PROMPT_VERSION,
} from "../constants/ai.constants";
import {answerWaveChat} from "../helpers/wave.chat.helper";
import {loadWaveProfile} from "../helpers/wave.profile.helper";
import {toAiApiError} from "../helpers/openai.helper";
import {
  recordAiTokens,
  releaseAiQuota,
  reserveAiQuota,
} from "../helpers/usage.helper";
import {WaveReply, waveReplySchema} from "../models/wave.model";
import {waveChatValidator} from "../validators/wave.chat.validator";

export const handleWaveChat = async (req: Request, res: Response) => {
  const body = waveChatValidator.parse(req.body);
  const uid = req.user.uid;

  await reserveAiQuota(uid, "waveChat", WAVE_CHAT_DAILY_LIMIT);

  let result;
  try {
    const profile = await loadWaveProfile(uid);
    result = await answerWaveChat(body, profile, uid);
  } catch (error) {
    await releaseAiQuota(uid, "waveChat").catch((releaseError) =>
      logger.error("handleWaveChat: quota release failed", {releaseError}));
    throw toAiApiError(error, "handleWaveChat");
  }

  await recordAiTokens(uid, "waveChat", result.usage).catch((usageError) =>
    logger.error("handleWaveChat: token usage write failed", {usageError}));

  const reply: WaveReply = waveReplySchema.parse({
    ...result.answer,
    aiModel: WAVE_CHAT_MODEL,
    promptVersion: WAVE_CHAT_PROMPT_VERSION,
    createdAt: new Date().toISOString(),
  });

  sendData(res, reply);
};
