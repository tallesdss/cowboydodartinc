import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Kasy-styled field error message (HeroUI ErrorMessage / FieldError) — the
/// danger-coloured sibling of [KasyDescription], shown below a form control only
/// when its value is invalid. Same layout and typography as the description,
/// differing only in colour.
///
/// [KasyTextField] already renders its own error text; reach for this when
/// composing a custom field.
class KasyFieldError extends StatelessWidget {
  const KasyFieldError(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    // HeroUI "Body xs": Inter Regular 12 / 16, danger colour.
    return Text(
      text,
      style: (context.textTheme.bodySmall ?? const TextStyle()).copyWith(
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        color: context.colors.error,
      ),
    );
  }
}
