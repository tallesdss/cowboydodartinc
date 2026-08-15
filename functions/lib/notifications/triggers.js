"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onNotificationCreated = void 0;
const notifications_api_1 = require("./notifications_api");
const logger_1 = require("../core/logger/logger");
const notification_entity_1 = require("../core/data/entities/notification_entity");
const repositories_1 = require("../core/data/repositories/repositories");
const firestore_1 = require("firebase-functions/v2/firestore");
const kChannelId = "cowboydodartinc";
exports.onNotificationCreated = (0, firestore_1.onDocumentCreated)("users/{userId}/notifications/{notificationId}", async (event) => {
    var _a, _b;
    if (!event.data) {
        return;
    }
    const logger = new logger_1.Logger("onNotificationCreated");
    try {
        const notificationEntity = notification_entity_1.NotificationEntity.fromDocument(event.data);
        const userId = event.params.userId;
        if (!notificationEntity.notify_user) {
            return;
        }
        // Do NOT set imageUrl on the cross-platform notification object.
        // Setting notification.imageUrl makes FCM treat image delivery as
        // "managed" for both platforms and can interfere with the iOS
        // Notification Service Extension. Instead, specify per-platform:
        // Android: android.notification.imageUrl
        // iOS: apns.fcmOptions.imageUrl + apns.aps.mutableContent
        const notification = {
            title: notificationEntity.title,
            body: notificationEntity.body,
        };
        const data = Object.assign(Object.assign({ type: notificationEntity.type, title: notificationEntity.title, body: notificationEntity.body }, (notificationEntity.image_url ? { imageUrl: notificationEntity.image_url } : {})), notificationEntity.data);
        const android = {
            notification: Object.assign({ channelId: kChannelId }, (notificationEntity.image_url
                ? { imageUrl: notificationEntity.image_url }
                : {})),
        };
        const apns = {
            headers: {
                "apns-push-type": "alert",
                "apns-priority": "10",
            },
            payload: {
                aps: Object.assign({ sound: "default", badge: 1 }, (notificationEntity.image_url ? { mutableContent: true } : {})),
            },
            fcmOptions: notificationEntity.image_url
                ? { imageUrl: notificationEntity.image_url }
                : undefined,
        };
        const allDevices = await repositories_1.userDevicesRepository.getDevices([userId]);
        // Skip installs without a push token (notifications not enabled yet): no
        // point sending, and — crucially — an empty token fails as "invalid" which
        // would delete the install in the cleanup below.
        const userDevices = allDevices.filter((userDevice) => !!userDevice.token);
        const tokens = userDevices.map((userDevice) => userDevice.token);
        if (tokens.length === 0) {
            logger.info(`No device with a push token for user ${userId}`);
            return;
        }
        const notificationApi = notifications_api_1.NotificationsApi.create();
        const notificationsResult = await notificationApi.sendSystemNotification(tokens, notification, data, android, apns, null);
        if (notificationsResult && notificationsResult.failureCount > 0) {
            logger.error(`Error sending notification to user ${userId}: ${notificationsResult.failureCount} failed`);
            for (let i = 0; i < notificationsResult.responses.length; i++) {
                const response = notificationsResult.responses[i];
                if (!response.success) {
                    const device = userDevices[i];
                    const errorCode = (_b = (_a = response.error) === null || _a === void 0 ? void 0 : _a.code) !== null && _b !== void 0 ? _b : "";
                    logger.error(`Failed token for user ${userId}, device ${device.id}: ${errorCode}`);
                    // Only remove tokens that are permanently invalid (app uninstalled or token revoked).
                    // Temporary errors (quota, server unavailable, internal) must NOT cause deletion.
                    const isPermanent = errorCode === "messaging/registration-token-not-registered" ||
                        errorCode === "messaging/invalid-registration-token";
                    if (isPermanent && device.id) {
                        await repositories_1.userDevicesRepository.delete(userId, device.id);
                    }
                }
            }
        }
    }
    catch (e) {
        logger.error(`Error onNotificationCreated users/${event.params.userId}/notifications/${event.id} : ${e}`);
    }
});
//# sourceMappingURL=triggers.js.map