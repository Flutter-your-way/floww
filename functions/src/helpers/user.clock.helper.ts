import {DocumentData, Transaction} from "firebase-admin/firestore";
import {dayKeyAt, numberOf} from "../common/utils";
import {usersCollection} from "../constants/collections";

export const MAX_UTC_OFFSET_MINUTES = 14 * 60;
export const DELETION_FLAG = "deletionRequestedAt";

export interface UserClock {
  offsetMinutes: number;
  today: string;
}

export const offsetOf = (user: DocumentData | undefined): number => {
  const offset = numberOf(user?.utcOffsetMinutes);
  return Math.abs(offset) <= MAX_UTC_OFFSET_MINUTES ? offset : 0;
};

export const clockOf = (
  user: DocumentData | undefined,
  now: Date = new Date(),
): UserClock => {
  const offsetMinutes = offsetOf(user);
  return {offsetMinutes, today: dayKeyAt(now, offsetMinutes)};
};

export const isActiveUser = (user: DocumentData | undefined): boolean =>
  user !== undefined && !user[DELETION_FLAG];

export const loadActiveUser = async (
  uid: string,
  transaction?: Transaction,
): Promise<DocumentData | undefined> => {
  const ref = usersCollection.doc(uid);
  const snapshot = transaction ? await transaction.get(ref) : await ref.get();
  const data = snapshot.data();
  return isActiveUser(data) ? data : undefined;
};
