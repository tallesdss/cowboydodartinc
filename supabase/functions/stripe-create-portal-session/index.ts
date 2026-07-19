/**
 * Supabase Edge Function: Stripe — Create Customer Portal Session
 *
 * Creates a Stripe Customer Portal session (manage / cancel / switch plan) for
 * the authenticated user and returns its URL. The user is identified by the
 * verified JWT and the Stripe customer is looked up server-side.
 *
 * Deployed WITHOUT the platform JWT gate (verify_jwt = false in config.toml) so the
 * browser's CORS preflight passes; the handler still authenticates the user via the
 * verified JWT (getUser), so it stays secure.
 *
 * Secrets required:
 *   - STRIPE_SECRET_KEY
 *   - SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY (auto-provided)
 *
 * Optional env var:
 *   - STRIPE_PRODUCT_ID: narrows plan-switching to a single product's prices.
 *
 * Body: { returnUrl?: string, planSwitching?: boolean }
 */

import Stripe from "npm:stripe@18";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.47.10";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const CUSTOMERS_TABLE = "stripe_customers";

async function getUid(req: Request, supabaseUrl: string, anonKey: string): Promise<string | null> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) return null;
  const token = authHeader.replace("Bearer ", "");
  const client = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: { user }, error } = await client.auth.getUser(token);
  if (error || !user) return null;
  return user.id;
}

// Creates (once) a Customer Portal configuration with subscription_update
// (plan switching) enabled, then reuses it on every subsequent call.
// Uses the Stripe list API to find an existing config — no extra DB table needed.
// deno-lint-ignore no-explicit-any
async function getOrCreatePortalConfig(stripe: Stripe): Promise<string | undefined> {
  // Reuse an existing active config with plan switching already enabled
  const configs = await stripe.billingPortal.configurations.list({ active: true, limit: 20 });
  // deno-lint-ignore no-explicit-any
  const existing = configs.data.find((c: any) => c.features?.subscription_update?.enabled);
  if (existing) return existing.id;

  // Build the price list grouped by product so Stripe knows what to switch between
  const productId = Deno.env.get("STRIPE_PRODUCT_ID") ?? "";
  // deno-lint-ignore no-explicit-any
  const priceListParams: any = { active: true, type: "recurring", limit: 100 };
  if (productId) priceListParams.product = productId;
  const { data: prices } = await stripe.prices.list(priceListParams);

  if (prices.length === 0) return undefined;

  const byProduct: Record<string, string[]> = {};
  for (const p of prices) {
    // deno-lint-ignore no-explicit-any
    const pid = typeof p.product === "string" ? p.product : (p.product as any).id;
    if (!byProduct[pid]) byProduct[pid] = [];
    byProduct[pid].push(p.id);
  }
  const products = Object.entries(byProduct).map(([prod, priceIds]) => ({
    product: prod,
    prices: priceIds,
  }));

  const config = await stripe.billingPortal.configurations.create({
    features: {
      subscription_update: {
        enabled: true,
        default_allowed_updates: ["price"],
        products,
      },
      subscription_cancel: { enabled: true, mode: "at_period_end" },
      payment_method_update: { enabled: true },
    },
  });
  return config.id;
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

  const uid = await getUid(req, supabaseUrl, anonKey);
  if (!uid) {
    return Response.json({ error: "Sign in required" }, { status: 401, headers: corsHeaders });
  }

  let returnUrl = "";
  let planSwitching = false;
  try {
    const body = await req.json();
    returnUrl = (body?.returnUrl as string | undefined) ?? "";
    planSwitching = body?.planSwitching === true;
  } catch {
    // body is optional
  }

  try {
    const admin = createClient(supabaseUrl, serviceRoleKey);
    const { data } = await admin
      .from(CUSTOMERS_TABLE)
      .select("customer_id")
      .eq("user_id", uid)
      .maybeSingle();
    const customerId = data?.customer_id as string | undefined;
    if (!customerId) {
      return Response.json(
        { error: "No Stripe customer for user" },
        { status: 400, headers: corsHeaders },
      );
    }

    const stripe = new Stripe(secretKey);

    // When plan switching is requested, resolve (or create) a portal configuration
    // with subscription_update enabled — no manual Stripe dashboard setup needed.
    const configId = planSwitching ? await getOrCreatePortalConfig(stripe) : undefined;

    const session = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: returnUrl,
      ...(configId ? { configuration: configId } : {}),
    });
    return Response.json({ url: session.url }, { headers: corsHeaders });
  } catch (err) {
    console.error("[stripe-create-portal-session]", err);
    return Response.json(
      { error: err instanceof Error ? err.message : "Internal error" },
      { status: 500, headers: corsHeaders },
    );
  }
});
