import 'package:cowboydodartinc/components/kasy_spinner.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Semantic colour of a [KasyProgressCircle] (HeroUI ProgressCircleColors:
/// primary | default | success | warning | danger). [neutral] is HeroUI's
/// "default" — a foreground-toned arc for informational progress.
enum KasyProgressCircleColor { primary, neutral, success, warning, danger }

/// Size of a [KasyProgressCircle] — the circle diameter (HeroUI sm/md/lg →
/// 20 / 28 / 36, with the stroke scaling 2 / 3 / 4).
enum KasyProgressCircleSize { sm, md, lg }

extension _ProgressCircleSizeX on KasyProgressCircleSize {
  double get diameter => switch (this) {
        KasyProgressCircleSize.sm => 20,
        KasyProgressCircleSize.md => 28,
        KasyProgressCircleSize.lg => 36,
      };

  double get stroke => switch (this) {
        KasyProgressCircleSize.sm => 2,
        KasyProgressCircleSize.md => 3,
        KasyProgressCircleSize.lg => 4,
      };
}

/// Kasy-styled circular progress indicator (HeroUI ProgressCircle).
///
/// **Determinate**: pass [value] in 0..1 — the arc fills clockwise from the top
/// over a neutral track. **Indeterminate**: leave [value] null — a smooth arc
/// spins continuously.
///
/// Built on Material's [CircularProgressIndicator] (rounded cap) tuned to the
/// Kasy tokens. **Sizes**: sm / md / lg (circle 20 / 28 / 36). **Colours**:
/// primary / neutral / success / warning / danger. An optional [label] (e.g.
/// "25% Complete") sits to the right.
class KasyProgressCircle extends StatelessWidget {
  const KasyProgressCircle({
    super.key,
    this.value,
    this.size = KasyProgressCircleSize.md,
    this.variant = KasyProgressCircleColor.primary,
    this.color,
    this.label,
    this.semanticsLabel,
  });

  /// Progress in 0..1. Null → indeterminate (spins).
  final double? value;

  final KasyProgressCircleSize size;
  final KasyProgressCircleColor variant;

  /// Explicit arc colour. Overrides [variant] when set.
  final Color? color;

  /// Optional text shown to the right of the circle.
  final String? label;

  /// Accessibility label. Defaults to the percentage when determinate.
  final String? semanticsLabel;

  bool get _isIndeterminate => value == null;

  Color _resolveColor(BuildContext context) {
    if (color != null) return color!;
    final KasyColors c = context.colors;
    return switch (variant) {
      KasyProgressCircleColor.primary => c.primary,
      KasyProgressCircleColor.neutral => c.onSurface,
      KasyProgressCircleColor.success => c.success,
      KasyProgressCircleColor.warning => c.warning,
      KasyProgressCircleColor.danger => c.danger,
    };
  }

  @override
  Widget build(BuildContext context) {
    final double d = size.diameter;
    final double stroke = size.stroke;
    final Color arcColor = _resolveColor(context);
    // Determinate shows a neutral track behind the arc; indeterminate is a
    // clean spinning arc with no track (matches the spinner).
    final Color? trackColor = _isIndeterminate ? null : context.colors.neutral;

    CircularProgressIndicator indicator(double? v) => CircularProgressIndicator(
          value: v,
          strokeWidth: stroke,
          strokeCap: StrokeCap.round,
          valueColor: AlwaysStoppedAnimation<Color>(arcColor),
          backgroundColor: trackColor,
        );

    Widget circle = _isIndeterminate
        ? KasySpinner(
            diameter: d,
            strokeWidth: stroke,
            color: arcColor,
          )
        : SizedBox(
            width: d,
            height: d,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value!.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, v, _) => indicator(v),
            ),
          );

    if (label != null) {
      circle = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          circle,
          const SizedBox(width: KasySpacing.smd),
          Flexible(
            child: Text(
              label!,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.onSurface,
              ),
            ),
          ),
        ],
      );
    }

    final String? value0to100 = _isIndeterminate
        ? null
        : '${(value!.clamp(0.0, 1.0) * 100).round()}%';

    return Semantics(
      label: semanticsLabel ?? (value0to100 == null ? 'Loading' : null),
      value: value0to100,
      child: ExcludeSemantics(child: circle),
    );
  }
}
