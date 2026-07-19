import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

class FeatureLine extends StatelessWidget {
  final String? text;
  final String title;
  final bool crossed;
  final double topPadding;
  final IconData? icon;

  const FeatureLine({
    super.key,
    required this.title,
    this.text,
    this.icon,
    this.crossed = false,
    this.topPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon,
              color: context.colors.onBackground,
              size: KasyIconSize.sm,
            ),
          if (icon != null)
            const SizedBox(width: KasySpacing.smd),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colors.onBackground,
                      decoration: crossed ? TextDecoration.lineThrough : null,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (text != null)
                  Flexible(
                    child: Text(
                      text!,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onBackground.withValues(alpha: .6),
                        decoration: crossed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class FeatureWithTwoLines extends StatelessWidget {
  final String? text;
  final String title;
  final bool crossed;
  final double topPadding;
  final IconData? icon;

  const FeatureWithTwoLines({
    super.key,
    required this.title,
    this.text,
    this.icon,
    this.crossed = false,
    this.topPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              color: context.colors.onBackground,
              size: KasyIconSize.xl,
            ),
          const SizedBox(width: KasySpacing.smd),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colors.onBackground,
                      decoration: crossed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (text != null)
                  Flexible(
                    child: Text(
                      text!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onBackground.withValues(alpha: .6),
                        decoration: crossed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
