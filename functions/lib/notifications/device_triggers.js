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
exports.dedupeDeviceTokens = void 0;
const admin = __importStar(require("firebase-admin"));
const firestore_1 = require("firebase-functions/v2/firestore");
const logger_1 = require("../core/logger/logger");
/**
 * Cross-user device token deduplication.
 *
 * Fires when any `users/{userId}/devices/{deviceId}` doc is written. If the
 * same FCM token exists under another user (typical scenario: logout failed
 * offline, then the same install registered under a new account), the older
 * docs are deleted. Winner = the doc that was just written (most recent intent).
 *
 * This guarantees the invariant: one FCM token belongs to at most one user at
 * any time. Without it, sending a push to user A could deliver to a phone now
 * signed in as user B.
 */
exports.dedupeDeviceTokens = (0, firestore_1.onDocumentWritten)("users/{userId}/devices/{deviceId}", async (event) => {
    var _a, _b, _c;
    const after = (_b = (_a = event.data) === null || _a === void 0 ? void 0 : _a.after) === null || _b === void 0 ? void 0 : _b.data();
    if (!after)
        return; // Deletion — nothing to dedup against.
    const token = after.token;
    if (!token)
        return;
    const currentUserId = event.params.userId;
    const currentDeviceId = event.params.deviceId;
    const logger = new logger_1.Logger("dedupeDeviceTokens");
    try {
        const duplicates = await admin
            .firestore()
            .collectionGroup("devices")
            .where("token", "==", token)
            .get();
        const batch = admin.firestore().batch();
        let staleCount = 0;
        for (const doc of duplicates.docs) {
            const parentUserId = (_c = doc.ref.parent.parent) === null || _c === void 0 ? void 0 : _c.id;
            if (parentUserId === currentUserId && doc.id === currentDeviceId) {
                continue;
            }
            batch.delete(doc.ref);
            staleCount++;
        }
        if (staleCount > 0) {
            await batch.commit();
            logger.info(`Removed ${staleCount} duplicate device doc(s) for token …${token.slice(-8)} ` +
                `after write at users/${currentUserId}/devices/${currentDeviceId}`);
        }
    }
    catch (e) {
        logger.error(`Cross-user device dedup failed: ${e}`);
    }
});
//# sourceMappingURL=device_triggers.js.map