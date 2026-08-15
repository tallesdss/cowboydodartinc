"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Stores = exports.SubscriptionStatus = void 0;
exports.SubscriptionStatus = {
    ACTIVE: "ACTIVE",
    PAUSED: "PAUSED",
    EXPIRED: "EXPIRED",
    LIFETIME: "LIFETIME",
};
exports.Stores = {
    PLAY_STORE: "PLAY_STORE",
    APPLE_STORE: "APPLE_STORE",
    EARLY_BIRD: "EARLY_BIRD",
    // Subscription purchased on the web via Stripe.
    STRIPE: "STRIPE",
};
//# sourceMappingURL=subscription_status.js.map