import 'package:cowboydodartinc/components/kasy_tooltip.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Kasy-styled form label (HeroUI Label) — an accessible label for a form
/// control. Purely presentational: it owns no state or validation, it just
/// renders the [text], an optional required asterisk, and an optional info
/// tooltip trigger.
///
/// It reads the SAME `inputDecorationTheme.labelStyle` that [KasyTextField] uses
/// for its built-in label and mirrors its states ([isInvalid] → error colour,
/// [enabled] false → softened), so a standalone label sitting above a custom
/// control is pixel-identical to the label baked into a text field.
class KasyLabel extends StatelessWidget {
  const KasyLabel(
    this.text, {
    super.key,
    this.required = false,
    this.enabled = true,
    this.isInvalid = false,
    this.tooltip,
    this.color,
  });

  final String text;

  /// Appends a danger-coloured asterisk for mandatory fields.
  final bool required;

  /// Softens the label (matching a disabled field's label) when false.
  final bool enabled;

  /// Paints the label in the error colour, like an invalid field's label.
  final bool isInvalid;

  /// When set, shows an info glyph after the label that reveals this text.
  final String? tooltip;

  /// Explicit colour override. When null the label resolves its colour exactly
  /// as the text-field label does (default / invalid / disabled).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    // Same base style the field's label is built from — single source of truth.
    final TextStyle base =
        Theme.of(context).inputDecorationTheme.labelStyle ??
            context.textTheme.bodyMedium ??
            const TextStyle();

    final Color resolved;
    if (color != null) {
      resolved = color!;
    } else if (isInvalid) {
      resolved = c.error;
    } else {
      final Color baseColor = base.color ?? c.fieldLabel;
      // Disabled: opaque softening toward the surface (alpha 0.55), identical to
      // KasyTextField's dimDisabled for the label.
      resolved = enabled
          ? baseColor
          : Color.alphaBlend(baseColor.withValues(alpha: 0.55), c.surface);
    }

    final TextStyle style = base.copyWith(color: resolved);

    final Widget labelText = Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: text, style: style),
          if (required)
            TextSpan(text: ' *', style: style.copyWith(color: c.error)),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );

    if (tooltip == null) return labelText;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: labelText),
        const SizedBox(width: KasySpacing.xs),
        KasyTooltip(
          message: tooltip!,
          child: Icon(
            KasyIcons.info,
            size: 14,
            color: (style.color ?? c.muted).withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
