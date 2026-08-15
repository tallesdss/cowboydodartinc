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
exports.onFirstDeviceRegistered = exports.onUserRegistration = void 0;
const logger_1 = require("../core/logger/logger");
const user_entity_1 = require("../core/data/entities/user_entity");
const notifications_api_1 = require("../notifications/notifications_api");
const notification_entity_1 = require("../core/data/entities/notification_entity");
const firestore_1 = require("firebase-admin/firestore");
const repositories_1 = require("../core/data/repositories/repositories");
const functions = __importStar(require("firebase-functions/v1"));
const firestore_2 = require("firebase-functions/v2/firestore");
/**
 * Triggered when a new user registers.
 * Uses v1 auth trigger (always deploys to us-central1 — Firebase limitation).
 * Creates the user document in Firestore.
 */
exports.onUserRegistration = functions
    .auth
    .user()
    .onCreate(async (user) => {
    const logger = new logger_1.Logger("onUserRegistration");
    try {
        const exists = await repositories_1.usersRepository.getFromId(user.uid);
        if (exists) {
            logger.info(`User ${user.uid} already exists — updating email`);
            if (user.email) {
                await repositories_1.usersRepository.updateEmail(user.uid, user.email);
            }
            return;
        }
        const userEntity = new user_entity_1.UserEntity({
            id: user.uid,
            email: user.email,
            name: user.displayName,
            creation_date: firestore_1.Timestamp.now(),
            last_update_date: firestore_1.Timestamp.now(),
        });
        await repositories_1.usersRepository.create(userEntity);
    }
    catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        logger.error(`Error creating users/${user.uid} : ${msg}`);
        if (msg.includes('PERMISSION_DENIED') || msg.includes('permission-denied')) {
            logger.error(`→ PERMISSION_DENIED: the Cloud Functions service account lacks Firestore write access.\n` +
                `  Fix: gcloud projects add-iam-policy-binding PROJECT_ID \\\n` +
                `    --member=serviceAccount:PROJECT_ID@appspot.gserviceaccount.com \\\n` +
                `    --role=roles/datastore.user`);
        }
    }
});
/**
 * Triggered when a device is registered.
 * Sends a localized welcome notification ONCE per account (saved to DB only, no
 * push). Fires on device creation so the device locale is available.
 *
 * The "once per account" guard is [UserRepository.claimWelcome], not a device
 * count: a device re-registered after a logout/login cycle looks like a fresh
 * first device, so counting devices re-sent the welcome on every re-login.
 */
exports.onFirstDeviceRegistered = (0, firestore_2.onDocumentCreated)("users/{userId}/devices/{deviceId}", async (event) => {
    var _a, _b, _c;
    const logger = new logger_1.Logger("onFirstDeviceRegistered");
    const userId = event.params.userId;
    try {
        const shouldWelcome = await repositories_1.usersRepository.claimWelcome(userId);
        if (!shouldWelcome)
            return;
        const deviceData = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
        // Flutter serializes as "extraData" (camelCase); Firestore schema uses "extra_data".
        // Check both to handle devices registered by either serialization.
        const rawExtraData = (_b = deviceData === null || deviceData === void 0 ? void 0 : deviceData.extra_data) !== null && _b !== void 0 ? _b : deviceData === null || deviceData === void 0 ? void 0 : deviceData["extraData"];
        const rawLocale = (_c = rawExtraData === null || rawExtraData === void 0 ? void 0 : rawExtraData["deviceLocale"]) !== null && _c !== void 0 ? _c : "en";
        const locale = rawLocale.substring(0, 2).toLowerCase();
        let title;
        let body;
        if (locale === "pt") {
            title = "Bem-vindo!";
            body = "Sua conta está pronta. Aproveite!";
        }
        else if (locale === "es") {
            title = "¡Bienvenido!";
            body = "Tu cuenta está lista. ¡Disfrútala!";
        }
        else {
            title = "Welcome!";
            body = "Your account is ready. Enjoy!";
        }
        await notifications_api_1.notificationsApi.createNotificationOnly([userId], {
            title,
            body,
            systemNotification: {
                type: notification_entity_1.NotificationTypes.WELCOME,
            },
        });
    }
    catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        logger.error(`Error in onFirstDeviceRegistered for user ${userId}: ${msg}`);
    }
});
//# sourceMappingURL=triggers.js.map