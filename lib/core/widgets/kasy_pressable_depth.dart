import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:cowboydodartinc/core/haptics/haptic_feedback_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Press-in with slight overshoot-back (same tactility as [KasyAlert] actions).
///
/// No Material ripple. Optional [pressOverlayColor] + [clipBorderRadius]:
/// a quick flash on tap (veil), not while the finger merely rests on it.
/// Also exposes semantics for TalkBack/VoiceOver and an optional light haptic ([hapticFeedbackEnabled]).
class KasyPressableDepth extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final String semanticLabel;

  /// Brief flash on tap (translucent veil); not while merely pressing.
  final Color? pressOverlayColor;

  /// Required with [pressOverlayColor] when the surface has rounded clips (pill, etc.).
  final BorderRadius? clipBorderRadius;

  /// If false, does not call [HapticFeedback.lightImpact] on tap.
  final bool hapticFeedbackEnabled;

  /// When true, the control becomes a keyboard tab-stop: it is wrapped in a
  /// [KasyFocusRing] so Tab shows the focus outline and Enter/Space activate it.
  /// Defaults to false because [KasyButton] already wraps its own ring around
  /// the child — turning this on there would paint a second ring. Use it for
  /// direct, standalone uses (e.g. a text link) that need keyboard access.
  final bool focusable;

  /// Corner radius for the focus ring (only used when [focusable]). Defaults to
  /// [clipBorderRadius] when set, otherwise a small radius hugging the visual.
  final BorderRadius? focusBorderRadius;

  /// Gap colour for the focus ring (only used when [focusable]). Pass the
  /// surface the control sits on so the ring's hair-line gap blends in instead
  /// of showing a halo (notably in dark mode). Null falls back to `background`.
  final Color? focusGapColor;

  const KasyPressableDepth({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.pressOverlayColor,
    this.clipBorderRadius,
    this.hapticFeedbackEnabled = true,
    this.focusable = false,
    this.focusBorderRadius,
    this.focusGapColor,
  });

  @override
  ConsumerState<KasyPressableDepth> createState() => _KasyPressableDepthState();
}

class _KasyPressableDepthState extends ConsumerState<KasyPressableDepth>
    with SingleTickerProviderStateMixin {
  static const double _pressIn = 0.992;
  static const double _releasePeak = 1.002;
  late final AnimationController _depthController;
  Timer? _veilTimer;
  bool _veilVisible = false;
  bool _hovered = false;

  bool get _useVeil =>
      widget.pressOverlayColor != null && widget.clipBorderRadius != null;

  @override
  void initState() {
    super.initState();
    _depthController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..addListener(() {
          setState(() {});
        });
  }

  @override
  void dispose() {
    _veilTimer?.cancel();
    _depthController.dispose();
    super.dispose();
  }

  double get _depthScale {
    final double t = _depthController.value.clamp(0.0, 1.0);
    if (t <= 0.28) {
      return lerpDouble(1.0, _pressIn, t / 0.28)!;
    }
    if (t <= 0.55) {
      return lerpDouble(_pressIn, _releasePeak, (t - 0.28) / 0.27)!;
    }
    return lerpDouble(_releasePeak, 1.0, (t - 0.55) / 0.45)!;
  }

  void _handleTap() {
    if (widget.hapticFeedbackEnabled && ref.read(hapticFeedbackProvider)) {
      HapticFeedback.lightImpact();
    }
    _flashVeil();
    widget.onPressed();
    _depthController.forward(from: 0).whenComplete(() {
      if (mounted) {
        _depthController.reset();
      }
    });
  }

  void _flashVeil() {
    if (!_useVeil) {
      return;
    }
    _veilTimer?.cancel();
    setState(() => _veilVisible = true);
    _veilTimer = Timer(const Duration(milliseconds: 110), () {
      if (!mounted) {
        return;
      }
      setState(() => _veilVisible = false);
    });
  }

  Widget _wrapScaledChild(Widget rawChild) {
    if (!_useVeil) {
      return Transform.scale(scale: _depthScale, child: rawChild);
    }

    // On web the overlay doubles as a hover highlight: a subtle persistent fill
    // while the pointer is over the control, flashing to full on press. On touch
    // it only flashes on press (_hovered never becomes true).
    final Widget pressVeil = AnimatedOpacity(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOutCubic,
      opacity: _veilVisible ? 1.0 : (_hovered ? 0.6 : 0.0),
      child: IgnorePointer(child: ColoredBox(color: widget.pressOverlayColor!)),
    );

    return Transform.scale(
      scale: _depthScale,
      // Clip only the press veil to the rounded shape — never [rawChild]. The
      // child may host a keyboard focus ring that paints just outside its box;
      // clipping the whole stack would shave that ring off.
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          rawChild,
          Positioned.fill(
            child: ClipRRect(
              borderRadius: widget.clipBorderRadius!,
              child: pressVeil,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The ring wraps the scaled visual (not the 44px tap target) so it hugs the
    // control's shape, and sits outside Transform.scale so it doesn't pulse with
    // the press. Keyboard activation is wired to the same handler as the tap.
    Widget visual = _wrapScaledChild(widget.child);
    if (widget.focusable) {
      visual = KasyFocusRing(
        onActivate: _handleTap,
        borderRadius: widget.focusBorderRadius ??
            widget.clipBorderRadius ??
            BorderRadius.circular(KasyRadius.sm),
        gapColor: widget.focusGapColor,
        child: visual,
      );
    }

    final Widget inner = Semantics(
      button: true,
      enabled: true,
      label: widget.semanticLabel,
      onTap: _handleTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: _handleTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Center(child: visual),
        ),
      ),
    );

    if (!kIsWeb) return inner;

    // On web: pointer cursor + a subtle hover highlight (drives the overlay
    // opacity above), so buttons feel interactive on hover as expected on the
    // web. Only meaningful when there's an overlay to show (_useVeil).
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _useVeil ? (_) => setState(() => _hovered = true) : null,
      onExit: _useVeil ? (_) => setState(() => _hovered = false) : null,
      child: inner,
    );
  }
}
