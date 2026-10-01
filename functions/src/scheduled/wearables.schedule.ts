import {logger} from "firebase-functions";
import {onSchedule} from "firebase-functions/scheduler";
import {USER_COLLECTIONS, firestore} from "../constants/collections";
import {wearableSecrets} from "../constants/wearable.secrets";
import {
  WEARABLE_CONFIGS,
  WEARABLE_SCHEDULE_CONCURRENCY,
} from "../constants/wearable.constants";
import {syncProvider} from "../helpers/wearable.sync.helper";
import {WearableProvider, isWearableProvider} from "../models/wearable.model";

export const syncWearablesHourly = onSchedule(
  {
    schedule: "every 60 minutes",
    secrets: wearableSecrets,
    memory: "512MiB",
    timeoutSeconds: 540,
  },
  async () => {
    const snapshot = await firestore
      .collectionGroup(USER_COLLECTIONS.integrations)
      .get();

    const jobs: {uid: string; provider: WearableProvider}[] = [];
    for (const doc of snapshot.docs) {
      const uid = doc.ref.parent.parent?.id;
      const provider = doc.id;
      if (!uid || !isWearableProvider(provider)) continue;
      if (!WEARABLE_CONFIGS[provider].pullsData) continue;
      jobs.push({uid, provider});
    }

    const counts: Record<string, number> = {};
    for (let i = 0; i < jobs.length; i += WEARABLE_SCHEDULE_CONCURRENCY) {
      const results = await Promise.all(
        jobs.slice(i, i + WEARABLE_SCHEDULE_CONCURRENCY)
          .map(({uid, provider}) => syncProvider(uid, provider)),
      );
      for (const result of results) counts[result] = (counts[result] ?? 0) + 1;
    }

    logger.info("syncWearablesHourly: done", {jobs: jobs.length, counts});
  },
);
