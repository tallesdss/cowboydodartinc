import * as admin from "firebase-admin";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {Logger} from "../core/logger/logger";

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
export const dedupeDeviceTokens = onDocumentWritten(
  "users/{userId}/devices/{deviceId}",
  async (event) => {
    const after = event.data?.after?.data();
    if (!after) return; // Deletion — nothing to dedup against.

    const token = after.token as string | undefined;
    if (!token) return;

    const currentUserId = event.params.userId;
    const currentDeviceId = event.params.deviceId;
    const logger = new Logger("dedupeDeviceTokens");

    try {
      const duplicates = await admin
        .firestore()
        .collectionGroup("devices")
        .where("token", "==", token)
        .get();

      const batch = admin.firestore().batch();
      let staleCount = 0;
      for (const doc of duplicates.docs) {
        const parentUserId = doc.ref.parent.parent?.id;
        if (parentUserId === currentUserId && doc.id === currentDeviceId) {
          continue;
        }
        batch.delete(doc.ref);
        staleCount++;
      }

      if (staleCount > 0) {
        await batch.commit();
        logger.info(
          `Removed ${staleCount} duplicate device doc(s) for token …${token.slice(-8)} ` +
          `after write at users/${currentUserId}/devices/${currentDeviceId}`,
        );
      }
    } catch (e) {
      logger.error(`Cross-user device dedup failed: ${e}`);
    }
  });
