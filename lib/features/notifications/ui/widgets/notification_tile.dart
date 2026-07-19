import 'package:cowboydodartinc/components/kasy_image_viewer.dart';
import 'package:cowboydodartinc/components/kasy_skeleton.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:cowboydodartinc/features/notifications/notifications_ui_constants.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/notification.dart'
    as app;
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

typedef OnTapNotification = void Function(app.Notification notification);

/// A tile for the [NotificationsPage] widget.
///
/// Renders only the row content (icon + title / body / date + unread dot). The
/// card surface (elevated [KasyCard]) and the tap/hover feedback live in
/// [NotificationTileComponent], so a notification reads exactly like a Settings
/// card. Unread vs read is signalled by the trailing dot and text strength, not
/// by a tinted background.
class NotificationTile extends StatelessWidget {
  final double titleOpacity;
  final Color titleColor;
  final Color descriptionColor;
  final Color dateColor;
  final Widget icon;
  final DateTime date;
  final String title;
  final String description;
  final bool showUnreadDot;
  final OnTapNotification? onTap;

  const NotificationTile({
    super.key,
    required this.titleOpacity,
    required this.icon,
    required this.date,
    required this.title,
    required this.description,
    required this.titleColor,
    required this.descriptionColor,
    required this.dateColor,
    this.showUnreadDot = false,
    this.onTap,
  });

  factory NotificationTile.active({
    required DateTime date,
    required String title,
    required String description,
    required BuildContext context,
    String? imageUrl,
    OnTapNotification? onTap,
    Key? key,
  }) => NotificationTile(
    key: key,
    titleOpacity: 1,
    showUnreadDot: true,
    icon: imageUrl != null
        ? TileNotificationImage(url: imageUrl)
        : const TileNotificationIcon(active: true),
    date: date,
    title: title,
    description: description,
    // Unread notifications carry the brand primary on the title so they read
    // as the active, attention-worthy item (the read variant stays muted).
    titleColor: context.colors.primary,
    descriptionColor: context.colors.onSurface,
    dateColor: context.colors.muted,
    onTap: onTap,
  );

  factory NotificationTile.old({
    required DateTime date,
    required String title,
    required String description,
    required BuildContext context,
    String? imageUrl,
    OnTapNotification? onTap,
    Key? key,
  }) => NotificationTile(
    key: key,
    titleOpacity: .6,
    icon: imageUrl != null
        ? TileNotificationImage(url: imageUrl)
        : const TileNotificationIcon(active: false),
    date: date,
    title: title,
    description: description,
    // Read notifications keep a full-strength, bold title (it just loses the
    // primary colour and the unread dot); only the description is muted, so the
    // title still reads as bold instead of washed out.
    titleColor: context.colors.onSurface,
    descriptionColor: context.colors.onSurface.withValues(alpha: 0.45),
    dateColor: context.colors.muted,
    onTap: onTap,
  );

  factory NotificationTile.from(
    BuildContext context,
    app.Notification notification, {
    Key? key,
    OnTapNotification? onTap,
  }) => notification.seen
      ? NotificationTile.old(
          key: key,
          date: notification.createdAt,
          title: notification.title,
          description: notification.body,
          imageUrl: notification.imageUrl,
          context: context,
          onTap: onTap,
        )
      : NotificationTile.active(
          key: key,
          date: notification.createdAt,
          title: notification.title,
          description: notification.body,
          imageUrl: notification.imageUrl,
          context: context,
          onTap: onTap,
        );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: KasySpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Headline row: bold title on the left, timestamp (and the
              // unread dot) pinned to the right — the compact, professional
              // notification layout (Linear / Gmail).
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: context.kasyTextTheme.listRowTitle.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: KasySpacing.sm),
                  Text(
                    Jiffy.parseFromDateTime(date).fromNow(),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: dateColor,
                    ),
                  ),
                  if (showUnreadDot) ...[
                    const SizedBox(width: KasySpacing.sm),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: KasySpacing.xs),
              Text(
                description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: descriptionColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: kNotificationListBodyMaxLines,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A thumbnail image for the [NotificationTile] widget when a notification has an image.
/// Tapping it opens a full-screen viewer.
class TileNotificationImage extends StatelessWidget {
  final String url;

  const TileNotificationImage({super.key, required this.url});

  Object get _heroTag => 'notification-image:$url';

  void _openFullscreen(BuildContext context) {
    KasyHaptics.light(context);
    showKasyImageViewer(
      context,
      imageUrl: url,
      heroTag: _heroTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    return KasyFocusRing(
      onActivate: () => _openFullscreen(context),
      borderRadius: BorderRadius.circular(KasyRadius.sm),
      child: GestureDetector(
        onTap: () => _openFullscreen(context),
        child: Hero(
          tag: _heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(KasyRadius.sm),
            child: Image.network(
              url,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  const TileNotificationIcon(active: false),
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const TileNotificationIcon(active: false),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small rounded-square icon badge for the [NotificationTile] widget.
/// Follows the same visual language as [SettingsIconBadge].
class TileNotificationIcon extends StatelessWidget {
  final bool active;

  const TileNotificationIcon({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active
        ? context.colors.primary
        : context.colors.onSurface.withValues(alpha: 0.35);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: active
            ? context.colors.primary.withValues(alpha: 0.12)
            : context.colors.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(KasyRadius.md),
      ),
      child: Icon(
        active ? KasyIcons.notificationActive : KasyIcons.notification,
        size: KasyIconSize.sm,
        color: color,
      ),
    );
  }
}

/// Skeleton placeholder for [NotificationTile], built from the design-system
/// [KasySkeleton] bones so the loading shimmer matches the kit everywhere and
/// mirrors the real tile's layout (leading badge + title / body / date lines).
class NotificationSkeletonTile extends StatelessWidget {
  const NotificationSkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: KasySpacing.sm),
      child: KasySkeletonGroup(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: KasySpacing.md,
            vertical: KasySpacing.smd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KasySkeleton(
                width: 36,
                height: 36,
                borderRadius: BorderRadius.all(Radius.circular(KasyRadius.md)),
              ),
              SizedBox(width: KasySpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: KasySkeleton(width: 150, height: 13)),
                        SizedBox(width: KasySpacing.sm),
                        KasySkeleton(width: 44, height: 10),
                      ],
                    ),
                    SizedBox(height: KasySpacing.sm),
                    KasySkeleton(width: double.infinity, height: 11),
                    SizedBox(height: KasySpacing.xs),
                    KasySkeleton(width: 210, height: 11),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
