import {FieldValue} from "firebase-admin/firestore";
import {onDocumentWritten} from "firebase-functions/firestore";
import {numberOf, recordOf} from "../common/utils";
import {syncActivityDays} from "../helpers/flow.sync.helper";
import {
  matchesMerged,
  mergeHealthSources,
} from "../helpers/health.merge.helper";

export const onHealthLogWritten = onDocumentWritten(
  "users/{uid}/health_logs/{dayId}",
  async (event) => {
    const after = event.data?.after;
    const data = after?.data();
    if (!after || !data) return;

    const sources = recordOf(data.sources);
    const hasSources = Object.keys(sources).length > 0;
    const merged = hasSources ? mergeHealthSources(sources) : null;

    if (!merged || matchesMerged(data, merged)) {
      const before = event.data?.before.data();
      const recoveryChanged =
        numberOf(before?.sleepMinutes) !== numberOf(data.sleepMinutes) ||
        numberOf(before?.hrvMs) !== numberOf(data.hrvMs);
      if (recoveryChanged) {
        await syncActivityDays(event.params.uid, [event.params.dayId]);
      }
      return;
    }

    await after.ref.update({
      steps: merged.steps,
      activeCaloriesKcal: merged.activeCaloriesKcal,
      sleepMinutes: merged.sleepMinutes,
      workoutCount: merged.workoutCount,
      restingHeartRate: merged.restingHeartRate ?? FieldValue.delete(),
      hrvMs: merged.hrvMs ?? FieldValue.delete(),
      syncedAt: merged.syncedAt ?? data.syncedAt ?? new Date().toISOString(),
    });
  },
);
