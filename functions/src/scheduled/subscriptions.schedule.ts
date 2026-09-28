import {logger} from "firebase-functions";
import {onSchedule} from "firebase-functions/scheduler";
import {usersCollection} from "../constants/collections";
import {hasPremiumAccess} from "../helpers/premium.helper";

export const expireSubscriptions = onSchedule(
  {schedule: "every day 00:30", timeZone: "UTC"},
  async () => {
    const now = new Date();
    const premium = await usersCollection.where("isPremium", "==", true).get();
    const expired = premium.docs.filter((doc) =>
      !hasPremiumAccess(doc.data(), now));

    for (const doc of expired) {
      await doc.ref.update({
        "isPremium": false,
        "subscription.updatedAt": now.toISOString(),
      }).catch((error) =>
        logger.error("expireSubscriptions: update failed", {
          uid: doc.id,
          error,
        }));
    }

    logger.info("expireSubscriptions: done", {expired: expired.length});
  },
);
