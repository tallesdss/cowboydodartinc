/**
 * Supabase Edge Function: Meta Conversions API — Generic Event Tracker
 *
 * Called by the Flutter app (authenticated via Supabase JWT) to send any
 * Meta Conversions API event server-to-server. This mirrors the MetaAdsApi
 * callable Cloud Functions available in the Firebase backend.
 *
 * Typical use-cases:
 *   - CompleteRegistration  → call on user sign-up
 *   - MobileAppInstall      → call on first app launch
 *   - Custom events         → achieve level, spend credits, etc.
 *
 * Subscription events (Subscribe, StartTrial, Purchase) are handled
 * automatically by the revenuecat-webhook edge function; do NOT duplicate
 * them here.
 *
 * Secrets required (set via `supabase secrets set`):
 *   - META_ACCESS_TOKEN  : Meta Marketing API system user access token
 *   - META_DATASET_ID    : Meta Conversions API dataset ID (Pixel ID)
 *
 * Request (POST, authenticated):
 *   Authorization: Bearer <supabase-user-jwt>
 *   Content-Type: application/json
 *   {
 *     "event_name": "CompleteRegistration",   // required – any Meta event name
 *     "custom_data": { "key": "value" }       // optional
 *   }
 *
 * The function resolves device data automatically from the `devices` table
 * (populated by the Flutter app via DeviceApi). If no device row exists yet,
 * the event is sent with minimal user data only.
 *
 * @see https://developers.facebook.com/docs/marketing-api/conversions-api/app-events/
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.47.10";

// ── Supported event names (mirrors MetaEventType from Firebase) ──────────────

export const MetaEventType = {
  COMPLETE_REGISTRATION: "CompleteRegistration",
  MOBILE_APP_INSTALL: "MobileAppInstall",
  VIEW_CONTENT: "ViewContent",
  ACHIEVE_LEVEL: "AchieveLevel",
  UNLOCK_ACHIEVEMENT: "UnlockAchievement",
  SPEND_CREDITS: "SpendCredits",
  RATE: "Rate",
  SEARCH: "Search",
  AD_IMPRESSION: "AdImpression",
  AD_CLICK: "AdClick",
} as const;

// ── Types ────────────────────────────────────────────────────────────────────

interface TrackEventRequest {
  event_name: string;
  custom_data?: Record<string, string | number>;
}

interface DeviceRow {
  operatingSystem?: string;
  extra_data: Record<string, string> | null;
}

interface UserRow {
  email?: string | null;
}

// ── Helpers ──────────────────────────────────────────────────────────────────

async function hashEmail(email: string): Promise<string> {
  const normalized = email.toLowerCase().trim();
  const data = new TextEncoder().encode(normalized);
  const hashBuffer = await crypto.subtle.digest("SHA-256", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}

function buildExtinfo(extra: Record<string, string>, os: string): string[] {
  return [
    os.toLowerCase() === "android" ? "a2" : "i2",
    extra.appPackageName ?? "",
    extra.appVersion ?? "",
    extra.appLongVersion ?? "",
    extra.osVersion ?? "",
    extra.deviceModel ?? "",
    extra.deviceLocale ?? "en_US",
    extra.timezone ?? "",
    extra.carrier ?? "",
    extra.screenWidth ?? "",
    extra.screenHeight ?? "",
    extra.screenDensity ?? "",
    extra.cpuCores ?? "",
    extra.storageSize ?? "",
    extra.freeStorage ?? "",
    extra.deviceTimezone ?? "",
  ];
}

function generateEventId(): string {
  return `${Date.now()}-${Math.random().toString(36).slice(2, 11)}`;
}

async function sendMetaEvent(
  eventName: string,
  userId: string,
  userEmail: string | null | undefined,
  device: DeviceRow | null,
  customData: Record<string, string | number> = {},
): Promise<void> {
  const metaToken = Deno.env.get("META_ACCESS_TOKEN");
  const datasetId = Deno.env.get("META_DATASET_ID");

  if (!metaToken || !datasetId) {
    console.log("[meta-track] META_ACCESS_TOKEN or META_DATASET_ID not configured — skipping");
    return;
  }

  const extra = (device?.extra_data ?? {}) as Record<string, string>;
  const os = device?.operatingSystem ?? "android";
  const anonymousFbId = extra.anonymousFbId ?? userId; // fallback to user ID when FB ID unavailable

  const userData: Record<string, string | string[]> = {
    anon_id: anonymousFbId,
  };
  if (userEmail) userData.em = [await hashEmail(userEmail)];
  if (extra.mobileAdvertiserId) userData.madid = extra.mobileAdvertiserId;
  if (extra.clientIpAddress) userData.client_ip_address = extra.clientIpAddress;

  const extinfo = buildExtinfo(extra, os);
  const hasAdvertiserId = Boolean(extra.mobileAdvertiserId);

  const appData: Record<string, unknown> = {
    advertiser_tracking_enabled: hasAdvertiserId ? 1 : 0,
    application_tracking_enabled: hasAdvertiserId ? 1 : 0,
    extinfo,
  };

  const serverEvent = {
    event_name: eventName,
    event_time: Math.floor(Date.now() / 1000),
    action_source: "app",
    event_id: generateEventId(),
    user_data: userData,
    custom_data: customData,
    app_data: appData,
  };

  const META_API_VERSION = "v24.0";
  const url = `https://graph.facebook.com/${META_API_VERSION}/${datasetId}/events`;

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${metaToken}`,
    },
    body: JSON.stringify({ data: [serverEvent] }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Meta API error: ${response.status} ${response.statusText} - ${errorText}`);
  }

  const result = await response.json();
  console.log(`[meta-track] ${eventName} sent:`, JSON.stringify(result));
}

// ── CORS headers ─────────────────────────────────────────────────────────────

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// ── Main handler ─────────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  // ── Auth: require valid Supabase JWT ──────────────────────────────────────

  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return new Response(JSON.stringify({ error: "Missing or invalid Authorization header" }), {
      status: 401,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !supabaseAnonKey) {
    return new Response(JSON.stringify({ error: "Server configuration error" }), {
      status: 500,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  // Use anon key + user JWT to get the authenticated user
  const userClient = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: { user }, error: authError } = await userClient.auth.getUser();
  if (authError || !user) {
    return new Response(JSON.stringify({ error: "Unauthenticated" }), {
      status: 401,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  // ── Parse body ────────────────────────────────────────────────────────────

  let body: TrackEventRequest;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON" }), {
      status: 400,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  const { event_name, custom_data } = body;
  if (!event_name || typeof event_name !== "string") {
    return new Response(JSON.stringify({ error: "event_name is required" }), {
      status: 400,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  // ── Fetch user + device data via service role ─────────────────────────────

  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const adminClient = createClient(supabaseUrl, serviceRoleKey!);

  const [userResult, deviceResult] = await Promise.all([
    adminClient.from("users").select("email").eq("id", user.id).maybeSingle(),
    adminClient
      .from("devices")
      .select("operatingSystem, extra_data")
      .eq("user_id", user.id)
      .order("last_update_date", { ascending: false })
      .limit(1)
      .maybeSingle(),
  ]);

  const userRow = userResult.data as UserRow | null;
  const deviceRow = deviceResult.data as DeviceRow | null;

  if (deviceResult.error) {
    console.warn("[meta-track] device fetch error (non-fatal):", deviceResult.error);
  }

  // ── Send event ────────────────────────────────────────────────────────────

  try {
    await sendMetaEvent(
      event_name,
      user.id,
      userRow?.email,
      deviceRow,
      custom_data,
    );
  } catch (e) {
    console.error("[meta-track] error sending event:", e);
    return new Response(
      JSON.stringify({ error: e instanceof Error ? e.message : "Failed to send Meta event" }),
      {
        status: 500,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      },
    );
  }

  return new Response(JSON.stringify({ ok: true }), {
    status: 200,
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });
});
