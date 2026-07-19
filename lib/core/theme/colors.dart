import 'package:flutter/material.dart';

/// Kasy Design System — Color Tokens (HeroUI semantic model)
///
/// Single source of truth for all colors in the app. Mirrors the HeroUI
/// color system: a small, meaningful set of semantic roles (primary, default,
/// success, warning, danger, foreground, background, surface, form field,
/// separator) rather than a large raw palette. Each role exposes its base
/// value plus `hover`, `soft`, `soft-hover` and `soft-foreground` variants
/// where applicable, and resolves to a Light and a Dark theme.
///
/// Usage via context extension:
///   context.colors.primary             → brand CTA fill (Figma `brand/primary/base`)
///   context.colors.primarySoft         → translucent primary fill
///   context.colors.surfaceSecondary    → zinc content fill (Figma `surface/secondary`)
///   context.colors.surfaceElevated     → lifted panel (Figma `surface/elevated`)
///   context.colors.info                → informational role (Figma `info/base`)
///   context.colors.foregroundTertiary  → Figma `text/tertiary`
///   context.colors.foregroundLink      → Figma `text/link` (may differ from primary in dark)
///   context.colors.borderSoft / .borderElevated / .borderField / .borderFieldFlat
///   context.colors.borderSubtle / .borderStrong / .borderOrb
/// Legacy names (primary, onSurface, error, outline, …) remain available as
/// aliases so existing components keep working.
///
/// Figma source: collection `01 Colors` (`brand/primary/*` only). Kit is
/// primary-led: no brand secondary token.
class KasyColors extends ThemeExtension<KasyColors> {
  /// Danger/error base (HeroUI danger, light). Kept for the few call sites that
  /// need a const color outside of a theme context.
  static const Color semanticError = Color(0xFFFF383C);

  /// Best on-color (text/icon) to sit on top of a filled [fill]: near-white on
  /// dark or saturated fills, near-black on light ones. Lets a fill change to
  /// any hue while the text on top stays legible — no manual tuning needed.
  ///
  /// Prefers white down to a 3:1 contrast ratio (covers branded mid-tones like
  /// blue, teal, violet, red), then flips to dark — which reproduces HeroUI's
  /// own foreground choices for primary/success/warning/danger.
  static Color onColor(Color fill) {
    final double contrastWithWhite = 1.05 / (fill.computeLuminance() + 0.05);
    return contrastWithWhite >= 3.0
        ? const Color(0xFFFCFCFC)
        : const Color(0xFF18181B);
  }

  // --- Primary (brand identity) ---
  // Only [primary] is stored; foreground, hover and soft variants all derive
  // from it (see getters below), so rebranding the CTA is a one-value edit per
  // mode. Light `#0553B1`, dark `#2563EB` (Figma `brand/primary/base`). Sparse
  // accents (chips, progress, spotlight) also use [primary]. Primary-led: no
  // second brand hue. Zinc fills live under [surfaceSecondary] /
  // [backgroundSecondary] (Figma `surface/secondary`, `background/secondary`).
  final Color primary;

  // --- Default (neutral backbone) ---
  final Color neutral;
  final Color neutralHover;
  final Color neutralForeground;

  // --- Success ---
  final Color success;
  final Color successForeground;
  final Color successHover;
  final Color successSoft;
  final Color successSoftHover;
  final Color successSoftForeground;

  // --- Warning ---
  final Color warning;
  final Color warningForeground;
  final Color warningHover;
  final Color warningSoft;
  final Color warningSoftHover;
  final Color warningSoftForeground;

  // --- Danger ---
  final Color danger;
  final Color dangerForeground;
  final Color dangerHover;
  final Color dangerSoft;
  final Color dangerSoftHover;
  final Color dangerSoftForeground;

  // --- Info (Figma `info/*`) ---
  final Color info;
  final Color infoForeground;
  final Color infoHover;
  final Color infoSoft;
  final Color infoSoftHover;
  final Color infoSoftForeground;

  // --- Foreground (text / icons) ---
  final Color foreground;
  final Color foregroundMuted;
  /// Figma `text/tertiary` (more muted than [foregroundMuted]).
  final Color foregroundTertiary;
  final Color foregroundSegment;
  final Color foregroundOverlay;
  final Color foregroundLink;
  final Color foregroundInverse;

  // --- Background (base canvas) ---
  final Color background;
  final Color backgroundSecondary;
  final Color backgroundTertiary;
  final Color backgroundInverse;

  // --- Surface (containers: cards, panels, modals) ---
  final Color surface;
  final Color surfaceSecondary;
  final Color surfaceTertiary;
  /// Lifted panel fill (Figma `surface/elevated`). Light white; dark zinc/800.
  final Color surfaceElevated;
  final Color surfaceTransparent;

  // --- Form field ---
  final Color fieldBackground;
  final Color fieldBackgroundHover;
  final Color fieldBackgroundFocus;
  final Color fieldPlaceholder;
  final Color fieldForeground;
  final Color fieldBorder;
  final Color fieldBorderHover;

  // --- Separator (dividers, outlines) ---
  final Color separator;
  final Color separatorSecondary;
  final Color separatorTertiary;

  // --- Other (border, overlay, segment, backdrop) ---
  /// Solid chrome (Figma `border/default`).
  final Color border;

  /// Soft outline (Figma `border/soft`). Alpha lives in the token (light/dark),
  /// not at the call site. Overlay panels, social chrome, outlined cards.
  final Color borderSoft;

  /// Elevated card stroke (Figma `border/elevated`). Transparent in dark.
  final Color borderElevated;

  /// TextField primary resting stroke (Figma `border/field`).
  final Color borderField;

  /// TextField flat/auth stroke (Figma `border/field-flat`).
  final Color borderFieldFlat;

  /// Quiet edge (Figma `border/subtle`).
  final Color borderSubtle;

  /// Calm chrome edge with alpha (Figma `border/strong`). Stronger than
  /// [borderSoft], quieter than a solid zinc line.
  final Color borderStrong;

  /// AppBar chrome orb outline (Figma `border/orb`). Quieter than [borderSoft]
  /// — light 14% / dark 17% of chrome.
  final Color borderOrb;

  final Color overlay;
  final Color segment;
  final Color backdrop;

  // --- Premium (paywall visual identity — app-specific, not a HeroUI role) ---
  final Color premiumOverlayMid;
  final Color premiumOverlayDark;
  final Color premiumBannerText;

  const KasyColors({
    required this.primary,
    required this.neutral,
    required this.neutralHover,
    required this.neutralForeground,
    required this.success,
    required this.successForeground,
    required this.successHover,
    required this.successSoft,
    required this.successSoftHover,
    required this.successSoftForeground,
    required this.warning,
    required this.warningForeground,
    required this.warningHover,
    required this.warningSoft,
    required this.warningSoftHover,
    required this.warningSoftForeground,
    required this.danger,
    required this.dangerForeground,
    required this.dangerHover,
    required this.dangerSoft,
    required this.dangerSoftHover,
    required this.dangerSoftForeground,
    required this.info,
    required this.infoForeground,
    required this.infoHover,
    required this.infoSoft,
    required this.infoSoftHover,
    required this.infoSoftForeground,
    required this.foreground,
    required this.foregroundMuted,
    required this.foregroundTertiary,
    required this.foregroundSegment,
    required this.foregroundOverlay,
    required this.foregroundLink,
    required this.foregroundInverse,
    required this.background,
    required this.backgroundSecondary,
    required this.backgroundTertiary,
    required this.backgroundInverse,
    required this.surface,
    required this.surfaceSecondary,
    required this.surfaceTertiary,
    required this.surfaceElevated,
    required this.surfaceTransparent,
    required this.fieldBackground,
    required this.fieldBackgroundHover,
    required this.fieldBackgroundFocus,
    required this.fieldPlaceholder,
    required this.fieldForeground,
    required this.fieldBorder,
    required this.fieldBorderHover,
    required this.separator,
    required this.separatorSecondary,
    required this.separatorTertiary,
    required this.border,
    required this.borderSoft,
    required this.borderElevated,
    required this.borderField,
    required this.borderFieldFlat,
    required this.borderSubtle,
    required this.borderStrong,
    required this.borderOrb,
    required this.overlay,
    required this.segment,
    required this.backdrop,
    required this.premiumOverlayMid,
    required this.premiumOverlayDark,
    required this.premiumBannerText,
  });

  factory KasyColors.light() => const KasyColors(
        // Primary — Figma `primary/base` (Sign In CTA bind). Filled brand only
        // (buttons, focus rings, selected accents). Structural chrome stays zinc.
        primary: Color(0xFF0553B1),
        // Default (neutrals) — zinc backbone, same restraint as HeroUI default.
        neutral: Color(0xFFE4E4E7),
        neutralHover: Color(0xFFD4D4D8),
        neutralForeground: Color(0xFF18181B),
        // Success.
        success: Color(0xFF17C964),
        // White text on the solid success green, matching the HeroUI reference
        // (the brand choice over the darker default).
        successForeground: Color(0xFFFFFFFF),
        successHover: Color(0xFF21B55D),
        successSoft: Color(0x2617C964),
        successSoftHover: Color(0x3317C964),
        // Soft foreground: HeroUI's readable dark tone (not the vivid base).
        successSoftForeground: Color(0xFF2B7744),
        // Warning.
        warning: Color(0xFFF5A524),
        warningForeground: Color(0xFF18181B),
        warningHover: Color(0xFFDC952A),
        warningSoft: Color(0x26F5A524),
        warningSoftHover: Color(0x33DC952A),
        warningSoftForeground: Color(0xFF855F2C),
        // Danger.
        danger: Color(0xFFFF383C),
        dangerForeground: Color(0xFFFCFCFC),
        dangerHover: Color(0xFFFF5551),
        dangerSoft: Color(0x26FF383C),
        dangerSoftHover: Color(0x33FF5551),
        dangerSoftForeground: Color(0xFFA43532),
        // Info — Figma `info/*` (Light).
        info: Color(0xFF027DFD),
        infoForeground: Color(0xFFFCFCFC),
        infoHover: Color(0xFF0269D9),
        infoSoft: Color(0x26027DFD),
        infoSoftHover: Color(0x33027DFD),
        infoSoftForeground: Color(0xFF0553B1),
        // Foreground — zinc text; link aliases Figma `primary/base`.
        foreground: Color(0xFF18181B),
        foregroundMuted: Color(0xFF71717A),
        foregroundTertiary: Color(0xFFA1A1AA),
        foregroundSegment: Color(0xFF18181B),
        foregroundOverlay: Color(0xFF18181B),
        foregroundLink: Color(0xFF0553B1),
        foregroundInverse: Color(0xFFFAFAFA),
        // Background — HeroUI zinc canvas. Also used by native splash: update
        // `flutter_native_splash.color` in pubspec.yaml and run
        // `dart run flutter_native_splash:create` when changing.
        background: Color(0xFFFAFAFA),
        backgroundSecondary: Color(0xFFF4F4F5),
        backgroundTertiary: Color(0xFFE4E4E7),
        backgroundInverse: Color(0xFF18181B),
        // Surface — elevated panels / cards on zinc.
        surface: Color(0xFFFFFFFF),
        surfaceSecondary: Color(0xFFF4F4F5),
        surfaceTertiary: Color(0xFFE4E4E7),
        surfaceElevated: Color(0xFFFFFFFF),
        surfaceTransparent: Color(0x00FFFFFF),
        // Form field.
        fieldBackground: Color(0xFFFFFFFF),
        fieldBackgroundHover: Color(0xEBF4F4F5),
        fieldBackgroundFocus: Color(0xFFFFFFFF),
        fieldPlaceholder: Color(0xFF71717A),
        fieldForeground: Color(0xFF18181B),
        // Transparent at rest; focus ring uses [primary] in the widget.
        fieldBorder: Color(0x00E4E4E7),
        fieldBorderHover: Color(0x00D4D4D8),
        // Separator / border — solid zinc chrome (never primary).
        separator: Color(0xFFE4E4E7),
        separatorSecondary: Color(0xFFD4D4D8),
        separatorTertiary: Color(0xFFA1A1AA),
        border: Color(0xFFDEDEE0),
        // Figma `border/soft` · `elevated` · `field` · `field-flat` (Light).
        // soft @ 0.26 — quiet overlay chrome (Dialog/Menu/Toast/DropDown).
        borderSoft: Color(0x42DEDEE0),
        borderElevated: Color(0x2EDEDEE0),
        // Figma `border/field` (Light): chrome #DEDEE0 @ 0.20 — quiet TextField/DropDown trigger.
        borderField: Color(0x33DEDEE0),
        borderFieldFlat: Color(0x1F18181B),
        borderSubtle: Color(0xFFF4F4F5),
        // Figma `border/strong` (Light): chrome #DEDEE0 @ 0.40.
        borderStrong: Color(0x66DEDEE0),
        // Figma `border/orb` (Light): chrome #DEDEE0 @ 0.14 — AppBar chrome orbs.
        borderOrb: Color(0x24DEDEE0),
        overlay: Color(0xFFFFFFFF),
        segment: Color(0xFFFFFFFF),
        backdrop: Color(0x80000000),
        // Premium (paywall).
        premiumOverlayMid: Color(0xFFA1A1AA),
        premiumOverlayDark: Color(0xFF0A0A0C),
        premiumBannerText: Color(0xFF49250A),
      );

  factory KasyColors.dark() => const KasyColors(
        // Primary — Figma `brand/primary/base` Dark (`#2563EB`).
        primary: Color(0xFF2563EB),
        // Default (neutrals).
        neutral: Color(0xFF27272A),
        neutralHover: Color(0xFF3F3F46),
        neutralForeground: Color(0xFFFAFAFA),
        // Success.
        success: Color(0xFF17C964),
        // White text on the solid success green, matching the HeroUI reference
        // (the brand choice over the darker default).
        successForeground: Color(0xFFFFFFFF),
        successHover: Color(0xFF21B55D),
        successSoft: Color(0x2617C964),
        successSoftHover: Color(0x3317C964),
        // Soft foreground: HeroUI's lighter dark-mode tone (not the vivid base).
        successSoftForeground: Color(0xFF74D88F),
        // Warning (brightened for dark).
        warning: Color(0xFFF7B750),
        warningForeground: Color(0xFF18181B),
        warningHover: Color(0xFFDEA54C),
        warningSoft: Color(0x26F7B750),
        warningSoftHover: Color(0x33DEA54C),
        warningSoftForeground: Color(0xFFF9CB87),
        // Danger (desaturated for dark).
        danger: Color(0xFFDB3B3E),
        dangerForeground: Color(0xFFFCFCFC),
        dangerHover: Color(0xFFE15451),
        dangerSoft: Color(0x26DB3B3E),
        dangerSoftHover: Color(0x33E15451),
        dangerSoftForeground: Color(0xFFEB7872),
        // Info — Figma `info/*` (Dark).
        info: Color(0xFF4BA3FF),
        infoForeground: Color(0xFF0A0A0C),
        infoHover: Color(0xFF6BB5FF),
        infoSoft: Color(0x264BA3FF),
        infoSoftHover: Color(0x334BA3FF),
        infoSoftForeground: Color(0xFFA9CBFF),
        // Foreground — zinc; link is lighter than CTA fill in dark (Figma `text/link`).
        foreground: Color(0xFFFAFAFA),
        foregroundMuted: Color(0xFFA1A1AA),
        foregroundTertiary: Color(0xFF71717A),
        foregroundSegment: Color(0xFFFAFAFA),
        foregroundOverlay: Color(0xFFFAFAFA),
        foregroundLink: Color(0xFF4BA3FF),
        foregroundInverse: Color(0xFF18181B),
        // Background — near-black zinc canvas.
        // Splash: update `flutter_native_splash.color_dark` when changing.
        background: Color(0xFF0A0A0C),
        backgroundSecondary: Color(0xFF18181B),
        backgroundTertiary: Color(0xFF27272A),
        backgroundInverse: Color(0xFFFAFAFA),
        // Surface.
        surface: Color(0xFF18181B),
        surfaceSecondary: Color(0xFF27272A),
        surfaceTertiary: Color(0xFF3F3F46),
        surfaceElevated: Color(0xFF27272A),
        surfaceTransparent: Color(0x00000000),
        // Form field.
        fieldBackground: Color(0xFF18181B),
        fieldBackgroundHover: Color(0xEB27272A),
        fieldBackgroundFocus: Color(0xFF18181B),
        fieldPlaceholder: Color(0xFFA1A1AA),
        fieldForeground: Color(0xFFFAFAFA),
        // Transparent at rest; focus ring uses [primary] in the widget.
        fieldBorder: Color(0x0027272A),
        fieldBorderHover: Color(0x003F3F46),
        // Separator / border — solid zinc chrome (never primary).
        separator: Color(0xFF27272A),
        separatorSecondary: Color(0xFF3F3F46),
        separatorTertiary: Color(0xFF52525B),
        border: Color(0xFF3F3F46),
        // Figma `border/soft` · `elevated` · `field` · `field-flat` (Dark).
        // soft @ 0.22 — quiet overlay chrome on dark (Dialog/Menu/Toast/DropDown).
        borderSoft: Color(0x383F3F46),
        borderElevated: Color(0x003F3F46),
        // Figma `border/field` (Dark): chrome #3F3F46 @ 0.15 — quiet TextField/DropDown trigger.
        borderField: Color(0x263F3F46),
        borderFieldFlat: Color(0x29FAFAFA),
        borderSubtle: Color(0xFF27272A),
        // Figma `border/strong` (Dark): chrome #3F3F46 @ 0.45.
        borderStrong: Color(0x733F3F46),
        // Figma `border/orb` (Dark): chrome #3F3F46 @ 0.17 — AppBar chrome orbs.
        borderOrb: Color(0x2B3F3F46),
        overlay: Color(0xFF18181B),
        segment: Color(0xFF27272A),
        backdrop: Color(0x80000000),
        // Premium (paywall).
        premiumOverlayMid: Color(0xFFA1A1AA),
        premiumOverlayDark: Color(0xFF0A0A0C),
        premiumBannerText: Color(0xFF49250A),
      );

  // -------------------------------------------------------------------------
  // Legacy aliases — keep existing components compiling. Prefer the HeroUI
  // names above for new code.
  // -------------------------------------------------------------------------

  /// Text/icon color on top of [primary] — auto-derived from the primary's
  /// luminance (white on dark/saturated primaries, near-black on light ones),
  /// so changing the primary hue alone always stays legible in both modes.
  Color get primaryForeground => onColor(primary);

  /// Hover state for [primary] — a subtle lift toward white.
  Color get primaryHover =>
      Color.lerp(primary, const Color(0xFFFFFFFF), 0.14)!;

  /// Translucent primary fill (15%) for soft / secondary surfaces.
  Color get primarySoft => primary.withValues(alpha: 0.15);

  /// Hover state for [primarySoft] (20%).
  Color get primarySoftHover => primary.withValues(alpha: 0.20);

  /// Text / icon color on a soft primary fill. Authored to match Figma
  /// `brand/primary/soft-foreground` (light `#042B59`, dark `#93C5FD`). Mode is
  /// detected from [foreground]'s luminance.
  Color get primarySoftForeground => foreground.computeLuminance() < 0.5
      ? const Color(0xFF042B59)
      : const Color(0xFF93C5FD);

  Color get onPrimary => primaryForeground;
  Color get onBackground => foreground;
  Color get onSurface => foreground;
  Color get surfacePrimarySoft => primarySoft;
  Color get surfaceNeutralSoft => neutral;
  Color get surfaceErrorSoft => dangerSoft;
  Color get avatarFallbackFill => surfaceSecondary;
  Color get error => danger;
  Color get onError => dangerForeground;
  Color get onSuccess => successForeground;
  Color get onWarning => warningForeground;
  Color get outline => border;
  Color get outlineButton => border;
  Color get muted => foregroundMuted;
  Color get grey1 => separatorSecondary;
  Color get grey2 => foregroundMuted;
  Color get grey3 => foreground;

  /// Form field labels: slightly stronger than [foregroundMuted].
  Color get fieldLabel {
    final bool isDark = background.computeLuminance() < 0.5;
    return Color.lerp(foregroundMuted, foreground, isDark ? 0.36 : 0.28)!;
  }

  // --- Task priority (kanban cards, priority pickers) ---
  // Readable-by-theme color for a priority level: HeroUI's darker tone in light
  // mode (legible as a label on the soft fill) and the vivid base in dark mode
  // (already high-contrast on dark surfaces). Pass to [KasyStatusTag.color] so the
  // kanban tag matches the table status pill. Low/medium/urgent reuse the
  // success/warning/danger soft-foregrounds; high gets its own orange — no token
  // sits between amber (warning) and red (danger).
  bool get _isDarkTheme => background.computeLuminance() < 0.5;
  Color get priorityLow => _isDarkTheme ? success : successSoftForeground;
  Color get priorityMedium => _isDarkTheme ? warning : warningSoftForeground;
  Color get priorityHigh =>
      _isDarkTheme ? const Color(0xFFFF7A00) : const Color(0xFFBF5400);
  Color get priorityUrgent => _isDarkTheme ? danger : dangerSoftForeground;

  @override
  ThemeExtension<KasyColors> copyWith({
    Color? primary,
    Color? neutral,
    Color? neutralHover,
    Color? neutralForeground,
    Color? success,
    Color? successForeground,
    Color? successHover,
    Color? successSoft,
    Color? successSoftHover,
    Color? successSoftForeground,
    Color? warning,
    Color? warningForeground,
    Color? warningHover,
    Color? warningSoft,
    Color? warningSoftHover,
    Color? warningSoftForeground,
    Color? danger,
    Color? dangerForeground,
    Color? dangerHover,
    Color? dangerSoft,
    Color? dangerSoftHover,
    Color? dangerSoftForeground,
    Color? info,
    Color? infoForeground,
    Color? infoHover,
    Color? infoSoft,
    Color? infoSoftHover,
    Color? infoSoftForeground,
    Color? foreground,
    Color? foregroundMuted,
    Color? foregroundTertiary,
    Color? foregroundSegment,
    Color? foregroundOverlay,
    Color? foregroundLink,
    Color? foregroundInverse,
    Color? background,
    Color? backgroundSecondary,
    Color? backgroundTertiary,
    Color? backgroundInverse,
    Color? surface,
    Color? surfaceSecondary,
    Color? surfaceTertiary,
    Color? surfaceElevated,
    Color? surfaceTransparent,
    Color? fieldBackground,
    Color? fieldBackgroundHover,
    Color? fieldBackgroundFocus,
    Color? fieldPlaceholder,
    Color? fieldForeground,
    Color? fieldBorder,
    Color? fieldBorderHover,
    Color? separator,
    Color? separatorSecondary,
    Color? separatorTertiary,
    Color? border,
    Color? borderSoft,
    Color? borderElevated,
    Color? borderField,
    Color? borderFieldFlat,
    Color? borderSubtle,
    Color? borderStrong,
    Color? borderOrb,
    Color? overlay,
    Color? segment,
    Color? backdrop,
    Color? premiumOverlayMid,
    Color? premiumOverlayDark,
    Color? premiumBannerText,
  }) {
    return KasyColors(
      primary: primary ?? this.primary,
      neutral: neutral ?? this.neutral,
      neutralHover: neutralHover ?? this.neutralHover,
      neutralForeground: neutralForeground ?? this.neutralForeground,
      success: success ?? this.success,
      successForeground: successForeground ?? this.successForeground,
      successHover: successHover ?? this.successHover,
      successSoft: successSoft ?? this.successSoft,
      successSoftHover: successSoftHover ?? this.successSoftHover,
      successSoftForeground:
          successSoftForeground ?? this.successSoftForeground,
      warning: warning ?? this.warning,
      warningForeground: warningForeground ?? this.warningForeground,
      warningHover: warningHover ?? this.warningHover,
      warningSoft: warningSoft ?? this.warningSoft,
      warningSoftHover: warningSoftHover ?? this.warningSoftHover,
      warningSoftForeground:
          warningSoftForeground ?? this.warningSoftForeground,
      danger: danger ?? this.danger,
      dangerForeground: dangerForeground ?? this.dangerForeground,
      dangerHover: dangerHover ?? this.dangerHover,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      dangerSoftHover: dangerSoftHover ?? this.dangerSoftHover,
      dangerSoftForeground: dangerSoftForeground ?? this.dangerSoftForeground,
      info: info ?? this.info,
      infoForeground: infoForeground ?? this.infoForeground,
      infoHover: infoHover ?? this.infoHover,
      infoSoft: infoSoft ?? this.infoSoft,
      infoSoftHover: infoSoftHover ?? this.infoSoftHover,
      infoSoftForeground: infoSoftForeground ?? this.infoSoftForeground,
      foreground: foreground ?? this.foreground,
      foregroundMuted: foregroundMuted ?? this.foregroundMuted,
      foregroundTertiary: foregroundTertiary ?? this.foregroundTertiary,
      foregroundSegment: foregroundSegment ?? this.foregroundSegment,
      foregroundOverlay: foregroundOverlay ?? this.foregroundOverlay,
      foregroundLink: foregroundLink ?? this.foregroundLink,
      foregroundInverse: foregroundInverse ?? this.foregroundInverse,
      background: background ?? this.background,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      backgroundTertiary: backgroundTertiary ?? this.backgroundTertiary,
      backgroundInverse: backgroundInverse ?? this.backgroundInverse,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceTertiary: surfaceTertiary ?? this.surfaceTertiary,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceTransparent: surfaceTransparent ?? this.surfaceTransparent,
      fieldBackground: fieldBackground ?? this.fieldBackground,
      fieldBackgroundHover: fieldBackgroundHover ?? this.fieldBackgroundHover,
      fieldBackgroundFocus: fieldBackgroundFocus ?? this.fieldBackgroundFocus,
      fieldPlaceholder: fieldPlaceholder ?? this.fieldPlaceholder,
      fieldForeground: fieldForeground ?? this.fieldForeground,
      fieldBorder: fieldBorder ?? this.fieldBorder,
      fieldBorderHover: fieldBorderHover ?? this.fieldBorderHover,
      separator: separator ?? this.separator,
      separatorSecondary: separatorSecondary ?? this.separatorSecondary,
      separatorTertiary: separatorTertiary ?? this.separatorTertiary,
      border: border ?? this.border,
      borderSoft: borderSoft ?? this.borderSoft,
      borderElevated: borderElevated ?? this.borderElevated,
      borderField: borderField ?? this.borderField,
      borderFieldFlat: borderFieldFlat ?? this.borderFieldFlat,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      borderOrb: borderOrb ?? this.borderOrb,
      overlay: overlay ?? this.overlay,
      segment: segment ?? this.segment,
      backdrop: backdrop ?? this.backdrop,
      premiumOverlayMid: premiumOverlayMid ?? this.premiumOverlayMid,
      premiumOverlayDark: premiumOverlayDark ?? this.premiumOverlayDark,
      premiumBannerText: premiumBannerText ?? this.premiumBannerText,
    );
  }

  @override
  ThemeExtension<KasyColors> lerp(
    covariant ThemeExtension<KasyColors>? other,
    double t,
  ) {
    if (other == null || other is! KasyColors) return this;

    return KasyColors(
      primary: Color.lerp(primary, other.primary, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      neutralHover: Color.lerp(neutralHover, other.neutralHover, t)!,
      neutralForeground:
          Color.lerp(neutralForeground, other.neutralForeground, t)!,
      success: Color.lerp(success, other.success, t)!,
      successForeground:
          Color.lerp(successForeground, other.successForeground, t)!,
      successHover: Color.lerp(successHover, other.successHover, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      successSoftHover: Color.lerp(successSoftHover, other.successSoftHover, t)!,
      successSoftForeground:
          Color.lerp(successSoftForeground, other.successSoftForeground, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningForeground:
          Color.lerp(warningForeground, other.warningForeground, t)!,
      warningHover: Color.lerp(warningHover, other.warningHover, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      warningSoftHover: Color.lerp(warningSoftHover, other.warningSoftHover, t)!,
      warningSoftForeground:
          Color.lerp(warningSoftForeground, other.warningSoftForeground, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerForeground:
          Color.lerp(dangerForeground, other.dangerForeground, t)!,
      dangerHover: Color.lerp(dangerHover, other.dangerHover, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      dangerSoftHover: Color.lerp(dangerSoftHover, other.dangerSoftHover, t)!,
      dangerSoftForeground:
          Color.lerp(dangerSoftForeground, other.dangerSoftForeground, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoForeground: Color.lerp(infoForeground, other.infoForeground, t)!,
      infoHover: Color.lerp(infoHover, other.infoHover, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      infoSoftHover: Color.lerp(infoSoftHover, other.infoSoftHover, t)!,
      infoSoftForeground:
          Color.lerp(infoSoftForeground, other.infoSoftForeground, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      foregroundMuted: Color.lerp(foregroundMuted, other.foregroundMuted, t)!,
      foregroundTertiary:
          Color.lerp(foregroundTertiary, other.foregroundTertiary, t)!,
      foregroundSegment:
          Color.lerp(foregroundSegment, other.foregroundSegment, t)!,
      foregroundOverlay:
          Color.lerp(foregroundOverlay, other.foregroundOverlay, t)!,
      foregroundLink: Color.lerp(foregroundLink, other.foregroundLink, t)!,
      foregroundInverse:
          Color.lerp(foregroundInverse, other.foregroundInverse, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundSecondary:
          Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      backgroundTertiary:
          Color.lerp(backgroundTertiary, other.backgroundTertiary, t)!,
      backgroundInverse:
          Color.lerp(backgroundInverse, other.backgroundInverse, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary:
          Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      surfaceTertiary: Color.lerp(surfaceTertiary, other.surfaceTertiary, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceTransparent:
          Color.lerp(surfaceTransparent, other.surfaceTransparent, t)!,
      fieldBackground: Color.lerp(fieldBackground, other.fieldBackground, t)!,
      fieldBackgroundHover:
          Color.lerp(fieldBackgroundHover, other.fieldBackgroundHover, t)!,
      fieldBackgroundFocus:
          Color.lerp(fieldBackgroundFocus, other.fieldBackgroundFocus, t)!,
      fieldPlaceholder:
          Color.lerp(fieldPlaceholder, other.fieldPlaceholder, t)!,
      fieldForeground: Color.lerp(fieldForeground, other.fieldForeground, t)!,
      fieldBorder: Color.lerp(fieldBorder, other.fieldBorder, t)!,
      fieldBorderHover:
          Color.lerp(fieldBorderHover, other.fieldBorderHover, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      separatorSecondary:
          Color.lerp(separatorSecondary, other.separatorSecondary, t)!,
      separatorTertiary:
          Color.lerp(separatorTertiary, other.separatorTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSoft: Color.lerp(borderSoft, other.borderSoft, t)!,
      borderElevated: Color.lerp(borderElevated, other.borderElevated, t)!,
      borderField: Color.lerp(borderField, other.borderField, t)!,
      borderFieldFlat: Color.lerp(borderFieldFlat, other.borderFieldFlat, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderOrb: Color.lerp(borderOrb, other.borderOrb, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      segment: Color.lerp(segment, other.segment, t)!,
      backdrop: Color.lerp(backdrop, other.backdrop, t)!,
      premiumOverlayMid:
          Color.lerp(premiumOverlayMid, other.premiumOverlayMid, t)!,
      premiumOverlayDark:
          Color.lerp(premiumOverlayDark, other.premiumOverlayDark, t)!,
      premiumBannerText:
          Color.lerp(premiumBannerText, other.premiumBannerText, t)!,
    );
  }
}
