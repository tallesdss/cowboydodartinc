import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Visual tone for the action revealed behind a [KasySwipeAction].
enum KasySwipeActionTone {
  /// Destructive action (delete, remove). Red background, white icon.
  destructive,

  /// Neutral action (archive, snooze). Surface tint, on-surface icon.
  neutral,
}

/// Direction in which the user must swipe to reveal the action.
enum KasySwipeActionDirection {
  /// Swipe from right to left (common for delete on mobile lists).
  endToStart,

  /// Swipe from left to right.
  startToEnd,

  /// Both directions allowed.
  both,
}

/// Wraps any [child] so the user can swipe it horizontally to trigger an
/// action — most commonly a delete. Visual chrome and dismiss threshold come
/// from the design system; the parent only supplies the action callback.
///
/// ```dart
/// KasySwipeAction(
///   key: ValueKey(item.id),
///   onDismissed: () => repository.delete(item),
///   child: NotificationTile(notification: item),
/// );
/// ```
///
/// For a confirmation step (e.g. asking before deleting), supply
/// [confirmDismiss] returning `true` to proceed. Returning `false` (or
/// awaiting a dialog that returns `false`) snaps the card back into place.
class KasySwipeAction extends StatelessWidget {
  final Widget child;
  final VoidCallback onDismissed;
  final KasySwipeActionTone tone;
  final KasySwipeActionDirection direction;
  final IconData icon;
  final String? label;

  /// Optional confirmation hook. Return `true` to dismiss, `false` to cancel.
  final Future<bool> Function()? confirmDismiss;

  const KasySwipeAction({
    required Key super.key,
    required this.child,
    required this.onDismissed,
    this.tone = KasySwipeActionTone.destructive,
    this.direction = KasySwipeActionDirection.endToStart,
    this.icon = KasyIcons.trash,
    this.label,
  }) : confirmDismiss = null;

  const KasySwipeAction.withConfirm({
    required Key super.key,
    required this.child,
    required this.onDismissed,
    required Future<bool> Function() confirm,
    this.tone = KasySwipeActionTone.destructive,
    this.direction = KasySwipeActionDirection.endToStart,
    this.icon = KasyIcons.trash,
    this.label,
  }) : confirmDismiss = confirm;

  DismissDirection _flutterDirection() {
    switch (direction) {
      case KasySwipeActionDirection.endToStart:
        return DismissDirection.endToStart;
      case KasySwipeActionDirection.startToEnd:
        return DismissDirection.startToEnd;
      case KasySwipeActionDirection.both:
        return DismissDirection.horizontal;
    }
  }

  Color _backgroundColor(BuildContext context) {
    switch (tone) {
      case KasySwipeActionTone.destructive:
        return context.colors.error;
      case KasySwipeActionTone.neutral:
        return context.colors.surfaceNeutralSoft;
    }
  }

  Color _foregroundColor(BuildContext context) {
    switch (tone) {
      case KasySwipeActionTone.destructive:
        return context.colors.onError;
      case KasySwipeActionTone.neutral:
        return context.colors.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = _backgroundColor(context);
    final Color fg = _foregroundColor(context);
    final DismissDirection flutterDirection = _flutterDirection();

    Widget buildBackground(Alignment alignment) {
      final children = <Widget>[
        Icon(icon, color: fg),
        if (label != null) ...[
          const SizedBox(width: KasySpacing.sm),
          Text(
            label!,
            style: context.textTheme.labelLarge?.copyWith(color: fg),
          ),
        ],
      ];
      return Container(
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: KasySpacing.lg),
        color: bg,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: alignment == Alignment.centerRight
              ? children
              : children.reversed.toList(),
        ),
      );
    }

    return Dismissible(
      key: key!,
      direction: flutterDirection,
      confirmDismiss: confirmDismiss == null
          ? null
          : (_) => confirmDismiss!.call(),
      onDismissed: (_) => onDismissed(),
      background: buildBackground(Alignment.centerLeft),
      secondaryBackground: buildBackground(Alignment.centerRight),
      child: child,
    );
  }
}
