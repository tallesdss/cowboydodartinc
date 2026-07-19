import 'package:cowboydodartinc/components/kasy_app_bar.dart';
import 'package:cowboydodartinc/components/kasy_card.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_brand_logo.dart';
import 'package:cowboydodartinc/core/widgets/page_background.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/authentication/ui/widgets/auth_page_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Auth wordmark box. Figma frame is 132×132 (node 52:61), but the image fill
/// there has padding so the ink reads ~95×45. Our PNGs are tighter, so a 132
/// box paints the glyph ~1.35× larger than Figma. 98 matches the visible size.
const double kAuthBrandLogoBox = 98;

/// Figma social buttons on Sign In: Google/Apple fixed 114, Facebook flex.
const double kAuthSocialButtonWidth = 114;

/// Premium shell shared by the auth screens (sign in / sign up / recover).
///
/// Follows the home design language: a soft, elevated [KasyCard] panel that
/// floats over the page background. The brand logo (same artwork as the splash)
/// sits INSIDE the card, centered, just above the title — it fades in gently.
/// Fully responsive: elevated card centered on tablet/desktop (Figma Desktop);
/// top-aligned and edge‑to‑edge (minus the page gutter) on mobile.
///
/// Layout mirrors Figma Sign In:
/// - **Mobile** (52:59): top inset [KasySpacing.authContentTop] (75),
///   content top-aligned, no card
/// - **Desktop** (276:117): card 420 centered in the viewport (axis CENTER)
/// - Logo 132×132 FIT, gap sm → title → gap xs → subtitle → gap xl
class AuthCardScaffold extends StatelessWidget {
  const AuthCardScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.showLogo = true,
    this.logoBoxSize = kAuthBrandLogoBox,
    this.maxContentWidth = 420,
  });

  /// Headline inside the card.
  final String title;

  /// Supporting line under the headline.
  final String subtitle;

  /// Form body: fields, primary button, prompts, social row, …
  final List<Widget> children;

  /// Show the brand logo above the title.
  final bool showLogo;

  /// Square logo frame (Figma `KasyBrandLogo`). Image FIT inside.
  final double logoBoxSize;

  /// Card width cap on wide screens.
  final double maxContentWidth;

  /// Mobile keeps [KasySpacing.authContentTop]. Desktop matches Figma:
  /// symmetric padding so the elevated card can sit in the true vertical center.
  EdgeInsets _paddingFor(BuildContext context, {required bool isMobile}) {
    if (isMobile) return authFormListPadding(context);
    const double horizontal = KasySpacing.pageHorizontalGutter;
    if (shouldShowAuthBackButton(context)) {
      return EdgeInsets.fromLTRB(
        horizontal,
        kasyAppBarBodyTopOverlap(context),
        horizontal,
        KasySpacing.md,
      );
    }
    // Figma Sign In · Desktop: screen padding 0. Keep a small symmetric
    // vertical gutter so a short viewport can still scroll without clipping.
    return const EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: KasySpacing.md,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // On the mobile breakpoint (small, < 768) the card container is
          // dropped: the form sits directly over the page background,
          // edge‑to‑edge minus the page gutter. The elevated card stays on
          // tablet/desktop (medium and up).
          final DeviceType device =
              DeviceType.fromWidth(constraints.maxWidth);
          final bool isMobile = device == DeviceType.small;
          final EdgeInsets padding = _paddingFor(context, isMobile: isMobile);
          final double minHeight = (constraints.maxHeight - padding.vertical)
              .clamp(0.0, double.infinity);
          final Widget content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLogo) ...[
                // Figma 52:61: frame 132×132, image scaleMode FIT, then gap sm.
                Center(
                  child: KasyBrandLogo(boxSize: logoBoxSize)
                      .animate()
                      .fadeIn(
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOut,
                      ),
                ),
                const SizedBox(height: KasySpacing.sm),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.kasyTextTheme.pageTitle.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
              const SizedBox(height: KasySpacing.xs),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: context.kasyTextTheme.pageSubtitle.copyWith(
                  color: context.colors.muted,
                ),
              ),
              const SizedBox(height: KasySpacing.xl),
              ...children,
            ],
          );
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Align(
                // Mobile: Figma pins under the top inset. Desktop: Figma
                // `Sign In · Desktop` uses primaryAxisAlignItems CENTER.
                alignment:
                    isMobile ? Alignment.topCenter : Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: isMobile
                      ? content
                      : KasyCard(
                          padding: const EdgeInsets.fromLTRB(
                            KasySpacing.lg,
                            KasySpacing.md,
                            KasySpacing.lg,
                            KasySpacing.xl,
                          ),
                          child: content,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
