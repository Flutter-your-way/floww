import {timingSafeEqual} from "node:crypto";
import {Request, Response} from "express";
import {logger} from "firebase-functions";
import {StatusCodes} from "http-status-codes";
import {ApiError, sendData} from "../common/api.error";
import {recordOf} from "../common/utils";
import {
  revenueCatSecretKey,
  revenueCatWebhookAuth,
} from "../constants/secrets";
import {
  RevenueCatEvent,
  customersOfEvent,
  recordInvoice,
  syncCustomer,
} from "../helpers/revenuecat.helper";

const BEARER_PREFIX = "Bearer ";

const matchesSecret = (header: string | undefined, secret: string) => {
  if (!header || !secret) return false;
  const value = header.startsWith(BEARER_PREFIX) ?
    header.slice(BEARER_PREFIX.length).trim() :
    header.trim();
  const given = Buffer.from(value);
  const expected = Buffer.from(secret);
  return given.length === expected.length && timingSafeEqual(given, expected);
};

export const handleSyncPremium = async (req: Request, res: Response) => {
  const uid = req.user.uid;
  let subscription;
  try {
    subscription = await syncCustomer(uid, revenueCatSecretKey.value());
  } catch (error) {
    logger.error("syncPremium: RevenueCat lookup failed", {uid, error});
    throw new ApiError(
      "INTERNAL",
      "Could not confirm your purchase yet. Please tap Restore Purchases.",
    );
  }
  if (subscription === undefined) {
    throw new ApiError("UNAUTHORIZED", "Please sign in again.");
  }
  sendData(res, {subscription});
};

export const handleRevenueCatWebhook = async (req: Request, res: Response) => {
  const secret = revenueCatWebhookAuth.value();
  if (!matchesSecret(req.headers.authorization, secret)) {
    res.status(StatusCodes.UNAUTHORIZED).json({received: false});
    return;
  }

  const event = recordOf(recordOf(req.body).event) as RevenueCatEvent;
  logger.info("revenuecatWebhook: event", {
    id: event.id,
    type: event.type,
    environment: event.environment,
    appUserId: event.app_user_id,
  });

  try {
    await recordInvoice(event);
    const secretKey = revenueCatSecretKey.value();
    for (const uid of customersOfEvent(event)) {
      await syncCustomer(uid, secretKey);
    }
  } catch (error) {
    logger.error("revenuecatWebhook: processing failed", {id: event.id, error});
    res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({received: false});
    return;
  }

  res.status(StatusCodes.OK).json({received: true});
};
