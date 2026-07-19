import 'dart:math' as math;

import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Semantic colour of a [KasySpinner] (HeroUI Spinner: primary | current |
/// success | warning | danger). [current] inherits the surrounding text colour.
enum KasySpinnerColor { primary, current, success, warning, danger }

/// Size of a [KasySpinner] — the drawn diameter in logical px. The Figma kit
/// draws the spinner at 24 (our [md]); [sm]/[lg] keep the same proportions.
enum KasySpinnerSize { sm, md, lg }

extension _SpinnerSizeX on KasySpinnerSize {
  double get diameter => switch (this) {
        KasySpinnerSize.sm => 16,
        KasySpinnerSize.md => 24,
        KasySpinnerSize.lg => 32,
      };
}

/// Kasy-styled loading indicator — a full ring with an **angular gradient**
/// that runs from a soft tone to the strong [color] and spins continuously
/// (HeroUI Spinner: `default-hover` → `default-foreground`, swept around).
///
/// **Sizes**: sm / md / lg (16 / 24 / 32). **Colours**: primary / current /
/// success / warning / danger, or pass an explicit [color]. The soft end of the
/// gradient is derived from [color] mixed toward the surface, so it stays
/// theme-aware; override it with [softColor] if needed.
class KasySpinner extends StatefulWidget {
  const KasySpinner({
    super.key,
    this.size = KasySpinnerSize.md,
    this.variant = KasySpinnerColor.primary,
    this.color,
    this.softColor,
    this.diameter,
    this.strokeWidth,
    this.semanticsLabel = 'Loading',
  });

  final KasySpinnerSize size;
  final KasySpinnerColor variant;

  /// Strong end of the gradient. Overrides [variant] when set.
  final Color? color;

  /// Soft end of the gradient. Defaults to [color] mixed toward the surface.
  final Color? softColor;

  /// Explicit diameter in logical px. Overrides [size] — handy when fitting a
  /// fixed slot (e.g. inside a button or alert).
  final double? diameter;

  /// Stroke thickness. Defaults to ~1/6 of the diameter (HeroUI: 4 on 24).
  final double? strokeWidth;

  final String? semanticsLabel;

  @override
  State<KasySpinner> createState() => _KasySpinnerState();
}

class _KasySpinnerState extends State<KasySpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSpin();
  }

  void _syncSpin() {
    // Infinite loops must respect reduce motion / test disableAnimations,
    // otherwise pumpAndSettle never settles.
    if (MediaQuery.disableAnimationsOf(context)) {
      _ctrl
        ..stop()
        ..value = 0;
      return;
    }
    if (!_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _resolveColor(BuildContext context) {
    if (widget.color != null) return widget.color!;
    final KasyColors c = context.colors;
    return switch (widget.variant) {
      KasySpinnerColor.primary => c.primary,
      KasySpinnerColor.current =>
        DefaultTextStyle.of(context).style.color ?? c.onSurface,
      KasySpinnerColor.success => c.success,
      KasySpinnerColor.warning => c.warning,
      KasySpinnerColor.danger => c.danger,
    };
  }

  @override
  Widget build(BuildContext context) {
    final double d = widget.diameter ?? widget.size.diameter;
    final double stroke = widget.strokeWidth ?? d / 6;
    final Color strong = _resolveColor(context);
    // Soft end: the same hue mixed ~80% toward the surface — opaque, so the
    // ring never fades into the background (which is what looked "broken").
    final Color soft = widget.softColor ??
        Color.lerp(strong, context.colors.surface, 0.80)!;

    return Semantics(
      label: widget.semanticsLabel,
      liveRegion: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: d,
          height: d,
          child: RotationTransition(
            turns: _ctrl,
            child: CustomPaint(
              painter: _SpinnerRingPainter(
                soft: soft,
                strong: strong,
                strokeWidth: stroke,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpinnerRingPainter extends CustomPainter {
  _SpinnerRingPainter({
    required this.soft,
    required this.strong,
    required this.strokeWidth,
  });

  final Color soft;
  final Color strong;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    const double start = -math.pi / 2; // seam at 12 o'clock

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + 2 * math.pi,
        colors: <Color>[soft, strong],
      ).createShader(rect);

    // Full 360° ring — continuous, with the angular gradient sweeping soft→strong.
    canvas.drawArc(rect, start, 2 * math.pi, false, ring);
  }

  @override
  bool shouldRepaint(_SpinnerRingPainter old) =>
      old.soft != soft ||
      old.strong != strong ||
      old.strokeWidth != strokeWidth;
}
