-- Ad rewards (AdMob rewarded Server-Side Verification).
-- The `verify-ad-reward` edge function inserts one row per verified reward
-- (idempotent on transaction_id) and bumps the user's running balance.
-- Replace/extend grant_ad_reward() with your own entitlement.

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS ad_reward_balance NUMERIC NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS public.ad_rewards (
  transaction_id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  amount NUMERIC NOT NULL DEFAULT 0,
  item TEXT,
  custom_data TEXT,
  ad_unit TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ad_rewards_user_id_idx ON public.ad_rewards(user_id);

ALTER TABLE public.ad_rewards ENABLE ROW LEVEL SECURITY;

-- Owners can read their own reward history. Writes happen only via the edge
-- function (service role), which bypasses RLS.
DROP POLICY IF EXISTS "ad_rewards_select_own" ON public.ad_rewards;
CREATE POLICY "ad_rewards_select_own" ON public.ad_rewards
  FOR SELECT USING (auth.uid() = user_id);

-- Atomic, idempotent reward grant. Returns true when a NEW reward was granted,
-- false when the transaction was already processed (duplicate callback).
CREATE OR REPLACE FUNCTION public.grant_ad_reward(
  p_user_id UUID,
  p_transaction_id TEXT,
  p_amount NUMERIC,
  p_item TEXT,
  p_custom_data TEXT,
  p_ad_unit TEXT
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  INSERT INTO public.ad_rewards (
    transaction_id, user_id, amount, item, custom_data, ad_unit
  )
  VALUES (
    p_transaction_id, p_user_id, p_amount, p_item, p_custom_data, p_ad_unit
  )
  ON CONFLICT (transaction_id) DO NOTHING;

  GET DIAGNOSTICS v_count = ROW_COUNT;
  IF v_count > 0 THEN
    -- ─── Grant the reward ─────────────────────────────────────────────────
    -- Replace with your own entitlement (coins, lives, no-ads pass…).
    UPDATE public.users
      SET ad_reward_balance = ad_reward_balance + p_amount
      WHERE id = p_user_id;
    RETURN true;
  END IF;
  RETURN false;
END;
$$;
