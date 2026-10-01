import {logger} from "firebase-functions";
import {ApiError} from "../common/api.error";
import {WEARABLE_HTTP_TIMEOUT_MS} from "../constants/wearable.constants";
import {WearableAuthError, WearableProvider} from "../models/wearable.model";

const UNAUTHORIZED_STATUSES = [401, 403];

export const unavailableError = (name: string) =>
  new ApiError("WEARABLE_FAILED", `${name} is not responding right now.`);

export const wearableFetch = async (
  provider: WearableProvider,
  url: string,
  init: RequestInit,
): Promise<Response> => {
  let response: Response;
  try {
    response = await fetch(url, {
      ...init,
      signal: AbortSignal.timeout(WEARABLE_HTTP_TIMEOUT_MS),
    });
  } catch (error) {
    logger.error("wearableFetch: request failed", {provider, url, error});
    throw new ApiError("WEARABLE_FAILED", "Could not reach the provider.");
  }

  if (UNAUTHORIZED_STATUSES.includes(response.status)) {
    throw new WearableAuthError(provider, `${provider} rejected the token.`);
  }
  return response;
};

export const wearableGetJson = async <T>(
  provider: WearableProvider,
  url: string,
  accessToken: string,
): Promise<T> => {
  const response = await wearableFetch(provider, url, {
    headers: {Authorization: `Bearer ${accessToken}`},
  });
  if (!response.ok) {
    logger.error("wearableGetJson: bad response", {
      provider,
      url,
      status: response.status,
      body: (await response.text()).slice(0, 300),
    });
    throw new ApiError("WEARABLE_FAILED", "The provider returned an error.");
  }
  return await response.json() as T;
};
