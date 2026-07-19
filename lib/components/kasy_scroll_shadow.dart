import 'dart:ui' as ui;

import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Visual style of a [KasyScrollShadow]. [opacity] is a subtle alpha gradient;
/// [blur] adds a backdrop blur for stronger depth.
enum KasyScrollShadowType { opacity, blur }

/// Kasy-styled scroll shadow (HeroUI ScrollShadow) — fades the leading/trailing
/// edges of a scrollable to signal that more content is available, appearing
/// only when there is overflow in that direction.
///
/// Set [inSurface] true when the scrollable sits inside a card/modal/popover so
/// the fade tints from the surface colour instead of the page background.
class KasyScrollShadow extends StatefulWidget {
  const KasyScrollShadow({
    super.key,
    required this.child,
    this.axis = Axis.vertical,
    this.type = KasyScrollShadowType.opacity,
    this.inSurface = false,
    this.size = 40,
  });

  /// The scrollable subtree (e.g. a [ListView] or [SingleChildScrollView]).
  final Widget child;
  final Axis axis;
  final KasyScrollShadowType type;
  final bool inSurface;

  /// Extent of each edge fade.
  final double size;

  @override
  State<KasyScrollShadow> createState() => _KasyScrollShadowState();
}

class _KasyScrollShadowState extends State<KasyScrollShadow> {
  bool _atStart = true;
  bool _atEnd = true;
  bool _overflow = false;

  bool _handle(ScrollMetrics m) {
    final bool overflow = m.maxScrollExtent > m.minScrollExtent + 0.5;
    final bool atStart = m.pixels <= m.minScrollExtent + 0.5;
    final bool atEnd = m.pixels >= m.maxScrollExtent - 0.5;
    if (overflow != _overflow || atStart != _atStart || atEnd != _atEnd) {
      setState(() {
        _overflow = overflow;
        _atStart = atStart;
        _atEnd = atEnd;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isV = widget.axis == Axis.vertical;
    final bool showStart = _overflow && !_atStart;
    final bool showEnd = _overflow && !_atEnd;

    return Stack(
      children: <Widget>[
        NotificationListener<ScrollMetricsNotification>(
          onNotification: (n) => _handle(n.metrics),
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) => _handle(n.metrics),
            child: widget.child,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: isV ? 0 : null,
          bottom: isV ? null : 0,
          width: isV ? null : widget.size,
          height: isV ? widget.size : null,
          child: _EdgeFade(
            visible: showStart,
            start: true,
            axis: widget.axis,
            type: widget.type,
            inSurface: widget.inSurface,
          ),
        ),
        Positioned(
          bottom: isV ? 0 : 0,
          right: 0,
          left: isV ? 0 : null,
          top: isV ? null : 0,
          width: isV ? null : widget.size,
          height: isV ? widget.size : null,
          child: _EdgeFade(
            visible: showEnd,
            start: false,
            axis: widget.axis,
            type: widget.type,
            inSurface: widget.inSurface,
          ),
        ),
      ],
    );
  }
}

class _EdgeFade extends StatelessWidget {
  const _EdgeFade({
    required this.visible,
    required this.start,
    required this.axis,
    required this.type,
    required this.inSurface,
  });

  final bool visible;
  final bool start;
  final Axis axis;
  final KasyScrollShadowType type;
  final bool inSurface;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final Color base = inSurface ? c.surface : c.background;
    final bool isV = axis == Axis.vertical;

    // Solid edge → transparent inward.
    final Alignment edge = start
        ? (isV ? Alignment.topCenter : Alignment.centerLeft)
        : (isV ? Alignment.bottomCenter : Alignment.centerRight);
    final Alignment inward = start
        ? (isV ? Alignment.bottomCenter : Alignment.centerRight)
        : (isV ? Alignment.topCenter : Alignment.centerLeft);

    final Gradient gradient = LinearGradient(
      begin: edge,
      end: inward,
      colors: <Color>[base, base.withValues(alpha: 0)],
    );

    Widget fade = DecoratedBox(decoration: BoxDecoration(gradient: gradient));

    // Blur type also softens the content showing through the fade.
    if (type == KasyScrollShadowType.blur) {
      fade = ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: fade,
        ),
      );
    }

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: fade,
      ),
    );
  }
}
