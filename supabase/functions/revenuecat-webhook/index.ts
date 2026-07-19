/**
 * Supabase Edge Function: RevenueCat Webhook + Meta Ads Conversions API
 *
 * Receives RevenueCat subscription events, syncs to Supabase subscriptions table,
 * and sends conversion events to Meta Conversions API for attribution.
 *
 * Secrets required (set via `supabase secrets set`):
 *   - REVENUECAT_WEBHOOK_KEY: Bearer token from RevenueCat webhook config
 *   - META_ACCESS_TOKEN: Meta Marketing API access token
 *   - META_DATASET_ID: Meta Conversions API dataset ID (Pixel ID)
 *
 * @see https://www.revenuecat.com/docs/integrations/webhooks
 * @see https://developers.facebook.com/docs/marketing-api/conversions-api
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.47.10";

// ── Types (aligned with Firebase implementation) ────────────────────────────

const PeriodTypes = {
  TRIAL: "TRIAL",
  INTRO: "INTRO",
  NORMAL: "NORMAL",
  PROMOTIONAL: "PROMOTIONAL",
  PREPAID: "PREPAID",
} as const;

const SubscriptionStatus = {
  ACTIVE: "ACTIVE",
  PAUSED: "PAUSED",
  EXPIRED: "EXPIRED",
  LIFETIME: "LIFETIME",
} as const;

const Stores = {
  PLAY_STORE: "PLAY_STORE",
  APPLE_STORE: "APPLE_STORE",
  EARLY_BIRD: "EARLY_BIRD",
  // Subscription purchased on the web via Stripe (written by stripe-webhook).
  STRIPE: "STRIPE",
} as const;

type SubscriptionStatusType = (typeof SubscriptionStatus)[keyof typeof SubscriptionStatus];
type StoresType = (typeof Stores)[keyof typeof Stores];

interface RevenueCatEvent {
  event_timestamp_ms: number;
  product_id: string;
  presented_offering_identifier?: string | null;
  period_type?: (typeof PeriodTypes)[keyof typeof PeriodTypes];
  expiration_at_ms: number | null;
  store: string;
  app_user_id: string;
  type: string;
  currency?: string;
  price_in_purchased_currency?: number;
  is_trial_conversion?: boolean;
}

interface UserRow {
  id: string;
  email?: string | null;
  name?: string | null;
}

interface DeviceRow {
  id: string;
  user_id: string;
  installation_id: string;
  token: string;
  operatingSystem?: string;
  operating_system?: string;
  extra_data: Record<string, unknown> | null;
}

interface SubscriptionRow {
  user_id: string;
  status: string;
  creation_date: string;
  last_update_date: string;
  expiration_date: string | null;
  store: string;
  product_id: string;
}

// ── RevenueCat event helpers ────────────────────────────────────────────────

function getSubscriptionStatus(type: string): SubscriptionStatusType {
  switch (type) {
    case "INITIAL_PURCHASE":
    case "RENEWAL":
    case "UNCANCELLATION":
    case "SUBSCRIPTION_EXTENDED":
    case "PRODUCT_CHANGE":
      return SubscriptionStatus.ACTIVE;
    case "CANCELLATION":
    case "SUBSCRIPTION_PAUSED":
    case "EXPIRATION":
      return SubscriptionStatus.EXPIRED;
    case "NON_RENEWING_PURCHASE":
      return SubscriptionStatus.LIFETIME;
    default:
      return SubscriptionStatus.EXPIRED;
  }
}

function shouldIgnoreEvent(type: string): boolean {
  return [
    "BILLING_ISSUE",
    "TRANSFER",
    "TEMPORARY_ENTITLEMENT_GRANT",
    "EXPERIMENT_ENROLLMENT",
    "REFUND_REVERSED",
    "INVOICE_ISSUANCE",
    "VIRTUAL_CURRENCY_TRANSACTION",
  ].includes(type);
}

function getStore(store: string): StoresType {
  return store === "APP_STORE" ? Stores.APPLE_STORE : Stores.PLAY_STORE;
}

function isInitialPurchase(type: string, periodType: string | undefined, isTrialConversion?: boolean): boolean {
  return (
    (type === "INITIAL_PURCHASE" && periodType !== PeriodTypes.TRIAL) ||
    (isTrialConversion === true)
  );
}

// ── Meta Conversions API ───────────────────────────────────────────────────

const META_API_VERSION = "v24.0";

async function hashEmail(email: string): Promise<string> {
  const normalized = email.toLowerCase().trim();
  const encoder = new TextEncoder();
  const data = encoder.encode(normalized);
  const hashBuffer = await crypto.subtle.digest("SHA-256", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}

function buildExtinfo(extraData: Record<string, unknown>, operatingSystem: string): string[] {
  const os = operatingSystem?.toLowerCase() === "android" ? "a2" : "i2";
  return [
    os,
    (extraData.appPackageName as string) || "",
    (extraData.appVersion as string) || "",
    (extraData.appLongVersion as string) || "",
    (extraData.osVersion as string) || "",
    (extraData.deviceModel as string) || "",
    (extraData.deviceLocale as string) || "en_US",
    (extraData.timezone as string) || "",
    (extraData.carrier as string) || "",
    (extraData.screenWidth as string) || "",
    (extraData.screenHeight as string) || "",
    (extraData.screenDensity as string) || "",
    (extraData.cpuCores as string) || "",
    (extraData.storageSize as string) || "",
    (extraData.freeStorage as string) || "",
    (extraData.deviceTimezone as string) || "",
  ];
}

async function sendMetaEvent(
  eventType: string,
  params: {
    anonymousFbId: string;
    email?: string | null;
    operatingSystem: string;
    eventId: string;
    clientIpAddress?: string;
    mobileAdvertiserId?: string;
    appPackageName?: string;
    appVersion?: string;
    appLongVersion?: string;
    osVersion?: string;
    deviceModel?: string;
    deviceLocale?: string;
    timezone?: string;
    carrier?: string;
    screenWidth?: string;
    screenHeight?: string;
    screenDensity?: string;
    customData?: Record<string, string | number>;
  }
): Promise<void> {
  const metaToken = Deno.env.get("META_ACCESS_TOKEN");
  const datasetId = Deno.env.get("META_DATASET_ID");
  if (!metaToken || !datasetId) {
    console.log("[meta-ads] META_ACCESS_TOKEN or META_DATASET_ID not set, skipping");
    return;
  }

  const extraData = {
    appPackageName: params.appPackageName ?? "",
    appVersion: params.appVersion ?? "",
    appLongVersion: params.appLongVersion ?? "",
    osVersion: params.osVersion ?? "",
    deviceModel: params.deviceModel ?? "",
    deviceLocale: params.deviceLocale ?? "en_US",
    timezone: params.timezone ?? "",
    carrier: params.carrier ?? "",
    screenWidth: params.screenWidth ?? "",
    screenHeight: params.screenHeight ?? "",
    screenDensity: params.screenDensity ?? "",
    cpuCores: "",
    storageSize: "",
    freeStorage: "",
    deviceTimezone: params.timezone ?? "",
  };

  const userData: Record<string, string | string[]> = {
    anon_id: params.anonymousFbId,
  };
  if (params.clientIpAddress) userData.client_ip_address = params.clientIpAddress;
  if (params.email) userData.em = [await hashEmail(params.email)];
  if (params.mobileAdvertiserId) userData.madid = params.mobileAdvertiserId;

  const extinfo = buildExtinfo(extraData as Record<string, unknown>, params.operatingSystem);
  const appData: Record<string, unknown> = {
    advertiser_tracking_enabled: params.mobileAdvertiserId ? 1 : 0,
    application_tracking_enabled: params.mobileAdvertiserId ? 1 : 0,
    extinfo,
  };

  const serverEvent = {
    event_name: eventType,
    event_time: Math.floor(Date.now() / 1000),
    action_source: "app",
    event_id: params.eventId,
    user_data: userData,
    custom_data: params.customData || {},
    app_data: appData,
  };

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
  console.log(`[meta-ads] ${eventType} sent`);
}

// ── Main handler ───────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  const authHeader = req.headers.get("Authorization");
  const webhookKey = Deno.env.get("REVENUECAT_WEBHOOK_KEY");
  if (!webhookKey || authHeader !== webhookKey) {
    console.log("Unauthorized - invalid or missing token");
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  let body: { event?: RevenueCatEvent } & RevenueCatEvent;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  const eventData = body.event ?? body;
  const event: RevenueCatEvent = {
    event_timestamp_ms: eventData.event_timestamp_ms,
    product_id: eventData.product_id,
    presented_offering_identifier: eventData.presented_offering_identifier,
    period_type: eventData.period_type,
    expiration_at_ms: eventData.expiration_at_ms,
    store: eventData.store,
    app_user_id: eventData.app_user_id,
    type: eventData.type,
    currency: eventData.currency,
    price_in_purchased_currency: eventData.price_in_purchased_currency,
    is_trial_conversion: eventData.is_trial_conversion,
  };

  console.log("[revenuecat-webhook] event type:", event.type, "app_user_id:", event.app_user_id);

  if (shouldIgnoreEvent(event.type)) {
    console.log("[revenuecat-webhook] ignored event type");
    return new Response(JSON.stringify({ ok: true, message: "ignored" }), {
      status: 200,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
    });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRoleKey) {
    console.error("SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY not set");
    return new Response(JSON.stringify({ error: "Server configuration error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  try {
    // 1. Fetch user
    const { data: userRows, error: userError } = await supabase
      .from("users")
      .select("id, email, name")
      .eq("id", event.app_user_id)
      .limit(1);

    if (userError || !userRows?.length) {
      console.log("[revenuecat-webhook] user not found:", event.app_user_id);
      return new Response(JSON.stringify({ error: "User not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      });
    }

    const user = userRows[0] as UserRow;

    // 2. Upsert subscription
    const status = getSubscriptionStatus(event.type);
    const store = getStore(event.store);
    const now = new Date().toISOString();
    const expirationDate = event.expiration_at_ms
      ? new Date(event.expiration_at_ms).toISOString()
      : null;

    const subscriptionRow: SubscriptionRow = {
      user_id: user.id,
      status,
      creation_date: now,
      last_update_date: now,
      expiration_date: status === SubscriptionStatus.LIFETIME ? null : expirationDate,
      store,
      product_id: event.product_id,
    };

    const subPayload = {
      status: subscriptionRow.status,
      last_update_date: subscriptionRow.last_update_date,
      period_end_date: subscriptionRow.expiration_date,
      sku_id: subscriptionRow.product_id,
      offer_id: event.presented_offering_identifier ?? event.product_id,
      store: subscriptionRow.store,
    };
    const { data: existingSub } = await supabase
      .from("subscriptions")
      .select("user_id")
      .eq("user_id", user.id)
      .limit(1)
      .maybeSingle();

    if (existingSub) {
      const { error: updateErr } = await supabase
        .from("subscriptions")
        .update(subPayload)
        .eq("user_id", user.id);
      if (updateErr) console.error("[revenuecat-webhook] subscription update error:", updateErr);
    } else {
      const { error: insertErr } = await supabase.from("subscriptions").insert({
        user_id: user.id,
        ...subPayload,
        creation_date: subscriptionRow.creation_date,
      });
      if (insertErr) console.error("[revenuecat-webhook] subscription insert error:", insertErr);
    }

    // 3. Send Meta Ads events (if RevenueCat + user + device with anonymousFbId)
    try {
      const { data: deviceRows, error: deviceError } = await supabase
        .from("devices")
        .select("id, user_id, installation_id, token, operatingSystem, extra_data")
        .eq("user_id", event.app_user_id);

      if (deviceError || !deviceRows?.length) {
        console.log("[meta-ads] no devices found, skipping");
      } else {
        const devices = deviceRows as DeviceRow[];
        const selectedDevice = devices.find((d) => d.extra_data?.anonymousFbId) ?? devices[0];
        const extraData = (selectedDevice.extra_data || {}) as Record<string, string>;
        const anonymousFbId = extraData.anonymousFbId;

        if (!anonymousFbId) {
          console.log("[meta-ads] device has no anonymousFbId, skipping");
        } else {
          const eventId = `${Date.now()}-${Math.random().toString(36).slice(2, 11)}`;
          const params = {
            anonymousFbId,
            email: user.email,
            operatingSystem: selectedDevice.operatingSystem || selectedDevice.operating_system || "android",
            eventId,
            clientIpAddress: extraData.clientIpAddress,
            mobileAdvertiserId: extraData.mobileAdvertiserId,
            appPackageName: extraData.appPackageName,
            appVersion: extraData.appVersion,
            appLongVersion: extraData.appLongVersion,
            osVersion: extraData.osVersion,
            deviceModel: extraData.deviceModel,
            deviceLocale: extraData.deviceLocale,
            timezone: extraData.timezone,
            carrier: extraData.carrier,
            screenWidth: extraData.screenWidth,
            screenHeight: extraData.screenHeight,
            screenDensity: extraData.screenDensity,
          };

          if (
            event.type === "INITIAL_PURCHASE" &&
            event.period_type === PeriodTypes.TRIAL
          ) {
            await sendMetaEvent("StartTrial", {
              ...params,
              customData: {
                value: (event.price_in_purchased_currency ?? 0).toString(),
                currency: event.currency ?? "USD",
              },
            });
          } else if (status === SubscriptionStatus.LIFETIME) {
            await sendMetaEvent("Purchase", {
              ...params,
              customData: {
                value: (event.price_in_purchased_currency ?? 0).toString(),
                currency: event.currency ?? "USD",
              },
            });
          } else if (isInitialPurchase(event.type, event.period_type, event.is_trial_conversion) || event.type === "RENEWAL") {
            if (event.price_in_purchased_currency != null && event.currency) {
              await sendMetaEvent("Subscribe", {
                ...params,
                customData: {
                  value: event.price_in_purchased_currency.toString(),
                  currency: event.currency,
                },
              });
            } else {
              console.log("[meta-ads] missing currency/value for subscription event");
            }
          }
        }
      }
    } catch (metaErr) {
      console.error("[meta-ads] error (non-fatal):", metaErr);
    }

    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
    });
  } catch (err) {
    console.error("[revenuecat-webhook] error:", err);
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : "Internal server error" }),
      {
        status: 500,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      }
    );
  }
});
