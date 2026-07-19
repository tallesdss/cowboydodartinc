-- Stripe (web) subscriptions support + subscription write hardening.
--
-- 1. `stripe_customers` maps a Supabase auth user to its single Stripe customer
--    id, so the checkout/portal Edge Functions can find-or-create one customer
--    per user.
-- 2. Hardens `subscriptions` so ONLY the server (service role, used by the
--    Stripe and RevenueCat webhooks) can write it. The client can only read its
--    own row. This prevents a client from forging a premium subscription.
--    Previously a `FOR ALL` policy let a client insert/update its own row.

-- Map auth user -> Stripe customer id. Written only by the server (service role,
-- which bypasses RLS). Clients may read their own mapping but never write it.
CREATE TABLE IF NOT EXISTS public.stripe_customers (
  user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  customer_id TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_stripe_customers_customer_id
  ON public.stripe_customers(customer_id);

ALTER TABLE public.stripe_customers ENABLE ROW LEVEL SECURITY;

-- Read-only for the owning user; no insert/update/delete policy => clients
-- cannot write (only the service role, which bypasses RLS, can).
DROP POLICY IF EXISTS "Stripe customers read own" ON public.stripe_customers;
CREATE POLICY "Stripe customers read own" ON public.stripe_customers
  FOR SELECT USING (auth.uid() = user_id);

-- Harden subscriptions: clients read their own row only; all writes come from
-- the webhook via the service role. Replaces the previous FOR ALL policy that
-- allowed a client to insert/update (forge) its own subscription.
DROP POLICY IF EXISTS "Subscriptions own" ON public.subscriptions;
DROP POLICY IF EXISTS "Subscriptions read own" ON public.subscriptions;
CREATE POLICY "Subscriptions read own" ON public.subscriptions
  FOR SELECT USING (auth.uid() = user_id);
