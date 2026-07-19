import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/bottom_menu/bart_inner_navigation.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_scroll_behavior.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/settings_drill_down_layout.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:cowboydodartinc/router.dart' show navigatorKey;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared chrome for settings drill-downs (Reminders, Send feedback, …).
///
/// Desktop: admin-style drill-down (left breadcrumb, 44px top) with the content
/// contained to the internal-screen ruler (~600, [kKasyContentMaxWidth]) so
/// settings forms read the same width as on mobile, not the wide catalog width.
/// Phone/tablet: floating page bar via [KasyOverlayScaffold].
class SettingsSubpageScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? trailing;
  final bool scrollBody;

  const SettingsSubpageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.trailing,
    this.scrollBody = true,
  });

  static void popToSettingsOrHome(BuildContext context) {
    final NavigatorState nav = Navigator.of(context);
    if (nav.canPop()) {
      // Pop only: the tab underneath is already visible. Never call GoRouter
      // here — the context belongs to the route being torn down and a go() would
      // remount the whole shell (crash on the next open).
      popSettingsInnerRoute(context);
      return;
    }
    final String? returnPath = consumeSettingsInnerReturnPath();
    final String destination = returnPath ?? '/$kSettingsTabId';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? root = navigatorKey.currentContext;
      if (root != null && root.mounted) {
        root.go(destination);
      }
    });
  }

  static String backLabelFor(BuildContext context) {
    final String? returnPath = peekSettingsInnerReturnPath();
    final translations = Translations.of(context);
    if (returnPath != null && returnPath.startsWith('/admin')) {
      if (returnPath.contains('/debug')) {
        return translations.admin_console.tabs.debug;
      }
      return translations.admin_console.tabs.tools;
    }
    if (returnPath == '/notifications') {
      return translations.navigation.notifications;
    }
    if (returnPath == '/') {
      return translations.navigation.home;
    }
    if (returnPath == '/support') {
      return translations.navigation.support;
    }
    return translations.settings.title;
  }

  @override
  Widget build(BuildContext context) {
    final String backLabel = backLabelFor(context);
    final bool desktopDrillDown =
        MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint &&
            KasyAppBarScope.of(context);
    if (desktopDrillDown) {
      return SettingsDrillDownLayout(
        title: title,
        backLabel: backLabel,
        onBack: () => popToSettingsOrHome(context),
        trailing: trailing,
        scrollBody: scrollBody,
        body: body,
      );
    }

    return ScrollConfiguration(
      behavior: const KasyKitScrollBehavior(),
      child: KasyOverlayScaffold(
        title: title,
        appBarStyle: trailing != null
            ? KasyAppBarStyle.subpageActions
            : KasyAppBarStyle.subpage,
        backLabel: backLabel,
        onBack: () => popToSettingsOrHome(context),
        trailing: trailing,
        maxContentWidth: kKasyContentMaxWidth,
        slivers: [
          SliverToBoxAdapter(child: body),
          const SliverToBoxAdapter(child: SizedBox(height: KasySpacing.xl)),
        ],
      ),
    );
  }
}
