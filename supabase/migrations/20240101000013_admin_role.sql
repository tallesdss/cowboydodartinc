-- Admin role support
--
-- Adds a server-only `role` column to public.users. null/absent = normal user,
-- 'admin' = administrator (unlocks the admin console's server data). The column
-- can be written ONLY by the service role (Edge Functions) or the dashboard /
-- SQL editor — never by the app client, so a user can never promote themselves
-- to admin. This mirrors the Firebase rule that blocks `role` writes.

ALTER TABLE public.users ADD COLUMN IF NOT EXISTS role TEXT;

-- Guard trigger: the app client (anon / authenticated) can update its own row
-- but never the `role` column. Privileged roles pass straight through:
--   - service_role : used by Edge Functions and the dashboard
--   - postgres / supabase_admin : migrations and the SQL editor
-- so an admin can still assign roles by hand.
CREATE OR REPLACE FUNCTION public.enforce_role_immutable()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF current_user IN ('service_role', 'postgres', 'supabase_admin') THEN
    RETURN NEW; -- privileged caller: allow the change
  END IF;

  IF TG_OP = 'INSERT' THEN
    NEW.role := NULL; -- clients never set a role on signup
  ELSIF NEW.role IS DISTINCT FROM OLD.role THEN
    RAISE EXCEPTION 'The role field can only be changed by the server';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS users_enforce_role_immutable ON public.users;
CREATE TRIGGER users_enforce_role_immutable
  BEFORE INSERT OR UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.enforce_role_immutable();

-- Admin helper: true when the current caller is an administrator. SECURITY
-- DEFINER so it reads the role regardless of the caller's own RLS (and avoids
-- policy recursion). Used by admin-only policies below.
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  );
$$;

-- Feature requests moderation (admin console "Requests" tab): only admins can
-- toggle visibility (active) or edit the localized texts. Voting still flows
-- through the feature_votes triggers, so this admin policy is the ONLY way a
-- client can UPDATE feature_requests directly.
DROP POLICY IF EXISTS "Feature requests admin update" ON public.feature_requests;
CREATE POLICY "Feature requests admin update" ON public.feature_requests
  FOR UPDATE USING (public.is_admin()) WITH CHECK (public.is_admin());
