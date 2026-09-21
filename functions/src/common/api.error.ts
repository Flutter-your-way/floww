import {Response} from "express";
import {StatusCodes} from "http-status-codes";

export const API_ERROR_STATUS = {
  INVALID_REQUEST: StatusCodes.BAD_REQUEST,
  UNAUTHORIZED: StatusCodes.UNAUTHORIZED,
  NOT_FOUND: StatusCodes.NOT_FOUND,
  NOT_FOOD: StatusCodes.UNPROCESSABLE_ENTITY,
  QUOTA_EXCEEDED: StatusCodes.TOO_MANY_REQUESTS,
  AI_FAILED: StatusCodes.BAD_GATEWAY,
  AI_UNAVAILABLE: StatusCodes.SERVICE_UNAVAILABLE,
  INTERNAL: StatusCodes.INTERNAL_SERVER_ERROR,
} as const;

export type ApiErrorCode = keyof typeof API_ERROR_STATUS;

export interface ApiSuccess<T> {
  data: T;
}

export interface ApiFailure {
  error: {
    code: ApiErrorCode;
    message: string;
  };
}

export class ApiError extends Error {
  constructor(readonly code: ApiErrorCode, message: string) {
    super(message);
    this.name = "ApiError";
  }

  get status(): number {
    return API_ERROR_STATUS[this.code];
  }
}

export const sendData = <T>(res: Response, data: T) => {
  const body: ApiSuccess<T> = {data};
  res.status(StatusCodes.OK).json(body);
};

export const sendError = (res: Response, error: ApiError) => {
  const body: ApiFailure = {
    error: {code: error.code, message: error.message},
  };
  res.status(error.status).json(body);
};
