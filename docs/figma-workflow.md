# Figma → Flutter workflow

One workflow for every Kasy project. The client **almost never keeps the default
Kasy brand**. They rebrand first (colours, font, radius), then build screens.
Your job as the AI is to keep **Figma, the design system, and Flutter code in
sync**, and to ship screens that are **faithful and functional**.

Human-friendly guides (step by step, localized): **`docs/figma-guia.md`** in the
user's project language. Public docs: **kasy.dev/docs** → Personalização → Figma.

## Get the design system file

There is **no local design file** in the generated project. The master lives on
Figma Community:

| Resource | URL |
| -------- | --- |
| Design system (duplicate) | https://www.figma.com/design/S083trj2ctFrEFNjcavtpC/Kasy-Design-System/duplicate |
| Design system (view) | https://www.figma.com/design/S083trj2ctFrEFNjcavtpC/Kasy-Design-System |
| This workflow (AI) | `docs/figma-workflow.md` |
| Beginner guide (human) | `docs/figma-guia.md` |

**How the client gets their own copy:**

1. Open the duplicate link above (or the Community page → **Open in Figma**).
2. Figma saves an independent copy to the client's Drafts.
3. The client (or you via Figma MCP) edits **Variables** in that copy.
4. Pass the duplicated file URL / `fileKey` to the AI for sync into Flutter.

The MCP Figma plugin **cannot clone** a Community file programmatically. Duplicate
via the link or Community UI first, then use MCP on the client's copy.

## The two Figma files

| File | Purpose |
| ---- | ------- |
| **Kasy Design System** (duplicate from Community) | Brand tokens + components. Rebrand here first. |
| **App Design** (e.g. `My App`) | Product screens. Must use the same variables as the design system. |

## Figma MCP tools (read design)

Use these on the **client's duplicated file** (`fileKey` from the Figma URL):

| Tool | Use |
| ---- | --- |
| `get_variable_defs` | Read colour/spacing/radius variables for a node |
| `get_design_context` | Layout, typography, component structure for a frame |
| `get_screenshot` | Visual verification vs the running app |
| `get_metadata` | Frame / page structure |
| `use_figma` | Edit variables or frames (rebrand assist) |

## Step 1 — Rebrand (always before screens)

### 1a. Read tokens from Figma

Open the duplicated **Kasy Design System** file. Variable collections:

| Collection | Modes | Maps to |
| ---------- | ----- | ------- |
| **Kasy Colors** | Light, Dark | `KasyColors.light()` / `.dark()` |
| **Kasy Spacing** | Value | `KasySpacing.*` |
| **Kasy Radius** | Value | `KasyRadius.*` |

Page **01 Tokens** mirrors **Home → Design System** in the app
(`design_system_page.dart`): same color categories, typography breakpoints,
spacing and radius.

**Rebrand shortcut:** change `primary/base` (or legacy `color/accent/accent`)
in **Kasy Colors** per mode (light stays the darker brand blue; dark needs a
lighter blue for contrast on near-black), then update derived primary tokens
and run the full sync below. Do **not** stop at primary only.

**Color order (same as the app):** Accent → Default → Success → Warning → Danger →
Foreground → Background → Surface → Form field → Separator → Other.

Premium paywall tokens (`premiumOverlay*`, `premiumBannerText`) are **not** in the
Figma file. They stay internal in `colors.dart`.

### 1b. Sync colours → `lib/core/theme/colors.dart`

Edit **`KasyColors.light()`** and **`KasyColors.dark()`** factories. Map every
Figma variable below. Do **not** change only `primary` / accent.

| Figma variable | `KasyColors` field | Notes |
| -------------- | ------------------ | ----- |
| `primary/base` or `color/accent/accent` (+ hover/soft via getters) | `primary` | Page 01 **Accent** / Primary |
| `color/default/neutral` (+ hover, foreground) | `neutral`, `neutralHover`, `neutralForeground` | **Default** |
| `color/success/*`, `color/warning/*`, `color/danger/*` | matching semantic fields | Semantic categories |
| `foreground/*` or `color/foreground/*` | `foreground*` | **Foreground** |
| `background/base` or `color/background/*` | `background*` | **Background** |
| `surface/base` or `color/surface/*` | `surface*` | **Surface** |
| `color/field/*` | `fieldBackground`, `fieldPlaceholder`, … | **Form field** |
| `color/separator/*` | `separator*` | **Separator** |
| `color/other/border`, `overlay`, `segment`, `backdrop` | same | **Other** |

**Derived tokens** (`primarySoft`, `dangerSoft`, …): keep the existing alpha
pattern in `colors.dart` (e.g. `0x26` + base colour) unless the user provides
explicit soft values. Update `*Foreground` and `*Hover` to stay readable on the
new bases.

**Typography:** Figma `font/display` + `font/body` → **Poppins** (single family in
`texts.dart`). Hierarchy is size + weight, not a second typeface. Figma and the
Flutter app use the same family.

### 1c. Sync radius and spacing

| Figma variable | Dart |
| -------------- | ---- |
| `radius/xs` … `radius/xl`, `radius/full` | `KasyRadius.xs` … in `radius.dart` |
| `spacing/xs` … `spacing/xxxl` | `KasySpacing.*` in `spacing.dart` |

### 1c-bis. Sync shadows

**Figma 01 Effect Styles** (`shadow/surface`, `field`, `switch`, `tab`,
`overlay`, `inner`) own the numbers. Mirror them in
`lib/core/theme/shadows.dart`. Components and the Design System screen call the
same helpers. Prefer **light / clean** elevation (Home reference).

| Role | Dart helper | Figma Effect |
| ---- | ----------- | ------------ |
| Card | `cardElevated` / `surfaceOf` | `shadow/surface` |
| Field | `inputField` / `fieldOf` | `shadow/field` |
| Switch thumb | `switchControlOf` | `shadow/switch` |
| Tabs pill | `tabOf` | `shadow/tab` |
| Menu · Dropdown · Popover · bell | `overlayPanel` | `shadow/overlay` |
| Inner inset | `innerShadowOf` | `shadow/inner` |
| Frosted / modal scrim | `frostedBlur` / `modalScrimBlur` | `blur/frosted` · `blur/scrim` |
| Focus | `focusRing` / `focusRingField` | `focus/ring` · `focus/ring-field` |

`KasyShadows.component()` remains a soft single-shadow fallback for chrome that
still expects one `BoxShadow`. New surfaces should use the stacks above.

### 1d. Sync typography

| Figma / page 01 | Dart |
| --------------- | ---- |
| Typography ramp (3 columns, size + line-height) | `KasyTypeScale` in `type_scale.dart` |
| Semantic roles | `texts.dart` (`KasyTextTheme.build`) |
| `font/display` + `font/body` | Poppins via `_poppins()` / `GoogleFonts.poppins` |

**Font family change:**

1. Figma: set `font/display` and `font/body` Variables to **Poppins**; update
   all `kasy/*` Text Styles. Quick path: run **Kasy Poppins Sync**
   (`tools/kasy-figma-poppins-sync/`) on the open file. Full rebuild: **Kasy DS
   Generator** (`tools/kasy-figma-generator/`).
2. `lib/core/theme/texts.dart`: `_poppins()` via `GoogleFonts.poppins`.
3. Confirm `google_fonts` in `pubspec.yaml`.
4. Run `flutter pub get`.

**Auth layout notes (Figma Example Screen):**

- Mobile Sign In: top inset 75, content top-aligned, no card.
- Desktop Sign In: elevated card 420, vertically centered.
- Tablet: no dedicated Figma frame; kit treats `medium+` like desktop (card +
  center). Add a tablet frame in Figma if you need a distinct layout.

### 1e. Verify rebrand

1. `kasy run --web`.
2. Open **Home → Design System**. Compare light + dark to Figma page 01.
3. `flutter analyze` — zero issues.

Do not implement product screens until this step passes.

## Step 2 — Implement a screen (faithful + functional)

### 2a. Inputs

- Frame name in the client's **App Design** file (light + dark if both exist).
- Rebrand already applied (Step 1).
- Client's Figma `fileKey` connected via MCP.

### 2b. Design system guard (run first)

For every colour and font size in the screen frame:

| Situation | Action |
| --------- | ------ |
| Matches a Figma variable / `colors.dart` token | Use `context.colors.*` |
| Hex matches `KasyColors.light()` / `.dark()` | Use the token name |
| Hex **not** in design system | **Stop.** Report: *"Colour `#XXXXXX` is not in the design system. Add to `colors.dart` + Figma variables, or fix the frame."* |
| Font not in project | Add font (Step 1d), then continue |
| Text size matches `KasyTypeScale` role | `context.kasyTextTheme.*` |

### 2c. Build the screen

| Requirement | How |
| ----------- | --- |
| Layout faithful to Figma | Spacing, hierarchy, light + dark |
| Tokens only | `context.colors.*`, `context.kasyTextTheme.*`, `KasySpacing.*`, `KasyRadius.*` |
| Kit components | `KasyButton`, `KasyTextField`, `KasySwitch`, `KasyCard`, `KasyScreen`, … |
| Functional | Real `onPressed`, controllers, providers, navigation |
| i18n | `context.t.*` + keys in slang JSON (pt, en, es) |
| No raw Material | `showKasyConfirmDialog`, `showKasyToast`, not `AlertDialog` / `SnackBar` |

### 2d. Verify screen

- [ ] Matches Figma frame (light + dark)
- [ ] Interactions work
- [ ] `flutter analyze` clean
- [ ] Optional: `dart run tool/design_check.dart`

## Kit map (Figma → Flutter)

| Figma / component | Flutter | Notes |
| ----------------- | ------- | ----- |
| Button variants | `KasyButton` | primary, secondary, outline, ghost, destructive, soft, … |
| TextField | `KasyTextField` | `primary`, `flat`, `secondary`, `embedded` |
| Switch | `KasySwitch` | md track 40×20 |
| Card | `KasyCard` | `elevated`, `filled`, `outlined`, `ghost`, `spotlight` |
| Menu | `KasyMenu` / dropdown patterns | see Components gallery |
| `primary/base` or `color/accent/accent` | `context.colors.primary` | **Primary rebrand lever** |
| `color/foreground/foreground` | `context.colors.foreground` | |
| `background/base` or `color/background/background` | `context.colors.background` | Also splash colour |
| `surface/base` | `context.colors.surface` | Elevated panels / cards |
| `font/display` + `font/body` | Poppins in `texts.dart` | All roles |
| `radius/lg` | `KasyRadius.lg` (16) | |
| `spacing/md` | `KasySpacing.md` (16) | |

Component APIs: **Home → Components** gallery and
`lib/features/home/home_components_preview_registry.dart`.

## Copy-paste prompts (user → AI)

**Rebrand:**

```
Read AGENTS.md and docs/figma-workflow.md.
My Figma design system file: [PASTE FIGMA URL AFTER DUPLICATE].
Use Figma MCP get_variable_defs on page 01 Tokens.
Sync ALL colour tokens into KasyColors.light() and .dark() in
lib/core/theme/colors.dart (not accent only).
Update splash colour in pubspec.yaml if background changed.
Verify on Design System screen. flutter analyze clean.
```

**New screen:**

```
Read docs/figma-workflow.md. My app design file: [FIGMA URL].
Run design system guard on frame [FRAME NAME].
Use get_design_context + get_screenshot for reference.
Implement faithful + functional screen: feature folder, route, i18n (pt/en/es),
Kasy components + tokens only. flutter analyze clean.
```

## Common mistakes

| Mistake | Fix |
| ------- | --- |
| Rebrand accent only | Update full mapping table (Step 1b) |
| `Color(0x…)` on screens | Token in `colors.dart` first |
| Screen before rebrand | Step 1 first |
| Static mockup | Wire state and callbacks |
| Raw Material widgets | Kasy components |
| Orphan hex in App design | Guard: report and fix DS |
| Forgot splash after background change | `pubspec.yaml` + `flutter_native_splash:create` |
| MCP on Community master | Duplicate to Drafts first |

## AI checklist

- [ ] Read `docs/figma-workflow.md` and `docs/figma-guia.md` if user is non-technical
- [ ] Client duplicated the Community file to their account
- [ ] Rebrand complete (all mapped colours, light + dark)
- [ ] Design system guard passed for screen frames
- [ ] Feature + route + i18n
- [ ] Faithful + functional
- [ ] `flutter analyze` clean

## Related docs

- **`docs/figma-guia.md`** — beginner guide (project language)
- **`AGENTS.md`** — golden rules
- **`DESIGN_SYSTEM.md`** — full token reference
- **kasy.dev/docs** → Personalização → Figma
