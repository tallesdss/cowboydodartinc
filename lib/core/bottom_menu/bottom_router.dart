import 'package:bart/bart.dart';
import 'package:cowboydodartinc/core/bottom_menu/bart_inner_navigation.dart';
import 'package:cowboydodartinc/core/bottom_menu/web_content_wrapper.dart';
import 'package:cowboydodartinc/core/config/features.dart';
import 'package:cowboydodartinc/core/navigation/kasy_navigation_config.dart';
import 'package:cowboydodartinc/core/navigation/kasy_route_transition.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/feedbacks/ui/feedback_page.dart';
import 'package:cowboydodartinc/features/local_reminders/ui/reminder_page.dart';
import 'package:cowboydodartinc/features/settings/settings_page.dart';
import 'package:cowboydodartinc/features/library/ui/explore_page.dart';
import 'package:cowboydodartinc/features/library/ui/library_page.dart';
import 'package:cowboydodartinc/features/library/ui/profiles_page.dart';
import 'package:cowboydodartinc/features/library/ui/my_profile_page.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Bart tab routes (bottom bar). Detail screens reachable from a tab — Features,
/// Components, Design System, component previews — are NOT inner routes here:
/// they're pushed on the ROOT navigator (see home_page.dart / home_components_page.dart)
/// so they open full-screen without the bottom bar and return to the tab intact.
List<BartMenuRoute> subRoutes() {
  return [
    BartMenuRoute.bottomBar(
      label: t.library.title,
      icon: Icons.menu_book,
      path: 'home',
      pageBuilder: (_, _, settings) =>
          const WebContentWrapper(child: LibraryPage()),
      transitionDuration: bottomBarTransitionDuration,
      transitionsBuilder: bottomBarTransition,
    ),
    BartMenuRoute.bottomBar(
      label: t.library.explore,
      icon: Icons.explore,
      path: 'explore',
      pageBuilder: (_, _, settings) =>
          const WebContentWrapper(child: ExplorePage()),
      transitionDuration: bottomBarTransitionDuration,
      transitionsBuilder: bottomBarTransition,
    ),
    BartMenuRoute.bottomBar(
      label: t.library.public_profile,
      icon: Icons.people,
      path: 'library/profiles',
      pageBuilder: (_, _, settings) =>
          const WebContentWrapper(child: ProfilesPage()),
      transitionDuration: bottomBarTransitionDuration,
      transitionsBuilder: bottomBarTransition,
    ),
    BartMenuRoute.bottomBar(
      label: t.library.my_pdfs,
      icon: Icons.account_circle,
      path: 'library/my-profile',
      pageBuilder: (_, _, settings) =>
          const WebContentWrapper(child: MyProfilePage()),
      transitionDuration: bottomBarTransitionDuration,
      transitionsBuilder: bottomBarTransition,
    ),
    BartMenuRoute.bottomBar(
      label: t.navigation.settings,
      icon: KasyIcons.settings,
      path: 'settings',
      pageBuilder: (_, _, settings) =>
          const WebContentWrapper(child: SettingsPage()),
      transitionDuration: bottomBarTransitionDuration,
      transitionsBuilder: bottomBarTransition,
    ),
    // Settings sub-pages (Reminders, Feedback). These are NOT bottom-bar tabs:
    // as inner routes they render inside the nested navigator, so on desktop the
    // sidebar stays put and only the content area swaps (the Stripe pattern), and
    // on phone they open full-screen with the bar hidden (showBottomBar: false).
    // Wrapped in WebContentWrapper so the desktop application bar is present; the
    // page's own breadcrumb (backLabel) gives the title + "back to Settings".
    if (withLocalReminders)
      BartMenuRoute.innerRoute(
        path: settingsInnerPath('reminder'),
        showBottomBar: false,
        pageBuilder: (_, _, settings) => BartInnerRouteUrlSync(
          urlPath: settingsInnerPath('reminder'),
          parentTabPath: '/$kSettingsTabId',
          child: const WebContentWrapper(child: ReminderPage()),
        ),
        transitionDuration: bottomBarTransitionDuration,
        transitionsBuilder: bottomBarTransition,
      ),
    if (withFeedback)
      BartMenuRoute.innerRoute(
        path: settingsInnerPath('feedback'),
        showBottomBar: false,
        pageBuilder: (_, _, settings) => BartInnerRouteUrlSync(
          urlPath: settingsInnerPath('feedback'),
          parentTabPath: '/$kSettingsTabId',
          child: const WebContentWrapper(child: FeedbackPage()),
        ),
        transitionDuration: bottomBarTransitionDuration,
        transitionsBuilder: bottomBarTransition,
      ),
  ];
}

Widget bottomBarTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return kasyBuildRouteTransition(
    context: context,
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    child: child,
    kind: KasyNavigationConfig.bottomTab,
    fillColor: Colors.transparent,
  );
}

Duration get bottomBarTransitionDuration => KasyNavigationConfig.duration;
