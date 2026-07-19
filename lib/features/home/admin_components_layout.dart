import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_scroll_behavior.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/home/components_navigation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Left-aligned breadcrumb + title for admin component drill-downs on
/// tablet/desktop.
///
/// Matches [_KasyDesktopSubpageHeader] typography but uses the admin section
/// column (gutter + [kComponentsCatalogMaxWidth]) instead of centred overlay
/// layout. Desktop top inset comes from [AdminShell]; tablet adds a lighter
/// chrome gap here because the page app bar sits in a [Column] above.
class AdminComponentsDrillDownHeader extends StatelessWidget {
  final String title;
  final String backLabel;
  final VoidCallback onBack;
  final Widget? trailing;

  const AdminComponentsDrillDownHeader({
    super.key,
    required this.title,
    required this.backLabel,
    required this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle? titleRef =
        context.textTheme.headlineSmall ?? context.textTheme.titleLarge;
    final TextStyle? titleStyle = titleRef?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.35,
      color: context.colors.onBackground,
    );

    Widget backLink = Semantics(
      button: true,
      label: backLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onBack,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              KasyIcons.arrowBackIos,
              size: KasyIconSize.sm,
              color: context.colors.primary,
            ),
            const SizedBox(width: KasySpacing.xs),
            Text(
              backLabel,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
    if (kIsWeb) {
      backLink = MouseRegion(cursor: SystemMouseCursors.click, child: backLink);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: KasySpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          backLink,
          const SizedBox(height: KasySpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ],
      ),
    );
  }
}

/// Tablet/desktop admin layout for Design System / component previews: same
/// horizontal rhythm as Overview / Paywalls ([pageHorizontalGutter] + max width
/// column), left-aligned breadcrumb. Desktop top inset via [AdminShell]; tablet
/// uses [KasySpacing.belowChromeContentGap] so the back link clears the page
/// app bar without overshooting.
class AdminComponentsDrillDownLayout extends StatelessWidget {
  final String title;
  final String backLabel;
  final VoidCallback onBack;
  final Widget body;
  final bool scrollBody;
  final Widget? trailing;

  const AdminComponentsDrillDownLayout({
    super.key,
    required this.title,
    required this.backLabel,
    required this.onBack,
    required this.body,
    this.scrollBody = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    const double gutter = KasySpacing.pageHorizontalGutter;
    final double bottom =
        MediaQuery.paddingOf(context).bottom + KasySpacing.xl;
    // Desktop: [AdminShell] already pads below the application bar.
    // Tablet: a lighter chrome gap than desktop — enough to clear the page
    // app bar without floating the back link too far down.
    final double topPad =
        MediaQuery.sizeOf(context).width < DeviceType.large.breakpoint
            ? KasySpacing.belowChromeContentGap
            : 0;

    Widget widthCap(Widget child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: gutter),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: kComponentsCatalogMaxWidth),
            child: child,
          ),
        ),
      );
    }

    final Widget header = AdminComponentsDrillDownHeader(
      title: title,
      backLabel: backLabel,
      onBack: onBack,
      trailing: trailing,
    );

    if (scrollBody) {
      return Padding(
        padding: EdgeInsets.only(top: topPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widthCap(header),
            Expanded(
              child: ScrollConfiguration(
                behavior: const KasyKitScrollBehavior(),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(bottom: bottom),
                  child: widthCap(body),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: topPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widthCap(header),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: gutter),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: kComponentsCatalogMaxWidth,
                  ),
                  child: SizedBox.expand(child: body),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
