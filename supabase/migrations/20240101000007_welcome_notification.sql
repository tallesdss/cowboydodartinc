-- Send a welcome notification ONCE per account when a device is registered.
--
-- Why on device registration and not on user creation?
-- At user creation time no device token exists yet. By firing on INSERT into
-- `devices` we guarantee the locale is set and the notification can be localised
-- accurately.
--
-- Why a `welcome_sent` flag and not a device count?
-- Logout removes the device row and login re-creates it, so a device count
-- ("is this the first device?") sees a brand-new first device on every
-- re-login and re-sent the welcome each time. A one-shot flag on the user,
-- claimed atomically, sends it exactly once for the life of the account.
--
-- notify_user = false: the user is already inside the app at registration time,
-- so no push is needed — the notification is saved to the DB only.
--
-- Anonymous users (no email in public.users) are skipped until they have one.

-- One-time welcome guard (idempotent so re-running the migration is safe).
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS welcome_sent boolean NOT NULL DEFAULT false;

CREATE OR REPLACE FUNCTION public.trigger_welcome_notification()
RETURNS TRIGGER AS $$
DECLARE
  v_email   text;
  v_locale  text;
  v_claimed int;
  v_title   text;
  v_body    text;
BEGIN
  -- Skip anonymous users (no email yet); they get welcomed once they have one,
  -- WITHOUT consuming the one-time claim below.
  SELECT email, locale INTO v_email, v_locale
  FROM public.users
  WHERE id = NEW.user_id;

  IF v_email IS NULL OR v_email = '' THEN
    RETURN NEW;
  END IF;

  -- Atomically claim the one-time welcome: flip welcome_sent to true only if it
  -- isn't already. ROW_COUNT is 1 for the very first claim, 0 for any later
  -- device registration — including one re-created after a logout/login cycle.
  UPDATE public.users
  SET welcome_sent = true
  WHERE id = NEW.user_id AND welcome_sent = false;

  GET DIAGNOSTICS v_claimed = ROW_COUNT;
  IF v_claimed = 0 THEN
    RETURN NEW;
  END IF;

  -- Localised welcome message (falls back to English).
  IF v_locale = 'pt' THEN
    v_title := 'Bem-vindo!';
    v_body  := 'Sua conta está pronta. Aproveite!';
  ELSIF v_locale = 'es' THEN
    v_title := '¡Bienvenido!';
    v_body  := 'Tu cuenta está lista. ¡Disfrútala!';
  ELSE
    v_title := 'Welcome!';
    v_body  := 'Your account is ready. Enjoy!';
  END IF;

  -- notify_user = false: user is inside the app, no push needed.
  INSERT INTO public.notifications (user_id, title, body, type, notify_user)
  VALUES (NEW.user_id, v_title, v_body, 'welcome', false);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_first_device_registered ON public.devices;
CREATE TRIGGER on_first_device_registered
  AFTER INSERT ON public.devices
  FOR EACH ROW EXECUTE PROCEDURE public.trigger_welcome_notification();
