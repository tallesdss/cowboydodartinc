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
