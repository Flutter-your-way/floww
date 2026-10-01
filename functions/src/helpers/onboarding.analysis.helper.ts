import {DocumentData} from "firebase-admin/firestore";
import {zodTextFormat} from "openai/helpers/zod";
import {ApiError} from "../common/api.error";
import {listOf, recordOf} from "../common/utils";
import {
  MAX_ONBOARDING_DETAILS_LENGTH,
  ONBOARDING_ANALYSIS_INSIGHT_COUNT,
  ONBOARDING_ANALYSIS_MODEL,
  ONBOARDING_ANALYSIS_REASONING_EFFORT,
} from "../constants/ai.constants";
import {
  OnboardingAnalysis,
  OnboardingInsight,
  onboardingAnalysisOutputSchema,
} from "../models/onboarding.analysis.model";
import {
  ONBOARDING_ANALYSIS_INSTRUCTIONS,
  buildOnboardingAnalysisUserText,
} from "../prompts/onboarding.analysis.prompt";
import {NutritionTargets} from "./nutrition.goal.helper";
import {
  BlueprintRanges,
  OnboardingBlueprint,
  ProposedBlueprint,
} from "./onboarding.blueprint.helper";
import {getOpenAI} from "./openai.helper";
import {AiTokenUsage} from "./usage.helper";

export interface OnboardingAnalysisResult {
  analysis: OnboardingAnalysis;
  proposed: ProposedBlueprint;
  usage: AiTokenUsage;
}

const OMITTED_KEYS = [
  "uid",
  "startedAt",
  "completedAt",
  "updatedAt",
  "blueprint",
];

const TRAINING_SECTIONS: Record<string, string> = {
  Gym: "gymDetails",
  Calisthenics: "calisthenicsDetails",
  Yoga: "yogaDetails",
};

const textOf = (value: unknown): string =>
  typeof value === "string" ? value.trim() : "";

const serializeDetails = (details: DocumentData): string => {
  const kept = Object.fromEntries(
    Object.entries(details).filter(([key]) => !OMITTED_KEYS.includes(key)),
  );
  return JSON.stringify(kept).slice(0, MAX_ONBOARDING_DETAILS_LENGTH);
};

const firstNameOf = (details: DocumentData): string =>
  textOf(recordOf(details.profile).name).split(/\s+/)[0] || "there";

const sanitizeInsight = (insight: OnboardingInsight): OnboardingInsight => ({
  title: insight.title.trim(),
  body: insight.body.trim(),
});

const sanitizeAnalysis = (
  analysis: OnboardingAnalysis,
): OnboardingAnalysis => ({
  headline: analysis.headline.trim(),
  summary: analysis.summary.trim(),
  insights: analysis.insights
    .map(sanitizeInsight)
    .filter((insight) => insight.title && insight.body)
    .slice(0, ONBOARDING_ANALYSIS_INSIGHT_COUNT),
});

export const analyzeOnboardingProfile = async (
  details: DocumentData,
  targets: NutritionTargets,
  baseline: OnboardingBlueprint,
  ranges: BlueprintRanges,
): Promise<OnboardingAnalysisResult> => {
  const response = await getOpenAI().responses.parse({
    model: ONBOARDING_ANALYSIS_MODEL,
    reasoning: {effort: ONBOARDING_ANALYSIS_REASONING_EFFORT},
    instructions: ONBOARDING_ANALYSIS_INSTRUCTIONS,
    input: [
      {
        role: "user",
        content: [
          {
            type: "input_text",
            text: buildOnboardingAnalysisUserText(
              serializeDetails(details),
              targets,
              baseline,
              ranges,
            ),
          },
        ],
      },
    ],
    text: {
      format: zodTextFormat(
        onboardingAnalysisOutputSchema,
        "onboarding_analysis",
      ),
    },
  });

  const parsed = response.output_parsed;
  if (!parsed || !parsed.headline.trim() || !parsed.summary.trim()) {
    throw new ApiError("AI_FAILED", "WAVE could not analyze your profile.");
  }

  const {blueprint, ...analysis} = parsed;
  return {
    analysis: sanitizeAnalysis(analysis),
    proposed: blueprint,
    usage: {
      inputTokens: response.usage?.input_tokens ?? 0,
      outputTokens: response.usage?.output_tokens ?? 0,
    },
  };
};

const trainingInsightOf = (details: DocumentData): OnboardingInsight => {
  const setup = recordOf(details.trainingSetup);
  const type = textOf(setup.trainingType);
  const section = recordOf(details[TRAINING_SECTIONS[type] ?? ""]);
  const days = listOf(section.trainingDays ?? section.practiceDays).length;
  const duration = textOf(section.workoutDuration ?? section.practiceDuration);
  const level = textOf(setup.experienceLevel).toLowerCase();

  if (!type) {
    return {
      title: "Training rhythm",
      body: "WAVE will start you with a manageable weekly rhythm and " +
        "build intensity as your consistency grows.",
    };
  }

  const schedule = days > 0 ?
    ` ${days} ${days === 1 ? "day" : "days"} a week` :
    "";
  const length = duration ? ` in ${duration} sessions` : "";
  return {
    title: `${type} plan`,
    body: `Your ${level ? `${level} ` : ""}${type.toLowerCase()} plan ` +
      `runs${schedule}${length}, progressing only as fast as you recover.`,
  };
};

export const fallbackOnboardingAnalysis = (
  details: DocumentData,
  targets: NutritionTargets,
): OnboardingAnalysis => {
  const goals = recordOf(details.goalsActivity);
  const diet = recordOf(details.healthDiet);
  const permissions = recordOf(details.targetsPermissions);
  const goal = textOf(goals.primaryGoal) || "fitness";
  const activity = textOf(goals.activityLevel).toLowerCase();
  const dietLabel = textOf(diet.preferredDiet).toLowerCase();
  const preferredDiet = dietLabel.startsWith("none") ? "" : dietLabel;
  const sleepHours = Number(permissions.sleepTargetHours);
  const liters = Math.round(targets.waterMl / 100) / 10;

  return {
    headline: `${firstNameOf(details)}, your starting point is set`,
    summary: `Your plan is built around your ${goal.toLowerCase()} goal` +
      `${activity ? ` and a ${activity} daily routine` : ""}. ` +
      `Aim for ${targets.calories} kcal and ${targets.proteinG} g of ` +
      "protein a day while WAVE learns how your body responds.",
    insights: [
      trainingInsightOf(details),
      {
        title: "Fuel the goal",
        body: `Hit ${targets.proteinG} g of protein across your meals` +
          `${preferredDiet ? ` with your ${preferredDiet} diet` : ""}, ` +
          `and keep calories close to ${targets.calories} kcal.`,
      },
      {
        title: "Recover to progress",
        body: `Drink about ${liters} L of water daily` +
          (Number.isFinite(sleepHours) && sleepHours > 0 ?
            ` and protect ${Math.round(sleepHours)} hours of sleep` :
            "") +
          ". Consistent recovery is what turns effort into results.",
      },
    ],
  };
};
