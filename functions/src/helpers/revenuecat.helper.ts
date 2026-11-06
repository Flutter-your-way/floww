import {DocumentData} from "firebase-admin/firestore";
import {recordOf} from "../common/utils";
import {
  USER_COLLECTIONS,
  userCollection,
  usersCollection,
} from "../constants/collections";
import {
  PREMIUM_ENTITLEMENT,
  PremiumPlan,
  SubscriptionTerm,
  hasPremiumAccess,
  planForProduct,
  termForProduct,
} from "./premium.helper";
import {loadActiveUser} from "./user.clock.helper";

const REVENUECAT_API = "https://api.revenuecat.com/v1/subscribers/";
const ANONYMOUS_PREFIX = "$RCAnonymousID:";
const REQUEST_TIMEOUT_MS = 15_000;
const SANDBOX_ENVIRONMENT = "SANDBOX";
const BILLED_EVENTS = ["INITIAL_PURCHASE", "RENEWAL", "NON_RENEWING_PURCHASE"];

export const STORE_SOURCE = "revenuecat";

export interface StoreSubscription {
  status: "active" | "cancelled";
  term: SubscriptionTerm;
  planId: string;
  planName: string;
  price: number;
  currency: string;
  periodLabel: string;
  startedAt: string;
  renewsOn: string;
  cancelledAt: string | null;
  trialEndsOn: string | null;
  updatedAt: string;
  isSimulated: boolean;
  source: typeof STORE_SOURCE;
  store: string | null;
  managementUrl: string | null;
  hasBillingIssue: boolean;
}

export interface RevenueCatEvent {
  id?: string;
  type?: string;
  app_user_id?: string;
  original_app_user_id?: string;
  transferred_from?: string[];
  transferred_to?: string[];
  product_id?: string;
  price_in_purchased_currency?: number;
  currency?: string;
  environment?: string;
  purchased_at_ms?: number;
}

const stringOf = (value: unknown): string | null =>
  typeof value === "string" && value.length > 0 ? value : null;

const isoOf = (value: unknown): string | null => {
  const text = stringOf(value);
  if (!text) return null;
  const time = Date.parse(text);
  return Number.isNaN(time) ? null : new Date(time).toISOString();
};

export const isCustomerId = (id: unknown): id is string =>
  typeof id === "string" && id.length > 0 && !id.startsWith(ANONYMOUS_PREFIX);

export const fetchSubscriber = async (
  uid: string,
  secretKey: string,
): Promise<Record<string, unknown>> => {
  const response = await fetch(`${REVENUECAT_API}${encodeURIComponent(uid)}`, {
    headers: {
      "Authorization": `Bearer ${secretKey}`,
      "Content-Type": "application/json",
    },
    signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
  });
  if (!response.ok) {
    throw new Error(`RevenueCat responded ${response.status}`);
  }
  const body = recordOf(await response.json());
  return recordOf(body.subscriber);
};

export const subscriptionFromSubscriber = (
  subscriber: Record<string, unknown>,
  now: Date = new Date(),
): StoreSubscription | null => {
  const entitlement = recordOf(
    recordOf(subscriber.entitlements)[PREMIUM_ENTITLEMENT],
  );
  const productId = stringOf(entitlement.product_identifier);
  if (!productId) return null;

  const plan: PremiumPlan = planForProduct(productId);
  const product = recordOf(recordOf(subscriber.subscriptions)[productId]);
  const refundedAt = isoOf(product.refunded_at);
  const expiresAt = refundedAt ??
    isoOf(entitlement.grace_period_expires_date) ??
    isoOf(entitlement.expires_date) ??
    isoOf(product.expires_date);
  if (!expiresAt) return null;

  const cancelledAt = refundedAt ?? isoOf(product.unsubscribe_detected_at);
  const price = recordOf(product.price);
  const amount = typeof price.amount === "number" ? price.amount : 0;

  const isExpired = Date.parse(expiresAt) <= now.getTime();

  return {
    status: cancelledAt || isExpired ? "cancelled" : "active",
    term: termForProduct(productId),
    planId: productId,
    planName: plan.planLabel,
    price: amount,
    currency: stringOf(price.currency) ?? "",
    periodLabel: plan.periodLabel,
    startedAt: isoOf(product.original_purchase_date) ??
      isoOf(entitlement.purchase_date) ??
      now.toISOString(),
    renewsOn: expiresAt,
    cancelledAt,
    trialEndsOn: product.period_type === "trial" ? expiresAt : null,
    updatedAt: now.toISOString(),
    isSimulated: product.is_sandbox === true,
    source: STORE_SOURCE,
    store: stringOf(product.store),
    managementUrl: stringOf(subscriber.management_url),
    hasBillingIssue: isoOf(product.billing_issues_detected_at) !== null,
  };
};

const premiumFieldsOf = (
  subscription: StoreSubscription | null,
  now: Date,
): DocumentData => {
  if (!subscription) {
    return {
      isPremium: false,
      subscription: {status: "none", updatedAt: now.toISOString()},
    };
  }
  return {
    isPremium: hasPremiumAccess({subscription}, now),
    planName: subscription.planName,
    subscription,
  };
};

export const syncCustomer = async (
  uid: string,
  secretKey: string,
): Promise<StoreSubscription | null | undefined> => {
  const user = await loadActiveUser(uid);
  if (!user) return undefined;

  const now = new Date();
  const subscription = subscriptionFromSubscriber(
    await fetchSubscriber(uid, secretKey),
    now,
  );
  const hadSubscription = recordOf(user.subscription).status !== undefined &&
    recordOf(user.subscription).status !== "none";
  if (!subscription && !hadSubscription) return null;

  await usersCollection.doc(uid).set(
    premiumFieldsOf(subscription, now),
    {merge: true},
  );
  return subscription;
};

export const recordInvoice = async (event: RevenueCatEvent) => {
  const uid = event.app_user_id;
  const amount = event.price_in_purchased_currency;
  if (!isCustomerId(uid) || !event.id || !event.type) return;
  if (!BILLED_EVENTS.includes(event.type)) return;
  if (typeof amount !== "number" || amount <= 0) return;
  if (!(await loadActiveUser(uid))) return;

  const productId = event.product_id ?? "";
  const plan = planForProduct(productId);
  const paidAt = typeof event.purchased_at_ms === "number" ?
    new Date(event.purchased_at_ms) :
    new Date();

  await userCollection(uid, USER_COLLECTIONS.invoices).doc(event.id).set({
    id: event.id,
    amount,
    planLabel: plan.planLabel,
    paidAt: paidAt.toISOString(),
    isPaid: true,
    isSimulated: event.environment === SANDBOX_ENVIRONMENT,
    planId: productId || plan.planId,
    currency: event.currency ?? "",
    source: STORE_SOURCE,
  });
};

export const customersOfEvent = (event: RevenueCatEvent): string[] => {
  const ids = event.type === "TRANSFER" ?
    [...(event.transferred_from ?? []), ...(event.transferred_to ?? [])] :
    [event.app_user_id, event.original_app_user_id];
  return [...new Set(ids.filter(isCustomerId))];
};
