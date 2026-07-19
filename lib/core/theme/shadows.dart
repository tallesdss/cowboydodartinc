import 'package:cowboydodartinc/core/theme/extensions/theme_extension.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Kasy Design System — shared component shadows.
///
/// Numbers come from Figma 01 Effect Styles (`shadow/*`, `blur/*`, `focus/*`).
/// Helpers are thin wrappers so the Design System screen and components share
/// one call site per role.
class KasyShadows {
  KasyShadows._();

  // -------------------------------------------------------------------------
  // Figma Effect Styles — DROP stacks (Light alphas from style; Dark raises
  // overlay / field-strong via Variables where elevation must still read).
  // -------------------------------------------------------------------------

  /// Surface elevation. Figma Effect Style `shadow/surface` (= `shadow/field`):
  /// field @ y0/blur1 + y1/blur2, component @ y2/blur4.
  /// Light snapshot for docs; prefer [surfaceOf] in UI.
  static const List<BoxShadow> surface = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 1),
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x08000000), offset: Offset(0, 2), blurRadius: 4),
  ];

  /// Theme-aware [surface]. Figma vars `shadow/field` · `shadow/component`
  /// (Light 0.04/0.03 · Dark 0.06/0.045).
  static List<BoxShadow> surfaceOf(BuildContext context) {
    final bool dark = context.isDark;
    final double fieldA = dark ? 0.06 : 0.04;
    final double componentA = dark ? 0.045 : 0.03;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: fieldA),
        blurRadius: 1,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: fieldA),
        offset: const Offset(0, 1),
        blurRadius: 2,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: componentA),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
    ];
  }

  /// Form field resting elevation. Figma: `shadow/field` (= [surface]).
  static const List<BoxShadow> field = surface;

  /// Theme-aware [field].
  static List<BoxShadow> fieldOf(BuildContext context) => surfaceOf(context);

  /// [KasyCardVariant.elevated] — Figma `shadow/surface`.
  static List<BoxShadow> cardElevated(BuildContext context) =>
      surfaceOf(context);

  /// [KasyCardVariant.filled] — flat (no elevation). Figma Home unselected
  /// filter cards and the component doc both use fill only, no drop shadow.
  static List<BoxShadow> cardFilled(BuildContext context) =>
      const <BoxShadow>[];

  /// Compact single-shadow lift for chrome that still expects one [BoxShadow]
  /// (avatar, calendar day, accordion). Prefer [surfaceOf] for new surfaces.
  ///
  /// Figma `shadow/component` (Light 0.03 · Dark 0.045). On web the alpha is
  /// reduced so borders carry separation.
  static BoxShadow component(
    BuildContext context, {
    double blurRadius = 4.0,
    double spreadRadius = 0,
    Offset offset = const Offset(0, 2),
  }) {
    final double baseAlpha = context.isDark ? 0.045 : 0.03;
    final double alpha = kIsWeb ? baseAlpha * 0.7 : baseAlpha;
    return BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: alpha),
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
      offset: offset,
    );
  }

  /// Resting border for [KasyTextField] and [KasyTextArea].
  ///
  /// Figma `border/field` (same token web + native).
  static Color inputFieldRestingBorder(BuildContext context) =>
      context.colors.borderField;

  /// Resting border for the FLAT [KasyTextField] / [KasyTextArea] variant.
  ///
  /// Figma `border/field-flat`.
  static Color inputFieldFlatBorder(BuildContext context) =>
      context.colors.borderFieldFlat;

  /// Floating-panel hairline. Alias of [KasyColors.borderSoft] (Figma
  /// `border/soft`). No local alpha: the token already carries opacity.
  static Color overlayPanelBorder(BuildContext context) =>
      context.colors.borderSoft;

  /// Drop-shadow stack for ALL floating panels (Menu · DropDown · Popover ·
  /// notifications bell · Toast). Figma: `shadow/overlay`.
  ///
  /// Tuned **light / clean** (lower alpha, shorter lift) so overlays read as
  /// soft float, not a heavy cast. Keep one stack for every floating panel.
  /// Numbers mirror Figma 01 Effect Style `shadow/overlay` (bound to
  /// `shadow/overlay` · `shadow/overlay-soft` · `shadow/component` vars).
  /// Dark stays quiet (HeroUI-like), not a heavy cast.
  static List<BoxShadow> overlayPanel(BuildContext context) {
    final bool dark = context.isDark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.07 : 0.04),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.03 : 0.015),
        blurRadius: 8,
        offset: const Offset(0, -3),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.045 : 0.03),
        blurRadius: 5,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Standard shadow for input surfaces ([KasyTextField] / [KasyTextArea]).
  ///
  /// Figma `shadow/field` (light stack). Disabled dims the alphas.
  static List<BoxShadow> inputField(
    BuildContext context, {
    required bool enabled,
  }) {
    final List<BoxShadow> base = fieldOf(context);
    if (enabled) return base;
    return [
      for (final BoxShadow s in base)
        s.copyWith(
          color: s.color.withValues(alpha: s.color.a * 0.72),
          blurRadius: (s.blurRadius - 0.3).clamp(0, 64),
        ),
    ];
  }

  /// Standard hairline border width. Figma: `stroke/hairline`.
  static const double hairlineWidth = 1.0;

  /// Switch thumb. Figma Effect Style `shadow/switch` (Light snapshot).
  /// Prefer [switchControlOf] in UI.
  static const List<BoxShadow> switchControl = [
    BoxShadow(color: Color(0x04000000), blurRadius: 5),
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 10),
    BoxShadow(color: Color(0x4D000000), blurRadius: 1),
  ];

  /// Theme-aware switch thumb. Figma: overlay-soft · field · inner.
  static List<BoxShadow> switchControlOf(BuildContext context) {
    final bool dark = context.isDark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.03 : 0.015),
        blurRadius: 5,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.06 : 0.04),
        offset: const Offset(0, 2),
        blurRadius: 10,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.40 : 0.30),
        blurRadius: 1,
      ),
    ];
  }

  /// Segmented control / tab selected thumb. Figma: `shadow/tab` (Light).
  static const List<BoxShadow> tab = [
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 8),
  ];

  /// Theme-aware [tab]. Figma `shadow/field` (Light 0.04 · Dark 0.06).
  static List<BoxShadow> tabOf(BuildContext context) => [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, context.isDark ? 0.06 : 0.04),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ];

  /// Light snapshot of [overlayPanel] (Tokens tile / docs). Prefer
  /// [overlayPanel] in UI. Alphas: 0.04 / 0.015 / 0.03 (= 0x0A / ~0x04 / 0x08).
  static const List<BoxShadow> overlay = [
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 8), blurRadius: 20),
    BoxShadow(color: Color(0x04000000), offset: Offset(0, -3), blurRadius: 8),
    BoxShadow(color: Color(0x08000000), offset: Offset(0, 2), blurRadius: 5),
  ];

  /// Tokens-tile [overlay].
  static List<BoxShadow> overlayOf(BuildContext context) =>
      overlayPanel(context);

  /// Inner-shadow colour Light snapshot (Figma `shadow/inner` Light = 30%).
  static const Color inner = Color(0x4D000000);

  /// Figma INNER_SHADOW blur is 1px; Flutter `BlurStyle.inner` needs a hair
  /// more blur to read as a soft recess.
  static const double innerBlur = 2;

  /// Figma INNER_SHADOW spread.
  static const double innerSpread = 0;

  /// Inner inset Light snapshot — prefer [innerShadowOf].
  static const List<BoxShadow> innerShadow = [
    BoxShadow(
      color: inner,
      blurRadius: innerBlur,
      blurStyle: BlurStyle.inner,
    ),
  ];

  /// Theme-aware inner inset. Figma: INNER_SHADOW · Light 30% / Dark 40%.
  /// Flutter paints thinner, so blur **2** and Light **33%** / Dark **42%**.
  static List<BoxShadow> innerShadowOf(BuildContext context) => [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, context.isDark ? 0.42 : 0.33),
          blurRadius: innerBlur,
          blurStyle: BlurStyle.inner,
        ),
      ];

  /// Frosted-glass blur (chrome panels). Figma: `blur/frosted`.
  static const double frostedBlur = 6;

  /// Frosted-glass blur applied behind modal scrims. Figma: `blur/scrim`.
  static const double modalScrimBlur = 4;

  /// Dim tint painted over the blurred modal backdrop.
  /// Figma Variable `blur/scrim-fill` alpha.
  static const double modalScrimDimAlpha = 0.28;

  /// Max width for [showKasyImageViewer] on desktop (logical px).
  static const double imageViewerDesktopMaxWidth = 380;

  /// Max height fraction for [showKasyImageViewer] on desktop.
  static const double imageViewerDesktopMaxHeightFraction = 0.55;

  /// Max height fraction for [showKasyImageViewer] on mobile/tablet.
  static const double imageViewerMobileMaxHeightFraction = 0.68;

  /// Focus ring outer spread. Figma Effect `focus/ring` outer layer.
  static const double ringFocusWidth = 4;

  /// Gap between the element and its focus ring. Figma Effect `focus/ring`
  /// inner / `focus/ring-field`.
  static const double ringOffsetWidth = 2;

  /// HeroUI focus ring as box-shadows: accent ring with a background-colored
  /// offset gap. Pass `ring` = accent and `gap` = the surrounding background.
  static List<BoxShadow> focusRing({required Color ring, required Color gap}) =>
      [
        BoxShadow(color: ring, spreadRadius: ringFocusWidth),
        BoxShadow(color: gap, spreadRadius: ringOffsetWidth),
      ];

  /// Focus ring for form fields: accent ring with no offset gap.
  static List<BoxShadow> focusRingField({required Color ring}) => [
        BoxShadow(color: ring, spreadRadius: ringOffsetWidth),
      ];
}
