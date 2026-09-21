import OpenAI, {
  APIConnectionError,
  APIError,
  BadRequestError,
  OpenAIError,
  RateLimitError,
} from "openai";
import {logger} from "firebase-functions";
import {ApiError} from "../common/api.error";
import {openAiApiKey} from "../constants/secrets";
import {
  OPENAI_MAX_RETRIES,
  OPENAI_TIMEOUT_MS,
} from "../constants/ai.constants";

let client: OpenAI | null = null;

export const getOpenAI = (): OpenAI => {
  if (!client) {
    client = new OpenAI({
      apiKey: openAiApiKey.value(),
      timeout: OPENAI_TIMEOUT_MS,
      maxRetries: OPENAI_MAX_RETRIES,
    });
  }
  return client;
};

const describeError = (error: unknown) => {
  if (error instanceof APIError) {
    return {
      name: error.name,
      status: error.status,
      code: error.code,
      message: error.message,
      requestId: error.requestID,
    };
  }
  if (error instanceof Error) {
    return {name: error.name, message: error.message, stack: error.stack};
  }
  return {error};
};

export const toAiApiError = (error: unknown, feature: string): ApiError => {
  if (error instanceof ApiError) {
    return error;
  }

  logger.error(`${feature}: OpenAI request failed`, describeError(error));

  if (error instanceof RateLimitError || error instanceof APIConnectionError) {
    return new ApiError(
      "AI_UNAVAILABLE",
      "WAVE is busy right now. Please try again in a moment.",
    );
  }
  if (error instanceof BadRequestError) {
    return new ApiError(
      "INVALID_REQUEST",
      "The image could not be processed. Try another photo.",
    );
  }
  if (error instanceof OpenAIError) {
    return new ApiError("AI_FAILED", "WAVE could not analyze this request.");
  }
  return new ApiError("INTERNAL", "Something went wrong.");
};
