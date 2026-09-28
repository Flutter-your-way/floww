import {DocumentData} from "firebase-admin/firestore";

export interface WaveProfile {
  digest: string;
  communicationStyle: string;
  pushIntensity: string;
  badDayBehaviour: string;
}

const text = (value: unknown): string =>
  typeof value === "string" ? value.trim() : "";

const list = (value: unknown): string[] =>
  Array.isArray(value) ?
    value.map(text).filter((item) => item.length > 0) :
    [];

const joined = (value: unknown): string => {
  const items = list(value);
  return items.length > 0 ? items.join(", ") : "";
};

const amount = (value: unknown): string => {
  if (typeof value !== "number" || !Number.isFinite(value)) return "";
  return Number.isInteger(value) ? `${value}` : value.toFixed(1);
};

const ageOf = (value: unknown): string => {
  const born = new Date(text(value));
  if (Number.isNaN(born.getTime())) return "";
  const now = new Date();
  let age = now.getFullYear() - born.getFullYear();
  const monthDelta = now.getMonth() - born.getMonth();
  if (monthDelta < 0 || (monthDelta === 0 && now.getDate() < born.getDate())) {
    age -= 1;
  }
  return age > 0 && age < 120 ? `${age}` : "";
};

const map = (value: unknown): DocumentData =>
  value !== null && typeof value === "object" ? value as DocumentData : {};

const line = (label: string, parts: (string | undefined)[]): string | null => {
  const body = parts.filter((part) => !!part && part.length > 0).join(" · ");
  return body.length > 0 ? `${label}: ${body}` : null;
};

const trainingLine = (details: DocumentData): string | null => {
  const gym = map(details.gymDetails);
  const cal = map(details.calisthenicsDetails);
  const yoga = map(details.yogaDetails);

  if (Object.keys(gym).length > 0) {
    return line("Gym", [
      text(gym.experienceLevel),
      joined(gym.goals),
      `${list(gym.trainingDays).length} days/week`,
      text(gym.workoutDuration),
      text(gym.equipment),
      text(gym.preferredSplit) && `${text(gym.preferredSplit)} split`,
      joined(gym.targetMuscleGroups) &&
        `focus ${joined(gym.targetMuscleGroups)}`,
    ]);
  }

  if (Object.keys(cal).length > 0) {
    return line("Calisthenics", [
      text(cal.experienceLevel),
      amount(cal.maxPushups) && `${amount(cal.maxPushups)} pushups`,
      amount(cal.maxPullups) && `${amount(cal.maxPullups)} pullups`,
      amount(cal.maxDips) && `${amount(cal.maxDips)} dips`,
      joined(cal.skillGoals) && `working toward ${joined(cal.skillGoals)}`,
      joined(cal.equipment),
      `${list(cal.trainingDays).length} days/week`,
      joined(cal.injuries) && `injuries ${joined(cal.injuries)}`,
    ]);
  }

  if (Object.keys(yoga).length > 0) {
    return line("Yoga", [
      text(yoga.experienceLevel),
      text(yoga.preferredStyle),
      text(yoga.primaryGoal),
      text(yoga.flexibilityLevel) &&
        `${text(yoga.flexibilityLevel)} flexibility`,
      text(yoga.practiceDuration),
      `${list(yoga.practiceDays).length} days/week`,
      joined(yoga.injuries) && `injuries ${joined(yoga.injuries)}`,
    ]);
  }

  return null;
};

export interface WaveProgress {
  stats: DocumentData;
  targets: DocumentData;
}

export const buildWaveProfile = (
  user: DocumentData,
  details: DocumentData,
  progress: WaveProgress = {stats: {}, targets: {}},
): WaveProfile => {
  const stats = progress.stats;
  const nutrition = progress.targets;
  const profile = map(details.profile);
  const goals = map(details.goalsActivity);
  const health = map(details.healthDiet);
  const setup = map(details.trainingSetup);
  const targets = map(details.targetsPermissions);
  const flo = map(details.floState);

  const name = text(profile.name) || text(user.displayName);
  const weight = amount(profile.weightKg);
  const target = amount(goals.targetWeightKg);

  const lines = [
    line("Name", [name || "there"]),
    line("Body", [
      ageOf(profile.dateOfBirth) && `${ageOf(profile.dateOfBirth)}y`,
      text(profile.biologicalSex),
      amount(profile.heightCm) && `${amount(profile.heightCm)}cm`,
      weight && `${weight}kg`,
      target && `target ${target}kg`,
    ]),
    line("Goal", [
      text(goals.primaryGoal),
      text(goals.activityLevel),
      text(health.motivation) && `motivated by ${text(health.motivation)}`,
    ]),
    line("Sleep", [
      text(goals.sleepTime) && text(goals.wakeTime) &&
        `${text(goals.sleepTime)}-${text(goals.wakeTime)}`,
      amount(targets.sleepTargetHours) &&
        `${amount(targets.sleepTargetHours)}h target`,
    ]),
    line("Targets", [
      amount(targets.stepsTarget) && `${amount(targets.stepsTarget)} steps`,
      amount(targets.waterTargetLiters) &&
        `${amount(targets.waterTargetLiters)}L water`,
    ]),
    line("Diet", [
      text(health.preferredDiet),
      joined(health.dietaryRestrictions) &&
        `restrictions ${joined(health.dietaryRestrictions)}`,
    ]),
    line("Allergies", [joined(health.foodAllergies) || "none reported"]),
    line("Health", [joined(health.healthConditions) || "none reported"]),
    line("Trains", [
      text(setup.trainingType),
      text(setup.experienceLevel),
    ]),
    trainingLine(details),
    line("Energy", [
      text(flo.morningEnergy) && `${text(flo.morningEnergy)} in the morning`,
      text(flo.recoverySpeed) && `recovers ${text(flo.recoverySpeed)}`,
      text(flo.stressLevel) && `${text(flo.stressLevel)} stress`,
      text(flo.sleepQuality) && `${text(flo.sleepQuality)} sleep quality`,
    ]),
    line("Skips workouts when", [joined(flo.missWorkoutReasons)]),
    line("On a bad day wants to", [text(flo.badDayBehaviour)]),
    line("Daily nutrition targets", [
      amount(nutrition.calories) && `${amount(nutrition.calories)} kcal`,
      amount(nutrition.proteinG) && `${amount(nutrition.proteinG)}g protein`,
      amount(nutrition.carbsG) && `${amount(nutrition.carbsG)}g carbs`,
      amount(nutrition.fatsG) && `${amount(nutrition.fatsG)}g fat`,
    ]),
    line("Flow streak", [
      amount(stats.currentStreak) && `${amount(stats.currentStreak)} days now`,
      amount(stats.longestStreak) && `best ${amount(stats.longestStreak)}`,
      amount(stats.weeklyAverage) &&
        `7-day avg score ${amount(stats.weeklyAverage)}`,
    ]),
    line("Plan", [text(user.planName), text(user.isPremium ? "premium" : "")]),
  ].filter((item): item is string => item !== null);

  return {
    digest: lines.join("\n"),
    communicationStyle: text(flo.communicationStyle),
    pushIntensity: text(flo.pushIntensity),
    badDayBehaviour: text(flo.badDayBehaviour),
  };
};
