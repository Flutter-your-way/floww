import {logger} from "firebase-functions";
import {addDaysToKey} from "../common/utils";
import {
  USER_COLLECTIONS,
  firestore,
  userCollection,
} from "../constants/collections";
import {
  GARMIN_API,
  GARMIN_BACKFILL_TYPES,
  WEARABLE_CONFIGS,
  WEARABLE_SYNC_DAYS,
} from "../constants/wearable.constants";
import {
  WearableAuthError,
  WearableDay,
  WearableDays,
  WEARABLE_PROVIDERS,
  WearableProvider,
  isWearableProvider,
} from "../models/wearable.model";
import {clockOf, loadActiveUser} from "./user.clock.helper";
import {
  fetchFitbitDays,
  fetchOuraDays,
  fetchWhoopDays,
} from "./wearable.fetch.helper";
import {wearableFetch, wearableGetJson} from "./wearable.http.helper";
import {
  garminLinkDoc,
  integrationsOf,
  removeIntegration,
  setConnectedFlags,
  validAccessToken,
} from "./wearable.oauth.helper";

const SECONDS_PER_DAY = 86_400;

export type WearableSyncResult = "synced" | "skipped" | "disconnected" |
  "failed";

const cleanDay = (day: WearableDay): WearableDay => {
  const clean: WearableDay = {};
  for (const [key, value] of Object.entries(day)) {
    if (typeof value === "number" && Number.isFinite(value) && value > 0) {
      clean[key as keyof WearableDay] = key === "hrvMs" ?
        Math.round(value * 10) / 10 :
        Math.round(value);
    }
  }
  return clean;
};

export const writeWearableDays = async (
  uid: string,
  source: string,
  days: WearableDays,
): Promise<number> => {
  const logs = userCollection(uid, USER_COLLECTIONS.healthLogs);
  const syncedAt = new Date().toISOString();
  const batch = firestore.batch();
  let writes = 0;

  for (const [dayKey, day] of Object.entries(days)) {
    const clean = cleanDay(day);
    if (Object.keys(clean).length === 0) continue;
    batch.set(
      logs.doc(dayKey),
      {date: dayKey, syncedAt, sources: {[source]: {...clean, syncedAt}}},
      {mergeFields: ["date", "syncedAt", `sources.${source}`]},
    );
    writes++;
  }

  if (writes > 0) await batch.commit();
  return writes;
};

const fetchDays = (
  provider: WearableProvider,
  accessToken: string,
  dayKeys: string[],
  offsetMinutes: number,
): Promise<WearableDays> => {
  switch (provider) {
  case "whoop":
    return fetchWhoopDays(accessToken, dayKeys, offsetMinutes);
  case "oura":
    return fetchOuraDays(accessToken, dayKeys);
  case "fitbit":
    return fetchFitbitDays(accessToken, dayKeys);
  case "garmin":
    return Promise.resolve({});
  }
};

export const syncProvider = async (
  uid: string,
  provider: WearableProvider,
): Promise<WearableSyncResult> => {
  if (!WEARABLE_CONFIGS[provider].pullsData) return "skipped";
  const user = await loadActiveUser(uid);
  if (!user) return "skipped";

  const {offsetMinutes, today} = clockOf(user);
  const dayKeys = Array.from(
    {length: WEARABLE_SYNC_DAYS},
    (_, index) => addDaysToKey(today, index - WEARABLE_SYNC_DAYS + 1),
  );

  try {
    const accessToken = await validAccessToken(uid, provider);
    const days = await fetchDays(provider, accessToken, dayKeys, offsetMinutes);
    await writeWearableDays(uid, provider, days);
    await integrationsOf(uid).doc(provider).update({
      lastSyncedAt: new Date().toISOString(),
    });
    return "synced";
  } catch (error) {
    if (error instanceof WearableAuthError) {
      logger.warn("syncProvider: access revoked", {uid, provider});
      await removeIntegration(uid, provider, {revokeAccess: false});
      return "disconnected";
    }
    logger.error("syncProvider: failed", {uid, provider, error});
    return "failed";
  }
};

export const syncUserWearables = async (
  uid: string,
): Promise<Partial<Record<WearableProvider, WearableSyncResult>>> => {
  const snapshot = await integrationsOf(uid).get();
  const providers = snapshot.docs
    .map((doc) => doc.id)
    .filter(isWearableProvider);
  const results = await Promise.all(
    providers.map(async (provider) =>
      [provider, await syncProvider(uid, provider)] as const),
  );
  const connected = new Set(results
    .filter(([, result]) => result !== "disconnected")
    .map(([provider]) => provider));
  await setConnectedFlags(uid, Object.fromEntries(
    WEARABLE_PROVIDERS.map((provider) => [provider, connected.has(provider)]),
  ));
  return Object.fromEntries(results);
};

export const linkGarminUser = async (
  uid: string,
  accessToken: string,
): Promise<string | undefined> => {
  try {
    const json = await wearableGetJson<{userId?: string}>(
      "garmin",
      `${GARMIN_API}/user/id`,
      accessToken,
    );
    if (!json.userId) return undefined;
    await garminLinkDoc(json.userId).set({uid});
    return json.userId;
  } catch (error) {
    logger.error("linkGarminUser: failed", {uid, error});
    return undefined;
  }
};

export const requestGarminBackfill = async (
  accessToken: string,
): Promise<void> => {
  const end = Math.floor(Date.now() / 1000);
  const start = end - WEARABLE_SYNC_DAYS * SECONDS_PER_DAY;
  const params = new URLSearchParams({
    summaryStartTimeInSeconds: String(start),
    summaryEndTimeInSeconds: String(end),
  });
  await Promise.all(GARMIN_BACKFILL_TYPES.map(async (type) => {
    try {
      const url = `${GARMIN_API}/backfill/${type}?${params.toString()}`;
      await wearableFetch("garmin", url, {
        headers: {Authorization: `Bearer ${accessToken}`},
      });
    } catch (error) {
      logger.warn("requestGarminBackfill: failed", {type, error});
    }
  }));
};
