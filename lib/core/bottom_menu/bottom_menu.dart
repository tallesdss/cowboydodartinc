import 'package:bart/bart.dart' as bart;
import 'package:cowboydodartinc/components/kasy_sidebar.dart';
import 'package:cowboydodartinc/core/bottom_menu/active_tab_notifier.dart';
import 'package:cowboydodartinc/core/bottom_menu/bart_inner_navigation.dart';
import 'package:cowboydodartinc/core/bottom_menu/bottom_router.dart';
import 'package:cowboydodartinc/core/bottom_menu/kasy_bottom_bar_factory.dart';
import 'package:cowboydodartinc/core/bottom_menu/sidebar_focus.dart';
import 'package:cowboydodartinc/core/bottom_menu/web_url.dart';
import 'package:cowboydodartinc/core/chrome/chrome_visibility.dart';
import 'package:cowboydodartinc/core/chrome/sidebar_expansion_scope.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/navigation/dev_route_memory.dart';
import 'package:cowboydodartinc/core/states/logout_action.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/notifications/providers/unread_notifications_count_provider.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/kasy_user_avatar.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Records the active tab so it survives the next remount. Wired to
/// [bart.BartScaffold.onRouteChanged]. See [activeTabRouteNotifier].
void _rememberActiveTab(bart.BartMenuRoute route) {
  activeTabRouteNotifier.value = route.path;
  // A fresh tab always starts with the chrome shown (it may have been hidden by
  // scrolling on the previous tab).
  KasyChromeVisibility.instance.resetShown();
  // Home is the app root: GoRouter serves it at '/', but Bart writes the bare
  // tab path ('/home') like every other tab. Normalize so Home always reads as
  // '/' — matching the post-login URL and the real GoRouter route (reload-safe)
  // — instead of leaving two URLs for the same screen.
  final bool isHome = route.path == subRoutes().first.path;
  if (isHome) {
    syncBrowserUrl('/');
  }
  // Keep the debug route-resume in step with the active tab. Bart tab changes
  // bypass GoRouter, so without this DevRouteMemory would hold the last GoRouter
  // location (e.g. a stale /settings from a deep link) and a web reload would
  // jump there instead of staying on the tab you're on.
  //
  // We store the very location Bart writes to the address bar, so the resume and
  // the URL always agree. A tab that has its own GoRouter route (e.g. /settings)
  // resumes straight onto it; one that only lives inside the '/' shell falls
  // through GoRouter's onException to home — exactly like opening that URL
  // directly would. So adding a new tab needs no bookkeeping here.
  DevRouteMemory.save(isHome ? '/' : '/${route.path}');
}

/// Bottom navigation host powered by Bart (https://pub.dev/packages/bart).
///
/// [ResponsiveLayout] swaps between three [bart.BartScaffold]s (small / medium /
/// large) based on width. The bottom bar shows on every tab; detail screens
/// (Features, Components, …) are pushed on the root navigator from the pages
/// themselves, so they cover this menu and there's nothing to toggle here.
///
/// Stateful on purpose: Bart's [MenuRouter] re-snaps the highlight to
/// `initialRoute` on every scaffold rebuild. GoRouter tab entry points
/// (`/settings`, …) keep passing that stale entry even after the user switches
/// tabs inside Bart (Admin → back to Settings → Home). After the nested
/// navigator has taken its mount route, we pass the *live* tab from
/// [activeTabRouteNotifier] so rebuilds cannot pin Config while Home is showing.
class BottomMenu extends StatefulWidget {
  final String? initialRoute;

  const BottomMenu({super.key, this.initialRoute});

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  /// Route handed to Bart on the first frame (may be an inner path like
  /// `/settings/feedback`). NestedNavigator only reads this once.
  late String? _navigatorInitialRoute;

  /// After the first frame the nested navigator is mounted; further
  /// `initialRoute` values only affect MenuRouter's highlight snap.
  bool _shellReady = false;

  @override
  void initState() {
    super.initState();
    _applyEntryRoute(widget.initialRoute);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _shellReady = true);
    });
  }

  @override
  void didUpdateWidget(covariant BottomMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRoute == oldWidget.initialRoute) {
      return;
    }
    // GoRouter moved us onto a different shell entry (e.g. `/` → `/settings`).
    // Re-seed so the nested navigator and highlight follow the new route.
    _shellReady = false;
    _applyEntryRoute(widget.initialRoute);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _shellReady = true);
    });
  }

  void _applyEntryRoute(String? route) {
    _navigatorInitialRoute = _resolveMountRoute(route);
    final String? tab = _topLevelBottomTab(_navigatorInitialRoute);
    if (tab != null) {
      rememberActiveTab(tab);
    }
  }

  /// Value passed into [bart.BartScaffold.initialRoute].
  ///
  /// First frame: mount route (so deep links like `/settings/feedback` open).
  /// After that: live tab, so MenuRouter rebuilds cannot re-pin a stale
  /// GoRouter entry over the tab the user already selected.
  String? get _routeForBart {
    if (!_shellReady) {
      return _navigatorInitialRoute;
    }
    final String? live = activeTabRouteNotifier.value;
    if (live != null && _isKnownBottomTab(live)) {
      return _bareTab(live);
    }
    return _navigatorInitialRoute;
  }

  @override
  Widget build(BuildContext context) {
    final String? resolvedInitialRoute = _routeForBart;
    final bool showBottomBarOnStart = _shouldShowBottomBarOnStart(
      resolvedInitialRoute,
    );
    final scaffoldOptions = bart.ScaffoldOptions(
      backgroundColor: context.colors.background,
      // Let tab content scroll behind the floating bar; the page-level scrolls
      // reserve the bar's height via the bottom inset Scaffold injects here.
      extendBody: true,
    );

    // Desktop/tablet sidebar, marked as the FIRST stop in the keyboard Tab
    // order. Together with the header/content orders set in WebContentWrapper
    // and the OrderedTraversalPolicy below, every screen tabs the same way:
    // sidebar → header → content. (Touch/mobile has no Tab, so the `small`
    // layout below is left untouched.)
    //
    // [expansion] is owned by [_SidebarShell] above this scaffold so the page
    // app bar can hide the brand logo while the sidebar is wide.
    bart.CustomSideBarOptions connectedSidebar(ValueNotifier<bool> expansion) =>
        bart.CustomSideBarOptions(
          sideBarBuilder: (routes, onTap, current) => FocusTraversalOrder(
            order: const NumericFocusOrder(1),
            child: KasyFocusableSidebar(
              currentItem: current,
              child: Consumer(
                builder: (context, ref, _) {
                  final User user =
                      ref.watch(userStateNotifierProvider).user;
                  final int unread = ref
                      .watch(unreadNotificationsCountProvider)
                      .value ??
                      0;
                  final (String name, String email) = switch (user) {
                    final AuthenticatedUserData u => (
                      (u.name?.isNotEmpty ?? false)
                          ? u.name!
                          : u.email.split('@').first,
                      u.email,
                    ),
                    _ => (context.t.settings.my_account, ''),
                  };
                  return KasySidebar(
                    routes: routes,
                    onTapItem: onTap,
                    currentItem: current,
                    onLogout: () => confirmLogout(context, ref),
                    profileName: name,
                    profileEmail: email,
                    profileAvatar: const KasyUserAvatar(),
                    notificationsUnread: unread,
                    expansionListenable: expansion,
                  );
                },
              ),
            ),
          ),
        );

    // medium and large are identical here — the sidebar collapses itself by
    // viewport width. The OrderedTraversalPolicy turns the numbered orders
    // (sidebar=1, header=2, content=3) into the actual Tab sequence.
    Widget connectedScaffold() => _SidebarShell(
          builder: (ValueNotifier<bool> expansion) => FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: bart.BartScaffold(
              routesBuilder: subRoutes,
              bottomBar: kasyPaddedSurfaceBottomBar(),
              navigationKey: kasyShellNavigatorKey,
              initialRoute: resolvedInitialRoute,
              showBottomBarOnStart: showBottomBarOnStart,
              scaffoldOptions: scaffoldOptions,
              sideBarOptions: connectedSidebar(expansion),
              onRouteChanged: _rememberActiveTab,
            ),
          ),
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: switch (Theme.brightnessOf(context)) {
        Brightness.dark => SystemUiOverlayStyle.light,
        Brightness.light => SystemUiOverlayStyle.dark,
      },
      child: ResponsiveLayout(
        small: Consumer(
          // The scaffold is passed as `child` so it is built ONCE and reused
          // across rebuilds of this Consumer. Toggling the setting below must
          // NOT rebuild BartScaffold: if it did, Bart's MenuRouter (an
          // InheritedWidget) re-runs its constructor and snaps the highlighted
          // tab back to `initialRoute`. We keep `initialRoute` on the live tab
          // after the first frame (see [_routeForBart]), but skipping the
          // rebuild still avoids pointless MenuRouter churn.
          child: NotificationListener<ScrollUpdateNotification>(
            onNotification: (notification) {
              KasyChromeVisibility.instance.handleScrollUpdate(notification);
              return false; // let the notification keep bubbling
            },
            child: bart.BartScaffold(
              routesBuilder: subRoutes,
              bottomBar: kasyPaddedSurfaceBottomBar(),
              navigationKey: kasyShellNavigatorKey,
              initialRoute: resolvedInitialRoute,
              showBottomBarOnStart: showBottomBarOnStart,
              scaffoldOptions: scaffoldOptions,
              onRouteChanged: _rememberActiveTab,
            ),
          ),
          builder: (context, ref, child) {
            // Watching the provider here keeps the persisted on/off setting in
            // sync with the controller (the notifier writes the effective value
            // into KasyChromeVisibility.instance.enabled), and scopes it to the
            // mobile shell only. Returning the cached `child` keeps the scaffold
            // out of this rebuild.
            ref.watch(hideChromeOnScrollProvider);
            return child!;
          },
        ),
        medium: connectedScaffold(),
        large: connectedScaffold(),
      ),
    );
  }

  /// Mount-time resolution only (GoRouter prop → force-home → remembered tab →
  /// web URL). Used once when the shell opens; afterwards [_routeForBart]
  /// prefers the live tab.
  String? _resolveMountRoute(String? route) {
    if (route != null) {
      return _normalizeBartInitialRoute(route);
    }
    // A fresh login forced Home: ignore the remembered tab AND the (possibly
    // stale) web URL for this one mount, so signing in never reopens whatever
    // the previous session left behind. Reload (F5) and the responsive remount
    // don't set this flag, so they keep restoring the tab below.
    if (consumeForceHomeOnNextMount()) {
      return null;
    }
    // Restore the last tab across a remount. This is the reliable source: the
    // browser URL is contended by both GoRouter and Bart, but this notifier is
    // owned solely by the bottom bar and lives above the rebuilt subtree.
    //
    // The value is returned as a BARE tab name (e.g. "settings", not
    // "/settings"). Bart's NestedNavigator matches routes by their exact path,
    // which has no leading slash; passing a "/"-prefixed route makes Flutter's
    // Navigator split it into segments that never match, so it falls back to the
    // first tab (home). See bart's nested_navigator.dart onGenerateRoute.
    final String? lastTab = activeTabRouteNotifier.value;
    if (lastTab != null && _isKnownBottomTab(lastTab)) {
      return _bareTab(lastTab);
    }
    if (!kIsWeb) {
      return null;
    }
    final path = _initialWebPath(Uri.base);
    final segments = Uri.parse(path).pathSegments;
    if (segments.isEmpty) {
      return null;
    }
    // A single segment is a bottom-bar tab (home/notifications/settings/…).
    // Bart keeps the browser URL in sync via history.pushState, so honoring it
    // here also restores the tab on a hard reload (F5). Only accept it when it
    // maps to a real tab; anything else falls back to the default tab.
    if (segments.length == 1) {
      return _isKnownBottomTab(segments.first) ? _bareTab(segments.first) : null;
    }
    return '/${segments.join('/')}';
  }

  String _bareTab(String path) => path.replaceAll('/', '');

  bool _isKnownBottomTab(String path) {
    final String tab = _bareTab(path);
    return subRoutes().any(
      (bart.BartMenuRoute r) =>
          r.type == bart.BartMenuRouteType.bottomNavigation &&
          _bareTab(r.path) == tab,
    );
  }

  /// Bottom-bar tab id for a mount route (`settings` from `settings` or from
  /// `/settings/feedback`). Null when the route is not under a known tab.
  String? _topLevelBottomTab(String? route) {
    if (route == null) {
      return null;
    }
    final String normalized = _normalizeBartInitialRoute(route);
    final List<String> segments = Uri.parse(
      normalized.startsWith('/') ? normalized : '/$normalized',
    ).pathSegments;
    if (segments.isEmpty) {
      return null;
    }
    final String tab = segments.first;
    return _isKnownBottomTab(tab) ? tab : null;
  }

  String _initialWebPath(Uri uri) {
    final path = uri.path;
    if (path != '/' && path.isNotEmpty) {
      return path;
    }
    final fragment = uri.fragment;
    if (fragment.isNotEmpty) {
      final cleanFragment = fragment.startsWith('!/')
          ? fragment.substring(1)
          : fragment;
      final fragmentPath = cleanFragment.startsWith('/')
          ? cleanFragment
          : '/$cleanFragment';
      return Uri.parse(fragmentPath).path;
    }
    return path;
  }

  bool _shouldShowBottomBarOnStart(String? route) {
    if (route == null) {
      return true;
    }
    final segments = Uri.parse(route).pathSegments;
    return segments.length < 2;
  }

  /// Bart tab ids are bare (`settings`); inner routes keep their registered path
  /// (`/settings/reminder`). A leading slash on a single segment makes Flutter's
  /// Navigator split the name and fall back to the first tab (Home).
  String _normalizeBartInitialRoute(String route) {
    final List<String> segments = Uri.parse(route).pathSegments;
    if (segments.length == 1) {
      return segments.first;
    }
    return route.startsWith('/') ? route : '/$route';
  }
}

/// Owns the sidebar expansion [ValueNotifier] for tablet/desktop shells and
/// publishes it via [KasySidebarExpansionScope] so routed pages (Home app bar)
/// can hide the brand logo while the sidebar is wide.
class _SidebarShell extends StatefulWidget {
  final Widget Function(ValueNotifier<bool> expansion) builder;

  const _SidebarShell({required this.builder});

  @override
  State<_SidebarShell> createState() => _SidebarShellState();
}

class _SidebarShellState extends State<_SidebarShell> {
  late final ValueNotifier<bool> _expansion = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _expansion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KasySidebarExpansionScope(
      notifier: _expansion,
      child: widget.builder(_expansion),
    );
  }
}
