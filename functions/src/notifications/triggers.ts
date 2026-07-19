import {messaging} from "firebase-admin";
import {NotificationsApi} from "./notifications_api";
import {Logger} from "../core/logger/logger";
import {NotificationEntity} from "../core/data/entities/notification_entity";
import {userDevicesRepository} from "../core/data/repositories/repositories";
import {onDocumentCreated} from "firebase-functions/v2/firestore";

const kChannelId = "cowboydodartinc";

export const onNotificationCreated = onDocumentCreated(
  "users/{userId}/notifications/{notificationId}",
  async (event) => {
    if (!event.data) {
      return;
    }
    const logger = new Logger("onNotificationCreated");
    try {
      const notificationEntity = NotificationEntity.fromDocument(event.data);
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
      const notification = <messaging.Notification>{
        title: notificationEntity.title,
        body: notificationEntity.body,
      };
      const data = <{ [key: string]: string }> {
        type: notificationEntity.type,
        title: notificationEntity.title,
        body: notificationEntity.body,
        ...(notificationEntity.image_url ? {imageUrl: notificationEntity.image_url} : {}),
        ...notificationEntity.data,
      };
      const android = <messaging.AndroidConfig>{
        notification: {
          channelId: kChannelId,
          ...(notificationEntity.image_url
            ? {imageUrl: notificationEntity.image_url}
            : {}),
        },
      };
      const apns = <messaging.ApnsConfig>{
        headers: {
          "apns-push-type": "alert",
          "apns-priority": "10",
        },
        payload: {
          aps: {
            sound: "default",
            badge: 1,
            ...(notificationEntity.image_url ? {mutableContent: true} : {}),
          },
        },
        fcmOptions: notificationEntity.image_url
          ? { imageUrl: notificationEntity.image_url }
          : undefined,
      };
      const allDevices = await userDevicesRepository.getDevices([userId]);
      // Skip installs without a push token (notifications not enabled yet): no
      // point sending, and — crucially — an empty token fails as "invalid" which
      // would delete the install in the cleanup below.
      const userDevices = allDevices.filter((userDevice) => !!userDevice.token);
      const tokens = userDevices.map((userDevice) => userDevice.token);
      if (tokens.length === 0) {
        logger.info(`No device with a push token for user ${userId}`);
        return;
      }
      const notificationApi = NotificationsApi.create();
      const notificationsResult = await notificationApi.sendSystemNotification(
        tokens,
        notification,
        data,
        android,
        apns,
        null
      );

      if (notificationsResult && notificationsResult.failureCount > 0) {
        logger.error(`Error sending notification to user ${userId}: ${notificationsResult.failureCount} failed`);
        for (let i = 0; i < notificationsResult.responses.length; i++) {
          const response = notificationsResult.responses[i];
          if (!response.success) {
            const device = userDevices[i];
            const errorCode = response.error?.code ?? "";
            logger.error(`Failed token for user ${userId}, device ${device.id}: ${errorCode}`);
            // Only remove tokens that are permanently invalid (app uninstalled or token revoked).
            // Temporary errors (quota, server unavailable, internal) must NOT cause deletion.
            const isPermanent =
              errorCode === "messaging/registration-token-not-registered" ||
              errorCode === "messaging/invalid-registration-token";
            if (isPermanent && device.id) {
              await userDevicesRepository.delete(userId, device.id);
            }
          }
        }
      }
    } catch (e) {
      logger.error(`Error onNotificationCreated users/${event.params.userId}/notifications/${event.id} : ${e}`);
    }
  });
