-- Decouple the welcome notification from push permission (parity with Firebase).
--
-- Before: the welcome was SKIPPED for anonymous users (no email) and read the
-- locale from public.users.locale — which is null at signup, so it always fell
-- back to English. Combined with the fact that a device only registered once a
-- push token existed (iOS required permission), users who skipped push never got
-- a welcome at all.
--
-- Now: the install registers even without a push token (client change), so this
-- trigger fires for EVERY account on first device registration, and localises
-- from the device's own reported locale (device.extra_data.deviceLocale) —
-- exactly like the Firebase `onFirstDeviceRegistered` trigger. The one-time
-- `welcome_sent` claim and notify_user = false (DB only, no push) are unchanged.

CREATE OR REPLACE FUNCTION public.trigger_welcome_notification()
RETURNS TRIGGER AS $$
DECLARE
  v_locale  text;
  v_claimed int;
  v_title   text;
  v_body    text;
BEGIN
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

  -- Locale from the device that just registered (e.g. 'pt_BR' -> 'pt'),
  -- independent of push permission. Falls back to English.
  v_locale := lower(substring(coalesce(NEW.extra_data->>'deviceLocale', 'en') from 1 for 2));

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

-- Re-assert the trigger so a database built from these migrations is consistent.
DROP TRIGGER IF EXISTS on_first_device_registered ON public.devices;
CREATE TRIGGER on_first_device_registered
  AFTER INSERT ON public.devices
  FOR EACH ROW EXECUTE PROCEDURE public.trigger_welcome_notification();
