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
exports.adminSendNotification = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const notification_entity_1 = require("../core/data/entities/notification_entity");
const repositories_1 = require("../core/data/repositories/repositories");
/**
 * Callable function for the admin panel to send push notifications.
 * Uses Admin SDK — bypasses Firestore security rules.
 * Only authenticated users can call this; add custom claims check for stricter control.
 */
exports.adminSendNotification = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Login required.");
    }
    const data = request.data;
    const { title, body, imageUrl, route, targetEmails, targetUserIds, sendToAll } = data;
    if (!title || !body) {
        throw new https_1.HttpsError("invalid-argument", "title and body are required.");
    }
    const entity = new notification_entity_1.NotificationEntity({
        title,
        body,
        image_url: imageUrl !== null && imageUrl !== void 0 ? imageUrl : undefined,
        type: notification_entity_1.NotificationTypes.OTHER,
        creation_date: admin.firestore.Timestamp.now(),
        notify_user: true,
        data: route ? { route } : undefined,
    });
    if (sendToAll) {
        // Use Auth listUsers (paginated, 1000/page) instead of a Firestore full scan.
        // This avoids billing reads for every user doc and scales without timeout risk.
        const userIds = [];
        let pageToken;
        do {
            const result = await admin.auth().listUsers(1000, pageToken);
            userIds.push(...result.users.map((u) => u.uid));
            pageToken = result.pageToken;
        } while (pageToken);
        if (userIds.length > 0) {
            await repositories_1.notificationsRepository.saveAll(userIds, entity);
        }
        return { sent: userIds.length };
    }
    // Resolve emails → userIds via Admin Auth (parallel)
    const resolvedIds = [...(targetUserIds !== null && targetUserIds !== void 0 ? targetUserIds : [])];
    const notFound = [];
    const emailResults = await Promise.all((targetEmails !== null && targetEmails !== void 0 ? targetEmails : []).map(async (email) => {
        try {
            const userRecord = await admin.auth().getUserByEmail(email.trim());
            return { uid: userRecord.uid, email: email.trim() };
        }
        catch (_a) {
            return { uid: null, email: email.trim() };
        }
    }));
    for (const result of emailResults) {
        if (result.uid) {
            resolvedIds.push(result.uid);
        }
        else {
            notFound.push(result.email);
        }
    }
    if (notFound.length > 0) {
        throw new https_1.HttpsError("not-found", notFound.join(", "));
    }
    if (resolvedIds.length === 0) {
        throw new https_1.HttpsError("invalid-argument", "Provide targetEmails, targetUserIds, or sendToAll.");
    }
    await repositories_1.notificationsRepository.saveAll(resolvedIds, entity);
    return { sent: resolvedIds.length };
});
//# sourceMappingURL=admin_functions.js.map