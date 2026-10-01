import {Request, Response} from "express";
import {logger} from "firebase-functions";
import {DocumentData, FieldValue, Transaction} from "firebase-admin/firestore";
import {ApiError, sendData} from "../common/api.error";
import {numberOf, recordOf} from "../common/utils";
import {WORKOUT_PLAN_DAILY_LIMIT} from "../constants/ai.constants";
import {
  USER_COLLECTIONS,
  WORKOUT_STATE_DOC,
  firestore,
  onboardingDetailsCollection,
  userCollection,
} from "../constants/collections";
import {GeneratedProgram, PlannedDay} from "../models/workout.plan.model";
import {
  recordAiTokens,
  releaseAiQuota,
  reserveAiQuota,
} from "../helpers/usage.helper";
import {
  aiProgramOf,
  draftOf,
  generateAiPlan,
  hasUsableDraft,
  standardProgramOf,
} from "../helpers/workout.plan.helper";
import {
  CatalogExercise,
  PlanProfile,
  allowedExercisesOf,
  catalogExerciseOf,
  planProfileOf,
} from "../helpers/workout.plan.profile.helper";
import {
  COMPLETED_STATUS,
  DayActivity,
  flowDocOf,
  flowEntryOf,
  readDayActivity,
  sessionPlannedSetsOf,
} from "../helpers/flow.score.helper";
import {readDayReadiness} from "../helpers/flow.readiness.helper";
import {flowDoc} from "../helpers/flow.sync.helper";
import {UserClock, clockOf, loadActiveUser} from "../helpers/user.clock.helper";
import {
  FALLBACK_BODY_WEIGHT_KG,
  bestsOf,
  caloriesOf,
  entriesOf,
  muscleActivationOf,
  personalRecordsOf,
  plannedSetsOf,
  totalsOf,
  trainingEffectOf,
} from "../helpers/workout.metrics.helper";
import {
  completeWorkoutValidator,
  generateWorkoutPlanValidator,
  unlogWorkoutValidator,
} from "../validators/workout.validator";

const HISTORY_LIMIT = 60;

const sessionsOf = (uid: string) =>
  userCollection(uid, USER_COLLECTIONS.workoutSessions);

const planDoc = (uid: string, day: string) =>
  userCollection(uid, USER_COLLECTIONS.workoutPlans).doc(day);

const planDayOf = (session: DocumentData): string =>
  typeof session.planDate === "string" ? session.planDate : session.date;

const requireUser = async (
  uid: string,
  transaction: Transaction,
): Promise<UserClock> => {
  const user = await loadActiveUser(uid, transaction);
  if (!user) throw new ApiError("UNAUTHORIZED", "Please sign in again.");
  return clockOf(user);
};

const requireSession = async (
  uid: string,
  sessionId: string,
  transaction: Transaction,
): Promise<DocumentData> => {
  const snapshot = await transaction.get(sessionsOf(uid).doc(sessionId));
  const data = snapshot.data();
  if (!data || typeof data.date !== "string") {
    throw new ApiError("NOT_FOUND", "This workout no longer exists.");
  }
  return data;
};

const bodyWeightOf = async (
  uid: string,
  transaction: Transaction,
): Promise<number> => {
  const latest = await transaction.get(
    userCollection(uid, USER_COLLECTIONS.weightLogs)
      .orderBy("loggedAt", "desc")
      .limit(1),
  );
  const logged = numberOf(latest.docs[0]?.get("weightKg"));
  if (logged > 0) return logged;

  const details = await transaction.get(onboardingDetailsCollection.doc(uid));
  const profileWeight = numberOf(recordOf(details.get("profile")).weightKg);
  return profileWeight > 0 ? profileWeight : FALLBACK_BODY_WEIGHT_KG;
};

const withoutSession = (
  activity: DayActivity,
  sessionId: string,
  session: DocumentData,
): DayActivity => {
  if (!activity.sessionIds.includes(sessionId)) return activity;
  return {
    ...activity,
    workoutSets: Math.max(
      0,
      activity.workoutSets - numberOf(session.totalSets),
    ),
    workoutPlannedSets: Math.max(
      0,
      activity.workoutPlannedSets - sessionPlannedSetsOf(session),
    ),
    sessionIds: activity.sessionIds.filter((id) => id !== sessionId),
  };
};

export const handleCompleteWorkout = async (req: Request, res: Response) => {
  const body = completeWorkoutValidator.parse(req.body);
  const uid = req.user.uid;

  const result = await firestore.runTransaction(async (transaction) => {
    const clock = await requireUser(uid, transaction);
    const session = await requireSession(uid, body.sessionId, transaction);
    const day: string = session.date;

    const [history, bodyWeightKg, activity, plan, readiness] =
      await Promise.all([
        transaction.get(
          sessionsOf(uid).orderBy("startedAt", "desc").limit(HISTORY_LIMIT),
        ),
        bodyWeightOf(uid, transaction),
        readDayActivity(transaction, uid, day, clock),
        transaction.get(planDoc(uid, planDayOf(session))),
        readDayReadiness(transaction, uid, day),
      ]);

    const entries = entriesOf(body.exercises);
    const totals = totalsOf(entries);
    const plannedSets = plannedSetsOf(entries);
    const previous = history.docs
      .filter((doc) =>
        doc.id !== body.sessionId && doc.get("status") === COMPLETED_STATUS)
      .map((doc) => doc.data());
    const effect = trainingEffectOf(totals, body.durationSeconds);

    const before = withoutSession(activity, body.sessionId, session);
    const beforeEntry = flowEntryOf(day, before, readiness);
    const afterEntry = flowEntryOf(day, {
      ...before,
      workoutSets: before.workoutSets + totals.totalSets,
      workoutPlannedSets: before.workoutPlannedSets + plannedSets,
    }, readiness);

    const heartRate = body.heartRate;
    const payload: DocumentData = {
      status: COMPLETED_STATUS,
      completedAt: new Date().toISOString(),
      durationSeconds: body.durationSeconds,
      isTimerPaused: true,
      restEndsAt: null,
      restRemainingSeconds: 0,
      currentEntryId: null,
      exercises: body.exercises,
      volumeKg: totals.volumeKg,
      totalSets: totals.totalSets,
      plannedSets,
      totalReps: totals.totalReps,
      exerciseCount: totals.exerciseCount,
      caloriesKcal: caloriesOf(totals, body.durationSeconds, bodyWeightKg),
      trainingEffect: effect,
      muscleActivation: muscleActivationOf(entries),
      personalRecords: personalRecordsOf(entries, bestsOf(previous)),
      flowPoints: afterEntry.score - beforeEntry.score,
      flowScoreBefore: beforeEntry.score,
      flowScoreAfter: afterEntry.score,
      heartRateSamples: heartRate?.samples ?? [],
      ...(heartRate?.average ? {averageHeartRate: heartRate.average} : {}),
      ...(heartRate?.peak ? {peakHeartRate: heartRate.peak} : {}),
    };

    transaction.set(sessionsOf(uid).doc(body.sessionId), payload,
      {merge: true});
    transaction.set(flowDoc(uid, day), flowDocOf(afterEntry));
    if (plan.exists) {
      transaction.update(plan.ref, {sessionId: body.sessionId});
    }

    return {
      session: {...session, ...payload, id: body.sessionId},
      flowScoreBefore: beforeEntry.score,
      flowScoreAfter: afterEntry.score,
    };
  });

  sendData(res, result);
};

export const handleUnlogWorkout = async (req: Request, res: Response) => {
  const body = unlogWorkoutValidator.parse(req.body);
  const uid = req.user.uid;

  await firestore.runTransaction(async (transaction) => {
    const clock = await requireUser(uid, transaction);
    const session = await requireSession(uid, body.sessionId, transaction);
    const day: string = session.date;

    const [activity, plan, stored, readiness] = await Promise.all([
      readDayActivity(transaction, uid, day, clock),
      transaction.get(planDoc(uid, planDayOf(session))),
      transaction.get(flowDoc(uid, day)),
      readDayReadiness(transaction, uid, day),
    ]);

    const entry = flowEntryOf(
      day,
      withoutSession(activity, body.sessionId, session),
      readiness,
    );

    transaction.delete(sessionsOf(uid).doc(body.sessionId));
    if (plan.exists && plan.get("sessionId") === body.sessionId) {
      transaction.update(plan.ref, {sessionId: FieldValue.delete()});
    }
    if (stored.exists || entry.score > 0) {
      transaction.set(stored.ref, flowDocOf(entry));
    }
  });

  sendData(res, {unlogged: true});
};

const workoutStateDoc = (uid: string) =>
  userCollection(uid, USER_COLLECTIONS.workoutState).doc(WORKOUT_STATE_DOC);

const loadCatalog = async (uid: string): Promise<CatalogExercise[]> => {
  const snapshot = await userCollection(uid, USER_COLLECTIONS.workoutExercises)
    .get();
  return snapshot.docs
    .map((doc) => catalogExerciseOf(doc.data()))
    .filter((exercise): exercise is CatalogExercise => exercise !== null);
};

const aiProgramFor = async (
  uid: string,
  profile: PlanProfile,
  allowed: CatalogExercise[],
  draft: PlannedDay[],
): Promise<GeneratedProgram | null> => {
  try {
    await reserveAiQuota(uid, "workoutPlan", WORKOUT_PLAN_DAILY_LIMIT);
  } catch (error) {
    logger.warn("handleGenerateWorkoutPlan: quota unavailable", {error});
    return null;
  }
  try {
    const result = await generateAiPlan(profile, allowed, draft);
    await recordAiTokens(uid, "workoutPlan", result.usage).catch(
      (usageError) => logger.error(
        "handleGenerateWorkoutPlan: token usage write failed", {usageError}));
    return aiProgramOf(profile, draft, result.output, allowed);
  } catch (error) {
    logger.error("handleGenerateWorkoutPlan: AI plan failed", {error});
    await releaseAiQuota(uid, "workoutPlan").catch((releaseError) =>
      logger.error("handleGenerateWorkoutPlan: quota release failed",
        {releaseError}));
    return null;
  }
};

export const handleGenerateWorkoutPlan = async (
  req: Request,
  res: Response,
) => {
  const {useAi = true} = generateWorkoutPlanValidator.parse(req.body ?? {});
  const uid = req.user.uid;

  const [user, details, catalog] = await Promise.all([
    loadActiveUser(uid),
    onboardingDetailsCollection.doc(uid).get(),
    loadCatalog(uid),
  ]);
  if (!user) throw new ApiError("UNAUTHORIZED", "Please sign in again.");
  const answers = details.data();
  if (!answers) {
    throw new ApiError("INVALID_REQUEST", "Finish onboarding first.");
  }

  const profile = planProfileOf(answers);
  const allowed = allowedExercisesOf(catalog, profile, answers);
  const draft = draftOf(profile, allowed);
  if (!hasUsableDraft(draft)) {
    throw new ApiError(
      "INVALID_REQUEST",
      "Your exercise library is still syncing. Try again in a moment.",
    );
  }

  const program = (useAi ?
    await aiProgramFor(uid, profile, allowed, draft) :
    null) ?? standardProgramOf(profile, draft);

  const batch = firestore.batch();
  batch.set(
    userCollection(uid, USER_COLLECTIONS.workoutPrograms).doc(program.id),
    program,
  );
  batch.set(workoutStateDoc(uid), {
    generatedProgramId: program.id,
    planGeneratedAt: program.generatedAt,
  }, {merge: true});
  await batch.commit();

  sendData(res, {program});
};
