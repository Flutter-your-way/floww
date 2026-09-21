import {NextFunction, Request, Response} from "express";
import {logger} from "firebase-functions";
import {z} from "zod";
import {ApiError, sendError} from "../common/api.error";

export const notFoundHandler = (req: Request, res: Response) => {
  sendError(res, new ApiError("NOT_FOUND", `No route for ${req.path}.`));
};

export const errorHandler = (
  error: unknown,
  req: Request,
  res: Response,
  _next: NextFunction,
) => {
  if (error instanceof ApiError) {
    sendError(res, error);
    return;
  }

  if (error instanceof z.ZodError) {
    sendError(res, new ApiError("INVALID_REQUEST", z.prettifyError(error)));
    return;
  }

  if (error instanceof SyntaxError) {
    sendError(res, new ApiError("INVALID_REQUEST", "Malformed JSON body."));
    return;
  }

  logger.error("Unhandled error", {path: req.path, error});
  sendError(res, new ApiError("INTERNAL", "Something went wrong."));
};
