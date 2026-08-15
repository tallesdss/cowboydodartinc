"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.RevenueCatEvent = exports.RcEventTypes = exports.PeriodTypes = void 0;
const subscription_status_1 = require("./subscription_status");
const admin = __importStar(require("firebase-admin"));
exports.PeriodTypes = {
    TRIAL: "TRIAL",
    INTRO: "INTRO",
    NORMAL: "NORMAL",
    PROMOTIONAL: "PROMOTIONAL",
    PREPAID: "PREPAID",
};
exports.RcEventTypes = {
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
};
class RevenueCatEvent {
    constructor({ event_timestamp_ms, product_id, period_type, expiration_at_ms, store, app_user_id, type, new_product_id, currency, price_in_purchased_currency, is_trial_conversion, }) {
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
    static fromJson(json) {
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
    static fromData(data) {
        return new RevenueCatEvent(Object.assign({}, data));
    }
    get expirationTimestamp() {
        const expirationDate = this.expirationDate;
        if (!expirationDate) {
            return undefined;
        }
        if (this.subscriptionStatus === subscription_status_1.SubscriptionStatus.LIFETIME) {
            return undefined;
        }
        return admin.firestore.Timestamp.fromMillis(this.expiration_at_ms);
    }
    get expirationDate() {
        if (this.subscriptionStatus === subscription_status_1.SubscriptionStatus.LIFETIME) {
            return undefined;
        }
        if (!this.expiration_at_ms) {
            return undefined;
        }
        return new Date(this.expiration_at_ms);
    }
    get subscriptionStatus() {
        switch (this.type) {
            case "INITIAL_PURCHASE":
            case "RENEWAL":
            case "UNCANCELLATION":
            case "SUBSCRIPTION_EXTENDED":
            case "PRODUCT_CHANGE":
                return subscription_status_1.SubscriptionStatus.ACTIVE;
            case "CANCELLATION":
            case "SUBSCRIPTION_PAUSED":
            case "EXPIRATION":
                return subscription_status_1.SubscriptionStatus.EXPIRED;
            case "NON_RENEWING_PURCHASE":
                return subscription_status_1.SubscriptionStatus.LIFETIME;
        }
        return subscription_status_1.SubscriptionStatus.EXPIRED;
    }
    get shouldIgnore() {
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
    get isInitialPurchase() {
        return (this.type === "INITIAL_PURCHASE" &&
            this.period_type !== exports.PeriodTypes.TRIAL) ||
            (this.is_trial_conversion === true);
    }
}
exports.RevenueCatEvent = RevenueCatEvent;
//# sourceMappingURL=revenuecat_events.js.map