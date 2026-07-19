import 'package:cowboydodartinc/components/kasy_card.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// A tappable admin panel card. Uses the design-system [KasyCard] (elevated
/// surface, hairline border, soft shadow) with a compact title / description
/// and a trailing chevron, so admin tools read like the rest of the app
/// instead of a flat tinted block.
class AdminPanelCard extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String description;
  final Color? textColor;
  final Color? backgroundColor;

  const AdminPanelCard({
    super.key,
    required this.onTap,
    required this.title,
    required this.description,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return KasyCard(
      onTap: () {
        KasyHaptics.medium(context);
        onTap();
      },
      color: backgroundColor,
      borderRadius: KasyRadius.lgBorderRadius,
      padding: const EdgeInsets.all(KasySpacing.md),
      semanticLabel: title,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: context.kasyTextTheme.cardTitle.copyWith(
                    color: textColor ?? context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: textColor ?? context.colors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: KasySpacing.sm),
          Icon(
            KasyIcons.arrowForwardIos,
            size: KasyIconSize.xs,
            color: context.colors.muted,
          ),
        ],
      ),
    );
  }
}
