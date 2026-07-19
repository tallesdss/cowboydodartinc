import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Semantic colour of a [KasyProgressBar] (HeroUI ProgressBar: primary | default
/// | success | warning | danger). [neutral] is HeroUI's "default".
enum KasyProgressBarColor { primary, neutral, success, warning, danger }

/// Size of a [KasyProgressBar] — track thickness (HeroUI sm/md/lg → 4 / 8 / 12).
enum KasyProgressBarSize { sm, md, lg }

extension _ProgressBarSizeX on KasyProgressBarSize {
  double get track => switch (this) {
        KasyProgressBarSize.sm => 4,
        KasyProgressBarSize.md => 8,
        KasyProgressBarSize.lg => 12,
      };
}

/// Kasy-styled linear progress bar (HeroUI ProgressBar).
///
/// **Determinate**: pass [value] in 0..1. **Indeterminate**: leave [value] null
/// — the fill animates back and forth.
///
/// Built on Material's [LinearProgressIndicator] tuned to the Kasy tokens (pill
/// track, neutral background). An optional [label] (left) and [valueLabel]
/// (right, e.g. "60%") sit above the track.
///
/// **Sizes**: sm / md / lg (track 4 / 8 / 12). **Colours**: primary / neutral /
/// success / warning / danger.
class KasyProgressBar extends StatelessWidget {
  const KasyProgressBar({
    super.key,
    this.value,
    this.size = KasyProgressBarSize.md,
    this.variant = KasyProgressBarColor.primary,
    this.color,
    this.trackColor,
    this.label,
    this.valueLabel,
    this.semanticsLabel,
  });

  /// Progress in 0..1. Null → indeterminate.
  final double? value;

  final KasyProgressBarSize size;
  final KasyProgressBarColor variant;

  /// Explicit fill colour. Overrides [variant] when set.
  final Color? color;

  /// Track (background) colour. Defaults to the neutral token.
  final Color? trackColor;

  /// Text on the left of the header (e.g. "Storage").
  final String? label;

  /// Text on the right of the header (e.g. "60%").
  final String? valueLabel;

  final String? semanticsLabel;

  Color _resolveColor(BuildContext context) {
    if (color != null) return color!;
    final KasyColors c = context.colors;
    return switch (variant) {
      KasyProgressBarColor.primary => c.primary,
      KasyProgressBarColor.neutral => c.onSurface,
      KasyProgressBarColor.success => c.success,
      KasyProgressBarColor.warning => c.warning,
      KasyProgressBarColor.danger => c.danger,
    };
  }

  @override
  Widget build(BuildContext context) {
    final double h = size.track;
    final Color fill = _resolveColor(context);
    final TextStyle? headerStyle = context.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
      color: context.colors.onSurface,
    );

    final Widget bar = LinearProgressIndicator(
      value: value,
      minHeight: h,
      color: fill,
      backgroundColor: trackColor ?? context.colors.neutral,
      borderRadius: BorderRadius.circular(h),
    );

    final bool hasHeader = label != null || valueLabel != null;
    final Widget content = hasHeader
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (label != null)
                    Expanded(child: Text(label!, style: headerStyle))
                  else
                    const Spacer(),
                  if (valueLabel != null)
                    Text(valueLabel!, style: headerStyle),
                ],
              ),
              const SizedBox(height: KasySpacing.xs),
              bar,
            ],
          )
        : bar;

    return Semantics(
      label: semanticsLabel ?? label,
      value: value == null ? null : '${(value!.clamp(0.0, 1.0) * 100).round()}%',
      child: content,
    );
  }
}
