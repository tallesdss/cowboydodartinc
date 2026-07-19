import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_scroll_behavior.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/home/admin_components_layout.dart';
import 'package:flutter/material.dart';

/// Desktop top inset below the application bar (same as [adminDesktopShellTopInset]).
const double settingsDrillDownDesktopTopInset =
    KasySpacing.belowChromeContentGap + KasySpacing.lg;

/// Settings drill-down desktop layout — same rhythm as admin component pages.
class SettingsDrillDownLayout extends StatelessWidget {
  final String title;
  final String backLabel;
  final VoidCallback onBack;
  final Widget body;
  final bool scrollBody;
  final Widget? trailing;

  /// Content column cap. Defaults to the internal-screen ruler (~600) so
  /// settings forms (Reminders, Feedback) stay contained on desktop instead of
  /// stretching to the wider components-catalog width.
  final double maxContentWidth;

  const SettingsDrillDownLayout({
    super.key,
    required this.title,
    required this.backLabel,
    required this.onBack,
    required this.body,
    this.scrollBody = true,
    this.trailing,
    this.maxContentWidth = kKasyContentMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    const double gutter = KasySpacing.pageHorizontalGutter;
    final double bottom =
        MediaQuery.paddingOf(context).bottom + KasySpacing.xl;

    Widget widthCap(Widget child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: gutter),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
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
        padding: const EdgeInsets.only(top: settingsDrillDownDesktopTopInset),
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

    // Full-height body (component previews): header fixed, body fills remainder.
    return Padding(
      padding: const EdgeInsets.only(top: settingsDrillDownDesktopTopInset),
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
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
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
