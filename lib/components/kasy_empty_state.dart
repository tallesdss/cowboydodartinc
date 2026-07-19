import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Centered empty-list pattern used across the kit (notifications, admin lists,
/// feedback, etc.).
///
/// Visual contract (matches [EmptyNotifications]):
/// - 80 circle with primary at 10% alpha
/// - icon at [KasyIconSize.display], primary at 60% alpha
/// - title (titleMedium, w600) + optional muted subtitle
/// - optional action below
///
/// Prefer this over one-off gray bubbles or bare muted text. Inline empties
/// inside a column (e.g. Kanban "no tasks in this column") stay text-only on
/// purpose: those are slot placeholders, not screen-level empty states.
class KasyEmptyState extends StatelessWidget {
  const KasyEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.padding = const EdgeInsets.symmetric(horizontal: KasySpacing.md),
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  static const double _bubbleSize = 80;

  @override
  Widget build(BuildContext context) {
    final String? sub = subtitle?.trim();
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _bubbleSize,
            height: _bubbleSize,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: KasyIconSize.display,
              color: context.colors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: KasySpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (sub != null && sub.isNotEmpty) ...[
            const SizedBox(height: KasySpacing.xs),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.muted,
                height: 1.4,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: KasySpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}
