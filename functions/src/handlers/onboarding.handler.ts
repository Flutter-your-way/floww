import {Request, Response} from "express";
import {ApiError, sendData} from "../common/api.error";
import {
  firestore,
  onboardingDetailsCollection,
  usersCollection,
} from "../constants/collections";
import {saveNutritionTargets} from "../helpers/nutrition.goal.helper";
import {loadActiveUser} from "../helpers/user.clock.helper";
import {
  completeOnboardingValidator,
  submitOnboardingValidator,
} from "../validators/onboarding.validator";

export const handleSubmitOnboarding = async (req: Request, res: Response) => {
  const {details} = submitOnboardingValidator.parse(req.body);
  const uid = req.user.uid;
  const now = new Date().toISOString();
  const stored = {...details, uid};

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
