-- Automatically call send-push-notification edge function when a notification is inserted.
-- Uses pg_net to make an async HTTP POST (fire-and-forget) to the edge function URL.
-- Equivalent to the Supabase Database Webhook configured manually in the Dashboard.
--
-- Tokens replaced by the CLI generator at project creation time:
--   ocrpybzdjrcldvlpgccw.supabase.co → your project URL host
--   https://ocrpybzdjrcldvlpgccw.supabase.co      → your project anon key

CREATE EXTENSION IF NOT EXISTS pg_net;

CREATE OR REPLACE FUNCTION public.trigger_send_push_notification()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.notify_user IS DISTINCT FROM false THEN
    PERFORM net.http_post(
      url     := 'https://ocrpybzdjrcldvlpgccw.supabase.co/functions/v1/send-push-notification',
      headers := jsonb_build_object(
        'Content-Type',  'application/json',
        'Authorization', 'Bearer https://ocrpybzdjrcldvlpgccw.supabase.co'
      ),
      body    := jsonb_build_object(
        'type',   'INSERT',
        'table',  TG_TABLE_NAME,
        'schema', TG_TABLE_SCHEMA,
        'record', row_to_json(NEW)::jsonb
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_notification_inserted ON public.notifications;
CREATE TRIGGER on_notification_inserted
  AFTER INSERT ON public.notifications
  FOR EACH ROW EXECUTE PROCEDURE public.trigger_send_push_notification();
