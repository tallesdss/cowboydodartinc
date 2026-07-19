/// Kasy Design System — Icon Size Tokens
///
/// Single source of truth for every icon dimension in the app. Screens and
/// components must read from here instead of hardcoding `size: 20` etc., so the
/// whole product can be re-scaled from one place.
///
/// Usage: `Icon(KasyIcons.person, size: KasyIconSize.rowLeading)`
///
/// Scale reference:
/// xxs  → 12   micro glyphs inside small badges
/// xs   → 14   tiny, dense inline glyphs
/// sm   → 16   secondary / trailing (chevrons, value adornments)
/// md   → 18   inline-with-text (chips, accordions, alerts)
/// lg   → 20   default — list-row leading icons, chrome actions
/// xl   → 24   prominent / large chrome
/// xxl  → 28   feature highlights
/// display → 36   illustrative glyphs (empty states, brand badges)
/// hero → 72   hero glyph at the top of a focused screen (auth, onboarding)
class KasyIconSize {
  KasyIconSize._();

  // Scale (Figma collection 06 Icon Size / Tokens · Icon Size tiles).
  static const double xxs = 12; // icon-12
  static const double xs = 14; // icon-14
  static const double sm = 16; // icon-16
  static const double md = 18; // icon-18
  static const double lg = 20; // icon-20
  static const double xl = 24; // icon-24
  static const double xxl = 28; // icon-28
  static const double display = 36; // icon-36
  static const double hero = 72; // icon-72

  // ── Semantic aliases ─────────────────────────────────────────────────────
  // Prefer these in screens so intent is explicit and a single edit re-scales
  // every row/chrome at once.

  /// Leading icon in a list / settings row (the standard list glyph).
  static const double rowLeading = lg; // 20

  /// Trailing affordance in a row — chevron, small value adornment.
  static const double rowTrailing = sm; // 16

  /// Action icons in the top/bottom chrome (app bar orbs, nav).
  static const double chrome = lg; // 20

  /// Glyph sitting inline next to body text (chips, inline status).
  static const double inline = md; // 18
}
