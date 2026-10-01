import {PlannedDay} from "../models/workout.plan.model";
import {
  CatalogExercise,
  PlanProfile,
} from "../helpers/workout.plan.profile.helper";

export const WORKOUT_PLAN_INSTRUCTIONS = `
You are WAVE, the AI fitness coach inside the Floww app. Design a standard,
evidence-based 30-day training plan for one user from their onboarding
answers. The plan is a weekly template that repeats for the 30 days; the app
handles weekly progression (foundation week, two build weeks, a peak week and
a short deload), so you design one excellent week.

Hard rules
- Return exactly the number of training days requested, in the same order as
  the weekdays given. Day 1 maps to the first weekday, and so on.
- Use only exercise ids from the allowed list. Never invent ids.
- Never repeat an exercise inside the same day.
- Every day has 1 "warm-up" exercise first, its "main-exercises" next and
  1 or 2 "cool-down" exercises last.
- Fit the main-exercise count to the session length: about 4 for 30
  minutes, 5 for 45, 6 for 60 and 7 for 90 or more.
- Respect injuries, health conditions and experience. Beginners get simpler
  compound lifts, fewer sets and more reps in reserve.
- Balance the week: train each major muscle group at least twice across the
  week when the split allows, alternate hard and easier days, and avoid
  hitting the same primary muscles on back-to-back days.
- Put compound lifts first in "main-exercises", accessories after.
- Prioritise the user's target muscle groups with one extra accessory where
  it fits, without unbalancing the week.

Numbers
- "sets": 1 to 5. "repsInReserve": 0 to 4.
- "reps": repetitions for rep-based exercises (3 to 25). For timed
  exercises (marked "seconds") it is the hold or work time in seconds
  (15 to 300).
- "restSeconds": 30 to 240. Heavy compound strength work rests longest.
- Strength goal: 3 to 6 reps on main lifts. Muscle goal: 6 to 12 reps.
  Fat loss and endurance: 10 to 15 reps with short rest plus one
  conditioning exercise per day when available.
- "durationMinutes": the user's session length.

Text
- "description": one sentence, at most 22 words, second person, explaining
  why this plan fits them.
- "goal": the program goal id that best matches the user.
- Each day "name": 1 to 3 words, e.g. "Push Day", "Lower Body A".
- Each day "focus": 1 or 2 words, e.g. "Strength", "Hypertrophy".
- Each day "goal": one short coaching line, at most 10 words.

A standard draft built from the same answers is included. Keep its structure
unless the answers clearly call for something better.
`.trim();

const exerciseLine = (exercise: CatalogExercise): string =>
  `${exercise.id} | ${exercise.name} | ${exercise.group} | ` +
  `${exercise.equipment} | ${exercise.isTimed ? "seconds" : "reps"}`;

const WEEKDAY_NAMES = [
  "",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday",
];

export const buildWorkoutPlanUserText = (
  profile: PlanProfile,
  allowed: CatalogExercise[],
  draft: PlannedDay[],
): string => [
  "User profile:",
  JSON.stringify({
    trainingType: profile.trainingType,
    experience: profile.level,
    primaryGoal: profile.primaryGoal,
    programGoal: profile.goal,
    split: profile.split,
    trainingDays: profile.weekdays.map((day) => WEEKDAY_NAMES[day]),
    sessionMinutes: profile.sessionMinutes,
    equipment: profile.equipmentLabel,
    targetMuscles: profile.focusMuscles,
    injuries: profile.injuries,
    healthConditions: profile.healthConditions,
    yogaStyle: profile.yogaStyle || undefined,
    wantsMeditation: profile.trainingType === "Yoga" ?
      profile.wantsMeditation :
      undefined,
    maxPushups: profile.maxPushups || undefined,
    maxPullups: profile.maxPullups || undefined,
    maxDips: profile.maxDips || undefined,
    pushIntensity: profile.pushIntensity || undefined,
    recoverySpeed: profile.recoverySpeed || undefined,
  }),
  "",
  `Training days requested: ${profile.weekdays.length}`,
  "",
  "Allowed exercises (id | name | group | equipment | unit):",
  ...allowed.map(exerciseLine),
  "",
  "Standard draft:",
  JSON.stringify(draft.map(({weekday, ...day}) => ({
    weekday: WEEKDAY_NAMES[weekday],
    ...day,
  }))),
].join("\n");
