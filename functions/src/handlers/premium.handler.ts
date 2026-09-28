import {Request, Response} from "express";
import {ApiError, sendData} from "../common/api.error";
import {
  USER_COLLECTIONS,
  firestore,
  userCollection,
  usersCollection,
} from "../constants/collections";
import {
  CURRENCY,
  PREMIUM_PLANS,
  hasPremiumAccess,
  periodEndFrom,
  trialEndFrom,
} from "../helpers/premium.helper";
import {loadActiveUser} from "../helpers/user.clock.helper";
import {subscribeValidator} from "../validators/premium.validator";

export const handleSubscribe = async (req: Request, res: Response) => {
  const {term} = subscribeValidator.parse(req.body);
  const uid = req.user.uid;
  const plan = PREMIUM_PLANS[term];
  const start = new Date();
  const startedAt = start.toISOString();

  const subscription = {
    status: "active",
    term,
    planId: plan.planId,
    planName: plan.planLabel,
    price: plan.price,
    currency: CURRENCY,
    periodLabel: plan.periodLabel,
    startedAt,
    renewsOn: periodEndFrom(start, plan.months).toISOString(),
    cancelledAt: null,
    trialEndsOn: trialEndFrom(start).toISOString(),
    updatedAt: startedAt,
    isSimulated: true,
  };

  await firestore.runTransaction(async (transaction) => {
    const user = await loadActiveUser(uid, transaction);
    if (!user) throw new ApiError("UNAUTHORIZED", "Please sign in again.");

    const invoice = userCollection(uid, USER_COLLECTIONS.invoices).doc();
    transaction.set(usersCollection.doc(uid), {
      isPremium: true,
      planName: plan.planLabel,
      subscription,
    }, {merge: true});
    transaction.set(invoice, {
      id: invoice.id,
      amount: plan.price,
      planLabel: plan.planLabel,
      paidAt: startedAt,
      isPaid: true,
      isSimulated: true,
      planId: plan.planId,
      currency: CURRENCY,
    });
  });

  sendData(res, {subscription});
};

export const handleCancelSubscription = async (
  req: Request,
  res: Response,
) => {
  const uid = req.user.uid;
  const now = new Date().toISOString();

  await firestore.runTransaction(async (transaction) => {
    const user = await loadActiveUser(uid, transaction);
    if (!user) throw new ApiError("UNAUTHORIZED", "Please sign in again.");
    if (!hasPremiumAccess(user)) {
      throw new ApiError("INVALID_REQUEST", "You have no active plan.");
    }
    transaction.update(usersCollection.doc(uid), {
      "subscription.status": "cancelled",
      "subscription.cancelledAt": now,
      "subscription.updatedAt": now,
    });
  });

  sendData(res, {cancelled: true});
};
