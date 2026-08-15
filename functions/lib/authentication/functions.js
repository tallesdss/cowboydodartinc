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
exports.deleteUserAccount = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const logger_1 = require("../core/logger/logger");
exports.deleteUserAccount = (0, https_1.onCall)(async (request) => {
    if (request == null) {
        throw new https_1.HttpsError("failed-precondition", "The function must be called while authenticated");
    }
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "You must be authenticated to delete your account");
    }
    const uid = request.auth.uid;
    const logger = new logger_1.Logger("deleteUserAccount");
    const db = admin.firestore();
    try {
        // Delete DATA first, IDENTITY last. Each Firestore delete is idempotent
        // (removing a missing doc is a no-op), so if anything below fails the
        // account is still signed-in and the whole operation can be retried
        // safely — we never leave a half-deleted "ghost" (auth gone, data left)
        // that would strand the client logged in against a user that no longer
        // exists. This mirrors the Supabase backend, where deleting auth.users
        // cascades to every related row in a single atomic step.
        // 1. Firestore user doc + subcollections (devices, notifications, ...)
        await db.recursiveDelete(db.collection("users").doc(uid));
        // 2. Subscription document
        await db.collection("subscriptions").doc(uid).delete();
        // 3. Firebase Auth identity — the irreversible step, done only once the
        //    data is gone so a failure above leaves a clean, retriable state.
        await admin.auth().deleteUser(uid);
        logger.info(`User ${uid} deleted successfully`);
    }
    catch (e) {
        logger.error(`Error deleteUserAccount users/${uid}: ${e}`);
        throw new https_1.HttpsError("internal", "Error deleting user account");
    }
});
//# sourceMappingURL=functions.js.map