# AGENTS.md — working in this codebase

This project was generated with the **Kasy** kit. This file orients any AI coding
assistant (Claude Code, Cursor, GitHub Copilot, …). Read it before generating
code. Claude Code users: `CLAUDE.md` points here.

## What this is

A Flutter Web library system built on the **Kasy design system** and a **feature-first** architecture.
**CRITICAL PROJECT RULE:** This project is exclusively frontend with mock data (using LocalStorage/memory for simulated persistence). There is no real backend database or API.

Currently, we are beginning the implementation of the **first and second phases** of the system:
1. **Fase 1**: Biblioteca de PDFs com categorias, Login mockado + Home autenticada, Menu lateral dinâmico por perfil, Seletor de troca de perfil, Comentários/avaliações em PDFs (Perfis: Admin/Desenvolvedor e Cliente).
2. **Fase 2**: As per requirements in the roadmap.


## Golden rules (every time)

1. **Use the design system, never raw values.** No hardcoded `fontSize`,
   `Color(0x…)`, `Colors.*`, or literal padding / radius / icon sizes. Use
   `context.textTheme.*` / `KasyTextTheme.*`, `context.colors.*`,
   `KasySpacing.*`, `KasyRadius.*`, `KasyIconSize.*`. Full reference:
   **`DESIGN_SYSTEM.md`**.
2. **Use kit components, not raw Material.** `KasyButton` (not
   ElevatedButton / TextButton), `showKasyConfirmDialog` (not AlertDialog),
   `showKasyToast` (not SnackBar), plus `KasyCard`, `KasyTextField`,
   `KasyScreen`, etc.
3. **The Home screen is the default visual for content screens** — clean,
   minimal, lots of surface, one accent colour used sparingly. Mirror it when a
   new screen has no design of its own. This is a starting point, **not a law**:
   override the composition freely when the design calls for it (the Kanban
   board, auth cards, paywalls and admin tables all diverge on purpose). What is
   never optional is the *foundation* — rules 1, 2 and 4 (tokens, kit
   components, i18n) hold on every screen, however different it looks.
4. **English everywhere** in code, comments and identifiers. **No hardcoded
   user-facing strings** — use slang i18n (`context.t.…`).
5. **Package imports only**: `import 'package:cowboydodartinc/…';`, never relative.
6. **Zero analyzer issues.** Run `flutter analyze` and fix everything before
   considering a change done.
7. **Live app session (hot reload).** If a Flutter session is already running
   (`kasy run` / `flutter run`, including web at http://localhost:5555 when
   applicable), after each code change: run `flutter analyze` and only continue
   when it is clean, then hot reload (`r`) or hot restart (`R`) as the change
   requires. **Never mention** reload, restart, analyze, or the run session in
   the chat reply. Just do it. If no session is running, skip; do not start one
   unless the user asked.

## Design system, components & responsiveness

This kit is an **organized, opinionated** design system — not a blank canvas.
Before building anything, browse the live **Design System** screen
(`lib/features/home/design_system_page.dart`) and the **Components** gallery:
colours, typography, spacing and dozens of ready widgets (`KasyButton`,
`KasyCard`, `KasyTextField`, `KasyScreen`, `showKasyToast`,
`showKasyConfirmDialog`, …). Reuse one before writing a new widget. Full token
reference: **`DESIGN_SYSTEM.md`**.

> **A component's real configuration lives in its Preview screen.** Whenever you
> need to know how a component is used — its default config and every supported
> variant — open the **Components preview** (the gallery → tap a component, code
> in `lib/features/home/home_components_preview_registry.dart`). Every
> pre-built configuration is there, demoed exactly as intended. Copy from it;
> never guess a component's API or invent props from memory.
>
> **Design System screen vs Components gallery:** the **Design System** page
> (`design_system_page.dart`) is for tokens (colour, type ramp, spacing). It is
> **not** the place to demo every variant of every widget. **Component variants
> live in the Components gallery** (Home → Components → pick a component → its
> variant tabs; code in `home_components_preview_registry.dart`).

### `KasyTextField` — pick the variant from the surface

Variants are defined on the component (`KasyTextFieldVariant` in
`kasy_text_field.dart`). **Do not invent a one-off look per screen.** Open
**Components → TextField → Variants** for the live reference, then apply this
surface contract:

| Surface | Variant | Notes |
| ------- | ------- | ----- |
| Open page / scaffold background | `primary` (default) | Fill + hairline border + soft shadow |
| Chrome / header search on canvas | `tonal` | `surfaceSecondary` fill, no border, no shadow (Figma Home Search) |
| Same-colour card or panel (auth card, settings group) | `flat` | Border defines the field; no shadow |
| Modal form body (`KasyBottomSheet`, `KasyDialog`) | `primary` default | Container elevates fill via `kasyElevatedSurfaceInputFill()` — no per-call override needed |
| Modal when you need explicit control | `secondary` | Same elevated fill (`surfaceSecondary`), no shadow; use when copying admin/form previews |

Auth (sign in / sign up / recover) uses **`flat`** on every breakpoint. Settings
**inline name edit** on tablet/desktop uses **`flat`** in the row (Stripe-style:
Edit → field appears in place). Mobile name edit still uses the bottom sheet
(`edit_name_sheet.dart`).

### Modal forms — bottom sheet vs dialog (desktop)

For **multi-field forms** opened from settings-like screens, mirror the existing
pattern (Criar senha, Enviar feedback, Kanban task/column):

- **Desktop** (`width >= DeviceType.large.breakpoint`, 1024): centered
  **`KasyDialog`** via `showKasyBlurDialog`.
- **Mobile / tablet**: **`KasyBottomSheet`** (or `KasyBottomSheet.form`).

Share one form widget with an `asDialog` (or equivalent) flag; only the shell
changes. **`KasyDialog`** already applies desktop layout (padding, width, gaps)
and elevated input fill for `primary` fields — implement once in the component,
not per feature.

**Inline edit on desktop** (single field, already on the page) stays inline — do
not force a dialog. Example: Settings account name on tablet/desktop
(`_EditableAccountFields` in `settings_page.dart`).

**Responsiveness is deliberate, not improvised.** The responsive system
(`DeviceType` in `lib/core/widgets/responsive_layout.dart`) has four tiers and the
type sizes are pinned per breakpoint, so the UI never oscillates or guesses:

| DeviceType | Width        | Notes                                            |
| ---------- | ------------ | ------------------------------------------------ |
| `small`    | `< 768`      | native iOS/Android + phone-width web             |
| `medium`   | `768–1023`   | tablet                                           |
| `large`    | `1024–1279`  | desktop, authored baseline                       |
| `xlarge`   | `>= 1280`    | wide desktop (web-scale design target, 1280)     |

Typography collapses `large`+`xlarge` into one "desktop" tier (same sizes); the
`1280` boundary matters for the web render scale (its design target), not type.

- **Typography** (`KasyTypeScale`): each role has an **explicit size per
  breakpoint** — headings are largest on desktop and step down on smaller
  screens; body/labels stay constant. It is applied globally by
  `ResponsiveTextTheme` — **screens just use `context.textTheme.*` /
  `context.kasyTextTheme.*` and the right size comes out**. Don't hardcode
  `fontSize`; don't invent your own breakpoints.
- **Native mobile** is straightforward: it's the Mobile breakpoint and never
  scales the viewport.
- **Web render scale** (`WebViewportScale`) is a *separate* concern: Flutter web
  renders ~10% large at every width, so the whole web UI (phone, tablet, desktop)
  is scaled to `0.93`; native renders at natural `1.0`. This is NOT the typography
  scale — don't conflate the two.
- **Screen width follows content type** (two tiers): read/form screens (Settings,
  Notifications) are contained + centred at `kKasyContentMaxWidth` (600) — set
  `KasyOverlayScaffold(maxContentWidth: kKasyContentMaxWidth)` or use `KasyScreen`;
  feed/dashboard screens (Home) go full width + the 16 gutter. Mirror
  Settings/Notifications, or Home. Full rule: **`DESIGN_SYSTEM.md`** → Internal-screen contract.

To re-tune sizes, edit `KasyTypeScale` in `lib/core/theme/type_scale.dart` —
nothing else. The live ramp (tabs per breakpoint) is under **Design System →
Typography**.

### Figma designs

When implementing screens from **Figma**, read **`docs/figma-workflow.md`**
first (technical). Point non-technical users to **`docs/figma-guia.md`**
(beginner guide in the project language). Public step-by-step:
**kasy.dev/docs** → Personalização → Figma.

Duplicate the master file from Community (link in `design/README.md` and
`docs/figma-guia.md`) before editing. Use Figma MCP (`get_variable_defs`,
`get_design_context`, `get_screenshot`) on the **client's copy**.

One workflow:

1. **Rebrand** — client duplicates **Kasy Design System**, updates Variables
   (colours, font), then sync into `lib/core/theme/`. Almost nobody keeps the
   default Kasy brand.
2. **Screen** — build from **App Design** file: faithful to the frame,
   **functional** (real taps, forms, navigation), using kit components and
   `context.colors` / `context.kasyTextTheme`.
3. **Guard** — if a colour or font in the screen frame is not in the design
   system, **report it** and fix Figma variables + `theme/` before hardcoding on
   the screen.

Do not maintain a separate "fixed palette" path on screens. The design system
is the single source of truth after rebrand.

## Architecture (feature-first, three layers)

```
lib/
├── components/   # Kasy design-system widgets (KasyButton, KasyCard, …)
├── core/         # cross-cutting: theme/, data/, states/, security/, widgets/, i18n
└── features/
    └── <feature>/
        ├── api/           # data source (Firebase / Supabase / REST) → returns entities
        ├── repositories/  # entities → domain models (business logic)
        ├── providers/     # Riverpod notifiers → immutable page state
        └── ui/            # pages, components (use provider + domain), widgets (dumb)
```

- **Data flow:** `api → repository → provider (notifier) → ui`. Only repositories
  use api classes. The api returns entities; repositories return domain models.
- **State:** a Riverpod notifier exposes an immutable (freezed) state; the view
  `ref.watch`es it and triggers actions. Use `.when` / `.map` for
  data / loading / error.
- **Backend note:** the `api` layer is the only backend-specific code. A new
  data-backed feature follows the same `api → repo → provider` chain the
  existing features use.

## Building a screen or component — checklist

1. Read `DESIGN_SYSTEM.md` (tokens, typography roles, components). If the screen
   comes from Figma, read `docs/figma-workflow.md` and apply the full colour
   mapping table (not accent only). Point the user to `docs/figma-guia.md` if needed.
2. Reuse a kit component before building one. Wrap new pages in `KasyScreen`
   (or mirror an existing page's scaffold). Pick the width tier — contained
   (mirror Settings/Notifications) vs full-width (mirror Home); see `DESIGN_SYSTEM.md`.
3. Use semantic typography roles (`pageTitle`, `sectionTitle`, `rowTitle`, …)
   and tokens for **every** size, colour and spacing.
4. Strings via `context.t.*` (add keys to the i18n JSON, never inline text).
5. `flutter analyze` clean. Optional: `dart run tool/design_check.dart` flags
   any raw values that slipped into `lib/features`.
6. If a Flutter run session is already active, hot reload / restart (golden
   rule 7). Do not start a session just for this checklist step.

## Flutter gotcha: key conditionally-swapped widgets

When a `Row`/`Column`/`Flex` swaps one widget for **another of the same type in
the same slot** based on state — e.g. an "Edit" button that becomes
"Cancel" + "Save" — give each variant a distinct `Key` (`ValueKey('…')`).
Otherwise Flutter reconciles by type + position, reuses the same element and
**carries over its internal state**, most visibly the hover flag: the widget that
takes the old one's place lights up hovered for one frame and then clears (a
hover "flash"). The same applies to focus, animations and controllers.

This is framework behaviour, **not a kit bug**, and it **cannot** be fixed inside
`KasyButton` / `KasyHover`: a button whose label legitimately changes (e.g.
"Follow" → "Following", or a counter) must keep its state across rebuilds, so an
automatic reset there would break the common case. The fix always lives at the
call site, with keys:

```dart
...editing
  ? [
      KasyButton(key: const ValueKey('edit-cancel'), label: tr.cancel, ...),
      KasyButton(key: const ValueKey('edit-save'), label: tr.save, ...),
    ]
  : [
      KasyButton(key: const ValueKey('edit-start'), label: tr.edit, ...),
    ]
```

Rule of thumb: any `cond ? WidgetX(...) : WidgetX(...)` (same type both sides)
inside a multi-child layout needs distinct keys.

### Selectable option groups — use `KasySelectableChip`

For a **single / multi-choice group of pills** (priority picker, filters, tag
selector), use **`KasySelectableChip`** — never hand-roll a `GestureDetector` +
`AnimatedContainer`. Switching selection in a hand-built chip group visibly
"blinks", and the cause is subtle (three things at once). The component bakes in
the whole fix so you never reproduce it:

- **Fixed label weight** — selection reads from colour + fill, not a heavier
  glyph; otherwise the chip's width changes and the `Wrap` reflows (the "jump").
- **Animated dot / label colour** — tracks the fill instead of snapping.
- **Border fades to its own hue at `alpha 0`** — never `Colors.transparent`
  (transparent *black*, which lerps through dark and flickers).

Pass `color:` so the chosen chip matches its display tag (e.g. a priority token,
to read like the `KasyStatusTag` on the card). In a list still give each chip a
stable `Key` (`ValueKey(value)`) — see the keys note above. This is the pattern
the Kanban priority picker uses (create + edit).

## Platform notes (native-only features)

Some features only work on a real iOS / Android build and are gated with
`kIsWeb`. They never run on web; where the user explicitly triggers them, a
"native app only" toast is shown instead of failing silently.

- **In-app review / store rating** — sends the user to the App Store / Play
  Store. It is never shown on web. **iOS requires the numeric App Store ID**:
  run `kasy configure` and fill `App Store ID (numeric)`. Android works
  automatically from the package name. Until the ID is set, iOS store review
  throws at runtime.
- **Push / FCM token, notification permission** — native APIs; on web the admin
  actions surface the "native app only" toast.
- **App update prompts** — two distinct flows, both native-only and driven by
  Firebase Remote Config (works on every backend): **"update available"** (shown
  *before*, when the installed version is below `app_latest_version` / blocking
  below `app_min_version`, sends the user to the store) and **"what's new"**
  (shown *after* updating). See `lib/core/app_update/` and the README.

## Optional design guard-rail

`dart run tool/design_check.dart` scans `lib/features` for raw values
(hardcoded fonts / colours / Material widgets). It is **opt-in and
non-blocking** — relax it, wire it into CI, or delete it freely. Per-line
escape hatch: `// design-check: ignore`.

## Updating the kit (merging new versions with your changes)

The project is a scaffold: the kit code was copied into it. Improvements ship via
the CLI, which **overwrites** files (it does not auto-merge). The safety net is git.

Recommended flow when the user wants newer kit code:

1. **Commit first** so the working tree is clean (the CLI also warns about this).
2. Run the relevant command:
   - `kasy update` — shows what's new for the features in use
   - `kasy update core` / `kasy update components` — refreshes core files / UI components
   - `kasy update <feature>` — e.g. `revenuecat`, `ai_chat`, `widget` (re-applies that feature)
3. The command overwrites the files and prints which ones changed.
4. **Merge:** if the user had customized any overwritten file, reconcile their version
   (in the previous git commit) with the new kit version. As the in-project agent,
   this is your job: read `git diff` (or `git show HEAD:<file>` for the user's prior
   version) and produce a result that keeps BOTH the user's customizations and the new
   kit improvements. Prefer additive merges; never silently drop the user's logic.
   When unsure which side wins for a hunk, ask the user.

This is why committing before `kasy update` matters: it makes the user's prior version
recoverable so the merge is a normal 3-way reconcile, not a guess.

## Debugging when something doesn't work

Diagnose with real signals, not guesses:

- **App logs first.** Key steps (auth, service init) are logged via `Logger` — read
  the `kasy run` terminal / browser console.
- **Then the backend logs.** Supabase: Dashboard → Logs (Auth / Edge Functions /
  Postgres). Firebase: Console → Functions logs / Authentication.
- **Auth / token errors:** decode the JWT (base64url-decode the middle segment) and
  inspect `sub` / `aud` / `iss`. A `missing sub claim` usually means the wrong
  session/token was sent (e.g. the publishable `anon` key), not a bad provider token.
- **`kasy doctor`** checks common setup gaps (Google SHA-1, authorized domains,
  provider config).
- **Web vs native differ:** web runs in `authRequired` mode (no anonymous user);
  native is anonymous-first. Account-linking only applies when a real session exists.

Add a temporary `print(...)` to inspect a runtime value, then remove it.
