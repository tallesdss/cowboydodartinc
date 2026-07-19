import {Logger} from "../core/logger/logger";

import {UserEntity} from "../core/data/entities/user_entity";
import {notificationsApi} from "../notifications/notifications_api";
import {NotificationPayload, SystemNotificationParams} from "../notifications/models/notification";
import {NotificationTypes} from "../core/data/entities/notification_entity";
import {Timestamp} from "firebase-admin/firestore";
import {usersRepository} from "../core/data/repositories/repositories";
import * as functions from "firebase-functions/v1";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {UserDeviceEntityData} from "../core/data/entities/user_device_entity";

/**
 * Triggered when a new user registers.
 * Uses v1 auth trigger (always deploys to us-central1 — Firebase limitation).
 * Creates the user document in Firestore.
 */
export const onUserRegistration = functions
  .auth
  .user()
  .onCreate(async (user) => {
    const logger = new Logger("onUserRegistration");
    try {
      const exists = await usersRepository.getFromId(user.uid);
      if (exists) {
        logger.info(`User ${user.uid} already exists — updating email`);
        if (user.email) {
          await usersRepository.updateEmail(user.uid, user.email);
        }
        return;
      }
      const userEntity = new UserEntity({
        id: user.uid,
        email: user.email,
        name: user.displayName,
        creation_date: Timestamp.now(),
        last_update_date: Timestamp.now(),
      });
      await usersRepository.create(userEntity);
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      logger.error(`Error creating users/${user.uid} : ${msg}`);
      if (msg.includes('PERMISSION_DENIED') || msg.includes('permission-denied')) {
        logger.error(
          `→ PERMISSION_DENIED: the Cloud Functions service account lacks Firestore write access.\n` +
          `  Fix: gcloud projects add-iam-policy-binding PROJECT_ID \\\n` +
          `    --member=serviceAccount:PROJECT_ID@appspot.gserviceaccount.com \\\n` +
          `    --role=roles/datastore.user`
        );
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
export const onFirstDeviceRegistered = onDocumentCreated(
  "users/{userId}/devices/{deviceId}",
  async (event) => {
    const logger = new Logger("onFirstDeviceRegistered");
    const userId = event.params.userId;
    try {
      const shouldWelcome = await usersRepository.claimWelcome(userId);
      if (!shouldWelcome) return;

      const deviceData = event.data?.data() as UserDeviceEntityData | undefined;
      // Flutter serializes as "extraData" (camelCase); Firestore schema uses "extra_data".
      // Check both to handle devices registered by either serialization.
      const rawExtraData = deviceData?.extra_data ?? (deviceData as Record<string, unknown> | undefined)?.["extraData"] as Record<string, string> | undefined;
      const rawLocale: string = (rawExtraData?.["deviceLocale"] as string) ?? "en";
      const locale = rawLocale.substring(0, 2).toLowerCase();

      let title: string;
      let body: string;
      if (locale === "pt") {
        title = "Bem-vindo!";
        body = "Sua conta está pronta. Aproveite!";
      } else if (locale === "es") {
        title = "¡Bienvenido!";
        body = "Tu cuenta está lista. ¡Disfrútala!";
      } else {
        title = "Welcome!";
        body = "Your account is ready. Enjoy!";
      }

      await notificationsApi.createNotificationOnly(
        [userId],
        <SystemNotificationParams>{
          title,
          body,
          systemNotification: <NotificationPayload>{
            type: NotificationTypes.WELCOME,
          },
        },
      );
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      logger.error(`Error in onFirstDeviceRegistered for user ${userId}: ${msg}`);
    }
  }
);
