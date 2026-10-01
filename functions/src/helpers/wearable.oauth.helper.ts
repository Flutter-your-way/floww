import {createHash, randomBytes} from "crypto";
import {logger} from "firebase-functions";
import {ApiError} from "../common/api.error";
import {numberOf} from "../common/utils";
import {
  SETTINGS_DOC,
  USER_COLLECTIONS,
  firestore,
  userCollection,
  wearableLinksCollection,
  wearableStatesCollection,
} from "../constants/collections";
import {
  FITBIT_REVOKE_URL,
  GARMIN_API,
  OURA_REVOKE_URL,
  WEARABLE_CALLBACK_FUNCTION,
  WEARABLE_CONFIGS,
  WEARABLE_REGION,
  WEARABLE_STATE_TTL_MS,
  WEARABLE_TOKEN_REFRESH_MARGIN_MS,
  WHOOP_API,
} from "../constants/wearable.constants";
import {
  WearableAuthError,
  WearableIntegration,
  WearableOAuthState,
  WearableProvider,
  WearableTokens,
  isWearableProvider,
} from "../models/wearable.model";
import {unavailableError, wearableFetch} from "./wearable.http.helper";

const STATE_BYTES = 24;
const VERIFIER_BYTES = 48;
const CONNECTED_APPS_FIELD = "connectedApps";

interface TokenResponse {
  access_token?: string;
  refresh_token?: string;
  expires_in?: number;
  scope?: string;
  user_id?: string;
}

const projectId = (): string => {
  if (process.env.GCLOUD_PROJECT) return process.env.GCLOUD_PROJECT;
  const config = process.env.FIREBASE_CONFIG;
  return config ? JSON.parse(config).projectId : "";
};

export const wearableCallbackUrl = (): string =>
  `https://${WEARABLE_REGION}-${projectId()}.cloudfunctions.net/` +
  WEARABLE_CALLBACK_FUNCTION;

export const integrationsOf = (uid: string) =>
  userCollection(uid, USER_COLLECTIONS.integrations);

export const garminLinkDoc = (garminUserId: string) =>
  wearableLinksCollection.doc(`garmin_${garminUserId}`);

const base64Url = (bytes: Buffer): string => bytes.toString("base64url");

const credentialsOf = (provider: WearableProvider) => {
  const config = WEARABLE_CONFIGS[provider];
  const clientId = config.clientId.value().trim();
  const clientSecret = config.clientSecret.value().trim();
  if (!clientId || !clientSecret) {
    throw new ApiError(
      "WEARABLE_UNAVAILABLE",
      `${config.name} is not available yet. Please try again later.`,
    );
  }
  return {clientId, clientSecret};
};

export const createAuthorizationUrl = async (
  uid: string,
  provider: WearableProvider,
): Promise<string> => {
  const config = WEARABLE_CONFIGS[provider];
  const {clientId} = credentialsOf(provider);
  const state = base64Url(randomBytes(STATE_BYTES));
  const codeVerifier = config.usesPkce ?
    base64Url(randomBytes(VERIFIER_BYTES)) :
    undefined;

  const record: WearableOAuthState = {
    uid,
    provider,
    codeVerifier,
    expiresAt: Date.now() + WEARABLE_STATE_TTL_MS,
  };
  await wearableStatesCollection.doc(state).set(record);

  const params = new URLSearchParams({
    response_type: "code",
    client_id: clientId,
    redirect_uri: wearableCallbackUrl(),
    state,
  });
  if (config.scopes.length > 0) params.set("scope", config.scopes.join(" "));
  if (codeVerifier) {
    params.set(
      "code_challenge",
      base64Url(createHash("sha256").update(codeVerifier).digest()),
    );
    params.set("code_challenge_method", "S256");
  }
  return `${config.authorizeUrl}?${params.toString()}`;
};

export const consumeState = async (
  state: string,
): Promise<WearableOAuthState | null> => {
  const ref = wearableStatesCollection.doc(state);
  return firestore.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const data = snapshot.data();
    if (!data) return null;
    transaction.delete(ref);
    if (!isWearableProvider(data.provider) || typeof data.uid !== "string") {
      return null;
    }
    if (numberOf(data.expiresAt) < Date.now()) return null;
    return data as WearableOAuthState;
  });
};

const requestTokens = async (
  provider: WearableProvider,
  params: Record<string, string>,
): Promise<WearableTokens & {userId?: string}> => {
  const config = WEARABLE_CONFIGS[provider];
  const {clientId, clientSecret} = credentialsOf(provider);
  const body = new URLSearchParams({...params, client_id: clientId});
  const headers: Record<string, string> = {
    "Content-Type": "application/x-www-form-urlencoded",
    "Accept": "application/json",
  };
  if (config.basicAuth) {
    const basic = Buffer.from(`${clientId}:${clientSecret}`).toString("base64");
    headers.Authorization = `Basic ${basic}`;
  } else {
    body.set("client_secret", clientSecret);
  }

  const response = await wearableFetch(provider, config.tokenUrl, {
    method: "POST",
    headers,
    body: body.toString(),
  });
  const json = await response.json().catch(() => ({})) as TokenResponse;

  if (!response.ok || !json.access_token) {
    logger.warn("requestTokens: rejected", {
      provider,
      status: response.status,
      grant: params.grant_type,
    });
    if (response.status >= 400 && response.status < 500) {
      throw new WearableAuthError(provider, `${provider} token rejected.`);
    }
    throw unavailableError(config.name);
  }

  return {
    accessToken: json.access_token,
    refreshToken: json.refresh_token,
    expiresAt: Date.now() + numberOf(json.expires_in, 3600) * 1000,
    scope: json.scope,
    userId: json.user_id,
  };
};

export const exchangeCode = (
  provider: WearableProvider,
  code: string,
  codeVerifier?: string,
) => requestTokens(provider, {
  grant_type: "authorization_code",
  code,
  redirect_uri: wearableCallbackUrl(),
  ...(codeVerifier ? {code_verifier: codeVerifier} : {}),
});

export const saveIntegration = async (
  uid: string,
  provider: WearableProvider,
  tokens: WearableTokens,
  externalUserId?: string,
): Promise<void> => {
  const record: WearableIntegration = {
    provider,
    accessToken: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    expiresAt: tokens.expiresAt,
    scope: tokens.scope,
    externalUserId,
    connectedAt: new Date().toISOString(),
  };
  await integrationsOf(uid).doc(provider).set(record);
};

export const loadIntegration = async (
  uid: string,
  provider: WearableProvider,
): Promise<WearableIntegration | null> => {
  const snapshot = await integrationsOf(uid).doc(provider).get();
  const data = snapshot.data();
  return data && typeof data.accessToken === "string" ?
    data as WearableIntegration :
    null;
};

export const validAccessToken = async (
  uid: string,
  provider: WearableProvider,
): Promise<string> => {
  const integration = await loadIntegration(uid, provider);
  if (!integration) {
    throw new WearableAuthError(provider, `${provider} is not connected.`);
  }
  if (integration.expiresAt - WEARABLE_TOKEN_REFRESH_MARGIN_MS > Date.now()) {
    return integration.accessToken;
  }
  if (!integration.refreshToken) {
    throw new WearableAuthError(provider, `${provider} token expired.`);
  }

  try {
    const tokens = await requestTokens(provider, {
      grant_type: "refresh_token",
      refresh_token: integration.refreshToken,
      ...(provider === "whoop" ? {scope: "offline"} : {}),
    });
    await integrationsOf(uid).doc(provider).update({
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken ?? integration.refreshToken,
      expiresAt: tokens.expiresAt,
    });
    return tokens.accessToken;
  } catch (error) {
    if (!(error instanceof WearableAuthError)) throw error;
    const latest = await loadIntegration(uid, provider);
    if (latest && latest.accessToken !== integration.accessToken &&
      latest.expiresAt > Date.now()) {
      return latest.accessToken;
    }
    throw error;
  }
};

export const setConnectedFlags = (
  uid: string,
  flags: Record<string, boolean>,
) => userCollection(uid, USER_COLLECTIONS.settings).doc(SETTINGS_DOC).set(
  {[CONNECTED_APPS_FIELD]: flags},
  {merge: true},
);

export const setConnectedFlag = (
  uid: string,
  provider: string,
  connected: boolean,
) => setConnectedFlags(uid, {[provider]: connected});

const revoke = async (
  provider: WearableProvider,
  integration: WearableIntegration,
): Promise<void> => {
  const token = integration.accessToken;
  const bearer = {Authorization: `Bearer ${token}`};
  switch (provider) {
  case "garmin":
    await wearableFetch(provider, `${GARMIN_API}/user/registration`, {
      method: "DELETE",
      headers: bearer,
    });
    return;
  case "whoop":
    await wearableFetch(provider, `${WHOOP_API}/user/access`, {
      method: "DELETE",
      headers: bearer,
    });
    return;
  case "oura":
    await wearableFetch(
      provider,
      `${OURA_REVOKE_URL}?access_token=${encodeURIComponent(token)}`,
      {method: "GET"},
    );
    return;
  case "fitbit": {
    const {clientId, clientSecret} = credentialsOf(provider);
    const basic = Buffer.from(`${clientId}:${clientSecret}`).toString("base64");
    await wearableFetch(provider, FITBIT_REVOKE_URL, {
      method: "POST",
      headers: {
        "Authorization": `Basic ${basic}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({token}).toString(),
    });
    return;
  }
  }
};

export const removeIntegration = async (
  uid: string,
  provider: WearableProvider,
  {revokeAccess}: {revokeAccess: boolean},
): Promise<void> => {
  const integration = await loadIntegration(uid, provider);
  if (integration && revokeAccess) {
    try {
      await revoke(provider, integration);
    } catch (error) {
      logger.warn("removeIntegration: revoke failed", {uid, provider, error});
    }
  }
  const batch = firestore.batch();
  batch.delete(integrationsOf(uid).doc(provider));
  if (provider === "garmin" && integration?.externalUserId) {
    batch.delete(garminLinkDoc(integration.externalUserId));
  }
  await batch.commit();
  await setConnectedFlag(uid, provider, false);
};
