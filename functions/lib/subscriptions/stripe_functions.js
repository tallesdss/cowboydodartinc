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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.onUserDeletedCleanupStripe = exports.stripeWebhook = exports.createPortalSession = exports.createCheckoutSession = exports.listPrices = void 0;
const logger_1 = require("firebase-functions/logger");
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-functions/v2/firestore");
const params_1 = require("firebase-functions/params");
const admin = __importStar(require("firebase-admin"));
const firestore_2 = require("firebase-admin/firestore");
const stripe_1 = __importDefault(require("stripe"));
const subscriptions_1 = require("./models/subscriptions");
const repositories_1 = require("../core/data/repositories/repositories");
const subscription_status_1 = require("./models/subscription_status");
// Server-side only. Never exposed to the client.
const stripeSecretKey = (0, params_1.defineSecret)("STRIPE_SECRET_KEY");
const stripeWebhookSecret = (0, params_1.defineSecret)("STRIPE_WEBHOOK_SECRET");
// Optional: restrict the listed prices to a single Stripe product.
const stripeProductId = (0, params_1.defineString)("STRIPE_PRODUCT_ID", { default: "" });
// Firestore collection mapping a Firebase uid -> its Stripe customer id.
const CUSTOMERS_COLLECTION = "stripe_customers";
function stripeClient() {
    return new stripe_1.default(stripeSecretKey.value());
}
async function getOrCreateCustomer(stripe, uid, email) {
    var _a;
    const db = admin.firestore();
    const ref = db.collection(CUSTOMERS_COLLECTION).doc(uid);
    const snap = await ref.get();
    const existing = (_a = snap.data()) === null || _a === void 0 ? void 0 : _a.customerId;
    if (existing) {
        // Keep the Stripe customer email in sync so Checkout pre-fills it and the
        // receipts carry the right address. The payment is bound to the app user by
        // UID (customer + metadata.firebaseUID), never by the typed email, so this
        // is purely UX / billing hygiene.
        if (email)
            await stripe.customers.update(existing, { email });
        return existing;
    }
    const customer = await stripe.customers.create({
        email,
        metadata: { firebaseUID: uid },
    });
    await ref.set({ customerId: customer.id, created_at: firestore_2.Timestamp.now() });
    return customer.id;
}
function trialDaysFor(price, product) {
    var _a, _b, _c;
    const meta = (_b = (_a = price.metadata) === null || _a === void 0 ? void 0 : _a.trial_days) !== null && _b !== void 0 ? _b : (_c = product.metadata) === null || _c === void 0 ? void 0 : _c.trial_days;
    return meta ? Number(meta) : null;
}
// ---------------------------------------------------------------------------
// listPrices — active recurring prices, mapped to the paywall offer contract.
// ---------------------------------------------------------------------------
exports.listPrices = (0, https_1.onCall)({ secrets: [stripeSecretKey] }, async () => {
    const stripe = stripeClient();
    const params = {
        active: true,
        type: "recurring",
        expand: ["data.product"],
        limit: 100,
    };
    const productFilter = stripeProductId.value();
    if (productFilter)
        params.product = productFilter;
    const prices = await stripe.prices.list(params);
    return prices.data
        .filter((p) => Boolean(p.recurring))
        .map((p) => {
        var _a, _b, _c, _d, _e, _f, _g, _h;
        const product = p.product;
        const features = ((_a = product.marketing_features) !== null && _a !== void 0 ? _a : [])
            .map((f) => f.name)
            .filter((n) => Boolean(n));
        return {
            priceId: p.id,
            productId: typeof p.product === "string" ? p.product : product.id,
            productName: (_b = product.name) !== null && _b !== void 0 ? _b : "",
            description: (_c = product.description) !== null && _c !== void 0 ? _c : "",
            unitAmount: (_d = p.unit_amount) !== null && _d !== void 0 ? _d : 0,
            currency: p.currency,
            interval: (_f = (_e = p.recurring) === null || _e === void 0 ? void 0 : _e.interval) !== null && _f !== void 0 ? _f : "month",
            intervalCount: (_h = (_g = p.recurring) === null || _g === void 0 ? void 0 : _g.interval_count) !== null && _h !== void 0 ? _h : 1,
            trialDays: trialDaysFor(p, product),
            features,
        };
    });
});
// ---------------------------------------------------------------------------
// createCheckoutSession — hosted Stripe Checkout (mode=subscription).
// ---------------------------------------------------------------------------
exports.createCheckoutSession = (0, https_1.onCall)({ secrets: [stripeSecretKey] }, async (request) => {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l;
    const uid = (_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid;
    if (!uid)
        throw new https_1.HttpsError("unauthenticated", "Sign in required");
    const priceId = (_b = request.data) === null || _b === void 0 ? void 0 : _b.priceId;
    if (!priceId)
        throw new https_1.HttpsError("invalid-argument", "priceId is required");
    const successUrl = (_d = (_c = request.data) === null || _c === void 0 ? void 0 : _c.successUrl) !== null && _d !== void 0 ? _d : "";
    const cancelUrl = (_f = (_e = request.data) === null || _e === void 0 ? void 0 : _e.cancelUrl) !== null && _f !== void 0 ? _f : successUrl;
    // Pre-fill Checkout with the signed-in user's email (UX only; the user is
    // identified by uid, so paying with a different email still updates them).
    const email = (_h = (_g = request.auth) === null || _g === void 0 ? void 0 : _g.token) === null || _h === void 0 ? void 0 : _h.email;
    // Persist the app language on the user so server-side notifications (e.g.
    // the "subscription saved" message) are sent in the right language. On web
    // there is no registered device to read the locale from, so we capture it
    // here at purchase time.
    const locale = (_k = (_j = request.data) === null || _j === void 0 ? void 0 : _j.locale) === null || _k === void 0 ? void 0 : _k.substring(0, 2).toLowerCase();
    if (locale) {
        await admin
            .firestore()
            .collection("users")
            .doc(uid)
            .set({ locale }, { merge: true });
    }
    const stripe = stripeClient();
    const customerId = await getOrCreateCustomer(stripe, uid, email);
    const price = await stripe.prices.retrieve(priceId, { expand: ["product"] });
    const trialDays = trialDaysFor(price, price.product);
    const allowPromoCodes = (_l = request.data) === null || _l === void 0 ? void 0 : _l.allowPromoCodes;
    const session = await stripe.checkout.sessions.create(Object.assign({ mode: "subscription", customer: customerId, client_reference_id: uid, line_items: [{ price: priceId, quantity: 1 }], success_url: successUrl, cancel_url: cancelUrl, subscription_data: Object.assign({ metadata: { firebaseUID: uid } }, (trialDays ? { trial_period_days: trialDays } : {})) }, (allowPromoCodes ? { allow_promotion_codes: true } : {})));
    return { url: session.url };
});
// ---------------------------------------------------------------------------
// getOrCreatePortalConfig — creates (once) a Customer Portal configuration
// with subscription_update (plan switching) enabled and caches its ID in
// Firestore so we don't recreate it on every portal open. Falls back to
// undefined (default portal) if there are no prices to switch between.
// ---------------------------------------------------------------------------
async function getOrCreatePortalConfig(stripe) {
    var _a;
    const db = admin.firestore();
    const configRef = db.doc("_config/stripe_portal");
    const snap = await configRef.get();
    const cachedId = (_a = snap.data()) === null || _a === void 0 ? void 0 : _a.configId;
    if (cachedId) {
        try {
            const cfg = await stripe.billingPortal.configurations.retrieve(cachedId);
            if (cfg.active)
                return cachedId;
        }
        catch (_b) {
            // Cached config was deleted on Stripe — recreate below
        }
    }
    // Build allowed-prices list grouped by product. STRIPE_PRODUCT_ID narrows the
    // query to a single product; if it's not set we use all active recurring prices.
    const productId = stripeProductId.value();
    const priceParams = { active: true, type: "recurring", limit: 100 };
    if (productId)
        priceParams.product = productId;
    const { data: prices } = await stripe.prices.list(priceParams);
    if (prices.length === 0)
        return undefined;
    const byProduct = {};
    for (const p of prices) {
        const pid = typeof p.product === "string" ? p.product : p.product.id;
        if (!byProduct[pid])
            byProduct[pid] = [];
        byProduct[pid].push(p.id);
    }
    const products = Object.entries(byProduct).map(([prod, priceIds]) => ({
        product: prod,
        prices: priceIds,
    }));
    const config = await stripe.billingPortal.configurations.create({
        features: {
            subscription_update: {
                enabled: true,
                default_allowed_updates: ["price"],
                products,
            },
            subscription_cancel: { enabled: true, mode: "at_period_end" },
            payment_method_update: { enabled: true },
        },
    });
    await configRef.set({ configId: config.id }, { merge: true });
    return config.id;
}
// ---------------------------------------------------------------------------
// createPortalSession — Stripe Customer Portal (manage / cancel / switch plan).
// ---------------------------------------------------------------------------
exports.createPortalSession = (0, https_1.onCall)({ secrets: [stripeSecretKey] }, async (request) => {
    var _a, _b, _c, _d, _e;
    const uid = (_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid;
    if (!uid)
        throw new https_1.HttpsError("unauthenticated", "Sign in required");
    const returnUrl = (_c = (_b = request.data) === null || _b === void 0 ? void 0 : _b.returnUrl) !== null && _c !== void 0 ? _c : "";
    const planSwitching = (_d = request.data) === null || _d === void 0 ? void 0 : _d.planSwitching;
    const stripe = stripeClient();
    const snap = await admin
        .firestore()
        .collection(CUSTOMERS_COLLECTION)
        .doc(uid)
        .get();
    const customerId = (_e = snap.data()) === null || _e === void 0 ? void 0 : _e.customerId;
    if (!customerId) {
        throw new https_1.HttpsError("failed-precondition", "No Stripe customer for user");
    }
    // When plan switching is requested, resolve (or create) a portal configuration
    // that has subscription_update enabled. This removes the need for any manual
    // setup in the Stripe dashboard.
    const configId = planSwitching ? await getOrCreatePortalConfig(stripe) : undefined;
    const session = await stripe.billingPortal.sessions.create(Object.assign({ customer: customerId, return_url: returnUrl }, (configId ? { configuration: configId } : {})));
    return { url: session.url };
});
// ---------------------------------------------------------------------------
// stripeWebhook — webhook. The ONLY writer of `subscriptions` for Stripe.
// ---------------------------------------------------------------------------
function statusFromStripe(sub) {
    switch (sub.status) {
        case "active":
        case "trialing":
            return subscription_status_1.SubscriptionStatus.ACTIVE;
        default:
            // canceled, unpaid, past_due, incomplete, incomplete_expired, paused
            return subscription_status_1.SubscriptionStatus.EXPIRED;
    }
}
async function upsertFromStripeSubscription(sub) {
    var _a, _b, _c, _d;
    const uid = (_a = sub.metadata) === null || _a === void 0 ? void 0 : _a.firebaseUID;
    if (!uid) {
        console.log("[stripe-webhook] subscription without firebaseUID metadata, skipping");
        return;
    }
    // Skip if the user no longer exists. Deleting an account cancels the Stripe
    // customer, which fires customer.subscription.deleted AFTER deleteUserAccount
    // already removed subscriptions/{uid} — without this guard the webhook would
    // re-create an orphan doc for a user that is gone. (The Supabase webhook does
    // the same check.) The lookup also gives us the email to denormalize below.
    const user = await repositories_1.usersRepository.getFromId(uid);
    if (!user) {
        console.log(`[stripe-webhook] user ${uid} not found (likely deleted), skipping`);
        return;
    }
    const now = firestore_2.Timestamp.now();
    const existing = await repositories_1.subscriptionsRepository.getFromUserId(uid);
    // In Stripe API v18 the billing period lives on each subscription item.
    const item = sub.items.data[0];
    const priceId = (_c = (_b = item === null || item === void 0 ? void 0 : item.price) === null || _b === void 0 ? void 0 : _b.id) !== null && _c !== void 0 ? _c : "";
    const periodEnd = item === null || item === void 0 ? void 0 : item.current_period_end;
    const expiration = periodEnd
        ? firestore_2.Timestamp.fromMillis(periodEnd * 1000)
        : undefined;
    const trialEnd = sub.trial_end
        ? firestore_2.Timestamp.fromMillis(sub.trial_end * 1000)
        : undefined;
    const subscription = new subscriptions_1.Subscription({
        userId: uid,
        status: statusFromStripe(sub),
        creationDate: (_d = existing === null || existing === void 0 ? void 0 : existing.creationDate) !== null && _d !== void 0 ? _d : now,
        lastUpdate: now,
        expirationDate: expiration,
        trialEnd,
        store: subscription_status_1.Stores.STRIPE,
        productId: priceId,
        email: user.email,
    }, repositories_1.subscriptionsRepository);
    await subscription.save();
}
exports.stripeWebhook = (0, https_1.onRequest)({ cors: false, secrets: [stripeSecretKey, stripeWebhookSecret] }, async (req, res) => {
    const signature = req.header("stripe-signature");
    if (!signature) {
        res.status(400).send("Missing signature");
        return;
    }
    const stripe = stripeClient();
    let event;
    try {
        event = stripe.webhooks.constructEvent(req.rawBody, signature, stripeWebhookSecret.value());
    }
    catch (e) {
        console.log(`[stripe-webhook] signature verification failed: ${e}`);
        res.status(400).send("Invalid signature");
        return;
    }
    try {
        switch (event.type) {
            case "customer.subscription.created":
            case "customer.subscription.updated":
            case "customer.subscription.deleted":
                await upsertFromStripeSubscription(event.data.object);
                break;
            default:
                break;
        }
        res.status(200).send("ok");
    }
    catch (e) {
        (0, logger_1.error)(e);
        res.status(500).send(e instanceof Error ? e.message : String(e));
    }
});
// ---------------------------------------------------------------------------
// onUserDeletedCleanupStripe — tears down Stripe state when an account is
// deleted. deleteUserAccount removes the users/{uid} doc; this trigger fires on
// that deletion and (a) deletes the Stripe customer, which immediately cancels
// all of its subscriptions so billing stops, and (b) removes the local
// uid -> customer mapping so no orphan stripe_customers doc is left behind.
// Lives in the Stripe module so a non-Stripe app never deploys it.
// ---------------------------------------------------------------------------
exports.onUserDeletedCleanupStripe = (0, firestore_1.onDocumentDeleted)({ document: "users/{userId}", secrets: [stripeSecretKey] }, async (event) => {
    var _a;
    const uid = event.params.userId;
    const custRef = admin
        .firestore()
        .collection(CUSTOMERS_COLLECTION)
        .doc(uid);
    try {
        const snap = await custRef.get();
        const customerId = (_a = snap.data()) === null || _a === void 0 ? void 0 : _a.customerId;
        if (customerId) {
            // Deleting the Stripe customer cancels all of its subscriptions, so
            // billing stops for the deleted account in a single call.
            await stripeClient().customers.del(customerId);
        }
    }
    catch (e) {
        console.log(`[stripe-cleanup] could not delete Stripe customer for ${uid}: ${e}`);
    }
    // Always drop the local mapping so no orphan remains.
    try {
        await custRef.delete();
    }
    catch (e) {
        console.log(`[stripe-cleanup] could not delete stripe_customers/${uid}: ${e}`);
    }
});
//# sourceMappingURL=stripe_functions.js.map