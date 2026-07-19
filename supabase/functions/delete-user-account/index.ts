/**
 * Supabase Edge Function: Delete User Account
 *
 * Deletes the authenticated user from auth.users. This is required for app store
 * compliance (Apple, Google) — users must be able to delete their account on demand.
 *
 * When auth.users is deleted:
 *   - public.users (REFERENCES auth.users ON DELETE CASCADE) is deleted automatically
 *   - devices, subscriptions, feature_votes, user_infos, notifications (REFERENCES
 *     public.users ON DELETE CASCADE) are deleted in cascade
 *
 * The client must be authenticated. The function uses the JWT to identify the user.
 *
 * @see https://supabase.com/docs/reference/javascript/auth-admin-deleteuser
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.47.10";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return new Response(
      JSON.stringify({ error: "Missing or invalid Authorization header" }),
      { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    console.error("[delete-user-account] Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
    return new Response(
      JSON.stringify({ error: "Server configuration error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  // Create a client with the user's JWT to verify they are authenticated
  const token = authHeader.replace("Bearer ", "");
  const supabaseAuth = createClient(supabaseUrl, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: { user }, error: authError } = await supabaseAuth.auth.getUser(token);

  if (authError || !user) {
    console.warn("[delete-user-account] Unauthenticated request:", authError?.message);
    return new Response(
      JSON.stringify({ error: "You must be authenticated to delete your account" }),
      { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey);

  // Best-effort Stripe teardown BEFORE deletion: deleting the Stripe customer
  // cancels all of its subscriptions, so billing stops for the deleted account.
  // The DB rows (stripe_customers, subscriptions, ...) are removed by ON DELETE
  // CASCADE, but that does not reach Stripe. Guarded by the secret so a
  // non-Stripe app simply skips it.
  const stripeKey = Deno.env.get("STRIPE_SECRET_KEY");
  if (stripeKey) {
    try {
      const { data: cust } = await supabaseAdmin
        .from("stripe_customers")
        .select("customer_id")
        .eq("user_id", user.id)
        .maybeSingle();
      const customerId = cust?.customer_id as string | undefined;
      if (customerId) {
        const { default: Stripe } = await import("npm:stripe@18");
        await new Stripe(stripeKey).customers.del(customerId);
      }
    } catch (e) {
      console.error("[delete-user-account] Stripe cleanup failed:", e);
    }
  }

  try {
    const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(user.id);

    if (deleteError) {
      console.error(`[delete-user-account] Error deleting user ${user.id}:`, deleteError.message);
      return new Response(
        JSON.stringify({ error: "Error deleting user account" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    console.log(`[delete-user-account] User ${user.id} deleted successfully`);
    return new Response(
      JSON.stringify({ ok: true }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (e) {
    console.error("[delete-user-account] Unexpected error:", e);
    return new Response(
      JSON.stringify({ error: "Error deleting user account" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
