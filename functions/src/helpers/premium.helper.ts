import {DocumentData} from "firebase-admin/firestore";
import {recordOf} from "../common/utils";

export const CURRENCY = "INR";
export const TRIAL_DAYS = 7;
const MS_PER_DAY = 86_400_000;

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

export const periodEndFrom = (start: Date, months: number): Date => {
  const end = new Date(start);
  end.setUTCMonth(end.getUTCMonth() + months);
  return end;
};

export const trialEndFrom = (start: Date): Date =>
  new Date(start.getTime() + TRIAL_DAYS * MS_PER_DAY);
