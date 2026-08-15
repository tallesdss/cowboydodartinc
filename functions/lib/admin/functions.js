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
exports.toggleUserBlock = exports.updateUserRole = exports.listUsers = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const logger_1 = require("../core/logger/logger");
const list_users_1 = require("./list_users");
/**
 * Admin console users API.
 *
 * Paginated list (default):
 *   { page?, pageSize?, search?, subscribersOnly?, sort?, sortAsc? }
 *   → { users, totalUsers, page, pageSize, pageCount, searchCapped? }
 *
 * Overview metrics (cheap aggregates, no full scan):
 *   { overview: true }
 *   → { totalUsers, subscribers, new7d, daily[14], firstDayMs, lastDayMs }
 *
 * Security: caller must be authenticated with role == "admin".
 */
exports.listUsers = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Authentication required");
    }
    const callerUid = request.auth.uid;
    const db = admin.firestore();
    const logger = new logger_1.Logger("listUsers");
    const callerDoc = await db.collection("users").doc(callerUid).get();
    if (!callerDoc.exists || callerDoc.get("role") !== "admin") {
        throw new https_1.HttpsError("permission-denied", "Admin role required");
    }
    try {
        return await (0, list_users_1.handleListUsers)(db, request.data, logger);
    }
    catch (e) {
        if (e instanceof https_1.HttpsError)
            throw e;
        logger.error(`listUsers error: ${e}`);
        throw new https_1.HttpsError("internal", "Failed to list users");
    }
});
/**
 * Updates the role of a user. Admin-only.
 * Payload: { userId: string, role: string }
 */
exports.updateUserRole = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Authentication required");
    }
    const callerUid = request.auth.uid;
    const db = admin.firestore();
    const callerDoc = await db.collection("users").doc(callerUid).get();
    if (!callerDoc.exists || callerDoc.get("role") !== "admin") {
        throw new https_1.HttpsError("permission-denied", "Admin role required");
    }
    const { userId, role } = request.data;
    if (!userId || !role) {
        throw new https_1.HttpsError("invalid-argument", "userId and role are required");
    }
    // Update Firestore document
    await db.collection("users").doc(userId).update({ role });
    // Update Custom Claims (admin flag)
    const isAdmin = role === "admin";
    await admin.auth().setCustomUserClaims(userId, { admin: isAdmin });
    return { success: true };
});
/**
 * Toggles the blocked status of a user (soft-block, Firestore only). Admin-only.
 * Payload: { userId: string, blocked: boolean }
 */
exports.toggleUserBlock = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Authentication required");
    }
    const callerUid = request.auth.uid;
    const db = admin.firestore();
    const callerDoc = await db.collection("users").doc(callerUid).get();
    if (!callerDoc.exists || callerDoc.get("role") !== "admin") {
        throw new https_1.HttpsError("permission-denied", "Admin role required");
    }
    const { userId, blocked } = request.data;
    if (!userId || typeof blocked !== "boolean") {
        throw new https_1.HttpsError("invalid-argument", "userId and blocked are required");
    }
    await db.collection("users").doc(userId).update({ blocked });
    return { success: true };
});
//# sourceMappingURL=functions.js.map