import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {Logger} from "../core/logger/logger";
import {handleListUsers} from "./list_users";

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
export const listUsers = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }
  const callerUid = request.auth.uid;
  const db = admin.firestore();
  const logger = new Logger("listUsers");

  const callerDoc = await db.collection("users").doc(callerUid).get();
  if (!callerDoc.exists || callerDoc.get("role") !== "admin") {
    throw new HttpsError("permission-denied", "Admin role required");
  }

  try {
    return await handleListUsers(db, request.data as Record<string, unknown>, logger);
  } catch (e) {
    if (e instanceof HttpsError) throw e;
    logger.error(`listUsers error: ${e}`);
    throw new HttpsError("internal", "Failed to list users");
  }
});

/**
 * Updates the role of a user. Admin-only.
 * Payload: { userId: string, role: string }
 */
export const updateUserRole = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }
  const callerUid = request.auth.uid;
  const db = admin.firestore();

  const callerDoc = await db.collection("users").doc(callerUid).get();
  if (!callerDoc.exists || callerDoc.get("role") !== "admin") {
    throw new HttpsError("permission-denied", "Admin role required");
  }

  const {userId, role} = request.data as {userId: string; role: string};
  if (!userId || !role) {
    throw new HttpsError("invalid-argument", "userId and role are required");
  }

  // Update Firestore document
  await db.collection("users").doc(userId).update({role});

  // Update Custom Claims (admin flag)
  const isAdmin = role === "admin";
  await admin.auth().setCustomUserClaims(userId, {admin: isAdmin});

  return {success: true};
});

/**
 * Toggles the blocked status of a user (soft-block, Firestore only). Admin-only.
 * Payload: { userId: string, blocked: boolean }
 */
export const toggleUserBlock = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }
  const callerUid = request.auth.uid;
  const db = admin.firestore();

  const callerDoc = await db.collection("users").doc(callerUid).get();
  if (!callerDoc.exists || callerDoc.get("role") !== "admin") {
    throw new HttpsError("permission-denied", "Admin role required");
  }

  const {userId, blocked} = request.data as {userId: string; blocked: boolean};
  if (!userId || typeof blocked !== "boolean") {
    throw new HttpsError("invalid-argument", "userId and blocked are required");
  }

  await db.collection("users").doc(userId).update({blocked});

  return {success: true};
});
