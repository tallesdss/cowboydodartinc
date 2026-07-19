import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {Logger} from "../core/logger/logger";

export const deleteUserAccount = onCall(
    async (request) => {
      if (request == null) {
        throw new HttpsError("failed-precondition", "The function must be called while authenticated");
      }
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "You must be authenticated to delete your account");
      }
      const uid = request.auth.uid;
      const logger = new Logger("deleteUserAccount");
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
      } catch (e) {
        logger.error(`Error deleteUserAccount users/${uid}: ${e}`);
        throw new HttpsError("internal", "Error deleting user account");
      }
    });
