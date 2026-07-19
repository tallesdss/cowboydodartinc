import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';

/// Responsive type scale — explicit font size per role, per breakpoint.
///
/// Single source of truth for typography sizes, and the ONLY place breakpoints
/// touch type. There is no global multiplier and no per-component scaling: every
/// role declares its own size at each breakpoint here, exactly like design-tool
/// modes (Figma variables) or platform text styles. Components only read the
/// resolved theme role (`context.textTheme.*`); they never scale text themselves
/// by width. (The `WebViewportScale` zoom is a separate, web-only UI alignment
/// fix — it scales the whole canvas, not these type sizes.)
///
/// The ladder is harmonious and SEMANTIC — each role one clear step from the
/// next, and each maps to a PURPOSE, not a guessed size:
/// - **Headings & display SCALE with the viewport** (this is where real
///   responsiveness lives): big on desktop, stepping down on mobile so a hero or
///   page title never wraps badly on a phone.
/// - **Body & labels are STABLE across breakpoints** — one comfortable reading
///   size per role, the Material/Apple model. The body ladder uses MARKED 2px
///   steps so hierarchy is actually visible: section/card title 18, content-row
///   title / body 16, secondary / value / nav 14, caption 12. No 1px in-between
///   levels — a 15-vs-16 difference reads as identical, so it isn't a hierarchy.
///   A row's LABEL (16) and its VALUE (14) are deliberately different sizes.
///
/// Line heights mirror Figma Text Styles per breakpoint when [mobileLineHeight]
/// / [tabletLineHeight] / [desktopLineHeight] are set; otherwise
/// `size * lineHeightRatio` is used.
///
/// To re-tune the whole app's typography, edit the numbers here — nothing else.
/// The live ramp is visible under Design System -> Typography (tabs per
/// breakpoint).
class RampSize {
  /// Phone (< 768).
  final double mobile;

  /// Tablet (768-1024).
  final double tablet;

  /// Desktop (>= 1024) — the authored reference.
  final double desktop;

  /// Fallback line-height / font-size when per-breakpoint LHs are omitted.
  final double lineHeightRatio;

  /// Explicit line height (logical px) at mobile, when set.
  final double? mobileLineHeight;

  /// Explicit line height (logical px) at tablet, when set.
  final double? tabletLineHeight;

  /// Explicit line height (logical px) at desktop, when set.
  final double? desktopLineHeight;

  const RampSize({
    required this.mobile,
    required this.tablet,
    required this.desktop,
    required this.lineHeightRatio,
    this.mobileLineHeight,
    this.tabletLineHeight,
    this.desktopLineHeight,
  });

  /// The font size (logical px) for [device].
  double size(DeviceType device) => switch (device) {
        DeviceType.small => mobile,
        DeviceType.medium => tablet,
        DeviceType.large || DeviceType.xlarge => desktop,
      };

  /// The line height (logical px) for [device].
  double lineHeight(DeviceType device) {
    final double? explicit = switch (device) {
      DeviceType.small => mobileLineHeight,
      DeviceType.medium => tabletLineHeight,
      DeviceType.large || DeviceType.xlarge => desktopLineHeight,
    };
    return explicit ?? size(device) * lineHeightRatio;
  }
}

/// The Kasy type scale: every typographic role's size across the 3 breakpoints.
///
/// Sizes and line heights match Figma `01 Tokens · Typography` / Text Styles.
class KasyTypeScale {
  const KasyTypeScale._();

  // Hero / display — Figma Display Large / Medium.
  static const displayLarge = RampSize(
    mobile: 36,
    tablet: 46,
    desktop: 57,
    lineHeightRatio: 64 / 57,
    mobileLineHeight: 40,
    tabletLineHeight: 52,
    desktopLineHeight: 64,
  );
  static const displayMedium = RampSize(
    mobile: 32,
    tablet: 38,
    desktop: 45,
    lineHeightRatio: 52 / 45,
    mobileLineHeight: 37,
    tabletLineHeight: 44,
    desktopLineHeight: 52,
  );

  // Headings — Figma Heading 1–4 (Poppins).
  static const heading1 = RampSize(
    mobile: 28,
    tablet: 32,
    desktop: 36,
    lineHeightRatio: 40 / 36,
    mobileLineHeight: 31,
    tabletLineHeight: 36,
    desktopLineHeight: 40,
  );
  // Page titles (auth, paywall). Steps mirror heading1's relative scale so
  // Small → Medium → Large read as different sizes on canvas (22/23/24 and
  // even 20/22/24 looked nearly identical for "Bem-vindo de volta").
  static const heading2 = RampSize(
    mobile: 18,
    tablet: 21,
    desktop: 24,
    lineHeightRatio: 32 / 24,
    mobileLineHeight: 26,
    tabletLineHeight: 28,
    desktopLineHeight: 32,
  );
  static const heading3 = RampSize(
    mobile: 20,
    tablet: 20,
    desktop: 20,
    lineHeightRatio: 28 / 20,
    mobileLineHeight: 28,
    tabletLineHeight: 28,
    desktopLineHeight: 28,
  );
  // Section / card title — 16 / 24 (HeroUI Heading 4 = text-base, w600).
  static const heading4 = RampSize(
    mobile: 16,
    tablet: 16,
    desktop: 16,
    lineHeightRatio: 24 / 16,
    mobileLineHeight: 24,
    tabletLineHeight: 24,
    desktopLineHeight: 24,
  );

  // Supporting line under a page title (auth, onboarding). Figma Sign In
  // reference (52:59): Body sm size, Regular (w400). 14 / lh 20. Stable across
  // breakpoints. (Was 18/28; felt oversized under pageTitle.)
  static const subtitle = RampSize(
    mobile: 14,
    tablet: 14,
    desktop: 14,
    lineHeightRatio: 20 / 14,
    mobileLineHeight: 20,
    tabletLineHeight: 20,
    desktopLineHeight: 20,
  );

  // Body & labels — STABLE, with MARKED 2px steps so hierarchy is visible.
  static const bodyBase = RampSize(
    mobile: 16,
    tablet: 16,
    desktop: 16,
    lineHeightRatio: 24 / 16,
    mobileLineHeight: 24,
    tabletLineHeight: 24,
    desktopLineHeight: 24,
  );
  static const bodySm = RampSize(
    mobile: 14,
    tablet: 14,
    desktop: 14,
    lineHeightRatio: 20 / 14,
    mobileLineHeight: 20,
    tabletLineHeight: 20,
    desktopLineHeight: 20,
  );
  static const bodyXs = RampSize(
    mobile: 12,
    tablet: 12,
    desktop: 12,
    lineHeightRatio: 16 / 12,
    mobileLineHeight: 16,
    tabletLineHeight: 16,
    desktopLineHeight: 16,
  );
}
