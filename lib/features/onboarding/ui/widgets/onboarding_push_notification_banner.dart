import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// iOS-style push banner for the onboarding notifications showcase — app icon,
/// sent-at, headline and body. In [compact] mode the app name label is omitted
/// (the icon is enough) and everything scales down for the phone mockup.
class OnboardingPushNotificationBanner extends StatelessWidget {
  const OnboardingPushNotificationBanner({
    super.key,
    required this.appName,
    required this.headline,
    required this.body,
    required this.sentAt,
    this.compact = false,
  });

  final String appName;
  final String headline;
  final String body;
  final String sentAt;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final double pad = compact ? 10 : 12;
    final double iconSize = compact ? 32 : 40;
    final double iconGap = compact ? 10 : 10;
    final double radius = compact ? 15 : 18;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: colors.outline.withValues(
            alpha: context.isDark ? 0.45 : 0.6,
          ),
        ),
        boxShadow: [KasyShadows.component(context)],
      ),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppIconBadge(name: appName, size: iconSize),
            SizedBox(width: iconGap),
            Expanded(
              child: compact
                  ? _compactTextBlock(context, colors)
                  : _standardTextBlock(context, colors),
            ),
          ],
        ),
      ),
    );
  }

  /// Icon only — headline + time on one row, body below (no app-name label).
  Widget _compactTextBlock(BuildContext context, KasyColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                headline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.kasyTextTheme.cardTitle
                    .withWeight(FontWeight.w600)
                    .copyWith(
                      color: colors.onSurface,
                      height: 1.2,
                      decoration: TextDecoration.none,
                    ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              sentAt,
              style: context.kasyTextTheme.caption.copyWith(
                color: colors.muted,
                height: 1.2,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.kasyTextTheme.caption.copyWith(
            color: colors.muted,
            height: 1.25,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _standardTextBlock(BuildContext context, KasyColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                appName.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.kasyTextTheme.sectionLabel.copyWith(
                  color: colors.muted,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              sentAt,
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.muted,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          headline,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.kasyTextTheme.listRowTitle
              .withWeight(FontWeight.w600)
              .copyWith(
                color: colors.onSurface,
                decoration: TextDecoration.none,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.kasyTextTheme.cardSubtitle.copyWith(
            color: colors.muted,
            height: 1.3,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _AppIconBadge extends StatelessWidget {
  const _AppIconBadge({required this.name, this.size = 40});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double radius = size * 0.25;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        'assets/branding/app-icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _fallback(context, radius),
      ),
    );
  }

  Widget _fallback(BuildContext context, double radius) {
    final String letter =
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primary,
            context.colors.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.onPrimary,
          fontWeight: FontWeight.w800,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
