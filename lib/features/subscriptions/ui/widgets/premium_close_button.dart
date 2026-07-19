import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_pressable_depth.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppCloseButtonComponent extends ConsumerWidget {
  final ValueNotifier<bool> showCloseBtn;

  final VoidCallback? onTap;

  const AppCloseButtonComponent({
    super.key,
    required this.showCloseBtn,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: showCloseBtn,
      builder: (context, value, child) {
        if (value) {
          return AppCloseButton(onTap: onTap);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class AppCloseButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? pressOverlayColor;

  const AppCloseButton({
    super.key,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.pressOverlayColor,
  });

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onClose = onTap;
    final scrim = backgroundColor ??
        context.colors.onBackground.withValues(alpha: 0.6);
    final glyph = iconColor ?? context.colors.background;
    final pressOverlay = pressOverlayColor ??
        context.colors.background.withValues(alpha: 0.2);

    // Dark translucent scrim keeps the glyph readable over any hero image.
    final Widget circle = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scrim,
      ),
      child: Center(
        child: Icon(
          KasyIcons.close,
          color: glyph,
          size: KasyIconSize.lg,
        ),
      ),
    );

    // Disabled (no handler): render the inert scrim, no interaction.
    if (onClose == null) {
      return circle;
    }

    // KasyPressableDepth gives the kit's press-in depth, a web hover highlight
    // and a keyboard focus ring (no Material ripple), plus a 44x44 tap target
    // around the 32px visual. A light veil lifts the dark scrim on hover/press.
    final BorderRadius pill = BorderRadius.circular(999);
    return KasyPressableDepth(
      onPressed: onClose,
      semanticLabel: t.common.close,
      focusable: true,
      clipBorderRadius: pill,
      focusBorderRadius: pill,
      pressOverlayColor: pressOverlay,
      child: circle,
    );
  }
}
