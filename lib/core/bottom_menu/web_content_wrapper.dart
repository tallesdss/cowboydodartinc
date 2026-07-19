import 'package:cowboydodartinc/components/kasy_app_bar.dart';
import 'package:cowboydodartinc/core/chrome/app_bar_config.dart';
import 'package:cowboydodartinc/core/chrome/app_bar_scope.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/notifications/ui/widgets/web_notifications_bell.dart';
import 'package:flutter/material.dart';

/// Focus target of the currently mounted content, exposed to the "skip to
/// content" link (which lives in the shell, outside the routed page).
///
/// Each [WebContentWrapper] owns its OWN [FocusNode] and publishes it here on
/// mount, so during a route transition (where the old and new page briefly
/// coexist) there is never a single node attached to two widgets. The link
/// always jumps to the most recently mounted page.
FocusNode? kasyContentFocusTarget;

/// On desktop (≥ [DeviceType.large]) this puts the [KasyAppBar.application] at the
/// top of the content area, above the routed page. On phone/tablet it is
/// transparent (returns the page untouched) — there the page keeps its own
/// [KasyAppBar].
///
/// Wrap each routed page with this in the bottom router so the header is present
/// across navigation without touching individual pages.
class WebContentWrapper extends StatefulWidget {
  final Widget child;

  const WebContentWrapper({super.key, required this.child});

  @override
  State<WebContentWrapper> createState() => _WebContentWrapperState();
}

class _WebContentWrapperState extends State<WebContentWrapper> {
  // skipTraversal: a tabindex="-1" style region. The "skip to content" link
  // steps past it to the first real control in the content (see
  // BottomMenu._skipToContent), and normal Tab order skips it too — so it never
  // becomes a focus stop of its own.
  final FocusNode _contentFocus = FocusNode(
    debugLabel: 'skipToContentTarget',
    skipTraversal: true,
  );

  /// Shell-wide default for the desktop application bar: empty search, theme
  /// toggle, the data-aware notifications bell, quick-create, and no avatar (the
  /// sidebar owns the profile). Screens adapt this via [KasyAppBarConfigurator].
  late final KasyAppBarConfig _defaultAppBarConfig = KasyAppBarConfig(
    onToggleTheme: () => ThemeProvider.of(context).toggle(),
    notifications: const WebNotificationsBell(),
    onCreate: () {},
    showAvatar: false,
  );

  /// Live config the bar renders; starts at the default, screens publish into it.
  late final ValueNotifier<KasyAppBarConfig> _appBarConfig =
      ValueNotifier<KasyAppBarConfig>(_defaultAppBarConfig);

  @override
  void initState() {
    super.initState();
    kasyContentFocusTarget = _contentFocus;
  }

  @override
  void dispose() {
    if (kasyContentFocusTarget == _contentFocus) {
      kasyContentFocusTarget = null;
    }
    _contentFocus.dispose();
    _appBarConfig.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = widget.child;
    final bool isDesktop =
        MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;
    if (!isDesktop) return child;

    // Keyboard Tab order across the whole app: sidebar (1, set in BottomMenu) →
    // header (2) → content (3). Each block is its own FocusTraversalGroup so its
    // internal order stays natural (e.g. header: search → theme → … → create).
    //
    // KasyAppBarScope marks this subtree as "has an application bar above", so the
    // page-level KasyAppBar hides on desktop here (the application bar owns the
    // chrome). Outside this scope (full-screen pushed routes) the bar stays visible.
    return KasyAppBarScope(
      config: _appBarConfig,
      defaultConfig: _defaultAppBarConfig,
      child: ColoredBox(
        color: context.colors.background,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // One application bar for the whole shell; each screen tunes it through
          // a KasyAppBarConfigurator that publishes into [_appBarConfig].
          FocusTraversalOrder(
            order: const NumericFocusOrder(2),
            child: FocusTraversalGroup(
              child: ValueListenableBuilder<KasyAppBarConfig>(
                valueListenable: _appBarConfig,
                builder: (context, config, _) =>
                    KasyAppBar.fromConfig(config),
              ),
            ),
          ),
          Expanded(
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(3),
              child: FocusTraversalGroup(
                // Focus target for "skip to content": the link steps past this
                // region straight to the first real control inside it.
                child: Focus(focusNode: _contentFocus, child: child),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
