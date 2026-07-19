import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Visual weight of a [KasySeparator] (HeroUI Separator). [primary] is the
/// lightest hairline; [secondary] and [tertiary] are progressively stronger.
enum KasySeparatorVariant { primary, secondary, tertiary }

/// Axis a [KasySeparator] is drawn along.
enum KasySeparatorOrientation { horizontal, vertical }

/// Kasy-styled divider (HeroUI Separator) — a hairline that visually divides
/// content, with an optional centred [label] (e.g. "OR").
///
/// **Variants**: primary / secondary / tertiary (increasing weight).
/// **Orientation**: horizontal (default) or vertical. A vertical separator must
/// be given a bounded height by its parent (or set [length]).
class KasySeparator extends StatelessWidget {
  const KasySeparator({
    super.key,
    this.variant = KasySeparatorVariant.primary,
    this.orientation = KasySeparatorOrientation.horizontal,
    this.label,
    this.thickness = 1,
    this.length,
  });

  final KasySeparatorVariant variant;
  final KasySeparatorOrientation orientation;

  /// Optional centred label (vertical or horizontal).
  final String? label;

  /// Line thickness in logical px (HeroUI hairline = 1).
  final double thickness;

  /// Fixed extent along the axis (width if horizontal, height if vertical).
  /// When null the separator stretches to fill its parent.
  final double? length;

  Color _lineColor(BuildContext context) {
    final KasyColors c = context.colors;
    // Exact HeroUI tokens: primary #E4E4E7, secondary #D7D7D7, tertiary #CDCDCE
    // (with their dark-theme pairs). Each step is a distinct, progressively
    // stronger grey — never derived from onSurface, which washed them out.
    return switch (variant) {
      KasySeparatorVariant.primary => c.separator,
      KasySeparatorVariant.secondary => c.separatorSecondary,
      KasySeparatorVariant.tertiary => c.separatorTertiary,
    };
  }

  bool get _isHorizontal =>
      orientation == KasySeparatorOrientation.horizontal;

  /// Fallback extent for a vertical rule when its parent gives an unbounded
  /// height (and no [length] is set), so it never collapses to nothing.
  static const double _kVerticalFallback = 24;

  @override
  Widget build(BuildContext context) {
    final Color color = _lineColor(context);
    // HeroUI "Body xs medium": Inter Medium 12 / line-height 16, muted.
    final Widget? text = label == null
        ? null
        : Text(
            label!,
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w500,
              color: context.colors.muted,
            ),
          );

    if (_isHorizontal) {
      final Widget line =
          SizedBox(height: thickness, child: ColoredBox(color: color));
      if (text == null) {
        return SizedBox(width: length, child: line);
      }
      return SizedBox(
        width: length,
        child: Row(
          children: [
            Expanded(child: line),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: KasySpacing.smd),
              child: text,
            ),
            Expanded(child: line),
          ],
        ),
      );
    }

    // Vertical: resolve a concrete height so the rule fills its parent (like a
    // VerticalDivider) instead of collapsing to zero under the loose
    // constraints a Row hands its children.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double height = length ??
            (constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : _kVerticalFallback);
        final Widget line =
            SizedBox(width: thickness, child: ColoredBox(color: color));
        if (text == null) {
          return SizedBox(
            width: thickness,
            height: height,
            child: ColoredBox(color: color),
          );
        }
        return SizedBox(
          height: height,
          child: Column(
            children: [
              Expanded(child: line),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: KasySpacing.sm),
                child: text,
              ),
              Expanded(child: line),
            ],
          ),
        );
      },
    );
  }
}
