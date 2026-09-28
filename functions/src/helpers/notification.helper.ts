import {DocumentData, FieldValue} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {logger} from "firebase-functions";
import {listOf, recordOf} from "../common/utils";
import {
  SETTINGS_DOC,
  USER_COLLECTIONS,
  userCollection,
  usersCollection,
} from "../constants/collections";

const MINUTES_PER_DAY = 24 * 60;
const OFFSET_STEP_MINUTES = 15;
const MIN_OFFSET_MINUTES = -12 * 60;
const MAX_OFFSET_MINUTES = 14 * 60;
const STALE_TOKEN_CODES = [
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
];

export type NotificationId = "streak_alerts" | "weekly_summary";

const DEFAULT_ENABLED: Record<NotificationId | "master", boolean> = {
  master: true,
  streak_alerts: false,
  weekly_summary: true,
};

export const offsetsAtLocalTime = (
  now: Date,
  localMinute: number,
  windowMinutes: number,
): number[] => {
  const utcMinute = now.getUTCHours() * 60 + now.getUTCMinutes();
  const offsets: number[] = [];
  for (let offset = MIN_OFFSET_MINUTES; offset <= MAX_OFFSET_MINUTES;
    offset += OFFSET_STEP_MINUTES) {
    const local = ((utcMinute + offset) % MINUTES_PER_DAY + MINUTES_PER_DAY) %
      MINUTES_PER_DAY;
    if (local >= localMinute && local < localMinute + windowMinutes) {
      offsets.push(offset);
    }
  }
  return offsets;
};

export const isNotificationEnabled = async (
  uid: string,
  id: NotificationId,
): Promise<boolean> => {
  const settings = await userCollection(uid, USER_COLLECTIONS.settings)
    .doc(SETTINGS_DOC)
    .get();
  const stored = recordOf(settings.get("notifications"));
  const flag = (key: NotificationId | "master") =>
    typeof stored[key] === "boolean" ?
      stored[key] as boolean :
      DEFAULT_ENABLED[key];
  return flag("master") && flag(id);
};

export const tokensOf = (user: DocumentData): string[] =>
  listOf(user.fcmToken).filter(
    (token): token is string => typeof token === "string" && token.length > 0,
  );

export const sendPush = async (
  uid: string,
  tokens: string[],
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<void> => {
  if (tokens.length === 0) return;
  const response = await getMessaging().sendEachForMulticast({
    tokens,
    notification: {title, body},
    data,
  });

  const stale = response.responses
    .map((result, index) => ({result, token: tokens[index]}))
    .filter(({result}) =>
      !result.success &&
      STALE_TOKEN_CODES.includes(result.error?.code ?? ""))
    .map(({token}) => token);
  if (stale.length === 0) return;

  await usersCollection.doc(uid).update({
    fcmToken: FieldValue.arrayRemove(...stale),
  }).catch((error) =>
    logger.error("sendPush: stale token cleanup failed", {uid, error}));
};
