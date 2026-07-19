import { Logger } from "../core/logger/logger";
import {usersRepository, userDevicesRepository} from "../core/data/repositories/repositories";
import {notificationsApi} from "../notifications/notifications_api";
import {SystemNotificationParams} from "../notifications/models/notification";
import {onDocumentCreated} from "firebase-functions/v2/firestore";

/// Localized copy for the "subscription saved" notification.
function subscriptionSavedText(locale: string): {title: string; body: string} {
  switch (locale) {
    case "pt":
      return {title: "Assinatura confirmada", body: "Obrigado pela sua confiança!"};
    case "es":
      return {title: "Suscripción confirmada", body: "¡Gracias por tu confianza!"};
    default:
      return {title: "Subscription confirmed", body: "Thank you for your trust!"};
  }
}

/// Resolves the user's language: the locale persisted on the user (set on web at
/// checkout), then the device locale (native), then English.
async function resolveUserLocale(
  userId: string,
  userLocale: string | undefined,
): Promise<string> {
  if (userLocale) return userLocale.substring(0, 2).toLowerCase();
  try {
    const devices = await userDevicesRepository.getDevices([userId]);
    const raw = devices[0]?.extra_data?.["deviceLocale"] as string | undefined;
    if (raw) return raw.substring(0, 2).toLowerCase();
  } catch {
    // Fall through to the default below.
  }
  return "en";
}

export const onNewSubscription = onDocumentCreated(
  "subscriptions/{userId}",
  async (event) => {
    if (!event.data) {
      return Promise.resolve();
    }
    const userId = event.params.userId;
    const logger = new Logger("onNewSubscription");

    try {
      logger.info(`New subscription for user ${userId}`);
      const user = await usersRepository.getFromId(userId);
      if (!user) {
        logger.error(`User ${userId} not found`);
        return;
      }
      const locale = await resolveUserLocale(userId, user.locale);
      const {title, body} = subscriptionSavedText(locale);
      await notificationsApi.notify(
        [userId],
        <SystemNotificationParams> {
          title,
          body,
        },
      );
    } catch (error) {
      logger.error(
        `Error processing subscription for user ${userId} : ${error}`,
      );
    }
  });
