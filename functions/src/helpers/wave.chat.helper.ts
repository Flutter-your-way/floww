import {createHash} from "crypto";
import {zodTextFormat} from "openai/helpers/zod";
import {ApiError} from "../common/api.error";
import {
  MAX_WAVE_ACTIONS,
  MAX_WAVE_REPLY_LENGTH,
  MAX_WAVE_TARGET_LENGTH,
} from "../constants/ai.constants";
import {
  WaveAction,
  WaveActionItem,
  WaveAnswer,
  WaveFoodDraft,
  WaveHabitDraft,
  WaveTargets,
  waveAnswerSchema,
} from "../models/wave.model";
import {
  WAVE_CHAT_INSTRUCTIONS,
  WaveMemoryContext,
  buildWaveContext,
  buildWaveInput,
} from "../prompts/wave.chat.prompt";
import {
  WaveHistoryTurn,
  WaveToday,
} from "../validators/wave.chat.validator";
import {getOpenAI} from "./openai.helper";
import {AiTokenUsage} from "./usage.helper";
import {WaveAccess} from "./wave.access.helper";
import {WaveProfile} from "./wave.digest.helper";
import {sanitizeMemoryUpdate} from "./wave.memory.helper";
import {WaveRouteConfig} from "./wave.route.helper";

export interface WaveChatInput {
  uid: string;
  message: string;
  turns: WaveHistoryTurn[];
  today?: WaveToday;
  profile: WaveProfile;
  history: string;
  memory: WaveMemoryContext;
  access: WaveAccess;
  route: WaveRouteConfig;
}

export interface WaveChatResult {
  answer: WaveAnswer;
  usage: AiTokenUsage;
}

const MAX_WATER_ML = 5000;
const MAX_SERVINGS = 20;
const MAX_MACRO = 5000;
const MAX_REPS = 200;
const MAX_LIFT_KG = 500;
const MIN_BODY_WEIGHT_KG = 25;
const MAX_BODY_WEIGHT_KG = 350;
const MAX_SLEEP_HOURS = 16;
const MAX_WATER_TARGET_LITERS = 8;
const MAX_STEPS_TARGET = 60000;
const DATE_PATTERN = /^\d{4}-\d{2}-\d{2}$/;

const TARGETED_ACTIONS = new Set<WaveAction>([
  "completeHabit",
  "uncompleteHabit",
  "editHabit",
  "deleteHabit",
  "logFood",
  "unlogFood",
  "logSet",
  "swapExercise",
]);

const FOOD_ACTIONS = new Set<WaveAction>(["logFood", "createFood"]);

const HABIT_DRAFT_ACTIONS = new Set<WaveAction>(["addHabit", "editHabit"]);

const clampAmount = (value: number, max: number): number => {
  const amount = Math.round(Number.isFinite(value) ? value : 0);
  return Math.min(Math.max(amount, 0), max);
};

const clampMacro = (value: number): number => {
  const amount = Number.isFinite(value) ? value : 0;
  return Math.min(Math.max(Math.round(amount * 10) / 10, 0), MAX_MACRO);
};

const clampDecimal = (value: number, min: number, max: number): number => {
  const amount = Number.isFinite(value) ? Math.round(value * 10) / 10 : 0;
  return amount < min ? 0 : Math.min(amount, max);
};

const textOf = (value: string): string =>
  value.trim().slice(0, MAX_WAVE_TARGET_LENGTH);

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

const EMPTY_HABIT_DRAFT: WaveHabitDraft = {
  title: "",
  target: 0,
  metric: "minutes",
};

const EMPTY_TARGETS: WaveTargets = {waterLiters: 0, steps: 0, sleepHours: 0};

const sanitizeFoodDraft = (draft: WaveFoodDraft): WaveFoodDraft => ({
  name: textOf(draft.name),
  serving: textOf(draft.serving),
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

const sanitizeTargets = (targets: WaveTargets): WaveTargets => ({
  waterLiters: clampDecimal(targets.waterLiters, 0.5, MAX_WATER_TARGET_LITERS),
  steps: clampAmount(targets.steps, MAX_STEPS_TARGET),
  sleepHours: clampDecimal(targets.sleepHours, 3, MAX_SLEEP_HOURS),
});

const valueOf = (item: WaveActionItem): number => {
  switch (item.action) {
  case "logWater":
  case "unlogWater":
    return clampAmount(item.value, MAX_WATER_ML);
  case "logSet":
    return clampAmount(item.value, MAX_REPS);
  case "logWeight":
    return clampDecimal(item.value, MIN_BODY_WEIGHT_KG, MAX_BODY_WEIGHT_KG);
  case "logSleep":
    return clampDecimal(item.value, 0.5, MAX_SLEEP_HOURS);
  default:
    return 0;
  }
};

const isUsable = (item: WaveActionItem): boolean => {
  switch (item.action) {
  case "none":
    return false;
  case "completeHabit":
  case "uncompleteHabit":
  case "deleteHabit":
  case "logFood":
  case "unlogFood":
  case "swapExercise":
    return item.target.length > 0;
  case "editHabit":
    return item.target.length > 0 && item.habitDraft.title.length > 0;
  case "addHabit":
    return item.habitDraft.title.length > 0 && item.habitDraft.target > 0;
  case "createFood":
    return item.foodDraft.name.length > 0;
  case "logWater":
  case "logSet":
  case "logWeight":
  case "logSleep":
    return item.value > 0;
  case "rescheduleWorkout":
    return DATE_PATTERN.test(item.date);
  case "adjustIntensity":
    return item.intensity !== "none";
  case "setFlowMode":
    return item.mode !== "none";
  case "setReminder":
    return item.reminder !== "none";
  case "updateTargets":
    return item.targets.waterLiters > 0 || item.targets.steps > 0 ||
      item.targets.sleepHours > 0;
  case "navigate":
    return item.screen !== "none";
  default:
    return true;
  }
};

const sanitizeActionItem = (item: WaveActionItem): WaveActionItem => {
  const action = item.action;
  const usesHabitDraft = HABIT_DRAFT_ACTIONS.has(action);
  return {
    action,
    target: TARGETED_ACTIONS.has(action) ? textOf(item.target) : "",
    replacement: action === "swapExercise" ? textOf(item.replacement) : "",
    value: valueOf(item),
    weightKg: action === "logSet" ?
      clampDecimal(item.weightKg, 0, MAX_LIFT_KG) :
      0,
    servings: action === "logFood" ?
      Math.min(Math.max(Math.round(item.servings) || 1, 1), MAX_SERVINGS) :
      0,
    meal: action === "logFood" ? item.meal : "auto",
    date: action === "rescheduleWorkout" ? item.date.trim() : "",
    intensity: action === "adjustIntensity" ? item.intensity : "none",
    mode: action === "setFlowMode" ? item.mode : "none",
    reminder: action === "setReminder" ? item.reminder : "none",
    enabled: action === "setReminder" ? item.enabled : false,
    screen: action === "navigate" ? item.screen : "none",
    targets: action === "updateTargets" ?
      sanitizeTargets(item.targets) :
      EMPTY_TARGETS,
    foodDraft: action === "createFood" ?
      sanitizeFoodDraft(item.foodDraft) :
      EMPTY_FOOD_DRAFT,
    habitDraft: usesHabitDraft ?
      {
        title: textOf(item.habitDraft.title),
        target: clampMacro(item.habitDraft.target),
        metric: item.habitDraft.metric,
      } :
      EMPTY_HABIT_DRAFT,
  };
};

export const sanitizeWaveAnswer = (answer: WaveAnswer): WaveAnswer => {
  const reply = answer.reply.trim().slice(0, MAX_WAVE_REPLY_LENGTH);
  const card = reply.length === 0 ? "none" : answer.card;
  const actions = reply.length === 0 ?
    [] :
    answer.actions
      .map(sanitizeActionItem)
      .filter(isUsable)
      .slice(0, MAX_WAVE_ACTIONS);

  const logsFood = actions.some((item) => FOOD_ACTIONS.has(item.action));
  const shownCard = card === "mealLog" && logsFood ? "none" : card;

  return {
    reply,
    card: shownCard,
    injuryArea: shownCard === "injurySwap" ? answer.injuryArea : "none",
    actions,
    memory: sanitizeMemoryUpdate(answer.memory),
  };
};

export const answerWaveChat = async (
  input: WaveChatInput,
): Promise<WaveChatResult> => {
  const context = buildWaveContext(
    input.profile,
    input.access,
    input.today,
    input.history,
    input.memory,
  );
  const identifier = createHash("sha256").update(input.uid).digest("hex");

  const response = await getOpenAI().responses.parse({
    model: input.route.model,
    reasoning: {effort: input.route.reasoning},
    max_output_tokens: input.route.maxOutputTokens,
    prompt_cache_key: identifier,
    safety_identifier: identifier,
    instructions: WAVE_CHAT_INSTRUCTIONS,
    input: [
      {
        role: "user",
        content: [
          {
            type: "input_text",
            text: buildWaveInput(context, input.turns, input.message),
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
