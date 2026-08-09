import 'package:cowboydodartinc/components/kasy_app_bar.dart';
import 'package:cowboydodartinc/core/chrome/app_bar_scope.dart';
import 'package:cowboydodartinc/core/chrome/sidebar_expansion_scope.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/states/components/maybe_ask_rating.dart';
import 'package:cowboydodartinc/core/states/components/maybe_show_update_available.dart';
import 'package:cowboydodartinc/core/states/components/maybe_show_update_bottom_sheet.dart';
import 'package:cowboydodartinc/core/states/components/maybeshow_component.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_brand_logo.dart';
import 'package:cowboydodartinc/features/home/home_feed.dart';
import 'package:cowboydodartinc/features/notifications/shared/att_permission.dart';
import 'package:cowboydodartinc/features/subscriptions/shared/maybeshow_premium.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home hub. Intentionally minimal for now — the Features/Components showcase
/// cards moved into the debug admin console (those are an administrator concern,
/// not the end user's home). A real product home lands here later.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // One brand mark at a time: when the tablet/desktop sidebar is wide it
    // already shows the wordmark, so the page app bar drops its centered logo.
    // Rail (collapsed) or phone (no sidebar) keeps the logo in the app bar.
    final bool sidebarWide = KasySidebarExpansionScope.isExpandedOf(context);

    return ConditionalWidgetsEvents(
      eventWidgets: [
        // A required/optional store update pre-empts every other start-up
        // prompt — if the user is behind, fix that before anything else.
        MaybeShowUpdateAvailable(),
        MaybeAskForReview(),
        MaybeAskForRating(),
        MaybeShowPremiumPage(),
        MaybeShowUpdateBottomSheet(),
        MaybeShowAttPermission(),
      ],
      child: KasyAppBarConfigurator(
        configure: (base) => base.copyWith(
          showSearch: true,
          searchHint: t.search.hint,
          onSearchSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              context.push('/search?q=${Uri.encodeComponent(val)}');
            } else {
              context.push('/search');
            }
          },
        ),
        child: ColoredBox(
          color: context.colors.background,
        child: Stack(
          children: [
            // True overlay: the feed fills the whole height and scrolls UNDER
            // the frosted app bar (the bar's top inset lives inside the feed's
            // scroll, so it scrolls away). This way, when the bar hides on
            // scroll, content already fills the top — no empty app-bar band.
            const Positioned.fill(child: HomeFeed()),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: KasyAppBar(
                title: sidebarWide ? '' : t.home.dashboard.brand,
                titleWidget: sidebarWide
                    ? null
                    : KasyBrandLogo(
                        height: kasyBrandLogoAppBarHeight(context),
                        semanticLabel: t.home.dashboard.brand,
                      ),
                style: KasyAppBarStyle.rootTab,
                hideOnScroll: true,
                trailing: KasyChromeOrbIconButton(
                  icon: Icons.search,
                  iconSize: 20,
                  foregroundColor: context.colors.primary,
                  onPressed: () {
                    context.push('/search');
                  },
                ),
                onThemeToggle: () {
                  KasyHaptics.light(context);
                  ThemeProvider.of(context).toggle();
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
