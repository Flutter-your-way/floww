import {Request, Response} from "express";
import {logger} from "firebase-functions";
import {ApiError, sendData} from "../common/api.error";
import {listOf, recordOf} from "../common/utils";
import {garminWebhookKey} from "../constants/wearable.secrets";
import {WEARABLE_CONFIGS} from "../constants/wearable.constants";
import {garminDaysOf} from "../helpers/wearable.fetch.helper";
import {
  consumeState,
  createAuthorizationUrl,
  exchangeCode,
  garminLinkDoc,
  removeIntegration,
  saveIntegration,
  setConnectedFlag,
} from "../helpers/wearable.oauth.helper";
import {
  linkGarminUser,
  requestGarminBackfill,
  syncProvider,
  syncUserWearables,
  writeWearableDays,
} from "../helpers/wearable.sync.helper";
import {WearableAuthError} from "../models/wearable.model";
import {wearableProviderValidator} from "../validators/wearable.validator";

const HTML_ESCAPES: Record<string, string> = {
  "&": "&amp;",
  "<": "&lt;",
  ">": "&gt;",
  "\"": "&quot;",
  "'": "&#39;",
};

const escapeHtml = (value: string): string =>
  value.replace(/[&<>"']/g, (char) => HTML_ESCAPES[char]);

const resultPage = (title: string, message: string): string => `<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${escapeHtml(title)}</title>
<style>
body{margin:0;min-height:100vh;display:flex;align-items:center;
justify-content:center;background:#0b0b0b;color:#f5f5f5;
font-family:-apple-system,system-ui,sans-serif;text-align:center;padding:24px;
box-sizing:border-box}
h1{font-size:22px;margin:0 0 12px}p{font-size:16px;opacity:.7;margin:0}
</style></head><body><div><h1>${escapeHtml(title)}</h1>
<p>${escapeHtml(message)}</p></div></body></html>`;

const sendPage = (
  res: Response,
  status: number,
  title: string,
  message: string,
) => res.status(status).type("html").send(resultPage(title, message));

export const handleConnectWearable = async (req: Request, res: Response) => {
  const {provider} = wearableProviderValidator.parse(req.body);
  const url = await createAuthorizationUrl(req.user.uid, provider);
  sendData(res, {url});
};

export const handleDisconnectWearable = async (req: Request, res: Response) => {
  const {provider} = wearableProviderValidator.parse(req.body);
  await removeIntegration(req.user.uid, provider, {revokeAccess: true});
  sendData(res, {provider, connected: false});
};

export const handleSyncWearables = async (req: Request, res: Response) => {
  const results = await syncUserWearables(req.user.uid);
  sendData(res, {results});
};

export const handleWearableCallback = async (req: Request, res: Response) => {
  const state = typeof req.query.state === "string" ? req.query.state : "";
  const code = typeof req.query.code === "string" ? req.query.code : "";
  const pending = state ? await consumeState(state) : null;

  if (!pending) {
    sendPage(res, 400, "Link expired",
      "Head back to Floww and tap Connect again.");
    return;
  }

  const {uid, provider, codeVerifier} = pending;
  const name = WEARABLE_CONFIGS[provider].name;

  if (!code || req.query.error) {
    sendPage(res, 200, `${name} not connected`,
      "No problem — you can close this window and return to Floww.");
    return;
  }

  try {
    const tokens = await exchangeCode(provider, code, codeVerifier);
    const externalUserId = provider === "garmin" ?
      await linkGarminUser(uid, tokens.accessToken) :
      tokens.userId;
    await saveIntegration(uid, provider, tokens, externalUserId);
    await setConnectedFlag(uid, provider, true);

    if (provider === "garmin") {
      await requestGarminBackfill(tokens.accessToken);
    } else {
      await syncProvider(uid, provider);
    }

    sendPage(res, 200, `${name} connected`,
      "You can close this window and return to Floww.");
  } catch (error) {
    logger.error("handleWearableCallback: failed", {uid, provider, error});
    const message = error instanceof WearableAuthError ?
      `${name} did not accept the connection. Please try again from Floww.` :
      error instanceof ApiError ?
        error.message :
        "Something went wrong. Please try again from Floww.";
    sendPage(res, 502, `${name} not connected`, message);
  }
};

export const handleGarminWebhook = async (req: Request, res: Response) => {
  if (req.query.key !== garminWebhookKey.value()) {
    res.status(401).end();
    return;
  }

  const payload = recordOf(req.body);

  for (const record of listOf(payload.deregistrations).map(recordOf)) {
    if (typeof record.userId !== "string") continue;
    const link = await garminLinkDoc(record.userId).get();
    const uid = link.data()?.uid;
    if (typeof uid === "string") {
      await removeIntegration(uid, "garmin", {revokeAccess: false});
    }
  }

  const byUser = garminDaysOf(payload);
  await Promise.all(Object.entries(byUser).map(async ([garminId, days]) => {
    const link = await garminLinkDoc(garminId).get();
    const uid = link.data()?.uid;
    if (typeof uid !== "string") {
      logger.warn("handleGarminWebhook: unknown user", {garminId});
      return;
    }
    await writeWearableDays(uid, "garmin", days);
  }));

  res.status(200).end();
};
