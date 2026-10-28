import {FieldPath, Transaction} from "firebase-admin/firestore";
import {
  addDaysToKey,
  dayKeyAt,
  numberOf,
  recordOf,
  startOfWeekKey,
} from "../common/utils";
import {USER_COLLECTIONS, userCollection} from "../constants/collections";
import {UserClock} from "./user.clock.helper";

const STATE_DOC = "state";
const DAYS_PER_WEEK = 7;

const startKeyOf = (
  startedAt: unknown,
  offsetMinutes: number,
): string | null => {
  if (typeof startedAt !== "string") return null;
  const time = Date.parse(startedAt);
  return Number.isFinite(time) ? dayKeyAt(new Date(time), offsetMinutes) : null;
};

export const isProgramActiveOn = (
  activeProgram: unknown,
  day: string,
  offsetMinutes: number,
): boolean => {
  const program = recordOf(activeProgram);
  const startKey = startKeyOf(program.startedAt, offsetMinutes);
  if (startKey === null) return false;

  const shiftDays = Math.trunc(numberOf(program.shiftDays));
  const programDay = addDaysToKey(day, -shiftDays);
  if (programDay < startKey) return false;

  const totalWeeks = Math.trunc(numberOf(program.totalWeeks));
  if (totalWeeks <= 0) return true;

  const totalDays = Math.trunc(numberOf(program.totalDays));
  const endKey = totalDays > 0 ?
    addDaysToKey(startKey, totalDays) :
    addDaysToKey(startOfWeekKey(startKey), totalWeeks * DAYS_PER_WEEK);
  return programDay < endKey;
};

export const readRestDay = async (
  transaction: Transaction,
  uid: string,
  day: string,
  clock: UserClock,
): Promise<boolean> => {
  const plans = userCollection(uid, USER_COLLECTIONS.workoutPlans);
  const [plan, later, state] = await Promise.all([
    transaction.get(plans.doc(day)),
    transaction.get(
      plans.orderBy(FieldPath.documentId()).startAfter(day).limit(1),
    ),
    transaction.get(
      userCollection(uid, USER_COLLECTIONS.workoutState).doc(STATE_DOC),
    ),
  ]);
  if (plan.exists || later.empty) return false;
  const activeProgram = state.get("activeProgram");
  return isProgramActiveOn(activeProgram, day, clock.offsetMinutes);
};
