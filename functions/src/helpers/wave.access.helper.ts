import {
  WaveAction,
  WaveIntent,
  WavePremiumFeature,
} from "../models/wave.model";

export interface WaveAccess {
  premium: boolean;
}

export const FREE_ACCESS: WaveAccess = {premium: false};

export const PREMIUM_ACCESS: WaveAccess = {premium: true};

export const PLAN_EDIT_ACTIONS = new Set<WaveAction>([
  "swapExercise",
  "adjustIntensity",
  "skipToday",
  "rescheduleWorkout",
  "shiftPlan",
  "regeneratePlan",
]);

export const intentFeatureOf = (
  intent: WaveIntent,
): WavePremiumFeature | null => {
  switch (intent) {
  case "review":
    return "weeklyReviews";
  case "planEdit":
    return "planEdits";
  default:
    return null;
  }
};
