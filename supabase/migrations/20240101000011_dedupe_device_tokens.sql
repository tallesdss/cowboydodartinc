-- Cross-user device token deduplication.
--
-- Guarantees that a single FCM token belongs to at most one user at any time.
-- When the same install registers under a new account (typical scenario:
-- logout failed offline), the old row is automatically deleted so the iPhone
-- only receives push for the account currently signed in.
--
-- Winner = the row that was just inserted/updated (most recent intent).

CREATE OR REPLACE FUNCTION public.cleanup_duplicate_device_tokens()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.token IS NULL OR NEW.token = '' THEN
    RETURN NEW;
  END IF;

  DELETE FROM public.devices
   WHERE token = NEW.token
     AND id <> NEW.id;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_cleanup_duplicate_device_tokens ON public.devices;

CREATE TRIGGER trg_cleanup_duplicate_device_tokens
AFTER INSERT OR UPDATE OF token ON public.devices
FOR EACH ROW
EXECUTE FUNCTION public.cleanup_duplicate_device_tokens();
