import {DocumentData} from "firebase-admin/firestore";
import {recordOf} from "../common/utils";

export const CURRENCY = "INR";

export type SubscriptionTerm = "monthly" | "yearly";

export interface PremiumPlan {
  planId: string;
  price: number;
  months: number;
  planLabel: string;
  periodLabel: string;
}

export const PREMIUM_PLANS: Record<SubscriptionTerm, PremiumPlan> = {
  monthly: {
    planId: "floww_premium_monthly",
    price: 499,
    months: 1,
    planLabel: "Monthly Plan",
    periodLabel: "/month",
  },
  yearly: {
    planId: "floww_premium_yearly",
    price: 3999,
    months: 12,
    planLabel: "Yearly Plan",
    periodLabel: "/year",
  },
};

export const PREMIUM_ENTITLEMENT = "premium";

export const termForProduct = (productId: string): SubscriptionTerm =>
  productId === PREMIUM_PLANS.yearly.planId ? "yearly" : "monthly";

export const planForProduct = (productId: string): PremiumPlan =>
  PREMIUM_PLANS[termForProduct(productId)];

const ACCESS_STATUSES = ["active", "cancelled"];

export const renewsOnOf = (user: DocumentData | undefined): number | null => {
  const renewsOn = recordOf(user?.subscription).renewsOn;
  if (typeof renewsOn !== "string") return null;
  const time = Date.parse(renewsOn);
  return Number.isNaN(time) ? null : time;
};

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
