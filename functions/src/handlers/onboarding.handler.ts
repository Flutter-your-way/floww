import {Request, Response} from "express";
import {logger} from "firebase-functions";
import {ApiError, sendData} from "../common/api.error";
import {ONBOARDING_ANALYSIS_DAILY_LIMIT} from "../constants/ai.constants";
import {
  ONBOARDING_BLUEPRINT_DOC,
  USER_COLLECTIONS,
  firestore,
  onboardingDetailsCollection,
  userCollection,
  usersCollection,
} from "../constants/collections";
import {
  NutritionTargets,
  nutritionTargetsOf,
  saveNutritionTargets,
} from "../helpers/nutrition.goal.helper";
import {
  OnboardingAnalysisResult,
  analyzeOnboardingProfile,
  fallbackOnboardingAnalysis,
} from "../helpers/onboarding.analysis.helper";
import {
  BlueprintRanges,
  OnboardingBlueprint,
  answersHashOf,
  baselineBlueprintOf,
  blueprintRangesOf,
  detailsWithBlueprint,
  resolveBlueprint,
} from "../helpers/onboarding.blueprint.helper";
import {
  recordAiTokens,
  releaseAiQuota,
  reserveAiQuota,
} from "../helpers/usage.helper";
import {loadActiveUser} from "../helpers/user.clock.helper";
import {
  analyzeOnboardingValidator,
  completeOnboardingValidator,
  submitOnboardingValidator,
} from "../validators/onboarding.validator";

const blueprintDoc = (uid: string) =>
  userCollection(uid, USER_COLLECTIONS.targets).doc(ONBOARDING_BLUEPRINT_DOC);

const answersOf = (details: Record<string, unknown>) =>
  Object.fromEntries(
    Object.entries(details).filter(([key]) => key !== "blueprint"),
  );

const savedBlueprintOf = async (
  uid: string,
  answers: Record<string, unknown>,
): Promise<OnboardingBlueprint> => {
  const saved = (await blueprintDoc(uid).get()).data();
  const matches = saved !== undefined &&
    saved.answersHash === answersHashOf(answers) &&
    saved.blueprint !== undefined;
  return matches ?
    saved.blueprint as OnboardingBlueprint :
    baselineBlueprintOf(answers);
};

export const handleSubmitOnboarding = async (req: Request, res: Response) => {
  const {details} = submitOnboardingValidator.parse(req.body);
  const uid = req.user.uid;
  const now = new Date().toISOString();
  const answers = answersOf(details);
  const blueprint = await savedBlueprintOf(uid, answers);
  const stored = {...detailsWithBlueprint(answers, blueprint), uid};

  await firestore.runTransaction(async (transaction) => {
    const user = await loadActiveUser(uid, transaction);
    if (!user) throw new ApiError("UNAUTHORIZED", "Please sign in again.");
    transaction.set(onboardingDetailsCollection.doc(uid), stored);
    transaction.update(usersCollection.doc(uid), {
      answersSubmitted: true,
      updatedAt: now,
    });
  });

  const targets = await saveNutritionTargets(uid, stored);
  sendData(res, {submitted: true, targets});
};

export const handleCompleteOnboarding = async (
  req: Request,
  res: Response,
) => {
  const {wearablesConnected} = completeOnboardingValidator.parse(req.body);
  const uid = req.user.uid;
  const now = new Date().toISOString();

  await firestore.runTransaction(async (transaction) => {
    const user = await loadActiveUser(uid, transaction);
    if (!user) throw new ApiError("UNAUTHORIZED", "Please sign in again.");
    const details = await transaction.get(onboardingDetailsCollection.doc(uid));
    if (!details.exists) {
      throw new ApiError("INVALID_REQUEST", "Finish the questionnaire first.");
    }
    transaction.update(details.ref, {
      "targetsPermissions.wearablesConnected": wearablesConnected,
      "updatedAt": now,
    });
    transaction.update(usersCollection.doc(uid), {
      onboardingCompleted: true,
      updatedAt: now,
    });
  });

  sendData(res, {completed: true});
};

const aiAnalysisOf = async (
  uid: string,
  answers: Record<string, unknown>,
  targets: NutritionTargets,
  baseline: OnboardingBlueprint,
  ranges: BlueprintRanges,
): Promise<OnboardingAnalysisResult | null> => {
  try {
    await reserveAiQuota(uid, "onboardingAnalysis",
      ONBOARDING_ANALYSIS_DAILY_LIMIT);
  } catch (error) {
    logger.warn("handleAnalyzeOnboarding: quota unavailable", {error});
    return null;
  }

  try {
    const result = await analyzeOnboardingProfile(
      answers,
      targets,
      baseline,
      ranges,
    );
    await recordAiTokens(uid, "onboardingAnalysis", result.usage).catch(
      (usageError) => logger.error(
        "handleAnalyzeOnboarding: token usage write failed", {usageError}));
    return result;
  } catch (error) {
    logger.error("handleAnalyzeOnboarding: analysis failed", {error});
    await releaseAiQuota(uid, "onboardingAnalysis").catch((releaseError) =>
      logger.error("handleAnalyzeOnboarding: quota release failed",
        {releaseError}));
    return null;
  }
};

export const handleAnalyzeOnboarding = async (
  req: Request,
  res: Response,
) => {
  const {details} = analyzeOnboardingValidator.parse(req.body);
  const uid = req.user.uid;
  const answers = answersOf(details);
  const baselineTargets = nutritionTargetsOf(answers);
  const baseline = baselineBlueprintOf(answers);
  const ranges = blueprintRangesOf(answers, baseline, baselineTargets);
  const result = await aiAnalysisOf(
    uid,
    answers,
    baselineTargets,
    baseline,
    ranges,
  );
  const blueprint = resolveBlueprint(
    answers,
    baseline,
    baselineTargets,
    result?.proposed ?? null,
  );
  const targets = nutritionTargetsOf(detailsWithBlueprint(answers, blueprint));
  const analysis = result?.analysis ??
    fallbackOnboardingAnalysis(answers, targets);

  await blueprintDoc(uid).set({
    answersHash: answersHashOf(answers),
    blueprint,
    updatedAt: new Date().toISOString(),
  }).catch((error) =>
    logger.error("handleAnalyzeOnboarding: blueprint save failed", {error}));

  sendData(res, {...analysis, targets, blueprint});
};
