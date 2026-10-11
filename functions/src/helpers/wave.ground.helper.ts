import {
  WaveActionItem,
  WavePremiumFeature,
  WaveRejectedAction,
} from "../models/wave.model";
import {PLAN_EDIT_ACTIONS, WaveAccess} from "./wave.access.helper";
import {
  WORKOUT_IN_PROGRESS,
  WORKOUT_PLANNED,
  WaveFacts,
} from "./wave.facts.helper";

type Verdict = WaveRejectedAction["reason"] | null;

export interface WaveGrounding {
  actions: WaveActionItem[];
  rejected: WaveRejectedAction[];
  locked: WavePremiumFeature[];
}

const matchesName = (value: string, wanted: string): boolean => {
  const name = value.trim().toLowerCase();
  const target = wanted.trim().toLowerCase();
  if (name.length === 0 || target.length === 0) return false;
  return name.includes(target) || target.includes(name);
};

const matchesAny = (values: string[], wanted: string): boolean =>
  values.some((value) => matchesName(value, wanted));

const verdictOf = (
  item: WaveActionItem,
  facts: WaveFacts,
  created: string[],
): Verdict => {
  const habits = facts.habits.map((habit) => habit.title);
  const planEditable = facts.workoutStatus === WORKOUT_PLANNED;
  const inProgress = facts.workoutStatus === WORKOUT_IN_PROGRESS;

  switch (item.action) {
  case "completeAllHabits":
    return facts.habits.some((habit) => !habit.done) ? null : "notAvailable";
  case "completeHabit":
  case "uncompleteHabit":
  case "editHabit":
  case "deleteHabit":
    return matchesAny(habits, item.target) ? null : "notFound";
  case "logFood":
    return matchesAny([...facts.knownFoods, ...created], item.target) ?
      null :
      "notFound";
  case "unlogFood":
    return matchesAny(facts.loggedFoods.map((food) => food.name),
      item.target) ? null : "notFound";
  case "startWorkout":
    return planEditable || inProgress ? null : "notAvailable";
  case "logSet":
    if (!inProgress) return "notAvailable";
    return item.target.length === 0 ||
      matchesAny(facts.activeExercises, item.target) ? null : "notFound";
  case "completeWorkout":
  case "cancelWorkout":
    return inProgress ? null : "notAvailable";
  case "swapExercise":
    if (!planEditable) return "notAvailable";
    return matchesAny(facts.planExercises, item.target) ? null : "notFound";
  case "adjustIntensity":
  case "skipToday":
  case "rescheduleWorkout":
  case "shiftPlan":
    return planEditable ? null : "notAvailable";
  default:
    return null;
  }
};

export const groundWaveActions = (
  actions: WaveActionItem[],
  facts: WaveFacts,
  access: WaveAccess,
): WaveGrounding => {
  const grounded: WaveGrounding = {actions: [], rejected: [], locked: []};
  const created: string[] = [];

  for (const item of actions) {
    const verdict = !access.premium && PLAN_EDIT_ACTIONS.has(item.action) ?
      "premium" :
      verdictOf(item, facts, created);

    if (verdict === null) {
      if (item.action === "createFood") created.push(item.foodDraft.name);
      grounded.actions.push(item);
      continue;
    }

    grounded.rejected.push({
      action: item.action,
      target: item.target,
      reason: verdict,
    });
    if (verdict === "premium" && !grounded.locked.includes("planEdits")) {
      grounded.locked.push("planEdits");
    }
  }

  return grounded;
};
