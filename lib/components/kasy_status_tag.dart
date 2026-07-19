import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Accent tone for [KasyStatusTag], resolved against the current theme.
enum KasyStatusTagTone { success, neutral, primary, warning, danger }

/// Compact, content-sized status pill: a soft-tinted rounded badge with an
/// optional leading dot and a colored label. Built for table cells, list rows
/// and detail headers where you want a quiet status indicator (active/inactive,
/// paid/free, visible/hidden, …) — not a loud solid badge.
///
/// It sizes to its content. Inside a tight parent (e.g. a table column wrapped
/// in [Expanded]) wrap it in an [Align] so it doesn't stretch:
///
/// ```dart
/// Expanded(
///   child: Align(
///     alignment: Alignment.centerLeft,
///     child: KasyStatusTag(label: 'Active', tone: KasyStatusTagTone.success),
///   ),
/// )
/// ```
class KasyStatusTag extends StatelessWidget {
  /// The text shown in the pill.
  final String label;

  /// Semantic tone (maps to theme colors). Ignored when [color] is set.
  final KasyStatusTagTone tone;

  /// Overrides the tone's accent color (used for both the dot and the label).
  final Color? color;

  /// Whether to show the small leading status dot.
  final bool showDot;

  const KasyStatusTag({
    super.key,
    required this.label,
    this.tone = KasyStatusTagTone.neutral,
    this.color,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = color ?? _toneColor(context, tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: context.isDark ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(KasyRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // Body xs (12) on the régua — w600 for legibility in the tiny
              // pill. No off-ladder 11.5.
              style: context.textTheme.labelSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _toneColor(BuildContext context, KasyStatusTagTone tone) {
    final c = context.colors;
    return switch (tone) {
      KasyStatusTagTone.success => c.success,
      KasyStatusTagTone.neutral => c.muted,
      KasyStatusTagTone.primary => c.primary,
      KasyStatusTagTone.warning => c.warning,
      KasyStatusTagTone.danger => c.error,
    };
  }
}
