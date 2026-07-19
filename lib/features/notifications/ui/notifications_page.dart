import 'dart:async';

import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/notification.dart'
    as app;
import 'package:cowboydodartinc/features/notifications/providers/models/notification_list.dart';
import 'package:cowboydodartinc/features/notifications/providers/notifications_provider.dart';
import 'package:cowboydodartinc/features/notifications/ui/components/notification_tile.dart';
import 'package:cowboydodartinc/features/notifications/ui/widgets/empty_notifications.dart';
import 'package:cowboydodartinc/features/notifications/ui/widgets/notification_tile.dart';
import 'package:cowboydodartinc/features/notifications/ui/widgets/push_permission_banner.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _autoReadTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollChange);
    requestReadAll();
  }

  @override
  void dispose() {
    _autoReadTimer?.cancel();
    _scrollController.removeListener(_onScrollChange);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollChange() {
    final direction = _scrollController.position.userScrollDirection;
    final isScrollingDown = direction == ScrollDirection.reverse;
    final isTriggered =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100;

    if (isScrollingDown && isTriggered) {
      ref.read(notificationsProvider.notifier).fetchNextPage();
    }
  }

  void requestReadAll() {
    _autoReadTimer?.cancel();
    _autoReadTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      ref.read(notificationsProvider.notifier).readAll();
    });
  }

  bool _hasAny(AsyncValue<NotificationsList> state) {
    if (!state.hasValue) return false;
    return state.value!.data.isNotEmpty;
  }

  Future<void> _confirmAndDeleteAll(BuildContext context) async {
    final tr = t.notifications;
    bool confirmed = false;
    await showKasyConfirmDialog(
      context,
      title: tr.delete_all_confirm_title,
      message: tr.delete_all_confirm_message,
      cancelLabel: tr.cancel_action,
      confirmLabel: tr.delete_action,
      destructive: true,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(notificationsProvider.notifier).deleteAll();
    if (!context.mounted) return;
    showKasyToast(
      context,
      title: tr.deleted_all,
      tone: KasyToastTone.success,
    );
  }

  Future<void> _deleteOne(BuildContext context, app.Notification n) async {
    final tr = t.notifications;
    await ref.read(notificationsProvider.notifier).delete(n);
    if (!context.mounted) return;
    showKasyToast(
      context,
      title: tr.deleted_one,
      tone: KasyToastTone.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(notificationsProvider);
    final hasAny = _hasAny(notificationsState);

    return KasyOverlayScaffold(
      title: t.notifications.title,
      appBarStyle: KasyAppBarStyle.rootTab,
      // Contain + center the list on desktop so cards never stretch edge-to-edge.
      maxContentWidth: kKasyContentMaxWidth,
      hideAppBarOnScroll: true,
      scrollController: _scrollController,
      trailing: Builder(
        builder: (ctx) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasAny)
              KasyChromeOrbIconButton(
                key: const Key('delete_all_button'),
                icon: KasyIcons.trash,
                iconSize: 18,
                foregroundColor: ctx.colors.onSurface,
                onPressed: () => _confirmAndDeleteAll(ctx),
                tooltip: t.notifications.delete_all,
              ),
            if (hasAny) const SizedBox(width: KasySpacing.xs),
            // Light/dark theme toggle, matching the other root-tab screens.
            KasyChromeOrbIconButton(
              icon: Theme.of(ctx).brightness == Brightness.dark
                  ? KasyIcons.lightMode
                  : KasyIcons.darkMode,
              iconSize: 18,
              foregroundColor: ctx.colors.onSurface,
              onPressed: () => ThemeProvider.of(ctx).toggle(),
              tooltip: Theme.of(ctx).brightness == Brightness.dark
                  ? 'Light mode'
                  : 'Dark mode',
            ),
          ],
        ),
      ),
      onRefresh: () async {
        ref.read(notificationsProvider.notifier).refresh();
        requestReadAll();
      },
      slivers: [
        // Native-only push nudge. Self-hides on web and once granted, and the
        // first time it appears in the "never asked" state it fires the native
        // OS prompt automatically. Sits above the list so it shows even when the
        // welcome notification already fills the screen.
        const SliverToBoxAdapter(
          child: PushPermissionBanner(autoRequest: true),
        ),
        notificationsState.when(
          loading: () => SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return _GroupLabel(label: t.notifications.group_today);
                }
                return const NotificationSkeletonTile();
              },
              childCount: 6,
            ),
          ),
          data: (notificationsList) {
            if (notificationsList.data.isEmpty) {
              return const SliverToBoxAdapter(child: EmptyNotifications());
            }
            final items = _buildGroupedItems(notificationsList.data);
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = items[index];
                  return switch (item) {
                    _HeaderItem(:final label) => _GroupLabel(label: label),
                    _TileItem(:final notification, :final animationIndex) =>
                      KasySwipeAction(
                        key: ValueKey(
                          'notification_${notification.id ?? animationIndex}',
                        ),
                        onDismissed: () => _deleteOne(context, notification),
                        child: NotificationTileComponent(
                          notification: notification,
                          index: animationIndex,
                          onTap: notification.hasDestination
                              ? (n) => ref
                                    .read(notificationsProvider.notifier)
                                    .onTapNotification(n)
                              : null,
                        ),
                      ),
                  };
                },
                childCount: items.length,
              ),
            );
          },
          error: (err, stacktrace) => SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(KasySpacing.xl),
                child: Text(
                  t.notifications.error_fetching,
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<_ListItem> _buildGroupedItems(List<app.Notification> notifications) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    final today = <app.Notification>[];
    final yesterday = <app.Notification>[];
    final older = <app.Notification>[];

    for (final n in notifications) {
      final day = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      if (!day.isBefore(todayStart)) {
        today.add(n);
      } else if (!day.isBefore(yesterdayStart)) {
        yesterday.add(n);
      } else {
        older.add(n);
      }
    }

    final items = <_ListItem>[];
    var animIndex = 0;

    void addGroup(String label, List<app.Notification> group) {
      if (group.isEmpty) return;
      items.add(_HeaderItem(label));
      for (final n in group) {
        items.add(_TileItem(n, animIndex++));
      }
    }

    addGroup(t.notifications.group_today, today);
    addGroup(t.notifications.group_yesterday, yesterday);
    addGroup(t.notifications.group_older, older);

    return items;
  }
}

sealed class _ListItem {}

class _HeaderItem extends _ListItem {
  final String label;
  _HeaderItem(this.label);
}

class _TileItem extends _ListItem {
  final app.Notification notification;
  final int animationIndex;
  _TileItem(this.notification, this.animationIndex);
}

class _GroupLabel extends StatelessWidget {
  final String label;
  const _GroupLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: KasySpacing.xl,
        bottom: KasySpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        // Design-system section-eyebrow role (same as Settings' section labels),
        // instead of a bespoke 11/w700 style.
        style: context.kasyTextTheme.sectionLabel.copyWith(
          color: context.colors.muted,
        ),
      ),
    );
  }
}

