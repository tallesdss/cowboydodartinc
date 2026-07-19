import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Outlined social sign-in button (Google / Apple / Facebook …) for the auth
/// screens. It centers the provider's brand glyph in an outlined box, with no
/// background fill — the [KasyHover] overlay supplies the hover/press tint, so
/// it has a real hover highlight on web/desktop and a press fill on every
/// platform (no Material ripple), matching the rest of the kit's controls.
///
/// Two layouts:
/// - icon-only (default): a compact tile that fills its slot in a row of
///   providers (the caller wraps each in an [Expanded]).
/// - with label ([showLabel] true): the glyph sits beside [label], for a
///   full-width "Continue with …" button.
///
/// While a request is in flight pass `onPressed: null`: the button dims and
/// stops responding to pointer and keyboard.
class KasySocialAuthButton extends StatelessWidget {
  const KasySocialAuthButton({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.onPressed,
    this.showLabel = false,
  });

  /// Provider name. Always the accessibility label announced to screen readers;
  /// also shown beside the glyph when [showLabel] is true.
  final String label;

  /// Path to the provider's official brand SVG bundled under `assets/icons/`
  /// (e.g. `assets/icons/google.svg`). Rendered at full brand colour in a shared
  /// [KasyIconSize.lg] box so every provider stays the same size. For Apple, the
  /// caller picks the black/white variant for the current theme.
  final String iconAsset;

  /// Tap handler. When null the button is disabled (dimmed, inert).
  final VoidCallback? onPressed;

  /// When true, shows [label] next to the glyph (full-width button); otherwise
  /// the button is an icon-only tile.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final BorderRadius radius = BorderRadius.circular(KasyRadius.sm);

    final Widget glyph = SvgPicture.asset(
      iconAsset,
      width: KasyIconSize.lg,
      height: KasyIconSize.lg,
    );

    // Brand logos have different aspect ratios (Apple is tall, Google square);
    // SvgPicture defaults to BoxFit.contain, keeping each inside the shared box
    // without distortion so a row of providers stays balanced.
    final Widget content = showLabel
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              glyph,
              const SizedBox(width: KasySpacing.smd),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ],
          )
        : Center(child: glyph);

    // No background fill: the hover overlay sits behind the transparent interior
    // and on the surface auth card a fill would be invisible anyway. The hairline
    // border gives the outlined shape, like KasyButton's outlined variant.
    final Widget surface = Container(
      height: 44,
      padding: showLabel
          ? const EdgeInsets.symmetric(horizontal: KasySpacing.md)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: context.colors.borderSoft,
        ),
      ),
      child: content,
    );

    if (!enabled) {
      return Opacity(opacity: 0.5, child: surface);
    }

    return KasyHover(
      onTap: () {
        KasyHaptics.medium(context);
        onPressed!();
      },
      // KasyHover fires a light selection haptic by default; a social sign-in is
      // a significant action, so opt out and fire the heavier "medium" above.
      hapticEnabled: false,
      focusable: true,
      borderRadius: radius,
      semanticLabel: label,
      child: surface,
    );
  }
}
