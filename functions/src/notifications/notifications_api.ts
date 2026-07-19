import * as admin from "firebase-admin";
import {SystemNotificationParams} from "./models/notification";
import {ApnsConfig, Message} from "firebase-admin/messaging";
import {UserNotificationsRepository} from "../core/data/repositories/user_notifications_repository";
import {NotificationEntity, NotificationTypes} from "../core/data/entities/notification_entity";
import {notificationsRepository} from "../core/data/repositories/repositories";

export class NotificationsApi {
  constructor(
        private messaging: admin.messaging.Messaging,
        private userNotificationsRepository: UserNotificationsRepository,
  ) {}

  static create() {
    return new NotificationsApi(
      admin.messaging(),
      notificationsRepository,
    );
  }

  /**
     * Creates a notification for the given users
     * A document is added in the user's notifications collection
     * This triggers a function that will call the sendSystemNotification function
     *
     * If you only want to send a system notification to the user,
     * use the [sendSystemNotification] function
     */
  public async notify(
    userIds: string[],
    notificationParams: SystemNotificationParams,
  ): Promise<void> {
    let type = NotificationTypes.OTHER;
    if (notificationParams.systemNotification) {
      type = notificationParams.systemNotification.type;
    }
    await this.userNotificationsRepository.saveAll(
      userIds,
      new NotificationEntity({
        title: notificationParams.title,
        body: notificationParams.body,
        image_url: notificationParams.image_url,
        type: type,
        creation_date: admin.firestore.Timestamp.now(),
        notify_user: true,
      })
    );
  }

  /**
     * Creates a notification for the given users
     * A document is added in the user's notifications collection
     * - This won't noty user with a system notification
     *
     * If you only want to send a system notification to the user,
     * use the [sendSystemNotification] function
     */
  public async createNotificationOnly(
    userIds: string[],
    notificationParams: SystemNotificationParams,
  ): Promise<void> {
    for (const userId of userIds) {
      await this.userNotificationsRepository.save(
        userId,
        new NotificationEntity({
          title: notificationParams.title,
          body: notificationParams.body,
          type: notificationParams.systemNotification.type,
          creation_date: admin.firestore.Timestamp.now(),
          notify_user: false,
        })
      );
    }
  }


  /**
     * Sends a system notification to the given users (tokens)
     * @param tokens
     * @param notification
     * @param data
     * @param android
     * @param apns
     * @param webpush
     */
  async sendSystemNotification(
    tokens: string[],
    notification: admin.messaging.Notification,
    data: { [key: string]: string } | null,
    android: admin.messaging.AndroidConfig | null,
    apns: admin.messaging.ApnsConfig | null,
    webpush: admin.messaging.WebpushConfig | null
  ) {
    if (tokens.length === 0) {
      return;
    }
    try {
      if (tokens.length > 500) {
        throw new Error("Too many tokens");
      }
      const messages = [];
      for (const token of tokens) {
        const msge = <Message>{
          token: token,
          data: data != null ? this.cleanNotStringData(data) : undefined,
          notification: notification,
          apns: <ApnsConfig>{
            payload: {
              aps: {
                contentAvailable: true,
              },
            },
          },
        };
        if (android) {
          msge.android = android;
        }
        if (apns) {
          msge.apns = apns;
        }
        if (webpush) {
          msge.webpush = webpush;
        }
        messages.push(msge);
      }
      // Invalid/expired tokens are detected from the BatchResponse and removed by the caller.
      // Rate limiting per user is enforced at the trigger level before this method is called.
      return this.messaging.sendEach(messages);
    } catch (err) {
      throw new Error(`Error while sending notification: ${err}`);
    }
  }

  private cleanNotStringData(
    data: { [key: string]: string }
  ): admin.messaging.DataMessagePayload {
    for (const key of Object.keys(data)) {
      if (typeof data[key] !== "string") {
        delete data[key];
      }
    }
    return data;
  }
}


export const notificationsApi = NotificationsApi.create();
