import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Kasy-styled field description (HeroUI Description) — muted helper text that
/// sits directly below a form control to explain expected input, constraints or
/// examples. Switch to [KasyFieldError] when the field becomes invalid; never
/// show both at once.
///
/// [KasyTextField] already renders its own description; reach for this when
/// composing a custom field.
class KasyDescription extends StatelessWidget {
  const KasyDescription(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    // HeroUI "Body xs": Inter Regular 12 / 16, muted foreground.
    return Text(
      text,
      style: (context.textTheme.bodySmall ?? const TextStyle()).copyWith(
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        color: context.colors.muted,
      ),
    );
  }
}
