# Kasy Design System (Figma)

Official Figma file for rebranding and screen design in Kasy projects.

## Get your copy

| Resource | URL |
| -------- | --- |
| **Duplicate to your account** | [Open in Figma](https://www.figma.com/design/S083trj2ctFrEFNjcavtpC/Kasy-Design-System/duplicate) |
| View only | [Kasy Design System](https://www.figma.com/design/S083trj2ctFrEFNjcavtpC/Kasy-Design-System) |

There is **no local file** in generated projects. Duplicate the link above into
your Figma Drafts, then rebrand and sync to Flutter.

**Community:** publish this file to Figma Community from the Kasy team account
so clients can also find it via **Open in Figma** on the resource page.

## Pages inside the file

| Page | Content |
| ---- | ------- |
| `01 Tokens` | Colors (variable-bound swatches), Typography (Small / Medium / Large), Spacing & Radius |
| `02 Components` | Button, TextField, Card, Menu previews |
| `03 Example Screen` | Mobile + Desktop, Light + Dark |

### Variable collections (rebrand)

| Collection | Modes | Dart |
| ---------- | ----- | ---- |
| **Kasy Colors** | Light, Dark | `KasyColors.light()` / `.dark()` |
| **Kasy Spacing** | Value | `KasySpacing.*` |
| **Kasy Radius** | Value | `KasyRadius.*` |

**Rebrand lever:** change `color/accent/accent` first, then sync the full palette
to `lib/core/theme/colors.dart` (see mapping in `docs/figma-workflow.md`).

Colour order matches the in-app Design System screen: Accent → Default →
Success → Warning → Danger → Foreground → Background → Surface → Form field →
Separator → Other.

Premium paywall tokens are **not** in Figma (internal to `colors.dart` only).

## Workflow

1. Duplicate the Community / duplicate link to your Figma account.
2. Rebrand variables (colours, font).
3. Point your AI assistant at your duplicated file + `docs/figma-workflow.md`.
4. Sync into `lib/core/theme/` in the Flutter project, then build screens.

**Human guide:** `docs/figma-guia.md` (project language after `kasy new`).

**Public docs:** [kasy.dev/docs](https://kasy.dev/docs) → Personalização → Figma.

Product screens: create a **separate** Figma file (e.g. `My App`) using the
same variables.

## Maintainers (kit repo)

The master file lives in Figma (not in git):

```text
fileKey: S083trj2ctFrEFNjcavtpC
https://www.figma.com/design/S083trj2ctFrEFNjcavtpC/Kasy-Design-System
```

After changing tokens in code (`colors.dart`, `spacing.dart`, `radius.dart`,
`type_scale.dart`), update the Figma master and republish to Community.

Do **not** commit a local design binary. PRs that change theme tokens should
include a follow-up to refresh the Figma master.
