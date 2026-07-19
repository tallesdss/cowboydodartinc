/**
 * Supabase Edge Function: Send Push Notification via FCM
 *
 * Triggered automatically by a database trigger (pg_net) when a row is inserted
 * into the `notifications` table with notify_user != false (migration
 * 20240101000006_notification_webhook.sql) — NOT by a Dashboard Database Webhook.
 * Reads device FCM tokens for the target user and sends a push notification via
 * Firebase Cloud Messaging HTTP v1 API.
 *
 * Secrets (set automatically by `kasy new` / `kasy deploy`):
 *   - FIREBASE_PROJECT_ID: Your Firebase project ID (e.g. my-app-12345)
 *   - FIREBASE_SERVICE_ACCOUNT_JSON: Full JSON of your Firebase service account key
 *       (Firebase Console → Project Settings → Service Accounts → Generate new private key)
 *
 * Do NOT also create a Dashboard Database Webhook for this function — the pg_net
 * trigger already calls it; a second webhook would double-fire push. See README.md.
 *
 * @see https://firebase.google.com/docs/cloud-messaging/send-message
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.47.10";

interface NotificationRecord {
  id: string;
  user_id: string;
  title: string;
  body: string;
  type?: string;
  data?: Record<string, unknown>;
  image_url?: string;
}

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: NotificationRecord;
  schema: string;
}

// ── FCM auth: exchange service account JSON for OAuth2 access token ──────────

async function getFcmAccessToken(serviceAccountJson: string): Promise<string> {
  const sa = JSON.parse(serviceAccountJson);
  const now = Math.floor(Date.now() / 1000);

  const header = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now,
  };

  const encode = (obj: unknown) =>
    btoa(JSON.stringify(obj))
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=/g, "");

  const signingInput = `${encode(header)}.${encode(payload)}`;

  const pemContents = sa.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s/g, "");

  const binaryDer = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signatureBytes = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signingInput),
  );

  const signature = btoa(String.fromCharCode(...new Uint8Array(signatureBytes)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=/g, "");

  const jwt = `${signingInput}.${signature}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  if (!tokenRes.ok) {
    throw new Error(`OAuth2 token exchange failed: ${await tokenRes.text()}`);
  }

  const { access_token } = await tokenRes.json();
  return access_token as string;
}

// ── FCM HTTP v1: send one message to one token ────────────────────────────────

async function sendToToken(
  projectId: string,
  accessToken: string,
  token: string,
  title: string,
  body: string,
  data: Record<string, string>,
  imageUrl?: string,
): Promise<boolean> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token,
          // imageUrl intentionally NOT set here — FCM "managed" delivery conflicts with
          // UNNotificationServiceExtension on iOS. Platform-specific fields used instead.
          notification: { title, body },
          data,
          android: {
            notification: {
              sound: "default",
              // channel_id omitted — Android uses default_notification_channel_id from AndroidManifest.
              // Sending "default" would create a new low-priority channel instead of the app's channel.
              ...(imageUrl ? { image: imageUrl } : {}),
            },
          },
          apns: {
            headers: {
              "apns-push-type": "alert",
              "apns-priority": "10",
            },
            payload: {
              aps: {
                sound: "default",
                badge: 1,
                // mutable-content: 1 tells iOS to invoke UNNotificationServiceExtension,
                // which downloads and attaches the image before the banner is shown.
                ...(imageUrl ? { "mutable-content": 1 } : {}),
              },
            },
            ...(imageUrl ? { fcm_options: { image: imageUrl } } : {}),
          },
        },
      }),
    },
  );

  if (!res.ok) {
    const err = await res.text();
    console.warn(`[send-push] FCM error for token …${token.slice(-8)}: ${res.status} ${err}`);
    // 404 / UNREGISTERED → stale token; 400 INVALID_ARGUMENT → malformed token — both should be cleaned up
    if (res.status === 404 || err.includes("UNREGISTERED") || err.includes("INVALID_ARGUMENT")) {
      return false;
    }
    return true;
  }
  const ok = await res.json();
  console.log(`[send-push] FCM ok for token …${token.slice(-8)}: ${JSON.stringify(ok)}`);
  return true;
}

// ── Main handler ──────────────────────────────────────────────────────────────

// SUPABASE_ANON_KEY is auto-injected by Supabase into all edge functions.
// The Supabase Dashboard webhook must be configured with:
//   Authorization: Bearer <SUPABASE_ANON_KEY>
// This prevents arbitrary external callers from triggering push notifications.
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

function isAuthorized(req: Request): boolean {
  if (!SUPABASE_ANON_KEY) return false;
  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.startsWith("Bearer ") ? authHeader.slice(7) : authHeader;
  return token === SUPABASE_ANON_KEY;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "POST, OPTIONS" },
    });
  }

  if (!isAuthorized(req)) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  let payload: WebhookPayload;
  try {
    payload = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  // Only handle INSERTs on the notifications table
  if (payload.type !== "INSERT" || payload.table !== "notifications") {
    return new Response(JSON.stringify({ ok: true, message: "ignored" }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  const notification = payload.record;
  if (!notification?.user_id || !notification?.title || !notification?.body) {
    return new Response(JSON.stringify({ error: "Missing required fields in notification record" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  const projectId = Deno.env.get("FIREBASE_PROJECT_ID");
  const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");

  if (!projectId || !serviceAccountJson) {
    console.log("[send-push] FCM not configured (FIREBASE_PROJECT_ID / FIREBASE_SERVICE_ACCOUNT_JSON missing) — push skipped");
    return new Response(JSON.stringify({ ok: true, message: "push skipped: FCM not configured" }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  // Fetch device tokens for the user, skipping orphan installs.
  // Devices not touched in the last 60 days are treated as leftovers from
  // previous installations on the same physical device (each install gets a
  // fresh installation_id). Sending to them causes duplicated push delivery.
  const STALE_DEVICE_TTL_MS = 60 * 24 * 60 * 60 * 1000;
  const cutoffIso = new Date(Date.now() - STALE_DEVICE_TTL_MS).toISOString();
  const { data: devices, error: devErr } = await supabase
    .from("devices")
    .select("id, token")
    .eq("user_id", notification.user_id)
    .or(`last_update_date.is.null,last_update_date.gte.${cutoffIso}`);

  if (devErr || !devices?.length) {
    console.log(`[send-push] no devices for user ${notification.user_id}`);
    return new Response(JSON.stringify({ ok: true, message: "no devices" }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  let accessToken: string;
  try {
    accessToken = await getFcmAccessToken(serviceAccountJson);
  } catch (e) {
    console.error("[send-push] FCM auth error:", e);
    return new Response(JSON.stringify({ error: "FCM authentication failed" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  const extraData: Record<string, string> = {};
  if (notification.type) extraData.type = notification.type;
  if (notification.image_url) extraData.imageUrl = notification.image_url;
  if (notification.data) {
    for (const [k, v] of Object.entries(notification.data)) {
      extraData[k] = String(v);
    }
  }

  let sent = 0;
  const staleTokenIds: string[] = [];

  for (const device of devices) {
    // Installs without a push token (notifications not enabled yet) aren't
    // sendable and must NOT be treated as stale/deleted — just skip them.
    if (!device.token) continue;
    const ok = await sendToToken(projectId, accessToken, device.token, notification.title, notification.body, extraData, notification.image_url);
    if (ok) {
      sent++;
    } else {
      staleTokenIds.push(device.id);
    }
  }

  // Clean up stale tokens
  if (staleTokenIds.length > 0) {
    await supabase.from("devices").delete().in("id", staleTokenIds);
    console.log(`[send-push] removed ${staleTokenIds.length} stale device(s)`);
  }

  console.log(`[send-push] sent ${sent}/${devices.length} for user ${notification.user_id}`);
  return new Response(JSON.stringify({ ok: true, sent, total: devices.length }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
