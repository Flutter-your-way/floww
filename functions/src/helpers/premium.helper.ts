import {DocumentData} from "firebase-admin/firestore";
import {recordOf} from "../common/utils";

export type SubscriptionTerm = "monthly" | "yearly";

export interface PremiumPlan {
  planId: string;
  months: number;
  planLabel: string;
  periodLabel: string;
}

export const PREMIUM_PLANS: Record<SubscriptionTerm, PremiumPlan> = {
  monthly: {
    planId: "floww_premium_monthly",
    months: 1,
    planLabel: "Monthly Plan",
    periodLabel: "/month",
  },
  yearly: {
    planId: "floww_premium_yearly",
    months: 12,
    planLabel: "Yearly Plan",
    periodLabel: "/year",
  },
};

export const PREMIUM_ENTITLEMENT = "premium";

const YEARLY_PRODUCT_PATTERN = /year|annual|12m|p1y/i;

export const termForProduct = (productId: string): SubscriptionTerm => {
  const baseId = productId.split(":")[0];
  return baseId === PREMIUM_PLANS.yearly.planId ||
    YEARLY_PRODUCT_PATTERN.test(productId) ? "yearly" : "monthly";
};

export const planForProduct = (productId: string): PremiumPlan =>
  PREMIUM_PLANS[termForProduct(productId)];

const ACCESS_STATUSES = ["active", "cancelled"];

export const renewsOnOf = (user: DocumentData | undefined): number | null => {
  const renewsOn = recordOf(user?.subscription).renewsOn;
  if (typeof renewsOn !== "string") return null;
  const time = Date.parse(renewsOn);
  return Number.isNaN(time) ? null : time;
};

/**
 * `users/{uid}.adminAccess` — written only by the admin console (server-owned
 * in firestore.rules). A `grant` gives Premium without a store purchase until
 * `until` (null = no end date). A `revoke` blocks Premium even when the store
 * says the user paid. RevenueCat sync respects both.
 */
export const ADMIN_SOURCE = "admin";
export const ADMIN_PLAN_ID = "floww_premium_admin";
export const ADMIN_NO_END = "9999-12-31T23:59:59.000Z";

export interface AdminAccess {
  mode: "grant" | "revoke";
  until: string | null;
  term: SubscriptionTerm;
  at: string;
}

export const adminAccessOf = (
  user: DocumentData | undefined,
): AdminAccess | null => {
  const raw = recordOf(user?.adminAccess);
  if (raw.mode !== "grant" && raw.mode !== "revoke") return null;
  const until = typeof raw.until === "string" &&
    !Number.isNaN(Date.parse(raw.until)) ? raw.until : null;
  return {
    mode: raw.mode,
    until,
    term: raw.term === "yearly" ? "yearly" : "monthly",
    at: typeof raw.at === "string" ? raw.at : new Date().toISOString(),
  };
};

export const isGrantActive = (
  access: AdminAccess | null,
  now: Date = new Date(),
): boolean =>
  access?.mode === "grant" &&
  (access.until === null || now.getTime() < Date.parse(access.until));

/** The `subscription` block the app parses for an admin grant. */
export const adminSubscriptionOf = (access: AdminAccess, now: Date) => ({
  status: "active" as const,
  term: access.term,
  planId: ADMIN_PLAN_ID,
  planName: "Premium (granted)",
  price: 0,
  currency: "",
  periodLabel: "",
  startedAt: access.at,
  renewsOn: access.until ?? ADMIN_NO_END,
  cancelledAt: null,
  trialEndsOn: null,
  updatedAt: now.toISOString(),
  isSimulated: false,
  source: ADMIN_SOURCE,
  store: null,
  managementUrl: null,
  hasBillingIssue: false,
});

export const hasPremiumAccess = (
  user: DocumentData | undefined,
  now: Date = new Date(),
): boolean => {
  const status = recordOf(user?.subscription).status;
  const renewsOn = renewsOnOf(user);
  return typeof status === "string" &&
    ACCESS_STATUSES.includes(status) &&
    renewsOn !== null &&
    now.getTime() < renewsOn;
};
