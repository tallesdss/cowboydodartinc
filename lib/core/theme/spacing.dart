/// Kasy Design System — Spacing Tokens
///
/// Single source of truth for all spacing values in the app.
/// Usage: KasySpacing.md → 16.0
///
/// Scale reference (named aliases used in layout):
/// xs   →  4
/// sm   →  8
/// smd  → 12
/// md   → 16
/// lg   → 24
/// xl   → 32
/// xxl  → 48
/// xxxl → 64
///
/// Full Figma ruler (0–160), one scale:
/// 0 · 4 · 8 · 12 · 16 · 24 · 32 · 40 · 48 · 56 · 64 · 75 · 80 · 96 · 128 · 160
/// (`75` = [authContentTop] / Figma `spacing/auth-top`, auth mobile only.)
///
/// **Page gutters** — baseline insets from the screen edge. [HomePage] and
/// [SettingsPage] use [md] horizontally; keep new screens aligned unless
/// a full-bleed layout is intentional. Pair top with [SafeArea] / notch; bottom
/// often adds [MediaQuery.padding] for the home indicator.
class KasySpacing {
  KasySpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double smd = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  /// Extra ruler steps beyond the named aliases (Figma collection 02). Prefer
  /// the named aliases in real UI; these exist for parity / rare large gaps.
  static const double space0 = 0;
  static const double space40 = 40;
  static const double space56 = 56;
  static const double space80 = 80;
  static const double space96 = 96;
  static const double space128 = 128;
  static const double space160 = 160;

  /// Auth mobile screen top inset. Figma `spacing/auth-top` (Sign In / Up /
  /// Recover · Mobile: content starts at y=75 from the frame top).
  static const double authContentTop = 75;

  /// Horizontal inset from left/right screen edge ([HomePage], [SettingsPage],
  /// auth, lists, etc.).
  static const double pageHorizontalGutter = md;

  /// Extra spacing added below content with [MediaQuery.padding] bottom
  /// (home indicator) — see [HomeComponentsPage] / tab roots.
  static const double pageVerticalGutter = sm;

  /// Gap between frosted chrome / [KasyAppBar] and main content (cards, list
  /// surface). Tuned for visual separation from the bar. See Home, Features,
  /// Components. Figma: `spacing/chrome-gap`.
  static const double belowChromeContentGap = 20;

  /// Alias of [belowChromeContentGap] (Figma `spacing/chrome-gap`).
  static const double chromeGap = belowChromeContentGap;
}
