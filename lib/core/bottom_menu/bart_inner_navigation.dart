import 'package:bart/bart/bart_bottombar_actions.dart';
import 'package:bart/bart/bart_model.dart';
import 'package:bart/bart/router_delegate.dart';
import 'package:cowboydodartinc/core/bottom_menu/active_tab_notifier.dart';
import 'package:cowboydodartinc/core/bottom_menu/bart_inner_paths.dart';
import 'package:cowboydodartinc/core/bottom_menu/web_url.dart';
import 'package:cowboydodartinc/core/navigation/dev_route_memory.dart';
import 'package:cowboydodartinc/router.dart' show navigatorKey;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

/// Settings tab id in [subRoutes] (`path: 'settings'`).
const String kSettingsTabId = 'settings';

/// Shell tab to restore after closing a drill-down opened from notifications.
const String kNotificationsShellReturnPath = '/notifications';

/// Nested navigator inside [BottomMenu]. Used to push settings drill-downs from
/// notification taps without remounting the shell via GoRouter.
final GlobalKey<NavigatorState> kasyShellNavigatorKey =
    GlobalKey<NavigatorState>();

/// When a settings inner screen is opened from outside Settings (e.g. the
/// notifications list), back should return here instead of Settings.
final ValueNotifier<String?> settingsInnerReturnPathNotifier =
    ValueNotifier<String?>(null);

/// Number of inner-route pops we already restored eagerly (in
/// [popSettingsInnerRoute] / [popShellInnerRoutesIfAny]) whose
/// [BartInnerRouteUrlSync.dispose] has not fired yet.
///
/// The dispose runs only AFTER the pop transition finishes, so it cannot be
/// bracketed by a synchronous counter around `Navigator.pop()`. Instead each
/// owned pop ARMS one suppression here and the matching dispose CONSUMES it,
/// skipping its own restore. Without this the late dispose runs a second restore
/// with the return path already consumed — defaulting to the parent
/// `/settings` tab and leaving Bart's index stuck on Settings (the tab then
/// ignores taps because its index already looks current).
int _settingsInnerPopSyncSuppressions = 0;

/// Invalidates stale post-frame URL / chrome callbacks.
int _browserUrlGeneration = 0;

/// Invalidates stale chrome re-assertions after a newer navigation starts.
int _shellChromeGeneration = 0;

/// Inner route currently on top of the shell navigator, if any.
String? _visibleSettingsInnerPath;

bool isSettingsInnerRouteVisible(String segment) =>
    _visibleSettingsInnerPath == settingsInnerPath(segment);

String settingsInnerPath(String segment) =>
    bartInnerPath(kSettingsTabId, segment);

void setSettingsInnerReturnPath(String path) {
  settingsInnerReturnPathNotifier.value = path;
}

String? peekSettingsInnerReturnPath() =>
    settingsInnerReturnPathNotifier.value;

String? consumeSettingsInnerReturnPath() {
  final String? path = settingsInnerReturnPathNotifier.value;
  settingsInnerReturnPathNotifier.value = null;
  return path;
}

bool _isForeignInnerReturnPath(String shellPath) =>
    shellPath != '/$kSettingsTabId';

/// Bart tab `path` for a shell GoRouter location (`/`, `/notifications`, …).
String? shellTabPathForRoute(String shellRoute) {
  switch (shellRoute) {
    case '/':
      return 'home';
    case '/notifications':
      return 'notifications';
    case '/settings':
      return kSettingsTabId;
    case '/support':
      return 'support';
    default:
      return null;
  }
}

void _deferBrowserUrl(String path) {
  final int generation = ++_browserUrlGeneration;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (generation != _browserUrlGeneration) {
      return;
    }
    syncBrowserUrl(path);
    DevRouteMemory.save(path);
  });
}

/// Aligns the address bar, remembered tab, sidebar highlight, and bottom bar
/// with [shellPath] after an in-shell navigation change.
void syncShellTabChrome(String shellPath, {MenuRouter? menuRouter}) {
  final String? tabPath = shellTabPathForRoute(shellPath);
  if (tabPath == null) {
    return;
  }
  rememberActiveTab(tabPath);
  _applyShellTabHighlight(menuRouter, tabPath);
  final BuildContext? shellContext = kasyShellNavigatorKey.currentContext;
  if (shellContext != null) {
    Actions.invoke(shellContext, BottomBarIntent.show());
  }
}

/// Bart's [RouteAwareWidget.didPush] schedules a post-frame route update that
/// points the sidebar at Settings for `/settings/*` inner routes. When the
/// drill-down was opened from another tab (e.g. Notifications), re-assert the
/// origin tab chrome on the next frames so Bart cannot win the race.
void _lockOriginTabChromeAfterForeignInnerPush(String originShellPath) {
  if (!_isForeignInnerReturnPath(originShellPath)) {
    return;
  }
  final int generation = ++_shellChromeGeneration;
  void reassert() {
    if (generation != _shellChromeGeneration) {
      return;
    }
    syncShellTabChrome(originShellPath);
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    reassert();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reassert();
      SchedulerBinding.instance.scheduleFrameCallback((_) => reassert());
    });
  });
}

/// Updates Bart's sidebar / bottom-bar highlight without relying on
/// [MenuRouter.updateRoute], which no-ops when the tab index looks unchanged
/// even though an inner route left the chrome on the wrong tab.
void _applyShellTabHighlight(MenuRouter? menuRouter, String tabPath) {
  MenuRouter? router = menuRouter;
  if (router == null) {
    final BuildContext? shellContext = kasyShellNavigatorKey.currentContext;
    if (shellContext == null) {
      return;
    }
    try {
      router = MenuRouter.of(shellContext);
    } catch (_) {
      return;
    }
  }
  final List<BartMenuRoute> routes = router.routesBuilder();
  final String bareTab = tabPath.replaceAll('/', '');
  final int index = routes.indexWhere(
    (BartMenuRoute route) => route.path.replaceAll('/', '') == bareTab,
  );
  if (index < 0) {
    return;
  }
  final BartMenuRoute route = routes[index];
  router.indexNotifier.value = index;
  router.routingTypeNotifier.value = route.type;
  router.onRouteChanged?.call(route);
}

/// Replaces the shell stack top with [tabPath] so Bart's index matches the
/// visible tab after closing a foreign inner route.
void _replaceShellTab(String tabPath) {
  final BuildContext? shellContext = kasyShellNavigatorKey.currentContext;
  if (shellContext == null) {
    return;
  }
  Navigator.of(shellContext).pushReplacementNamed(tabPath);
}

void _restoreShellAfterInnerRouteClosed(
  String restorePath, {
  MenuRouter? menuRouter,
}) {
  // No shell to restore. This is the case when the inner route's dispose fires
  // AFTER the shell itself was torn down — a session boundary (logout / account
  // deletion redirecting to /signin) or a responsive remount. Restoring here
  // would resurrect the tab that [forgetActiveTab] just cleared and, on web,
  // stamp the old tab's URL (e.g. /settings) over the sign-in screen. Just drop
  // the transient inner-route state so nothing leaks into the next session.
  if (kasyShellNavigatorKey.currentContext == null) {
    _visibleSettingsInnerPath = null;
    consumeSettingsInnerReturnPath();
    // Still honour non-shell returns (Admin Debug → Feedback preview → back).
    // Without this, back from a remounted settings shell stranded on /settings
    // with the Home tab body visible.
    if (_isNonShellReturnPath(restorePath)) {
      _goRoot(restorePath);
    }
    return;
  }
  _browserUrlGeneration++;
  _shellChromeGeneration++;
  final String? tabPath = shellTabPathForRoute(restorePath);
  if (tabPath == null) {
    // e.g. /admin/tools/debug: leave the BottomMenu route entirely.
    _visibleSettingsInnerPath = null;
    _goRoot(restorePath);
    return;
  }
  if (_isForeignInnerReturnPath(restorePath)) {
    _replaceShellTab(tabPath);
  }
  syncShellTabChrome(restorePath, menuRouter: menuRouter);
  _deferBrowserUrl(restorePath);
  _lockOriginTabChromeAfterForeignInnerPush(restorePath);
}

bool _isNonShellReturnPath(String path) =>
    path.startsWith('/admin') ||
    path.startsWith('/onboarding') ||
    path.startsWith('/signin');

void _goRoot(String path) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final BuildContext? root = navigatorKey.currentContext;
    if (root != null && root.mounted) {
      root.go(path);
    }
  });
}

/// Pops any settings drill-down sitting on the shell navigator stack.
void popShellInnerRoutesIfAny(BuildContext shellContext) {
  final NavigatorState nav = Navigator.of(shellContext);
  if (!nav.canPop()) {
    return;
  }
  consumeSettingsInnerReturnPath();
  // Arm one suppression per popped route; each inner route's dispose (fired
  // after its pop transition) consumes one and skips its own restore.
  while (nav.canPop()) {
    _settingsInnerPopSyncSuppressions++;
    nav.pop();
  }
  _visibleSettingsInnerPath = null;
}

/// Switches bottom-bar tabs without remounting the shell via GoRouter.
void navigateShellTabInPlace(String shellRoute) {
  final String? tabPath = shellTabPathForRoute(shellRoute);
  if (tabPath == null) {
    return;
  }
  final BuildContext? shellContext = kasyShellNavigatorKey.currentContext;
  if (shellContext == null) {
    return;
  }
  final String urlPath = shellRoute == '/' ? '/' : shellRoute;
  if (activeTabRouteNotifier.value == tabPath &&
      _visibleSettingsInnerPath == null) {
    syncShellTabChrome(urlPath);
    _deferBrowserUrl(urlPath);
    return;
  }
  popShellInnerRoutesIfAny(shellContext);
  rememberActiveTab(tabPath);
  Navigator.of(shellContext).pushReplacementNamed(tabPath);
  syncShellTabChrome(urlPath);
  _deferBrowserUrl(urlPath);
}

/// Opens a settings inner route and keeps the browser URL in sync.
///
/// Bart skips [MenuRouter.handleWebUrl] when the tab index does not change
/// (settings → settings/reminder), and its nested [RouteObserver] is not wired,
/// so `didPopNext` never restores the parent URL on back.
void pushSettingsInnerRoute(
  BuildContext context,
  String segment, {
  String? returnPath,
}) {
  if (returnPath != null) {
    setSettingsInnerReturnPath(returnPath);
  }
  final String path = settingsInnerPath(segment);
  final String? originShellPath = peekSettingsInnerReturnPath();
  _visibleSettingsInnerPath = path;
  Navigator.of(context).pushNamed(path);
  _deferBrowserUrl(path);
  if (originShellPath != null && _isForeignInnerReturnPath(originShellPath)) {
    _lockOriginTabChromeAfterForeignInnerPush(originShellPath);
  }
}

/// Pops a settings inner route and restores the parent URL (settings tab or the
/// [settingsInnerReturnPathNotifier] when the screen was opened from elsewhere).
///
/// Returns the path written to the address bar, or null when nothing was popped.
String? popSettingsInnerRoute(BuildContext context) {
  if (!Navigator.of(context).canPop()) {
    return null;
  }
  final String? returnPath = consumeSettingsInnerReturnPath();
  final String restorePath = returnPath ?? '/$kSettingsTabId';
  MenuRouter? menuRouter;
  try {
    menuRouter = MenuRouter.of(context);
  } catch (_) {
    // Fell through: highlight via shell navigator key after pop.
  }
  // Arm the suppression BEFORE popping: the inner route's dispose fires only
  // after the pop transition finishes (counter already back to 0 if we
  // decremented synchronously), so it must consume the arming itself instead.
  // We restore eagerly below; the late dispose must not run a second restore.
  _settingsInnerPopSyncSuppressions++;
  Navigator.of(context).pop();
  _visibleSettingsInnerPath = null;
  _restoreShellAfterInnerRouteClosed(restorePath, menuRouter: menuRouter);
  return restorePath;
}

/// Restores shell chrome after a standalone route (e.g. /premium) pushed from a
/// notification is closed.
void restoreShellAfterStandaloneRoute() {
  final String? returnPath = consumeSettingsInnerReturnPath();
  if (returnPath == null) {
    return;
  }
  _restoreShellAfterInnerRouteClosed(returnPath);
}

/// Keeps the address bar aligned for Bart inner routes (push + pop).
///
/// Wrap inner-route pages in [bottom_router.dart]. [dispose] restores
/// [parentTabPath] when the user navigates back within the same tab.
class BartInnerRouteUrlSync extends StatefulWidget {
  final String urlPath;
  final String parentTabPath;
  final Widget child;

  const BartInnerRouteUrlSync({
    super.key,
    required this.urlPath,
    required this.parentTabPath,
    required this.child,
  });

  @override
  State<BartInnerRouteUrlSync> createState() => _BartInnerRouteUrlSyncState();
}

class _BartInnerRouteUrlSyncState extends State<BartInnerRouteUrlSync> {
  MenuRouter? _menuRouter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      _menuRouter = MenuRouter.of(context);
    } catch (_) {
      _menuRouter = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _visibleSettingsInnerPath = widget.urlPath;
    _deferBrowserUrl(widget.urlPath);
    final String? originShellPath = peekSettingsInnerReturnPath();
    if (originShellPath != null && _isForeignInnerReturnPath(originShellPath)) {
      _lockOriginTabChromeAfterForeignInnerPush(originShellPath);
    }
  }

  @override
  void dispose() {
    if (_settingsInnerPopSyncSuppressions > 0) {
      // This pop was already restored eagerly (back button → popSettingsInner
      // Route / a tab switch → popShellInnerRoutesIfAny). Consume the arming
      // and skip the restore so it cannot clobber the chrome with the parent
      // tab and strand Bart's index on Settings.
      _settingsInnerPopSyncSuppressions--;
      super.dispose();
      return;
    }
    _visibleSettingsInnerPath = null;
    final String? returnPath = consumeSettingsInnerReturnPath();
    final String restorePath = returnPath ?? widget.parentTabPath;
    _restoreShellAfterInnerRouteClosed(restorePath, menuRouter: _menuRouter);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
