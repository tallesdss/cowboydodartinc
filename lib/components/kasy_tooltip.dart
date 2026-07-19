import 'dart:async';
import 'dart:math' as math;

import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Which side of its trigger a [KasyTooltip] opens toward. The arrow sits on the
/// edge facing the trigger and points at it.
enum KasyTooltipPlacement { top, bottom, left, right }

/// Kasy-styled tooltip (HeroUI Tooltip) — a small bubble of informative text that
/// appears when the user hovers (web/desktop) or long-presses (touch) the
/// [child]. Use it to clarify icons, controls or abbreviated text; keep the copy
/// short (1–2 lines).
///
/// The bubble follows the theme by default ([inverse] false → surface bubble,
/// foreground text). Set [inverse] true for a high-contrast inverted bubble
/// (dark on a light theme, light on a dark theme). [showArrow] toggles the little
/// pointer; turn it off for a tooltip with no directional indication.
class KasyTooltip extends StatefulWidget {
  const KasyTooltip({
    super.key,
    required this.message,
    required this.child,
    this.placement = KasyTooltipPlacement.top,
    this.inverse = false,
    this.showArrow = true,
    this.waitDuration = const Duration(milliseconds: 400),
    this.showDuration = const Duration(milliseconds: 1500),
  });

  /// The tooltip text.
  final String message;

  /// The control the tooltip describes (what the user hovers / long-presses).
  final Widget child;

  final KasyTooltipPlacement placement;
  final bool inverse;
  final bool showArrow;

  /// How long the pointer must dwell before the tooltip appears (hover).
  final Duration waitDuration;

  /// How long the tooltip stays up after a long-press (touch) before auto-hiding.
  final Duration showDuration;

  @override
  State<KasyTooltip> createState() => _KasyTooltipState();
}

class _KasyTooltipState extends State<KasyTooltip> {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();
  Timer? _showTimer;
  Timer? _hideTimer;

  // Distance from the trigger to the bubble's near edge. The arrow pokes back
  // into this gap so its tip ends up a hair off the control.
  static const double _gap = 8;

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _show() {
    _hideTimer?.cancel();
    if (!_controller.isShowing) _controller.show();
  }

  void _hide() {
    _showTimer?.cancel();
    if (_controller.isShowing) _controller.hide();
  }

  void _onEnter() {
    _showTimer?.cancel();
    _showTimer = Timer(widget.waitDuration, _show);
  }

  void _onLongPress() {
    _show();
    _hideTimer?.cancel();
    _hideTimer = Timer(widget.showDuration, _hide);
  }

  ({Alignment target, Alignment follower, Offset offset}) get _anchors {
    switch (widget.placement) {
      case KasyTooltipPlacement.top:
        return (
          target: Alignment.topCenter,
          follower: Alignment.bottomCenter,
          offset: const Offset(0, -_gap),
        );
      case KasyTooltipPlacement.bottom:
        return (
          target: Alignment.bottomCenter,
          follower: Alignment.topCenter,
          offset: const Offset(0, _gap),
        );
      case KasyTooltipPlacement.left:
        return (
          target: Alignment.centerLeft,
          follower: Alignment.centerRight,
          offset: const Offset(-_gap, 0),
        );
      case KasyTooltipPlacement.right:
        return (
          target: Alignment.centerRight,
          follower: Alignment.centerLeft,
          offset: const Offset(_gap, 0),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final anchors = _anchors;
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (BuildContext context) {
        return Positioned(
          width: 0,
          height: 0,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: anchors.target,
            followerAnchor: anchors.follower,
            offset: anchors.offset,
            child: IgnorePointer(
              child: _TooltipBubble(
                message: widget.message,
                inverse: widget.inverse,
                showArrow: widget.showArrow,
                placement: widget.placement,
              ),
            ),
          ),
        );
      },
      child: CompositedTransformTarget(
        link: _link,
        child: MouseRegion(
          onEnter: (_) => _onEnter(),
          onExit: (_) => _hide(),
          child: GestureDetector(
            onLongPress: _onLongPress,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// The bubble itself: the styled container plus an optional arrow on the edge
/// facing the trigger. Matches HeroUI's Tooltip (radius 12, padding 8×4, Inter
/// 12/16, the `overlay` surface token, and the soft overlay drop shadow).
class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble({
    required this.message,
    required this.inverse,
    required this.showArrow,
    required this.placement,
  });

  final String message;
  final bool inverse;
  final bool showArrow;
  final KasyTooltipPlacement placement;

  // Half of the 10px arrow square, so positioning its box at -poke centers the
  // square on the bubble edge (the buried half is hidden behind the bubble).
  static const double _poke = 5;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    // inverse just swaps the overlay surface with the foreground tone.
    final Color bg = inverse ? c.onSurface : c.overlay;
    final Color fg = inverse ? c.overlay : c.onSurface;

    final Widget bubble = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(KasyRadius.md),
          boxShadow: KasyShadows.overlay,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KasySpacing.sm,
            vertical: KasySpacing.xs,
          ),
          child: Text(
            message,
            style: (context.textTheme.bodySmall ?? const TextStyle()).copyWith(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w400,
              color: fg,
            ),
          ),
        ),
      ),
    );

    final Widget content = showArrow
        ? Stack(
            clipBehavior: Clip.none,
            children: <Widget>[_arrow(bg), bubble],
          )
        : bubble;

    return Material(type: MaterialType.transparency, child: content);
  }

  /// A 10px rounded square rotated 45° (a diamond) on the edge facing the
  /// trigger. Drawn BEHIND the bubble so its buried half is hidden and only the
  /// pointing triangle shows.
  Widget _arrow(Color bg) {
    final Widget diamond = Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(KasyRadius.roundedSm),
        ),
      ),
    );

    switch (placement) {
      case KasyTooltipPlacement.top: // bubble above trigger → arrow on bottom edge
        return Positioned(
          bottom: -_poke,
          left: 0,
          right: 0,
          child: Center(child: diamond),
        );
      case KasyTooltipPlacement.bottom: // arrow on top edge
        return Positioned(
          top: -_poke,
          left: 0,
          right: 0,
          child: Center(child: diamond),
        );
      case KasyTooltipPlacement.left: // arrow on right edge
        return Positioned(
          right: -_poke,
          top: 0,
          bottom: 0,
          child: Center(child: diamond),
        );
      case KasyTooltipPlacement.right: // arrow on left edge
        return Positioned(
          left: -_poke,
          top: 0,
          bottom: 0,
          child: Center(child: diamond),
        );
    }
  }
}
