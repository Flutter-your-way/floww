import {NextFunction, Request, Response} from "express";
import {getAuth} from "firebase-admin/auth";
import {ApiError, sendError} from "../common/api.error";

const BEARER_PREFIX = "Bearer ";

export const authenticate = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const {authorization} = req.headers;
  const token = authorization?.startsWith(BEARER_PREFIX) ?
    authorization.slice(BEARER_PREFIX.length).trim() :
    undefined;

  if (!token) {
    sendError(res, new ApiError("UNAUTHORIZED", "Missing bearer token."));
    return;
  }

  try {
    req.user = await getAuth().verifyIdToken(token);
  } catch (error) {
    sendError(res, new ApiError("UNAUTHORIZED", "Invalid or expired token."));
    return;
  }

  next();
};
