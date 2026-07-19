import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/bottom_menu/bart_inner_navigation.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/notification.dart'
    as app;
import 'package:cowboydodartinc/features/notifications/providers/notifications_provider.dart';
import 'package:cowboydodartinc/features/notifications/providers/unread_notifications_count_provider.dart';
import 'package:cowboydodartinc/features/notifications/ui/widgets/notification_tile.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Desktop web header bell that opens a recent-notifications dropdown anchored
/// below it (Gmail / GitHub pattern). The full list still lives at
/// `/notifications` — the panel's "See all" link goes there.
///
/// Owns its own overlay (OverlayPortal + LayerLink, the same popover technique
/// as [KasySidebar]), so [KasyAppBar.application] stays a pure presentational
/// component and the data wiring lives here.
class WebNotificationsBell extends ConsumerStatefulWidget {
  const WebNotificationsBell({super.key});

  @override
  ConsumerState<WebNotificationsBell> createState() =>
      _WebNotificationsBellState();
}

class _WebNotificationsBellState extends ConsumerState<WebNotificationsBell> {
  /// Max number of recent notifications shown in the panel before "See all".
  static const int _maxPreview = 5;

  /// Width of the dropdown panel.
  static const double _panelWidth = 380;

  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();

  void _toggle() {
    if (_controller.isShowing) {
      _controller.hide();
    } else {
      _controller.show();
    }
  }

  void _openFull() {
    // Close the panel first, then navigate on the next frame. Hiding the
    // OverlayPortal and calling context.go in the same frame remounts the
    // BottomMenu shell while the panel's InheritedWidget dependents are still
    // tearing down → framework.dart "dependent is not a descendant".
    _controller.hide();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Prefer an in-shell tab switch (same path notification deep-links use)
      // so Help → Notifications does not dispose the app bar that owns this
      // OverlayPortal mid-navigation.
      if (kasyShellNavigatorKey.currentContext != null) {
        navigateShellTabInPlace('/notifications');
        return;
      }
      context.go('/notifications');
    });
  }

  void _onTap(app.Notification notification) {
    _controller.hide();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(notificationsProvider.notifier).onTapNotification(notification);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int unread = ref.watch(unreadNotificationsCountProvider).value ?? 0;
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: _buildPanel,
      child: CompositedTransformTarget(
        link: _link,
        child: _bell(context, unread: unread),
      ),
    );
  }

  Widget _bell(BuildContext context, {required int unread}) {
    final Widget button = KasyButton.iconOnly(
      icon: KasyIcons.notification,
      variant: KasyButtonVariant.ghost,
      size: KasyButtonSize.small,
      iconOnlyLayoutExtent: 36,
      iconGlyphSize: KasyIconSize.md,
      onPressed: _toggle,
      semanticLabel: 'Notifications',
    );
    if (unread == 0) return button;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: context.colors.error,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.background, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanel(BuildContext context) {
    // Full-screen barrier so a click anywhere outside the panel dismisses it.
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _controller.hide,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          // Small gap below the bell — the icon button already has internal
          // padding, so 6 reads "attached to the bell" without looking glued.
          offset: const Offset(0, 6),
          child: Align(
            alignment: Alignment.topRight,
            child: _panelCard(context),
          ),
        ),
      ],
    );
  }

  Widget _panelCard(BuildContext context) {
    final KasyColors c = context.colors;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: _panelWidth,
        constraints: const BoxConstraints(maxHeight: 480),
        decoration: BoxDecoration(
          color: c.surface,
          // Overlay panel: Figma `border/soft` (token carries alpha).
          border: Border.all(color: c.borderSoft),
          borderRadius: KasyRadius.lgBorderRadius,
          boxShadow: KasyShadows.overlayPanel(context),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(context),
            Flexible(child: _body(context)),
            Divider(height: 1, thickness: 1, color: c.border),
            _footer(context),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final int unread = ref.watch(unreadNotificationsCountProvider).value ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KasySpacing.md,
        KasySpacing.smd,
        KasySpacing.sm,
        KasySpacing.smd,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              t.notifications.title,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (unread > 0)
            KasyButton(
              label: t.notifications.mark_all_read,
              variant: KasyButtonVariant.ghost,
              size: KasyButtonSize.small,
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).readAll(),
            ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    return state.when(
      loading: () => Column(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(
          3,
          (_) => const NotificationSkeletonTile(),
        ),
      ),
      error: (_, _) => _message(context, t.notifications.error_fetching),
      data: (list) {
        if (list.data.isEmpty) {
          return _message(context, t.notifications.empty_title);
        }
        final items = list.data.take(_maxPreview).toList();
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, thickness: 1, color: context.colors.border),
                _previewTile(context, items[i]),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _previewTile(BuildContext context, app.Notification notification) {
    final Widget tile = NotificationTile.from(context, notification);
    const EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: KasySpacing.md,
      vertical: KasySpacing.smd,
    );
    if (!notification.hasDestination) {
      return Padding(padding: padding, child: tile);
    }
    return KasyHover(
      onTap: () => _onTap(notification),
      padding: padding,
      child: tile,
    );
  }

  Widget _message(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.xl,
      ),
      child: Center(
        child: Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.muted,
          ),
        ),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KasySpacing.sm),
      child: SizedBox(
        width: double.infinity,
        child: KasyButton(
          label: t.notifications.see_all,
          variant: KasyButtonVariant.neutral,
          size: KasyButtonSize.small,
          onPressed: _openFull,
        ),
      ),
    );
  }
}
