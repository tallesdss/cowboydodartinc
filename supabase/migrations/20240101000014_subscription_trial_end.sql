-- Adds trial_end to subscriptions so trial periods are persisted and the app
-- can detect an active trial. Mirrors the Firebase backend, where the Stripe
-- webhook writes trial_end (RevenueCat trials are read from the SDK, not the DB).
-- Idempotent: safe to run on a fresh project or an already-deployed database.
ALTER TABLE public.subscriptions
  ADD COLUMN IF NOT EXISTS trial_end TIMESTAMPTZ;
