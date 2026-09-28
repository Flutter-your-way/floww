import {DocumentData} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {onSchedule} from "firebase-functions/scheduler";
import {addDaysToKey, dayKeyAt, numberOf} from "../common/utils";
import {usersCollection} from "../constants/collections";
import {
  NotificationId,
  isNotificationEnabled,
  offsetsAtLocalTime,
  sendPush,
  tokensOf,
} from "../helpers/notification.helper";
import {statsDoc} from "../helpers/stats.helper";
import {isActiveUser, offsetOf} from "../helpers/user.clock.helper";

const WINDOW_MINUTES = 30;
const STREAK_ALERT_MINUTE = 20 * 60;
const WEEKLY_SUMMARY_MINUTE = 19 * 60;
const SUNDAY = 0;
const MAX_OFFSETS_PER_QUERY = 30;
const MS_PER_MINUTE = 60_000;

interface ReminderContext {
  uid: string;
  today: string;
  stats: DocumentData;
}

type ReminderMessage = {title: string; body: string} | null;

const streakAlertOf = ({stats, today}: ReminderContext): ReminderMessage => {
  const streak = numberOf(stats.currentStreak);
  const activeToday = stats.today === today && numberOf(stats.todayScore) > 0;
  if (streak <= 0 || activeToday) return null;
  return {
    title: `Your ${streak}-day streak is on the line`,
    body: "Log a meal, some water or a habit to keep your flow going.",
  };
};

const WEEK_DAYS = 7;

const weeklySummaryOf = ({stats, today}: ReminderContext): ReminderMessage => {
  const average = numberOf(stats.weeklyAverage);
  const isRecent = typeof stats.today === "string" &&
    stats.today > addDaysToKey(today, -WEEK_DAYS);
  if (average <= 0 || !isRecent) return null;
  return {
    title: "Your week in flow",
    body: `Average Flow Score ${average}. Current streak ` +
      `${numberOf(stats.currentStreak)} days. See your full report.`,
  };
};

const sendReminders = async (
  id: NotificationId,
  localMinute: number,
  build: (context: ReminderContext) => ReminderMessage,
  isLocalDay?: (weekday: number) => boolean,
): Promise<number> => {
  const now = new Date();
  const offsets = offsetsAtLocalTime(now, localMinute, WINDOW_MINUTES)
    .filter((offset) => !isLocalDay ||
      isLocalDay(new Date(now.getTime() + offset * MS_PER_MINUTE).getUTCDay()));
  let sent = 0;

  for (let index = 0; index < offsets.length;
    index += MAX_OFFSETS_PER_QUERY) {
    const batch = offsets.slice(index, index + MAX_OFFSETS_PER_QUERY);
    const users = await usersCollection
      .where("utcOffsetMinutes", "in", batch)
      .get();

    for (const doc of users.docs) {
      const user = doc.data();
      const tokens = tokensOf(user);
      if (!isActiveUser(user) || tokens.length === 0) continue;
      try {
        if (!(await isNotificationEnabled(doc.id, id))) continue;
        const stats = (await statsDoc(doc.id).get()).data();
        if (!stats) continue;
        const message = build({
          uid: doc.id,
          today: dayKeyAt(now, offsetOf(user)),
          stats,
        });
        if (!message) continue;
        await sendPush(doc.id, tokens, message.title, message.body, {type: id});
        sent++;
      } catch (error) {
        logger.error("sendReminders: user failed", {uid: doc.id, id, error});
      }
    }
  }
  return sent;
};

export const sendScheduledReminders = onSchedule(
  {schedule: "0,30 * * * *", timeZone: "UTC"},
  async () => {
    const streak = await sendReminders(
      "streak_alerts",
      STREAK_ALERT_MINUTE,
      streakAlertOf,
    );
    const weekly = await sendReminders(
      "weekly_summary",
      WEEKLY_SUMMARY_MINUTE,
      weeklySummaryOf,
      (weekday) => weekday === SUNDAY,
    );
    logger.info("sendScheduledReminders: done", {streak, weekly});
  },
);
