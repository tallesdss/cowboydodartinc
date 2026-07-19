import 'dart:math' as math;

import 'package:cowboydodartinc/core/theme/radius.dart';
import 'package:flutter/material.dart';

// ─── Animation mode ───────────────────────────────────────────────────────────
/// Controls how skeleton bones animate while loading.
enum KasySkeletonAnimation {
  /// Highlight band sweeps left-to-right across each bone.
  shimmer,

  /// All bones fade in/out together.
  pulse,

  /// No animation — static base colour.
  none,
}

// ─── Inherited scope ──────────────────────────────────────────────────────────

class _KasySkeletonScope extends InheritedWidget {
  const _KasySkeletonScope({
    required this.animation,
    required this.mode,
    required super.child,
  });

  final Animation<double> animation;
  final KasySkeletonAnimation mode;

  static _KasySkeletonScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_KasySkeletonScope>();

  @override
  bool updateShouldNotify(_KasySkeletonScope old) =>
      mode != old.mode || animation != old.animation;
}

// ─── Group ────────────────────────────────────────────────────────────────────

/// Provides a shared [AnimationController] to all [KasySkeleton] bones in its
/// subtree so every bone animates in perfect sync.
///
/// Wrap the loading placeholder layout with [KasySkeletonGroup] and swap it
/// for the real content once data arrives.
///
/// ```dart
/// isLoading
///   ? KasySkeletonGroup(
///       child: Column(children: [
///         KasySkeleton(width: 120, height: 14),
///         KasySkeleton.circle(size: 40),
///       ]),
///     )
///   : MyRealContent()
/// ```
class KasySkeletonGroup extends StatefulWidget {
  const KasySkeletonGroup({
    super.key,
    required this.child,
    this.animation = KasySkeletonAnimation.shimmer,
  });

  final Widget child;

  /// How the bones animate. Defaults to [KasySkeletonAnimation.shimmer].
  final KasySkeletonAnimation animation;

  @override
  State<KasySkeletonGroup> createState() => _KasySkeletonGroupState();
}

class _KasySkeletonGroupState extends State<KasySkeletonGroup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// Platform "reduce motion" flag — bones render static when it is on.
  bool _motionReduced = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motionReduced = MediaQuery.disableAnimationsOf(context);
    _syncController();
  }

  @override
  void didUpdateWidget(KasySkeletonGroup old) {
    super.didUpdateWidget(old);
    if (widget.animation != old.animation) {
      _syncController();
    }
  }

  KasySkeletonAnimation get _effectiveAnimation =>
      _motionReduced ? KasySkeletonAnimation.none : widget.animation;

  void _syncController() {
    if (_effectiveAnimation == KasySkeletonAnimation.none) {
      _controller.stop();
      _controller.value = 0;
    } else {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _KasySkeletonScope(
      animation: _controller,
      mode: _effectiveAnimation,
      child: widget.child,
    );
  }
}

// ─── Bone ─────────────────────────────────────────────────────────────────────

/// A single skeleton bone — a placeholder rectangle or circle that animates
/// using the nearest [KasySkeletonGroup]'s shared controller.
///
/// For a circular bone (avatar, icon placeholder) use [KasySkeleton.circle].
class KasySkeleton extends StatelessWidget {
  /// Rectangular bone.
  const KasySkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  })  : _isCircle = false,
        _circleSize = 0;

  /// Circular bone of the given [size] (diameter).
  const KasySkeleton.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = null,
        _isCircle = true,
        _circleSize = size;

  /// Width of the bone. Pass `double.infinity` to fill available horizontal space.
  final double? width;

  /// Height of the bone.
  final double height;

  /// Corner radius for rectangular bones. Defaults to [KasyRadius.smBorderRadius].
  final BorderRadius? borderRadius;

  final bool _isCircle;
  final double _circleSize;

  BorderRadius get _effectiveBorderRadius {
    if (_isCircle) return BorderRadius.circular(_circleSize / 2);
    return borderRadius ?? KasyRadius.smBorderRadius;
  }

  // Palette ──────────────────────────────────────────────────────────────────

  static Color _base(bool dark) =>
      dark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

  static Color _highlight(bool dark) =>
      dark ? const Color(0xFF48484A) : const Color(0xFFF2F2F7);

  // Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scope = _KasySkeletonScope.maybeOf(context);
    final mode = scope?.mode ?? KasySkeletonAnimation.shimmer;
    final animation = scope?.animation;

    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color base = _base(dark);
    final Color highlight = _highlight(dark);

    if (mode == KasySkeletonAnimation.none || animation == null) {
      return _bone(color: base);
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double t = animation.value;

        if (mode == KasySkeletonAnimation.shimmer) {
          // Highlight band sweeps from off-screen-left to off-screen-right.
          // pos goes −2 → 2 (in alignment units; box spans −1 → 1).
          final double pos = -2 + t * 4;
          final gradient = LinearGradient(
            begin: Alignment(pos - 0.8, 0),
            end: Alignment(pos + 0.8, 0),
            colors: [base, highlight, base],
          );
          return _bone(gradient: gradient);
        } else {
          // Pulse: sine wave between base and highlight.
          final double factor = (math.sin(t * 2 * math.pi) + 1) / 2;
          return _bone(color: Color.lerp(base, highlight, factor) ?? base);
        }
      },
    );
  }

  Widget _bone({Color? color, Gradient? gradient}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: _effectiveBorderRadius,
      ),
    );
  }
}
