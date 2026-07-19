import 'package:flutter/material.dart';

/// Shine strength for mirror-sweep overlays on pills and CTAs.
enum KasyShineIntensity {
  /// Light fills (compare cyan pill).
  standard,

  /// Saturated small pills (unlock warning badge).
  soft,
}

/// Animated diagonal highlight band for paywall pills and buttons.
class KasyShineSweep extends StatefulWidget {
  const KasyShineSweep({
    super.key,
    required this.intensity,
    this.bandWidthFactor = 0.62,
    this.cycle = const Duration(milliseconds: 2800),
  });

  final KasyShineIntensity intensity;
  final double bandWidthFactor;
  final Duration cycle;

  @override
  State<KasyShineSweep> createState() => _KasyShineSweepState();
}

class _KasyShineSweepState extends State<KasyShineSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;
  late final Animation<double> _shine;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: widget.cycle,
    );
    _shine = CurvedAnimation(
      parent: _shineController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant KasyShineSweep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cycle != oldWidget.cycle) {
      _shineController.duration = widget.cycle;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncShineAnimation();
  }

  void _syncShineAnimation() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _shineController
        ..stop()
        ..value = 0;
      return;
    }
    if (!_shineController.isAnimating) {
      _shineController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  List<Color> _shineGradientColors() {
    return switch (widget.intensity) {
      KasyShineIntensity.standard => [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.72),
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0),
        ],
      KasyShineIntensity.soft => [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.26),
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0),
        ],
    };
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return const SizedBox.shrink();
    }
    final shineColors = _shineGradientColors();
    final bandWidthFactor = widget.bandWidthFactor;
    return AnimatedBuilder(
      animation: _shine,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final bandWidth = width * bandWidthFactor;
            final travel = width + bandWidth;
            final offsetX = -bandWidth + travel * _shine.value;
            return Transform.translate(
              offset: Offset(offsetX, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Transform.rotate(
                  angle: -0.35,
                  child: Container(
                    width: bandWidth,
                    height: height * 2.4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: shineColors,
                        stops: const [0.0, 0.32, 0.5, 0.68, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
