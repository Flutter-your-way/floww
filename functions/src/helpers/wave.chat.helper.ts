import {createHash} from "crypto";
import {zodTextFormat} from "openai/helpers/zod";
import {ApiError} from "../common/api.error";
import {
  MAX_WAVE_REPLY_LENGTH,
  MAX_WAVE_TARGET_LENGTH,
  WAVE_CHAT_MAX_OUTPUT_TOKENS,
  WAVE_CHAT_MODEL,
  WAVE_CHAT_REASONING_EFFORT,
} from "../constants/ai.constants";
import {
  WaveAnswer,
  WaveFoodDraft,
  waveAnswerSchema,
} from "../models/wave.model";
import {
  WAVE_CHAT_INSTRUCTIONS,
  buildWaveContext,
  buildWaveInput,
} from "../prompts/wave.chat.prompt";
import {WaveChatRequest} from "../validators/wave.chat.validator";
import {getOpenAI} from "./openai.helper";
import {AiTokenUsage} from "./usage.helper";
import {WaveProfile} from "./wave.digest.helper";

export interface WaveChatResult {
  answer: WaveAnswer;
  usage: AiTokenUsage;
}

const MAX_WATER_ML = 5000;
const MAX_SERVINGS = 20;
const MAX_MACRO = 5000;

const TARGETED_ACTIONS = new Set([
  "completeHabit",
  "uncompleteHabit",
  "editHabit",
  "deleteHabit",
  "logFood",
  "unlogFood",
]);

const WATER_ACTIONS = new Set(["logWater", "unlogWater"]);

const clampAmount = (value: number, max: number): number => {
  const amount = Math.round(Number.isFinite(value) ? value : 0);
  return Math.min(Math.max(amount, 0), max);
};

const clampMacro = (value: number): number => {
  const amount = Number.isFinite(value) ? value : 0;
  return Math.min(Math.max(Math.round(amount * 10) / 10, 0), MAX_MACRO);
};

const EMPTY_FOOD_DRAFT: WaveFoodDraft = {
  name: "",
  serving: "",
  weightG: 0,
  calories: 0,
  proteinG: 0,
  carbsG: 0,
  fatG: 0,
  fiberG: 0,
  sugarG: 0,
  sodiumMg: 0,
  waterMl: 0,
};

const sanitizeFoodDraft = (draft: WaveFoodDraft): WaveFoodDraft => ({
  name: draft.name.trim().slice(0, MAX_WAVE_TARGET_LENGTH),
  serving: draft.serving.trim().slice(0, MAX_WAVE_TARGET_LENGTH),
  weightG: clampMacro(draft.weightG),
  calories: clampMacro(draft.calories),
  proteinG: clampMacro(draft.proteinG),
  carbsG: clampMacro(draft.carbsG),
  fatG: clampMacro(draft.fatG),
  fiberG: clampMacro(draft.fiberG),
  sugarG: clampMacro(draft.sugarG),
  sodiumMg: clampMacro(draft.sodiumMg),
  waterMl: clampMacro(draft.waterMl),
});

export const sanitizeWaveAnswer = (answer: WaveAnswer): WaveAnswer => {
  const reply = answer.reply.trim().slice(0, MAX_WAVE_REPLY_LENGTH);
  const card = reply.length === 0 ? "none" : answer.card;
  const action = reply.length === 0 ? "none" : answer.action;
  const target = answer.actionTarget.trim().slice(0, MAX_WAVE_TARGET_LENGTH);

  const servings = action === "logFood" ?
    Math.min(Math.max(answer.servings || 1, 1), MAX_SERVINGS) :
    0;

  return {
    reply,
    card,
    injuryArea: card === "injurySwap" ? answer.injuryArea : "none",
    action,
    actionTarget: TARGETED_ACTIONS.has(action) ? target : "",
    actionAmountMl: WATER_ACTIONS.has(action) ?
      clampAmount(answer.actionAmountMl, MAX_WATER_ML) :
      0,
    servings,
    meal: action === "logFood" ? answer.meal : "auto",
    foodDraft: action === "createFood" ?
      sanitizeFoodDraft(answer.foodDraft) :
      EMPTY_FOOD_DRAFT,
    habitDraft: {
      title: action === "addHabit" || action === "editHabit" ?
        answer.habitDraft.title.trim().slice(0, MAX_WAVE_TARGET_LENGTH) :
        "",
      target: action === "addHabit" || action === "editHabit" ?
        clampMacro(answer.habitDraft.target) :
        0,
      metric: answer.habitDraft.metric,
    },
  };
};

export const answerWaveChat = async (
  request: WaveChatRequest,
  profile: WaveProfile,
  uid: string,
): Promise<WaveChatResult> => {
  const context = buildWaveContext(profile, request.today);
  const identifier = createHash("sha256").update(uid).digest("hex");

  const response = await getOpenAI().responses.parse({
    model: WAVE_CHAT_MODEL,
    reasoning: {effort: WAVE_CHAT_REASONING_EFFORT},
    max_output_tokens: WAVE_CHAT_MAX_OUTPUT_TOKENS,
    prompt_cache_key: identifier,
    safety_identifier: identifier,
    instructions: WAVE_CHAT_INSTRUCTIONS,
    input: [
      {
        role: "user",
        content: [
          {
            type: "input_text",
            text: buildWaveInput(context, request.history, request.message),
          },
        ],
      },
    ],
    text: {format: zodTextFormat(waveAnswerSchema, "wave_answer")},
  });

  const parsed = response.output_parsed;
  if (!parsed) {
    throw new ApiError("AI_FAILED", "WAVE could not answer that right now.");
  }

  const answer = sanitizeWaveAnswer(parsed);
  if (answer.reply.length === 0) {
    throw new ApiError("AI_FAILED", "WAVE could not answer that right now.");
  }

  return {
    answer,
    usage: {
      inputTokens: response.usage?.input_tokens ?? 0,
      outputTokens: response.usage?.output_tokens ?? 0,
    },
  };
};
