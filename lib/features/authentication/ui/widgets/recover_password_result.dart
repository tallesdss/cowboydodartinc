import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_brand_badge.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Success state after a reset link is sent. Mirrors the auth card language:
/// a centered, width‑capped column topped by a success badge.
class RecoverPasswordSent extends StatelessWidget {
  const RecoverPasswordSent({super.key});

  @override
  Widget build(BuildContext context) {
    final KasyColors colors = context.colors;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: KasySpacing.pageHorizontalGutter,
            vertical: KasySpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KasyBrandBadge(
                  icon: KasyIcons.checkCircle,
                  size: 72,
                  glyphSize: KasyIconSize.display,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.success,
                      Color.lerp(colors.success, Colors.black, 0.18)!,
                    ],
                  ),
                ),
                const SizedBox(height: KasySpacing.lg),
                Text(
                  t.recover_password_result.title,
                  textAlign: TextAlign.center,
                  style: context.kasyTextTheme.pageTitle.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: KasySpacing.smd),
                Text(
                  t.recover_password_result.description,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: colors.muted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: KasySpacing.xl),
                KasyButton(
                  label: t.recover_password_result.back_to_signin,
                  expand: true,
                  onPressed: () => context.pop(),
                ),
                const SizedBox(height: KasySpacing.lg),
                Text(
                  t.recover_password_result.note,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
