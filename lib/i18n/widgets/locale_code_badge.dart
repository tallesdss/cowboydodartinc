import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Compact locale indicator (e.g. `EN`, `PT`) — neutral alternative to country flags.
///
/// When [isActive] is true the badge uses a solid primary-color fill with white
/// text, making the currently-selected locale immediately obvious.
class LocaleCodeBadge extends StatelessWidget {
  const LocaleCodeBadge({
    super.key,
    required this.code,
    this.size = 32,
    this.isActive = false,
  });

  final String code;
  final double size;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final KasyColors colors = context.colors;
    final Color bg = isActive
        ? colors.primary
        : colors.primary.withValues(alpha: 0.10);
    final Color fg = isActive ? Colors.white : colors.primary;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(
        code,
        style: context.textTheme.labelSmall?.copyWith(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: fg,
        ),
      ),
    );
  }
}
