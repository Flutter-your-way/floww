import {Request, Response} from "express";
import {DocumentData, FieldValue, Transaction} from "firebase-admin/firestore";
import {ApiError, sendData} from "../common/api.error";
import {numberOf, recordOf} from "../common/utils";
import {
  USER_COLLECTIONS,
  firestore,
  onboardingDetailsCollection,
  userCollection,
} from "../constants/collections";
import {
  COMPLETED_STATUS,
  DayActivity,
  flowDocOf,
  flowEntryOf,
  readDayActivity,
} from "../helpers/flow.score.helper";
import {flowDoc} from "../helpers/flow.sync.helper";
import {UserClock, clockOf, loadActiveUser} from "../helpers/user.clock.helper";
import {
  FALLBACK_BODY_WEIGHT_KG,
  bestsOf,
  caloriesOf,
  entriesOf,
  muscleActivationOf,
  personalRecordsOf,
  totalsOf,
  trainingEffectOf,
} from "../helpers/workout.metrics.helper";
import {
  completeWorkoutValidator,
  unlogWorkoutValidator,
} from "../validators/workout.validator";

const HISTORY_LIMIT = 60;

const sessionsOf = (uid: string) =>
  userCollection(uid, USER_COLLECTIONS.workoutSessions);

const planDoc = (uid: string, day: string) =>
  userCollection(uid, USER_COLLECTIONS.workoutPlans).doc(day);

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

    const [history, bodyWeightKg, activity, plan] = await Promise.all([
      transaction.get(
        sessionsOf(uid).orderBy("startedAt", "desc").limit(HISTORY_LIMIT),
      ),
      bodyWeightOf(uid, transaction),
      readDayActivity(transaction, uid, day, clock),
      transaction.get(planDoc(uid, day)),
    ]);

    const entries = entriesOf(body.exercises);
    const totals = totalsOf(entries);
    const previous = history.docs
      .filter((doc) =>
        doc.id !== body.sessionId && doc.get("status") === COMPLETED_STATUS)
      .map((doc) => doc.data());
    const effect = trainingEffectOf(totals, body.durationSeconds);

    const before = withoutSession(activity, body.sessionId, session);
    const beforeEntry = flowEntryOf(day, before);
    const afterEntry = flowEntryOf(day, {
      ...before,
      workoutSets: before.workoutSets + totals.totalSets,
    });

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

    const [activity, plan, stored] = await Promise.all([
      readDayActivity(transaction, uid, day, clock),
      transaction.get(planDoc(uid, day)),
      transaction.get(flowDoc(uid, day)),
    ]);

    const entry = flowEntryOf(
      day,
      withoutSession(activity, body.sessionId, session),
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
