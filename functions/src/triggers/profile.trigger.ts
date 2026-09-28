import {logger} from "firebase-functions";
import {onDocumentWritten} from "firebase-functions/firestore";
import {numberOf, recordOf} from "../common/utils";
import {
  USER_COLLECTIONS,
  onboardingDetailsCollection,
  userCollection,
} from "../constants/collections";
import {saveNutritionTargets} from "../helpers/nutrition.goal.helper";
import {loadActiveUser} from "../helpers/user.clock.helper";

const WEIGHT_TOLERANCE_KG = 0.01;

export const onOnboardingDetailsWritten = onDocumentWritten(
  "onboarding_details/{uid}",
  async (event) => {
    const uid = event.params.uid;
    const details = event.data?.after.data();
    if (!details || !(await loadActiveUser(uid))) return;
    try {
      await saveNutritionTargets(uid, details);
    } catch (error) {
      logger.error("onOnboardingDetailsWritten: targets failed", {uid, error});
    }
  },
);

export const onWeightLogWritten = onDocumentWritten(
  "users/{uid}/weight_logs/{logId}",
  async (event) => {
    const uid = event.params.uid;
    if (!(await loadActiveUser(uid))) return;

    const latest = await userCollection(uid, USER_COLLECTIONS.weightLogs)
      .orderBy("loggedAt", "desc")
      .limit(1)
      .get();
    const weightKg = numberOf(latest.docs[0]?.get("weightKg"));
    if (weightKg <= 0) return;

    const detailsRef = onboardingDetailsCollection.doc(uid);
    const details = await detailsRef.get();
    if (!details.exists) return;

    const current = numberOf(recordOf(details.get("profile")).weightKg);
    if (Math.abs(current - weightKg) < WEIGHT_TOLERANCE_KG) return;

    await detailsRef.update({
      "profile.weightKg": weightKg,
      "updatedAt": new Date().toISOString(),
    });
  },
);
