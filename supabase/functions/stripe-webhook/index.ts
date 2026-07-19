/**
 * Supabase Edge Function: Stripe Webhook
 *
 * The ONLY writer of the `subscriptions` table for Stripe (web) subscriptions.
 * Verifies the Stripe signature, then upserts the user's subscription with
 * store='STRIPE'. The user id is read from the subscription metadata
 * (supabaseUID), which the checkout function set server-side.
 *
 * Deployed WITHOUT JWT verification (Stripe calls it with a stripe-signature,
 * not a Supabase JWT) — authenticity is enforced by the signature check.
 *
 * Secrets required (set via `supabase secrets set`):
 *   - STRIPE_SECRET_KEY
 *   - STRIPE_WEBHOOK_SECRET: whsec_... (from the Stripe webhook endpoint config)
 *   - SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY (auto-provided)
 */

import Stripe from "npm:stripe@18";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.47.10";

const SubscriptionStatus = {
  ACTIVE: "ACTIVE",
  EXPIRED: "EXPIRED",
} as const;

function statusFromStripe(sub: Stripe.Subscription): string {
  switch (sub.status) {
    case "active":
    case "trialing":
      return SubscriptionStatus.ACTIVE;
    default:
      // canceled, unpaid, past_due, incomplete, incomplete_expired, paused
      return SubscriptionStatus.EXPIRED;
  }
}

// In Stripe API v18 the billing period lives on each subscription item; older
// versions exposed it on the subscription. Read whichever is present.
function periodEndMs(sub: Stripe.Subscription): number | null {
  const item = sub.items?.data?.[0] as { current_period_end?: number } | undefined;
  const fromItem = item?.current_period_end;
  const fromSub = (sub as unknown as { current_period_end?: number }).current_period_end;
  const sec = fromItem ?? fromSub;
  return sec ? sec * 1000 : null;
}

Deno.serve(async (req: Request) => {
  const signature = req.headers.get("stripe-signature");
  if (!signature) return new Response("Missing signature", { status: 400 });

  const secretKey = Deno.env.get("STRIPE_SECRET_KEY");
  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!secretKey || !webhookSecret || !supabaseUrl || !serviceRoleKey) {
    console.error("[stripe-webhook] missing secrets");
    return new Response("Server configuration error", { status: 500 });
  }

  const stripe = new Stripe(secretKey);
  const bodyText = await req.text();

  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(bodyText, signature, webhookSecret);
  } catch (e) {
    console.log(`[stripe-webhook] signature verification failed: ${e}`);
    return new Response("Invalid signature", { status: 400 });
  }

  const handled = [
    "customer.subscription.created",
    "customer.subscription.updated",
    "customer.subscription.deleted",
  ];
  if (!handled.includes(event.type)) {
    return new Response("ok");
  }

  const sub = event.data.object as Stripe.Subscription;
  const uid = sub.metadata?.supabaseUID;
  if (!uid) {
    console.log("[stripe-webhook] subscription without supabaseUID metadata, skipping");
    return new Response("ok");
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  try {
    // The subscriptions row references public.users(id). Skip unknown users.
    const { data: userRows } = await supabase
      .from("users")
      .select("id")
      .eq("id", uid)
      .limit(1);
    if (!userRows?.length) {
      console.log("[stripe-webhook] user not found:", uid);
      return new Response("ok");
    }

    const item = sub.items?.data?.[0];
    const priceId = item?.price?.id ?? "";
    const ms = periodEndMs(sub);
    const trialMs = sub.trial_end ? sub.trial_end * 1000 : null;
    const now = new Date().toISOString();
    const payload = {
      status: statusFromStripe(sub),
      last_update_date: now,
      period_end_date: ms ? new Date(ms).toISOString() : null,
      trial_end: trialMs ? new Date(trialMs).toISOString() : null,
      sku_id: priceId,
      offer_id: priceId,
      store: "STRIPE",
    };

    const { data: existing } = await supabase
      .from("subscriptions")
      .select("user_id")
      .eq("user_id", uid)
      .maybeSingle();

    if (existing) {
      const { error: updateErr } = await supabase
        .from("subscriptions")
        .update(payload)
        .eq("user_id", uid);
      if (updateErr) console.error("[stripe-webhook] update error:", updateErr);
    } else {
      const { error: insertErr } = await supabase
        .from("subscriptions")
        .insert({ user_id: uid, creation_date: now, ...payload });
      if (insertErr) console.error("[stripe-webhook] insert error:", insertErr);
    }

    return new Response("ok");
  } catch (err) {
    console.error("[stripe-webhook] error:", err);
    return new Response(err instanceof Error ? err.message : "Internal error", { status: 500 });
  }
});
