import 'package:cowboydodartinc/core/theme/kasy_text_style.dart';
import 'package:cowboydodartinc/core/theme/type_scale.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kasy Design System — Typography Tokens
///
/// Single product family (Figma `font/display` + `font/body` → **Poppins**).
/// Hierarchy is size + weight, not a second typeface.
///
/// HeroUI roles (heading1…buttonSm) are exposed as static getters and are the
/// canonical styles. The Material slots (displayLarge…labelSmall) map onto
/// those roles so existing `context.textTheme.*` call sites keep working.
///
/// Usage:
///   context.textTheme.bodyMedium       → Body sm (Material slot)
///   context.kasyTextTheme.pageTitle    → Heading 2 Poppins w700
///   context.kasyTextTheme.pageSubtitle → Subtitle Poppins 14 / w400
///   KasyTextTheme.heading1             → Heading 1 (Poppins)
class KasyTextTheme extends ThemeExtension<KasyTextTheme> {
  // -----------------------------------------------------------------------
  // Font family — Poppins (display + body/UI).
  // -----------------------------------------------------------------------

  static TextStyle _poppins(
    FontWeight weight,
    double size,
    double lineHeight, {
    TextDecoration? decoration,
  }) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        height: lineHeight / size,
        letterSpacing: 0,
        decoration: decoration,
      );

  static TextStyle _fromRamp(
    FontWeight weight,
    RampSize ramp,
    DeviceType device, {
    TextDecoration? decoration,
  }) =>
      _poppins(
        weight,
        ramp.size(device),
        ramp.lineHeight(device),
        decoration: decoration,
      );

  // -----------------------------------------------------------------------
  // HeroUI roles — canonical styles (color applied per-theme downstream)
  // -----------------------------------------------------------------------
  static TextStyle get heading1 => _poppins(FontWeight.w800, 36, 40);
  static TextStyle get heading2 => _poppins(FontWeight.w700, 24, 32);
  static TextStyle get heading3 => _poppins(FontWeight.w600, 20, 28);
  static TextStyle get heading4 => _poppins(FontWeight.w600, 16, 24);
  static TextStyle get bodyBase => _poppins(FontWeight.w400, 16, 24);
  static TextStyle get bodyBaseMedium => _poppins(FontWeight.w500, 16, 24);
  static TextStyle get bodySm => _poppins(FontWeight.w400, 14, 20);
  static TextStyle get bodySmMedium => _poppins(FontWeight.w500, 14, 20);
  static TextStyle get bodyXs => _poppins(FontWeight.w400, 12, 16);
  static TextStyle get bodyXsMedium => _poppins(FontWeight.w500, 12, 16);
  static TextStyle get linkBase =>
      _poppins(FontWeight.w500, 16, 24, decoration: TextDecoration.underline);
  static TextStyle get linkSm =>
      _poppins(FontWeight.w500, 14, 20, decoration: TextDecoration.underline);
  /// Figma `font-size/text-field`: Regular 16 / 24 (matches [KasyTextField]).
  static TextStyle get textFieldBase => _poppins(FontWeight.w400, 16, 24);
  static TextStyle get textFieldSm => _poppins(FontWeight.w400, 14, 20);
  static TextStyle get buttonBase => _poppins(FontWeight.w500, 16, 24);
  static TextStyle get buttonSm => _poppins(FontWeight.w500, 14, 20);

  // -----------------------------------------------------------------------
  // Display — large hero text (Poppins)
  // -----------------------------------------------------------------------
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;

  // -----------------------------------------------------------------------
  // Headline — section headings (Heading 1–3)
  // -----------------------------------------------------------------------
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;

  // -----------------------------------------------------------------------
  // Title — card titles, dialog headers, navigation labels
  // -----------------------------------------------------------------------
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;

  // -----------------------------------------------------------------------
  // Body — paragraph text, list content
  // -----------------------------------------------------------------------
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;

  // -----------------------------------------------------------------------
  // Label — buttons, tags, chips, captions
  // -----------------------------------------------------------------------
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  /// Supporting line under a page title (auth, onboarding). Figma `kasy/Subtitle`.
  final TextStyle subtitle;

  // Legacy — kept for backward compatibility
  final TextStyle primary;

  const KasyTextTheme({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.subtitle,
    required this.primary,
  });

  /// Top-level page title (auth, paywall, full-screen flows). Heading 2 —
  /// 18 mobile / 21 tablet / 24 desktop, w700, tracking -1% (Figma
  /// `font-size/heading-2`).
  TextStyle get pageTitle => headlineMedium;

  /// Supporting line under [pageTitle] (auth subtitle, onboarding lead).
  /// 14 / w400 / lh 20. Lighter than the title; Figma Sign In supporting line.
  TextStyle get pageSubtitle => subtitle;

  /// Section or master-detail pane title (Settings detail, grouped areas).
  /// 16 / w600 (Heading 4) — the step above content rows comes from the
  /// weight, not a larger size.
  TextStyle get sectionTitle => titleMedium;

  /// Small header above a grouped list (e.g. "PREFERENCES"). 12 / w600, lightly tracked.
  TextStyle get sectionLabel =>
      bodySmall.withWeight(FontWeight.w600).copyWith(letterSpacing: 0.5);

  /// Primary text of a DENSE navigation / list row — sidebar, tabs, admin
  /// tables. 14 / w500. For full-width CONTENT rows (Settings, a messaging /
  /// conversation inbox) use [listRowTitle] (16) instead.
  TextStyle get rowTitle => titleSmall;

  /// Secondary / value text in a dense row (apply a muted colour at the call
  /// site). 14 / w400.
  TextStyle get rowValue => bodyMedium;

  /// EMPHASIS text of a CONTENT list row — the row's label/title (Settings, and
  /// other iOS-style lists where each row is primary content). 16 / w500. Pairs
  /// with [listRowValue] (14) so the label clearly outranks its value.
  TextStyle get listRowTitle =>
      bodyLarge.withWeight(FontWeight.w500);

  /// INFO text of a content list row — the value beside the label (apply a muted
  /// colour at the call site). 14 / w400, deliberately one step below
  /// [listRowTitle] so label vs value reads as a hierarchy, not a flat pair.
  TextStyle get listRowValue => bodyMedium;

  /// Card title. 14 / w500.
  TextStyle get cardTitle => titleSmall;

  /// Card subtitle / supporting line. 12 / w400.
  TextStyle get cardSubtitle => bodySmall;

  /// Caption, hint, version label, footnote. 12 / w400.
  TextStyle get caption => bodySmall;

  /// Builds the full text theme for a given [device].
  ///
  /// All roles use Poppins. Display + Heading 1–2 keep display tracking.
  /// Defaults to desktop ([DeviceType.large]); [ResponsiveTextTheme]
  /// rebuilds it per breakpoint below the MediaQuery.
  factory KasyTextTheme.build([DeviceType device = DeviceType.large]) {
    return KasyTextTheme(
      // Display — hero text. Tracking -2.2% matches Figma display styles.
      displayLarge: _fromRamp(
        FontWeight.w800,
        KasyTypeScale.displayLarge,
        device,
      ).copyWith(
        letterSpacing: KasyTypeScale.displayLarge.size(device) * -0.022,
      ),
      displayMedium: _fromRamp(
        FontWeight.w800,
        KasyTypeScale.displayMedium,
        device,
      ).copyWith(
        letterSpacing: KasyTypeScale.displayMedium.size(device) * -0.022,
      ),
      displaySmall: _fromRamp(
        FontWeight.w800,
        KasyTypeScale.heading1,
        device,
      ).copyWith(
        letterSpacing: KasyTypeScale.heading1.size(device) * -0.01,
      ),

      // Headline → Heading 1–2 (tracking -1%), Heading 3.
      headlineLarge: _fromRamp(
        FontWeight.w800,
        KasyTypeScale.heading1,
        device,
      ).copyWith(
        letterSpacing: KasyTypeScale.heading1.size(device) * -0.01,
      ),
      headlineMedium: _fromRamp(
        FontWeight.w700,
        KasyTypeScale.heading2,
        device,
      ).copyWith(
        letterSpacing: KasyTypeScale.heading2.size(device) * -0.01,
      ),
      headlineSmall:
          _fromRamp(FontWeight.w600, KasyTypeScale.heading3, device),

      // Title → Heading 3 / Heading 4 / Body sm (dense title 14, w500).
      titleLarge:
          _fromRamp(FontWeight.w600, KasyTypeScale.heading3, device),
      titleMedium:
          _fromRamp(FontWeight.w600, KasyTypeScale.heading4, device),
      titleSmall:
          _fromRamp(FontWeight.w500, KasyTypeScale.bodySm, device),

      // Body → Body base (16) / Body sm (14) / Body xs (12).
      bodyLarge:
          _fromRamp(FontWeight.w400, KasyTypeScale.bodyBase, device),
      bodyMedium:
          _fromRamp(FontWeight.w400, KasyTypeScale.bodySm, device),
      bodySmall:
          _fromRamp(FontWeight.w400, KasyTypeScale.bodyXs, device),

      // Label → Body sm (14, w500) / Body xs (12, w500).
      labelLarge:
          _fromRamp(FontWeight.w500, KasyTypeScale.bodySm, device),
      labelMedium:
          _fromRamp(FontWeight.w500, KasyTypeScale.bodyXs, device),
      labelSmall:
          _fromRamp(FontWeight.w500, KasyTypeScale.bodyXs, device),

      // Subtitle → page supporting line (14 / w400).
      subtitle:
          _fromRamp(FontWeight.w400, KasyTypeScale.subtitle, device),

      // Legacy primary.
      primary: _fromRamp(FontWeight.w400, KasyTypeScale.bodyBase, device),
    );
  }

  @override
  ThemeExtension<KasyTextTheme> copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
    TextStyle? subtitle,
    TextStyle? primary,
  }) {
    return KasyTextTheme(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
      subtitle: subtitle ?? this.subtitle,
      primary: primary ?? this.primary,
    );
  }

  @override
  ThemeExtension<KasyTextTheme> lerp(
    covariant ThemeExtension<KasyTextTheme>? other,
    double t,
  ) {
    if (other is! KasyTextTheme) return this;
    return KasyTextTheme(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      subtitle: TextStyle.lerp(subtitle, other.subtitle, t)!,
      primary: TextStyle.lerp(primary, other.primary, t)!,
    );
  }
}
