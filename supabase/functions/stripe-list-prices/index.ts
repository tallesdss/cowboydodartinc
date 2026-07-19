/**
 * Supabase Edge Function: Stripe — List Prices
 *
 * Returns the active recurring Stripe prices mapped to the paywall offer
 * contract used by the Flutter client (mirrors the Firebase `listPrices`
 * callable). The Stripe secret key never leaves the server.
 *
 * Deployed WITHOUT the platform JWT gate (verify_jwt = false in config.toml) so the
 * browser's CORS preflight passes. This endpoint is public by design — it only
 * returns the active prices (no user data) — so it does NOT authenticate the caller.
 *
 * Secrets required (set via `supabase secrets set`):
 *   - STRIPE_SECRET_KEY: sk_test_... / sk_live_...
 *   - STRIPE_PRODUCT_ID (optional): restrict prices to a single Stripe product.
 */

import Stripe from "npm:stripe@18";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function trialDaysFor(price: Stripe.Price, product: Stripe.Product): number | null {
  const meta = price.metadata?.trial_days ?? product.metadata?.trial_days;
  return meta ? Number(meta) : null;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  const secretKey = Deno.env.get("STRIPE_SECRET_KEY");
  if (!secretKey) {
    return Response.json(
      { error: "STRIPE_SECRET_KEY not configured. Run: supabase secrets set STRIPE_SECRET_KEY=..." },
      { status: 500, headers: corsHeaders },
    );
  }

  const stripe = new Stripe(secretKey);
  try {
    const params: Stripe.PriceListParams = {
      active: true,
      type: "recurring",
      expand: ["data.product"],
      limit: 100,
    };
    const productFilter = Deno.env.get("STRIPE_PRODUCT_ID");
    if (productFilter) params.product = productFilter;

    const prices = await stripe.prices.list(params);
    const offers = prices.data
      .filter((p) => Boolean(p.recurring))
      .map((p) => {
        const product = p.product as Stripe.Product;
        const features = (product.marketing_features ?? [])
          .map((f) => f.name)
          .filter((n): n is string => Boolean(n));
        return {
          priceId: p.id,
          productId: typeof p.product === "string" ? p.product : product.id,
          productName: product.name ?? "",
          description: product.description ?? "",
          unitAmount: p.unit_amount ?? 0,
          currency: p.currency,
          interval: p.recurring?.interval ?? "month",
          intervalCount: p.recurring?.interval_count ?? 1,
          trialDays: trialDaysFor(p, product),
          features,
        };
      });

    return Response.json(offers, { headers: corsHeaders });
  } catch (err) {
    console.error("[stripe-list-prices]", err);
    return Response.json(
      { error: err instanceof Error ? err.message : "Internal error" },
      { status: 500, headers: corsHeaders },
    );
  }
});
