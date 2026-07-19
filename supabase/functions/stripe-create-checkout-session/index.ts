/**
 * Supabase Edge Function: Stripe — Create Checkout Session
 *
 * Creates a hosted Stripe Checkout session (mode=subscription) for the
 * authenticated user and returns its URL. The user identity is taken from the
 * verified JWT, never trusted from the request body, so a client cannot check
 * out on behalf of someone else.
 *
 * Deployed WITHOUT the platform JWT gate (verify_jwt = false in config.toml) so the
 * browser's CORS preflight passes; the handler still authenticates the user via the
 * verified JWT (getUser), so it stays secure.
 *
 * Secrets required:
 *   - STRIPE_SECRET_KEY: sk_test_... / sk_live_...
 *   - SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY (auto-provided)
 *
 * Body: { priceId: string, successUrl?: string, cancelUrl?: string }
 */

import Stripe from "npm:stripe@18";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.47.10";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Maps a Supabase auth user -> its Stripe customer id.
const CUSTOMERS_TABLE = "stripe_customers";

function trialDaysFor(price: Stripe.Price, product: Stripe.Product): number | null {
  const meta = price.metadata?.trial_days ?? product.metadata?.trial_days;
  return meta ? Number(meta) : null;
}

async function getAuthUser(
  req: Request,
  supabaseUrl: string,
  anonKey: string,
): Promise<{ id: string; email?: string } | null> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) return null;
  const token = authHeader.replace("Bearer ", "");
  const client = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: { user }, error } = await client.auth.getUser(token);
  if (error || !user) return null;
  return { id: user.id, email: user.email ?? undefined };
}

// deno-lint-ignore no-explicit-any
async function getOrCreateCustomer(
  stripe: Stripe,
  admin: any,
  uid: string,
  email?: string,
): Promise<string> {
  const { data } = await admin
    .from(CUSTOMERS_TABLE)
    .select("customer_id")
    .eq("user_id", uid)
    .maybeSingle();
  const existing = data?.customer_id as string | undefined;
  if (existing) {
    // Keep the Stripe customer email in sync so Checkout pre-fills it. The
    // payment is bound to the app user by uid (customer + metadata.supabaseUID),
    // never by the typed email, so this is purely UX / billing hygiene.
    if (email) await stripe.customers.update(existing, { email });
    return existing;
  }
  const customer = await stripe.customers.create({ email, metadata: { supabaseUID: uid } });
  await admin.from(CUSTOMERS_TABLE).upsert({ user_id: uid, customer_id: customer.id });
  return customer.id;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return Response.json({ error: "Method not allowed" }, { status: 405, headers: corsHeaders });
  }

  const secretKey = Deno.env.get("STRIPE_SECRET_KEY");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!secretKey || !supabaseUrl || !anonKey || !serviceRoleKey) {
    return Response.json({ error: "Server configuration error" }, { status: 500, headers: corsHeaders });
  }

  const user = await getAuthUser(req, supabaseUrl, anonKey);
  if (!user) {
    return Response.json({ error: "Sign in required" }, { status: 401, headers: corsHeaders });
  }
  const uid = user.id;

  let body: { priceId?: string; successUrl?: string; cancelUrl?: string; locale?: string; allowPromoCodes?: boolean };
  try {
    body = await req.json();
  } catch {
    return Response.json({ error: "Invalid JSON" }, { status: 400, headers: corsHeaders });
  }
  const priceId = body.priceId;
  if (!priceId) {
    return Response.json({ error: "priceId is required" }, { status: 400, headers: corsHeaders });
  }
  const successUrl = body.successUrl ?? "";
  const cancelUrl = body.cancelUrl ?? successUrl;
  const locale = body.locale?.substring(0, 2).toLowerCase();
  const allowPromoCodes = body.allowPromoCodes === true;

  try {
    const stripe = new Stripe(secretKey);
    const admin = createClient(supabaseUrl, serviceRoleKey);
    // Persist the app language on the user so server-side notifications are sent
    // in the right language (on web there is no registered device to read it
    // from). Mirrors the Firebase checkout behavior.
    if (locale) {
      await admin.from("users").update({ locale }).eq("id", uid);
    }
    const customerId = await getOrCreateCustomer(stripe, admin, uid, user.email);

    const price = await stripe.prices.retrieve(priceId, { expand: ["product"] });
    const trialDays = trialDaysFor(price, price.product as Stripe.Product);

    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      customer: customerId,
      client_reference_id: uid,
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: successUrl,
      cancel_url: cancelUrl,
      subscription_data: {
        metadata: { supabaseUID: uid },
        ...(trialDays ? { trial_period_days: trialDays } : {}),
      },
      ...(allowPromoCodes ? { allow_promotion_codes: true } : {}),
    });
    return Response.json({ url: session.url }, { headers: corsHeaders });
  } catch (err) {
    console.error("[stripe-create-checkout-session]", err);
    return Response.json(
      { error: err instanceof Error ? err.message : "Internal error" },
      { status: 500, headers: corsHeaders },
    );
  }
});
