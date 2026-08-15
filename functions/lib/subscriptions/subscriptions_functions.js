"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.revenuecatWebhook = void 0;
const logger_1 = require("firebase-functions/logger");
const https_1 = require("firebase-functions/v2/https");
const subscriptions_1 = require("./models/subscriptions");
const repositories_1 = require("../core/data/repositories/repositories");
const revenuecat_events_1 = require("./models/revenuecat_events");
const params_1 = require("firebase-functions/params");
const subscription_status_1 = require("./models/subscription_status");
const meta_ads_api_1 = require("../core/api/meta_ads_api");
// firebase functions:config:set revenuecat.token=""
const revenuecatToken = (0, params_1.defineSecret)("REVENUECAT_WEBHOOK_KEY");
const metaAccessToken = (0, params_1.defineSecret)("META_ACCESS_TOKEN");
const metaDatasetId = (0, params_1.defineSecret)("META_DATASET_ID");
async function sendMetaEventsForSubscription(event, subscription) {
    var _a, _b, _c, _d, _e;
    if (!metaAccessToken.value() || !metaDatasetId.value())
        return;
    try {
        const user = await repositories_1.usersRepository.getFromId(event.app_user_id);
        if (!user) {
            console.log("[meta-ads] user not found, skipping");
            return;
        }
        const userDevices = await repositories_1.userDevicesRepository.getDevices([event.app_user_id]);
        if (userDevices.length === 0) {
            console.log("[meta-ads] no device found, skipping");
            return;
        }
        // Prefer device with anonymousFbId when possible.
        const selectedDevice = (_a = userDevices.find((device) => { var _a; return Boolean((_a = device.extra_data) === null || _a === void 0 ? void 0 : _a.anonymousFbId); })) !== null && _a !== void 0 ? _a : userDevices[0];
        const params = (0, meta_ads_api_1.createBaseEventParams)(user, selectedDevice);
        if (!params.anonymousFbId) {
            console.log("[meta-ads] device has no anonymousFbId, skipping");
            return;
        }
        const api = new meta_ads_api_1.MetaAdsApi();
        if (event.type === "INITIAL_PURCHASE" && event.period_type === revenuecat_events_1.PeriodTypes.TRIAL) {
            await api.sendStartTrialEvent(Object.assign(Object.assign({}, params), { trialValue: (_b = event.price_in_purchased_currency) !== null && _b !== void 0 ? _b : undefined, currency: (_c = event.currency) !== null && _c !== void 0 ? _c : undefined }));
            return;
        }
        if (event.subscriptionStatus === subscription_status_1.SubscriptionStatus.LIFETIME) {
            await api.sendLifetimeEvent(Object.assign(Object.assign({}, params), { lifetimeValue: (_d = event.price_in_purchased_currency) !== null && _d !== void 0 ? _d : undefined, currency: (_e = event.currency) !== null && _e !== void 0 ? _e : undefined }));
            return;
        }
        if (event.isInitialPurchase || event.type === "RENEWAL") {
            if (event.price_in_purchased_currency == null || event.currency == null) {
                console.log("[meta-ads] missing currency/value for subscription event");
                return;
            }
            await api.sendSubscriptionEvent(Object.assign(Object.assign({}, params), { subscriptionValue: event.price_in_purchased_currency, currency: event.currency }));
        }
    }
    catch (e) {
        // Meta conversion should never break webhook processing.
        console.log(`[meta-ads] skipped: ${e}`);
    }
}
exports.revenuecatWebhook = (0, https_1.onRequest)({ cors: true, secrets: [revenuecatToken, metaAccessToken, metaDatasetId] }, async (req, res) => {
    console.log("[revenuecatWebhook]");
    const authorization = req.header("Authorization");
    if (!authorization) {
        console.log("Unauthorized - no token provided");
        res.status(401).send("Unauthorized - no token provided");
        return;
    }
    if (authorization !== revenuecatToken.value()) {
        console.log("Unauthorized - invalid token");
        res.status(401).send("Unauthorized - invalid token");
        return;
    }
    const event = revenuecat_events_1.RevenueCatEvent.fromData(Object.assign({}, req.body.event));
    console.log("event type", event.type);
    console.log("product id", event.product_id);
    if (event.shouldIgnore) {
        console.log("ignored event");
        res.status(200).send("ignored event");
        return;
    }
    try {
        const subscription = await subscriptions_1.Subscription.fromRevenueCat({
            event,
            userRepository: repositories_1.usersRepository,
            subscriptionRepository: repositories_1.subscriptionsRepository,
        });
        await subscription.save();
        await sendMetaEventsForSubscription(event, subscription);
        if (event.isInitialPurchase || event.type === "RENEWAL") {
            //-- new subscription or renewal
        }
        else if (event.type === "INITIAL_PURCHASE" &&
            event.period_type === revenuecat_events_1.PeriodTypes.TRIAL) {
            //-- trial started
        }
        else if (event.subscriptionStatus === subscription_status_1.SubscriptionStatus.LIFETIME) {
            //-- 
        }
        res.status(200).send("ok");
    }
    catch (e) {
        (0, logger_1.error)(e);
        res.status(500).send(e instanceof Error ? e.message : String(e));
    }
});
//# sourceMappingURL=subscriptions_functions.js.map