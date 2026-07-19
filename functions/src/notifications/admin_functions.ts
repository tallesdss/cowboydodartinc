import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {NotificationEntity, NotificationTypes} from "../core/data/entities/notification_entity";
import {notificationsRepository} from "../core/data/repositories/repositories";

interface SendNotificationData {
  title: string;
  body: string;
  imageUrl?: string;
  route?: string;
  targetEmails?: string[];
  targetUserIds?: string[];
  sendToAll?: boolean;
}

/**
 * Callable function for the admin panel to send push notifications.
 * Uses Admin SDK — bypasses Firestore security rules.
 * Only authenticated users can call this; add custom claims check for stricter control.
 */
export const adminSendNotification = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login required.");
  }

  const data = request.data as SendNotificationData;
  const {title, body, imageUrl, route, targetEmails, targetUserIds, sendToAll} = data;

  if (!title || !body) {
    throw new HttpsError("invalid-argument", "title and body are required.");
  }

  const entity = new NotificationEntity({
    title,
    body,
    image_url: imageUrl ?? undefined,
    type: NotificationTypes.OTHER,
    creation_date: admin.firestore.Timestamp.now(),
    notify_user: true,
    data: route ? {route} : undefined,
  });

  if (sendToAll) {
    // Use Auth listUsers (paginated, 1000/page) instead of a Firestore full scan.
    // This avoids billing reads for every user doc and scales without timeout risk.
    const userIds: string[] = [];
    let pageToken: string | undefined;
    do {
      const result = await admin.auth().listUsers(1000, pageToken);
      userIds.push(...result.users.map((u) => u.uid));
      pageToken = result.pageToken;
    } while (pageToken);
    if (userIds.length > 0) {
      await notificationsRepository.saveAll(userIds, entity);
    }
    return {sent: userIds.length};
  }

  // Resolve emails → userIds via Admin Auth (parallel)
  const resolvedIds: string[] = [...(targetUserIds ?? [])];
  const notFound: string[] = [];

  const emailResults = await Promise.all(
    (targetEmails ?? []).map(async (email) => {
      try {
        const userRecord = await admin.auth().getUserByEmail(email.trim());
        return {uid: userRecord.uid, email: email.trim()};
      } catch {
        return {uid: null, email: email.trim()};
      }
    }),
  );
  for (const result of emailResults) {
    if (result.uid) {
      resolvedIds.push(result.uid);
    } else {
      notFound.push(result.email);
    }
  }

  if (notFound.length > 0) {
    throw new HttpsError("not-found", notFound.join(", "));
  }

  if (resolvedIds.length === 0) {
    throw new HttpsError("invalid-argument", "Provide targetEmails, targetUserIds, or sendToAll.");
  }

  await notificationsRepository.saveAll(resolvedIds, entity);
  return {sent: resolvedIds.length};
});
