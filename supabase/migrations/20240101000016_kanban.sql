-- Kanban board (kanban module)
--
-- Mirrors the Firebase backend, which stores the board in two Firestore
-- collections (`kanban_columns`, `kanban_tasks`). The board is GLOBAL (not
-- per-user): any signed-in user can read it, only admins can write it. This
-- matches firestore.rules:
--   match /kanban_columns/{id} { read: signed-in; write: isAdmin() }
--   match /kanban_tasks/{id}   { read: signed-in; write: isAdmin() }
--
-- Dates are timestamptz; PostgREST returns them as ISO-8601 strings, which the
-- KanbanColumnEntity/KanbanTaskEntity `DateTime.parse(createdAt)` consume as-is.
-- The `position` column maps to the entity's `order` field (avoids the SQL
-- reserved word); the Dart api layer does the snake_case -> camelCase mapping.

CREATE TABLE IF NOT EXISTS public.kanban_columns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  position INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.kanban_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  column_id UUID NOT NULL REFERENCES public.kanban_columns(id) ON DELETE CASCADE,
  position INTEGER NOT NULL DEFAULT 0,
  priority TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_kanban_tasks_column ON public.kanban_tasks(column_id);

-- RLS: read for any signed-in user, write only for admins (public.is_admin()
-- comes from 20240101000013_admin_role.sql).
ALTER TABLE public.kanban_columns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kanban_tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Kanban columns read" ON public.kanban_columns
  FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Kanban columns admin write" ON public.kanban_columns
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY "Kanban tasks read" ON public.kanban_tasks
  FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Kanban tasks admin write" ON public.kanban_tasks
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());
