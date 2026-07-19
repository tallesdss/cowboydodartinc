import 'package:cowboydodartinc/core/chrome/app_bar_config.dart';
import 'package:flutter/widgets.dart';

/// Transforms the shell's default application-bar config into a screen's version.
/// Receives the shell default (with its wired bell, theme toggle, etc.) so a
/// screen only toggles/overrides what it needs and inherits the rest.
typedef KasyAppBarConfigure = KasyAppBarConfig Function(KasyAppBarConfig base);

/// Marks the subtree that sits BELOW the desktop application bar
/// ([KasyAppBar.application]) — i.e. the shell content area, provided by
/// [WebContentWrapper] — and carries the config the bar renders from.
///
/// Two jobs:
/// 1. Presence ([of]) lets the page-level [KasyAppBar] hide on desktop INSIDE the
///    shell (where the application bar owns the chrome) but stay visible OUTSIDE
///    it (a full-screen pushed route), so the back button is never lost.
/// 2. [config] is the live config the bar listens to; [defaultConfig] is the
///    shell's app-wide default. A [KasyAppBarConfigurator] in the routed page
///    publishes `configure(defaultConfig)` into [config] to override the bar for
///    that screen.
class KasyAppBarScope extends InheritedWidget {
  /// Live config the application bar renders from. The bar listens; screens write.
  final ValueNotifier<KasyAppBarConfig> config;

  /// The shell's app-wide default — the starting point screen overrides build on.
  final KasyAppBarConfig defaultConfig;

  const KasyAppBarScope({
    super.key,
    required this.config,
    required this.defaultConfig,
    required super.child,
  });

  /// True when a [KasyAppBarScope] is an ancestor (no rebuild dependency —
  /// presence is fixed for a given subtree).
  static bool of(BuildContext context) => maybeOf(context) != null;

  /// The nearest scope, or null outside the shell (e.g. full-screen routes).
  static KasyAppBarScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<KasyAppBarScope>();

  @override
  bool updateShouldNotify(KasyAppBarScope oldWidget) =>
      config != oldWidget.config || defaultConfig != oldWidget.defaultConfig;
}

/// Wrap a routed page's body with this to override the desktop application bar
/// for that screen. On phone/tablet (no scope above) it is a transparent
/// pass-through, so it is always safe to add.
///
/// ```dart
/// KasyAppBarConfigurator(
///   configure: (bar) => bar.only(search: true),
///   child: MyScreen(),
/// )
/// ```
class KasyAppBarConfigurator extends StatefulWidget {
  /// How this screen adapts the shell default. Return [base] unchanged to keep
  /// the default, or e.g. `base.only(...)` / `base.copyWith(...)`.
  final KasyAppBarConfigure configure;
  final Widget child;

  const KasyAppBarConfigurator({
    super.key,
    required this.configure,
    required this.child,
  });

  @override
  State<KasyAppBarConfigurator> createState() => _KasyAppBarConfiguratorState();
}

class _KasyAppBarConfiguratorState extends State<KasyAppBarConfigurator> {
  void _publish() {
    if (!mounted) return;
    final KasyAppBarScope? scope = KasyAppBarScope.maybeOf(context);
    if (scope == null) return; // phone/tablet: no application bar to configure.
    // Always build from the ORIGINAL default (not the current value), so the
    // override is stable across rebuilds. The setter is a no-op when the result
    // is unchanged (==), so an inline-built config does not churn the bar.
    //
    // Published post-frame: the bar (a sibling above this page in the shell
    // Column) has already built this frame, so it picks the override up next.
    scope.config.value = widget.configure(scope.defaultConfig);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _publish());
  }

  @override
  void didUpdateWidget(covariant KasyAppBarConfigurator oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _publish());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
