import {Timestamp} from "firebase-admin/firestore";
import {SubscriptionStatus} from "./subscription_status";

import * as admin from "firebase-admin";

export const PeriodTypes = {
  TRIAL: "TRIAL",
  INTRO: "INTRO",
  NORMAL: "NORMAL",
  PROMOTIONAL: "PROMOTIONAL",
  PREPAID: "PREPAID",
} as const;

export type PeriodTypes = typeof PeriodTypes[keyof typeof PeriodTypes];

export const RcEventTypes = {
  TEST: "TEST",
  INITIAL_PURCHASE: "INITIAL_PURCHASE",
  RENEWAL: "RENEWAL",
  CANCELLATION: "CANCELLATION",
  UNCANCELLATION: "UNCANCELLATION",
  NON_RENEWING_PURCHASE: "NON_RENEWING_PURCHASE",
  SUBSCRIPTION_PAUSED: "SUBSCRIPTION_PAUSED",
  EXPIRATION: "EXPIRATION",
  BILLING_ISSUE: "BILLING_ISSUE",
  PRODUCT_CHANGE: "PRODUCT_CHANGE",
  TRANSFER: "TRANSFER",
  SUBSCRIPTION_EXTENDED: "SUBSCRIPTION_EXTENDED",
  TEMPORARY_ENTITLEMENT_GRANT: "TEMPORARY_ENTITLEMENT_GRANT",
  REFUND_REVERSED: "REFUND_REVERSED",
  INVOICE_ISSUANCE: "INVOICE_ISSUANCE",
  VIRTUAL_CURRENCY_TRANSACTION: "VIRTUAL_CURRENCY_TRANSACTION",
} as const;

export type RcEventTypes = typeof RcEventTypes[keyof typeof RcEventTypes];

// see https://www.revenuecat.com/docs/integrations/webhooks/event-types-and-fields

export interface RevenueCatEventData {
  event_timestamp_ms: number;
  product_id: string;
  period_type?: PeriodTypes;
  expiration_at_ms: number | null;
  store: string;
  app_user_id: string;
  type: string;
  new_product_id?: string;
  currency?: string;
  price_in_purchased_currency?: number;
  is_trial_conversion?: boolean;
}

// deno-lint-ignore no-empty-interface
export interface RevenueCatEvent extends RevenueCatEventData {}

export class RevenueCatEvent {
  constructor({
    event_timestamp_ms,
    product_id,
    period_type,
    expiration_at_ms,
    store,
    app_user_id,
    type,
    new_product_id,
    currency,
    price_in_purchased_currency,
    is_trial_conversion,
  }: RevenueCatEventData) {
    this.event_timestamp_ms = event_timestamp_ms;
    this.product_id = product_id;
    this.period_type = period_type;
    this.expiration_at_ms = expiration_at_ms;
    this.store = store;
    this.app_user_id = app_user_id;
    this.type = type;
    this.new_product_id = new_product_id;
    this.currency = currency;
    this.price_in_purchased_currency = price_in_purchased_currency;
    this.is_trial_conversion = is_trial_conversion;
  }

  static fromJson(json: string): RevenueCatEvent {
    const data = JSON.parse(json);
    return new RevenueCatEvent({
      event_timestamp_ms: parseInt(data.event_timestamp_ms),
      product_id: data.product_id,
      period_type: data.period_type,
      expiration_at_ms: data.expiration_at_ms != null ? parseInt(data.expiration_at_ms) : null,
      store: data.store,
      app_user_id: data.app_user_id,
      type: data.type,
      new_product_id: data.new_product_id,
      currency: data.currency,
      price_in_purchased_currency: data.price_in_purchased_currency,
      is_trial_conversion: data.is_trial_conversion,
    });
  }

  static fromData(data: any): RevenueCatEvent {
    return new RevenueCatEvent({ ...data });
  }

  get expirationTimestamp(): Timestamp | undefined {
    const expirationDate = this.expirationDate;
    if (!expirationDate) {
      return undefined;
    }
    if (this.subscriptionStatus === SubscriptionStatus.LIFETIME) {
      return undefined;
    }
    return admin.firestore.Timestamp.fromMillis(this.expiration_at_ms!);
  }

  get expirationDate(): Date | undefined {
    if (this.subscriptionStatus === SubscriptionStatus.LIFETIME) {
      return undefined;
    }
    if (!this.expiration_at_ms) {
      return undefined;
    }
    return new Date(this.expiration_at_ms);
  }

  get subscriptionStatus(): SubscriptionStatus {
    switch (this.type) {
      case "INITIAL_PURCHASE":
      case "RENEWAL":
      case "UNCANCELLATION":
      case "SUBSCRIPTION_EXTENDED":
      case "PRODUCT_CHANGE":
        return SubscriptionStatus.ACTIVE;
      case "CANCELLATION":
      case "SUBSCRIPTION_PAUSED":
      case "EXPIRATION":
        return SubscriptionStatus.EXPIRED;
      case "NON_RENEWING_PURCHASE":
        return SubscriptionStatus.LIFETIME;
    }
    return SubscriptionStatus.EXPIRED;
  }

  get shouldIgnore(): boolean {
    switch (this.type) {
      case "BILLING_ISSUE":
      case "TRANSFER":
      case "TEMPORARY_ENTITLEMENT_GRANT":
      case "EXPERIMENT_ENROLLMENT":
      case "REFUND_REVERSED":
      case "INVOICE_ISSUANCE":
      case "VIRTUAL_CURRENCY_TRANSACTION":
        return true;
    }
    return false;
  }

  get isInitialPurchase(): boolean {
    return (this.type === "INITIAL_PURCHASE" &&
      this.period_type !== PeriodTypes.TRIAL) ||
      (this.is_trial_conversion === true);
  }
}
