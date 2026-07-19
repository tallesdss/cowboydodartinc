# CLAUDE.md

This project shares one AI-guidance file across tools. **Read `AGENTS.md`** in
this directory first — it defines the architecture, the Kasy design system, and
the conventions to follow before generating any code.

Quick reminders:

- Use design-system tokens, never raw values — see `DESIGN_SYSTEM.md`
  (`context.textTheme.*`, `context.colors.*`, `KasySpacing.*`, `KasyRadius.*`,
  `KasyIconSize.*`).
- Use Kasy components (`KasyButton`, `KasyCard`, `showKasyToast`,
  `showKasyConfirmDialog`, …), not raw Material.
- The Home screen is the visual reference: clean, minimal, one accent colour.
- English in code; user strings via `context.t.*` (slang i18n).
- Run `flutter analyze` and keep it clean before considering a change done.
- If `kasy run` / `flutter run` is already active (including web at
  http://localhost:5555), after code changes: analyze clean, then hot reload
  (`r`) or hot restart (`R`). Never mention it in the reply. See `AGENTS.md`
  golden rule 7.
