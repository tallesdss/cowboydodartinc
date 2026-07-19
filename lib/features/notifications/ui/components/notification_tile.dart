import 'package:cowboydodartinc/components/kasy_card.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/notification.dart'
    as app;
import 'package:cowboydodartinc/features/notifications/ui/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationTileComponent extends StatelessWidget {
  final app.Notification notification;
  final OnTapNotification? onTap;
  final int index;

  const NotificationTileComponent({
    super.key,
    required this.notification,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 200)),
        MoveEffect(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          begin: Offset(0, 12),
        ),
      ],
      delay: index < 6 ? Duration(milliseconds: 60 * index) : Duration.zero,
      onComplete: (controller) => controller.stop(),
      // Card surface (elevated, radius 16, hairline border + soft shadow) to
      // match the Settings card; the hover/press feedback and keyboard focus
      // ring live inside on the surface, exactly like a Settings row.
      child: KasyCard(
        margin: const EdgeInsets.only(top: KasySpacing.sm),
        borderRadius: KasyRadius.lgBorderRadius,
        padding: EdgeInsets.zero,
        child: KasyHover(
          onTap: () => onTap?.call(notification),
          borderRadius: KasyRadius.lgBorderRadius,
          focusable: true,
          focusGapColor: context.colors.surface,
          padding: const EdgeInsets.symmetric(
            horizontal: KasySpacing.md,
            vertical: KasySpacing.smd,
          ),
          child: NotificationTile.from(
            key: ValueKey('notification_${notification.id}'),
            context,
            notification,
          ),
        ),
      ),
    );
  }
}
