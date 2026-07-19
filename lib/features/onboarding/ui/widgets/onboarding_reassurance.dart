import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CheckedReassurance extends StatelessWidget {
  final String text;

  const CheckedReassurance({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        MoveEffect(
          duration: Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          begin: Offset(0, -20),
          end: Offset.zero,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(KasySpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.success.withValues(alpha: 0.05),
          borderRadius: KasyRadius.lgBorderRadius,
          border: Border.all(
            color: context.colors.muted,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.muted,
          ),
        ),
      ),
    );
  }
}
