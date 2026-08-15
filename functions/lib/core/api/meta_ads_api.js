"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MetaAdsApi = exports.MetaEventType = void 0;
exports.generateEventId = generateEventId;
exports.createBaseEventParams = createBaseEventParams;
const params_1 = require("firebase-functions/params");
const user_device_entity_1 = require("../data/entities/user_device_entity");
const META_ACCESS_TOKEN = (0, params_1.defineSecret)("META_ACCESS_TOKEN");
const META_DATASET_ID = (0, params_1.defineSecret)("META_DATASET_ID");
// Event types enum for better type safety
var MetaEventType;
(function (MetaEventType) {
    MetaEventType["PURCHASE"] = "Purchase";
    MetaEventType["MOBILE_APP_INSTALL"] = "MobileAppInstall";
    MetaEventType["COMPLETE_REGISTRATION"] = "CompleteRegistration";
    MetaEventType["VIEW_CONTENT"] = "ViewContent";
    MetaEventType["ADD_TO_CART"] = "AddToCart";
    MetaEventType["INITIATE_CHECKOUT"] = "InitiateCheckout";
    MetaEventType["ACHIEVE_LEVEL"] = "AchieveLevel";
    MetaEventType["UNLOCK_ACHIEVEMENT"] = "UnlockAchievement";
    MetaEventType["SPEND_CREDITS"] = "SpendCredits";
    MetaEventType["RATE"] = "Rate";
    MetaEventType["SEARCH"] = "Search";
    MetaEventType["START_TRIAL"] = "StartTrial";
    MetaEventType["SUBSCRIBE"] = "Subscribe";
    MetaEventType["AD_IMPRESSION"] = "AdImpression";
    MetaEventType["AD_CLICK"] = "AdClick";
})(MetaEventType || (exports.MetaEventType = MetaEventType = {}));
class MetaAdsApi {
    constructor() {
        this.apiVersion = "v24.0";
        if (!META_ACCESS_TOKEN.value()) {
            throw new Error("META_ACCESS_TOKEN environment variable is required");
        }
        if (!META_DATASET_ID.value()) {
            throw new Error("META_DATASET_ID environment variable is required");
        }
    }
    /**
     * Base method to send any event to Meta Conversions API
     * Based on: https://developers.facebook.com/docs/marketing-api/conversions-api/app-events/
     */
    async sendMetaEvent(eventType, params, customData) {
        try {
            const { anonymousFbId, email, operatingSystem, eventId, clientIpAddress, mobileAdvertiserId, appPackageName, appVersion, appLongVersion, osVersion, deviceModel, deviceLocale, timezone, carrier, screenWidth, screenHeight, screenDensity, cpuCores, storageSize, freeStorage, deviceTimezone, campaignIds, installReferrer, } = params;
            // Build extinfo array - all values are required and must be in order
            // Missing values should be empty strings as placeholders
            const extinfo = [
                operatingSystem === user_device_entity_1.UserDevice.ANDROID ? "a2" : "i2", // 0: extinfo version (required)
                appPackageName || "", // 1: app package name
                appVersion || "", // 2: short version
                appLongVersion || "", // 3: long version
                osVersion || "", // 4: OS version (required)
                deviceModel || "", // 5: device model name
                deviceLocale || "en_US", // 6: locale
                timezone || "", // 7: timezone abbreviation
                carrier || "", // 8: carrier
                screenWidth || "", // 9: screen width
                screenHeight || "", // 10: screen height
                screenDensity || "", // 11: screen density
                cpuCores || "", // 12: CPU cores
                storageSize || "", // 13: external storage size in GB
                freeStorage || "", // 14: free space on external storage in GB
                deviceTimezone || "", // 15: device timezone
            ];
            // Build user_data object
            const userData = {
                anon_id: anonymousFbId,
            };
            if (clientIpAddress) {
                userData.client_ip_address = clientIpAddress;
            }
            // Add email if available (should be hashed)
            if (email) {
                userData.em = [await this.hashEmail(email)];
            }
            // Add mobile advertiser ID if available (should NOT be hashed)
            if (mobileAdvertiserId) {
                userData.madid = mobileAdvertiserId;
            }
            // Build custom_data object (if provided)
            const customDataObj = customData || {};
            const advertiserTrackingEnabled = mobileAdvertiserId &&
                mobileAdvertiserId.length > 0;
            // Build app_data object with required fields
            const appData = {
                advertiser_tracking_enabled: advertiserTrackingEnabled ? 1 : 0, // Required - ATT permission (iOS 14.5+)
                application_tracking_enabled: advertiserTrackingEnabled ? 1 : 0, // Required - app-level tracking permission
                extinfo: extinfo, // Required - extended device information
            };
            // Add optional campaign IDs if available
            if (campaignIds) {
                appData.campaign_ids = campaignIds;
            }
            // Add install referrer for Android if available
            if (installReferrer && operatingSystem === user_device_entity_1.UserDevice.ANDROID) {
                appData.install_referrer = installReferrer;
            }
            // Build server event
            const serverEvent = {
                event_name: eventType,
                event_time: Math.floor(Date.now() / 1000), // Unix timestamp
                action_source: "app", // Required - must be 'app' for app events
                event_id: eventId, // Required for deduplication
                user_data: userData,
                custom_data: customDataObj,
                app_data: appData,
            };
            // Build the payload
            const payload = {
                data: [serverEvent],
            };
            // Send the event via HTTP API
            const url = `https://graph.facebook.com/${this.apiVersion}/${META_DATASET_ID.value()}/events`;
            const response = await fetch(url, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${META_ACCESS_TOKEN.value()}`,
                },
                body: JSON.stringify(payload),
            });
            if (!response.ok) {
                const errorText = await response.text();
                throw new Error(`Meta API error: ${response.status} ${response.statusText} - ${errorText}`);
            }
            await response.json();
        }
        catch (error) {
            console.error(`Error sending ${eventType} event to Meta:`, error);
            throw error;
        }
    }
    /**
     * Send a subscription conversion event to Meta Conversions API
     */
    sendSubscriptionEvent(params) {
        const customData = {
            currency: params.currency,
            value: params.subscriptionValue.toString(),
        };
        return this.sendMetaEvent(MetaEventType.SUBSCRIBE, params, customData);
    }
    /**
     * Send a trial start event to Meta Conversions API
     */
    sendStartTrialEvent(params) {
        const customData = {};
        if (params.trialValue)
            customData.value = params.trialValue.toString();
        if (params.currency)
            customData.currency = params.currency;
        return this.sendMetaEvent(MetaEventType.START_TRIAL, params, customData);
    }
    sendLifetimeEvent(params) {
        const customData = {};
        if (params.lifetimeValue) {
            customData.value = params.lifetimeValue.toString();
        }
        if (params.currency)
            customData.currency = params.currency;
        return this.sendMetaEvent(MetaEventType.PURCHASE, params, customData);
    }
    /**
     * Send a custom event to Meta Conversions API
     */
    sendCustomEvent(params) {
        return this.sendMetaEvent(params.eventName, params, params.customData);
    }
    /**
     * Send a user registration event to Meta Conversions API
     */
    sendRegistrationEvent(params) {
        return this.sendMetaEvent(MetaEventType.COMPLETE_REGISTRATION, params);
    }
    /**
     * Send a level achievement event to Meta Conversions API
     */
    sendLevelAchievementEvent(params) {
        const customData = {
            level: params.level.toString(),
        };
        return this.sendMetaEvent(MetaEventType.ACHIEVE_LEVEL, params, customData);
    }
    /**
     * Send an achievement unlock event to Meta Conversions API
     */
    sendUnlockAchievementEvent(params) {
        const customData = {
            achievement_id: params.achievementId,
        };
        return this.sendMetaEvent(MetaEventType.UNLOCK_ACHIEVEMENT, params, customData);
    }
    /**
     * Send a spend credits event to Meta Conversions API
     */
    sendSpendCreditsEvent(params) {
        const customData = {
            credits: params.credits.toString(),
        };
        return this.sendMetaEvent(MetaEventType.SPEND_CREDITS, params, customData);
    }
    /**
     * Send a content view event to Meta Conversions API
     */
    sendViewContentEvent(params) {
        const customData = {};
        if (params.contentType)
            customData.content_type = params.contentType;
        if (params.contentId)
            customData.content_id = params.contentId;
        return this.sendMetaEvent(MetaEventType.VIEW_CONTENT, params, customData);
    }
    /**
     * Hash email using SHA-256 (as required by Meta)
     */
    async hashEmail(email) {
        // Normalize email: lowercase and trim whitespace
        const normalizedEmail = email.toLowerCase().trim();
        // Convert string to Uint8Array
        const encoder = new TextEncoder();
        const data = encoder.encode(normalizedEmail);
        // Hash using SHA-256
        const hashBuffer = await crypto.subtle.digest("SHA-256", data);
        // Convert to hex string
        const hashArray = Array.from(new Uint8Array(hashBuffer));
        const hashHex = hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
        return hashHex;
    }
}
exports.MetaAdsApi = MetaAdsApi;
// Helper function to generate unique event IDs for deduplication
function generateEventId() {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}
function createBaseEventParams(user, device) {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l, _m, _o, _p, _q, _r, _s, _t, _u, _v;
    const normalizedDevice = device;
    const extraData = (_b = (_a = normalizedDevice.extra_data) !== null && _a !== void 0 ? _a : normalizedDevice.extraData) !== null && _b !== void 0 ? _b : {};
    const operatingSystem = (_e = (_d = (_c = normalizedDevice.operatingSystem) !== null && _c !== void 0 ? _c : normalizedDevice.type) !== null && _d !== void 0 ? _d : normalizedDevice.operating_system) !== null && _e !== void 0 ? _e : user_device_entity_1.UserDevice.ANDROID;
    return {
        email: user.email,
        operatingSystem,
        osVersion: (_f = extraData.osVersion) !== null && _f !== void 0 ? _f : "",
        eventId: generateEventId(),
        appPackageName: (_g = extraData.appPackageName) !== null && _g !== void 0 ? _g : "",
        appVersion: (_h = extraData.appVersion) !== null && _h !== void 0 ? _h : "",
        appLongVersion: (_j = extraData.appLongVersion) !== null && _j !== void 0 ? _j : "",
        anonymousFbId: (_k = extraData.anonymousFbId) !== null && _k !== void 0 ? _k : "",
        deviceModel: (_l = extraData.deviceModel) !== null && _l !== void 0 ? _l : "",
        deviceLocale: (_m = extraData.deviceLocale) !== null && _m !== void 0 ? _m : "",
        timezone: (_o = extraData.timezone) !== null && _o !== void 0 ? _o : "",
        carrier: (_p = extraData.carrier) !== null && _p !== void 0 ? _p : "",
        screenWidth: (_q = extraData.screenWidth) !== null && _q !== void 0 ? _q : "",
        screenHeight: (_r = extraData.screenHeight) !== null && _r !== void 0 ? _r : "",
        screenDensity: (_s = extraData.screenDensity) !== null && _s !== void 0 ? _s : "",
        cpuCores: (_t = extraData.cpuCores) !== null && _t !== void 0 ? _t : "",
        mobileAdvertiserId: (_u = extraData.mobileAdvertiserId) !== null && _u !== void 0 ? _u : "",
        clientIpAddress: (_v = extraData.clientIpAddress) !== null && _v !== void 0 ? _v : "",
    };
}
//# sourceMappingURL=meta_ads_api.js.map