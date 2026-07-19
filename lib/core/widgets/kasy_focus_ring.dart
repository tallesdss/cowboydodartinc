import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The kit's single keyboard focus indicator: a thin primary-coloured ring shown
/// ONLY during keyboard navigation (never on pointer/touch focus), lifted off the
/// control by a hair-line gap so it reads as a crisp outline, not a glow.
///
/// Visibility follows [FocusManager]'s highlight mode via
/// [FocusableActionDetector.onShowFocusHighlight], so clicking/tapping a control
/// (or it merely receiving pointer focus) never paints the ring.
///
/// Two ways to use it:
/// - Controls without their own keyboard activation: pass [onActivate]
///   (Enter/Space) and let this widget own focus.
/// - Controls that already activate from their own focusable (e.g. an
///   [InkWell]): set that focusable's `canRequestFocus: false` and wrap it here
///   with [onActivate] so focus + ring live in one place.
class KasyFocusRing extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;

  /// Invoked on Enter/Space while focused. When null the ring still appears but
  /// no keyboard activation is wired (use when a child handles its own keys).
  final VoidCallback? onActivate;

  /// When false the ring never takes focus or paints (disabled controls).
  final bool enabled;

  /// Colour of the hair-line gap between the control and the ring. Defaults to
  /// [KasyColors.background] (correct on full-page backgrounds). Pass the actual
  /// surface colour the control sits on (e.g. the sidebar/header `surface`) so
  /// the gap blends in instead of painting a visible halo — this matters in dark
  /// mode, where `background` is darker than `surface`.
  final Color? gapColor;

  const KasyFocusRing({
    super.key,
    required this.child,
    required this.borderRadius,
    this.onActivate,
    this.enabled = true,
    this.gapColor,
  });

  @override
  State<KasyFocusRing> createState() => _KasyFocusRingState();
}

class _KasyFocusRingState extends State<KasyFocusRing> {
  bool _showFocusRing = false;

  static const Map<ShortcutActivator, Intent> _activateShortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  };

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final Color ringColor = context.colors.primary;
    // A hair-line gap in the canvas colour lifts the ring just off the control
    // so it reads as a crisp outline (same focus language as KasyTextField) and
    // stays visible even on primary-coloured buttons (e.g. the chat send orb).
    final Color gapColor = widget.gapColor ?? context.colors.background;
    final VoidCallback? onActivate = widget.onActivate;

    return FocusableActionDetector(
      shortcuts: onActivate != null
          ? _activateShortcuts
          : const <ShortcutActivator, Intent>{},
      actions: <Type, Action<Intent>>{
        if (onActivate != null)
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onActivate();
              return null;
            },
          ),
      },
      onShowFocusHighlight: (show) {
        if (mounted && show != _showFocusRing) {
          setState(() => _showFocusRing = show);
        }
      },
      // Two concentric layers instead of one box with two shadows: a [BoxShadow]
      // inflates its box by [spreadRadius] but keeps the box's corner radius, so
      // on a circular control the inflated ring squares off at the corners and
      // reads as a rounded rectangle. Giving each layer its own radius — matched
      // to its inflated edge — keeps the ring a true contour of any shape.
      // Outer: thin solid primary ring (~1.5px). Inner: a 1.5px gap so the ring
      // floats just off the control instead of hugging it.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: _showFocusRing
            ? BoxDecoration(
                borderRadius: _inflate(widget.borderRadius, 3),
                boxShadow: <BoxShadow>[
                  BoxShadow(color: ringColor, spreadRadius: 3),
                ],
              )
            : const BoxDecoration(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: _showFocusRing
              ? BoxDecoration(
                  borderRadius: _inflate(widget.borderRadius, 1.5),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: gapColor, spreadRadius: 1.5),
                  ],
                )
              : const BoxDecoration(),
          child: widget.child,
        ),
      ),
    );
  }

  /// Grows every corner of [radius] by [delta] so a layer inflated by the same
  /// amount stays a perfect contour (a circle stays a circle, not a squircle).
  BorderRadius _inflate(BorderRadius radius, double delta) {
    final Radius bump = Radius.circular(delta);
    return BorderRadius.only(
      topLeft: radius.topLeft + bump,
      topRight: radius.topRight + bump,
      bottomLeft: radius.bottomLeft + bump,
      bottomRight: radius.bottomRight + bump,
    );
  }
}
