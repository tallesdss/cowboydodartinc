-- Kasy Supabase schema
-- Tables: users, devices, subscriptions, feature_requests, feature_votes, user_infos, notifications

-- Users (id matches auth.users.id, created by app on signup)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  creation_date TIMESTAMPTZ DEFAULT now(),
  last_update_date TIMESTAMPTZ DEFAULT now(),
  name TEXT,
  email TEXT,
  avatar_url TEXT,
  onboarded BOOLEAN DEFAULT false,
  locale TEXT
);

-- Devices (push notifications)
CREATE TABLE IF NOT EXISTS public.devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  installation_id TEXT NOT NULL,
  token TEXT NOT NULL,
  "operatingSystem" TEXT NOT NULL CHECK ("operatingSystem" IN ('ios', 'android')),
  creation_date TIMESTAMPTZ DEFAULT now(),
  last_update_date TIMESTAMPTZ DEFAULT now(),
  extra_data JSONB DEFAULT '{}',
  UNIQUE(user_id, installation_id)
);

-- Subscriptions (RevenueCat webhook updates)
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
  status TEXT NOT NULL CHECK (status IN ('ACTIVE', 'PAUSED', 'EXPIRED', 'LIFETIME', 'CANCELLED')),
  creation_date TIMESTAMPTZ DEFAULT now(),
  last_update_date TIMESTAMPTZ DEFAULT now(),
  period_end_date TIMESTAMPTZ,
  sku_id TEXT NOT NULL,
  offer_id TEXT NOT NULL,
  store TEXT
);

-- Feature requests (vote/request module)
CREATE TABLE IF NOT EXISTS public.feature_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creation_date TIMESTAMPTZ DEFAULT now(),
  last_update_date TIMESTAMPTZ DEFAULT now(),
  title JSONB NOT NULL DEFAULT '{}',
  description JSONB NOT NULL DEFAULT '{}',
  votes INTEGER NOT NULL DEFAULT 0,
  active BOOLEAN NOT NULL DEFAULT true
);

-- Feature votes
CREATE TABLE IF NOT EXISTS public.feature_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creation_date TIMESTAMPTZ DEFAULT now(),
  user_uid UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  feature_id UUID NOT NULL REFERENCES public.feature_requests(id) ON DELETE CASCADE,
  UNIQUE(user_uid, feature_id)
);

-- User infos (onboarding)
CREATE TABLE IF NOT EXISTS public.user_infos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  info_key TEXT NOT NULL,
  info_value TEXT NOT NULL,
  UNIQUE(user_id, info_key)
);

-- Notifications
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  creation_date TIMESTAMPTZ DEFAULT now(),
  read_date TIMESTAMPTZ,
  type TEXT DEFAULT 'OTHER',
  data JSONB DEFAULT '{}',
  notify_user BOOLEAN DEFAULT true
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_devices_user_id ON public.devices(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_feature_votes_user ON public.feature_votes(user_uid);
CREATE INDEX IF NOT EXISTS idx_feature_votes_feature ON public.feature_votes(feature_id);
CREATE INDEX IF NOT EXISTS idx_user_infos_user_id ON public.user_infos(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);

-- RLS: enable for all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feature_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feature_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_infos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Users: own data only
CREATE POLICY "Users can read own" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

-- Devices: own data only
CREATE POLICY "Devices own" ON public.devices FOR ALL USING (auth.uid() = user_id);

-- Subscriptions: own data only
CREATE POLICY "Subscriptions own" ON public.subscriptions FOR ALL USING (auth.uid() = user_id);

-- Feature requests: anyone can read; authenticated users can submit (active=false, votes=0)
CREATE POLICY "Feature requests read" ON public.feature_requests FOR SELECT USING (true);
CREATE POLICY "Feature requests insert" ON public.feature_requests FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL
    AND active = false
    AND votes = 0
  );

-- Feature votes: own votes
CREATE POLICY "Feature votes own" ON public.feature_votes FOR ALL USING (auth.uid() = user_uid);

-- User infos: own data
CREATE POLICY "User infos own" ON public.user_infos FOR ALL USING (auth.uid() = user_id);

-- Notifications: own data
CREATE POLICY "Notifications own" ON public.notifications FOR ALL USING (auth.uid() = user_id);

-- Auto-create user profile in public.users when a new auth user signs up.
-- This mirrors Firebase's onUserCreate Cloud Function behavior.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', NULL)
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
