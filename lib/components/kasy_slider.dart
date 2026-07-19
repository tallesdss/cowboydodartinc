import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// HeroUI Slider geometry
// ---------------------------------------------------------------------------
const double _kTrack = 20; // fat pill track
const double _kThumbW = 24;
const double _kThumbH = 16; // 2px inset top/bottom inside the track
// Slot: 2px of coloured fill framing the thumb on every side (same as the
// top/bottom gap, since thumb 16 sits in track 20). The thumb travel is inset
// by this + half the thumb so at 0%/100% the thumb keeps its 2px frame and the
// fill still reaches the rounded track corners (NO grey gap).
const double _kThumbInset = 2;
const double _kThumbRadius = 8;
const double _kEdge = _kThumbInset + _kThumbW / 2;
const double _kTooltipReserve = 36; // space above the track for the value bubble

// HeroUI shadow-field: a subtle lift kept tight so it never reads as the thumb
// poking out of the track.
const List<BoxShadow> _kFieldShadow = [
  BoxShadow(color: Color(0x14000000), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0F000000), blurRadius: 1),
];

// ---------------------------------------------------------------------------
// KasySlider — single thumb
// ---------------------------------------------------------------------------

/// Kasy-styled slider (HeroUI Slider) — one draggable thumb selecting a value
/// in [[min], [max]].
///
/// A fat pill track with a white capsule thumb nested 2px inside it. Optional
/// [label] / [valueText] header above, [marks] below, [divisions] for snapping
/// (with step dots on the track), and a [tooltip] formatter that floats the
/// value over the thumb. Disabled when [onChanged] is null.
class KasySlider extends StatefulWidget {
  const KasySlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.valueText,
    this.marks,
    this.color,
    this.tooltip,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final String? valueText;
  final List<String>? marks;
  final Color? color;

  /// When set, floats a bubble with this text above the thumb.
  final String Function(double value)? tooltip;

  bool get _enabled => onChanged != null;

  @override
  State<KasySlider> createState() => _KasySliderState();
}

class _KasySliderState extends State<KasySlider> {
  double _fraction(double width) {
    final double span = widget.max - widget.min;
    if (span <= 0) return 0;
    return ((widget.value - widget.min) / span).clamp(0.0, 1.0);
  }

  double _valueFromDx(double dx, double width) {
    final double travel = width - 2 * _kEdge;
    final double f =
        travel <= 0 ? 0 : ((dx - _kEdge) / travel).clamp(0.0, 1.0);
    double v = widget.min + f * (widget.max - widget.min);
    if (widget.divisions != null && widget.divisions! > 0) {
      final double step = (widget.max - widget.min) / widget.divisions!;
      v = widget.min + ((v - widget.min) / step).round() * step;
    }
    return v.clamp(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    final Color active = widget.color ?? context.colors.primary;
    final bool showTooltip = widget.tooltip != null;

    final Widget control = LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double f = _fraction(w);
        final double cx = _kEdge + f * (w - 2 * _kEdge);

        void report(double dx, {bool end = false}) {
          final double v = _valueFromDx(dx, w);
          widget.onChanged?.call(v);
          if (end) widget.onChangeEnd?.call(v);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown:
              widget._enabled ? (d) => report(d.localPosition.dx) : null,
          onHorizontalDragUpdate:
              widget._enabled ? (d) => report(d.localPosition.dx) : null,
          onHorizontalDragEnd: widget._enabled
              ? (d) => widget.onChangeEnd?.call(widget.value)
              : null,
          child: SizedBox(
            height: _kTrack + (showTooltip ? _kTooltipReserve : 0),
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Track + thumb share one bottom-anchored box of height _kTrack,
                // so the thumb is centred inside the track (2px slot all round).
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _kTrack,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _TrackPainter(
                            fillFromX: 0,
                            fillToFraction: f,
                            active: active,
                            track: context.colors.neutral,
                            enabled: widget._enabled,
                            divisions: widget.divisions,
                            stepOn: Colors.white.withValues(alpha: 0.55),
                            stepOff:
                                context.colors.muted.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                      // top/bottom 2 force the thumb to be exactly track − 4px,
                      // so it can never poke out of the track (a 2px slot all
                      // round — same nesting as KasySwitch).
                      Positioned(
                        left: cx - _kThumbW / 2,
                        top: _kThumbInset,
                        bottom: _kThumbInset,
                        child: _Thumb(enabled: widget._enabled),
                      ),
                    ],
                  ),
                ),
                if (showTooltip)
                  Positioned(
                    left: cx,
                    bottom: _kTrack + 6,
                    child: FractionalTranslation(
                      translation: const Offset(-0.5, 0),
                      child: _ValueBubble(widget.tooltip!(widget.value)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    return _SliderScaffold(
      label: widget.label,
      valueText: widget.valueText,
      marks: widget.marks,
      control: control,
    );
  }
}

// ---------------------------------------------------------------------------
// KasyRangeSlider — two thumbs
// ---------------------------------------------------------------------------

/// Kasy-styled range slider (HeroUI Slider, range variant) — two thumbs
/// selecting a min/max span. Mirrors [KasySlider]'s styling.
class KasyRangeSlider extends StatefulWidget {
  const KasyRangeSlider({
    super.key,
    required this.values,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.valueText,
    this.marks,
    this.color,
    this.tooltip,
  });

  final RangeValues values;
  final ValueChanged<RangeValues>? onChanged;
  final ValueChanged<RangeValues>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final String? valueText;
  final List<String>? marks;
  final Color? color;
  final String Function(double value)? tooltip;

  bool get _enabled => onChanged != null;

  @override
  State<KasyRangeSlider> createState() => _KasyRangeSliderState();
}

class _KasyRangeSliderState extends State<KasyRangeSlider> {
  // 0 = start thumb, 1 = end thumb — locked on drag start.
  int _activeThumb = 0;

  double _fraction(double v) {
    final double span = widget.max - widget.min;
    if (span <= 0) return 0;
    return ((v - widget.min) / span).clamp(0.0, 1.0);
  }

  double _valueFromDx(double dx, double width) {
    final double travel = width - 2 * _kEdge;
    final double f =
        travel <= 0 ? 0 : ((dx - _kEdge) / travel).clamp(0.0, 1.0);
    double v = widget.min + f * (widget.max - widget.min);
    if (widget.divisions != null && widget.divisions! > 0) {
      final double step = (widget.max - widget.min) / widget.divisions!;
      v = widget.min + ((v - widget.min) / step).round() * step;
    }
    return v.clamp(widget.min, widget.max);
  }

  void _pickThumb(double dx, double width) {
    final double v = _valueFromDx(dx, width);
    _activeThumb =
        (v - widget.values.start).abs() <= (v - widget.values.end).abs()
            ? 0
            : 1;
  }

  void _report(double dx, double width, {bool end = false}) {
    final double v = _valueFromDx(dx, width);
    RangeValues next;
    if (_activeThumb == 0) {
      next = RangeValues(v.clamp(widget.min, widget.values.end), widget.values.end);
    } else {
      next = RangeValues(widget.values.start, v.clamp(widget.values.start, widget.max));
    }
    widget.onChanged?.call(next);
    if (end) widget.onChangeEnd?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final Color active = widget.color ?? context.colors.primary;
    final bool showTooltip = widget.tooltip != null;

    final Widget control = LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double fStart = _fraction(widget.values.start);
        final double fEnd = _fraction(widget.values.end);
        final double cxStart = _kEdge + fStart * (w - 2 * _kEdge);
        final double cxEnd = _kEdge + fEnd * (w - 2 * _kEdge);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget._enabled
              ? (d) {
                  _pickThumb(d.localPosition.dx, w);
                  _report(d.localPosition.dx, w);
                }
              : null,
          onHorizontalDragStart: widget._enabled
              ? (d) => _pickThumb(d.localPosition.dx, w)
              : null,
          onHorizontalDragUpdate:
              widget._enabled ? (d) => _report(d.localPosition.dx, w) : null,
          onHorizontalDragEnd: widget._enabled
              ? (d) => widget.onChangeEnd?.call(widget.values)
              : null,
          child: SizedBox(
            height: _kTrack + (showTooltip ? _kTooltipReserve : 0),
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _kTrack,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _TrackPainter(
                            fillFromFraction: fStart,
                            fillToFraction: fEnd,
                            active: active,
                            track: context.colors.neutral,
                            enabled: widget._enabled,
                            divisions: widget.divisions,
                            stepOn: Colors.white.withValues(alpha: 0.55),
                            stepOff:
                                context.colors.muted.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                      for (final double cx in [cxStart, cxEnd])
                        Positioned(
                          left: cx - _kThumbW / 2,
                          top: _kThumbInset,
                          bottom: _kThumbInset,
                          child: _Thumb(enabled: widget._enabled),
                        ),
                    ],
                  ),
                ),
                if (showTooltip)
                  for (final (double cx, double v) in [
                    (cxStart, widget.values.start),
                    (cxEnd, widget.values.end),
                  ])
                    Positioned(
                      left: cx,
                      bottom: _kTrack + 6,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, 0),
                        child: _ValueBubble(widget.tooltip!(v)),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );

    return _SliderScaffold(
      label: widget.label,
      valueText: widget.valueText,
      marks: widget.marks,
      control: control,
    );
  }
}

// ---------------------------------------------------------------------------
// Shared pieces
// ---------------------------------------------------------------------------

/// Header (label + value) above, control, then marks below.
class _SliderScaffold extends StatelessWidget {
  const _SliderScaffold({
    required this.label,
    required this.valueText,
    required this.marks,
    required this.control,
  });

  final String? label;
  final String? valueText;
  final List<String>? marks;
  final Widget control;

  @override
  Widget build(BuildContext context) {
    final TextStyle? headerStyle = context.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
      color: context.colors.onSurface,
    );
    final TextStyle? markStyle = context.textTheme.bodySmall?.copyWith(
      color: context.colors.muted,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || valueText != null) ...[
          Row(
            children: [
              if (label != null)
                Expanded(child: Text(label!, style: headerStyle))
              else
                const Spacer(),
              if (valueText != null) Text(valueText!, style: headerStyle),
            ],
          ),
          const SizedBox(height: KasySpacing.xs),
        ],
        control,
        if (marks != null && marks!.isNotEmpty) ...[
          const SizedBox(height: KasySpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KasySpacing.smd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [for (final m in marks!) Text(m, style: markStyle)],
            ),
          ),
        ],
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.enabled});
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      child: Container(
        width: _kThumbW,
        height: _kThumbH,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFF4F4F5),
          borderRadius: BorderRadius.circular(_kThumbRadius),
          boxShadow: _kFieldShadow,
        ),
      ),
    );
  }
}

class _ValueBubble extends StatelessWidget {
  const _ValueBubble(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KasySpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(KasyRadius.md),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 6)),
              BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            text,
            style: context.textTheme.bodySmall?.copyWith(
              color: c.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -3),
          child: Transform.rotate(
            angle: 0.785398, // 45°
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackPainter extends CustomPainter {
  _TrackPainter({
    this.fillFromX,
    this.fillFromFraction,
    required this.fillToFraction,
    required this.active,
    required this.track,
    required this.enabled,
    required this.divisions,
    required this.stepOn,
    required this.stepOff,
  });

  /// Single slider: fill starts at this absolute x (usually 0).
  final double? fillFromX;

  /// Range slider: fill starts at this fraction (the start thumb).
  final double? fillFromFraction;
  final double fillToFraction;
  final Color active;
  final Color track;
  final bool enabled;
  final int? divisions;
  final Color stepOn;
  final Color stepOff;

  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;
    final double w = size.width;
    final double r = h / 2;
    const double innerLeft = _kEdge;
    final double inner = w - 2 * _kEdge;

    final Color trackColor =
        enabled ? track : track.withValues(alpha: 0.6);
    final Color fillColor =
        enabled ? active : active.withValues(alpha: 0.4);

    // Track (full-width pill).
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(r)),
      Paint()..color = trackColor,
    );

    // Fill — extended past the thumb centre by half the thumb + the slot inset,
    // so the white thumb sits *inside* the coloured fill (framed 2px all round),
    // never poking out onto the track. This is the HeroUI nesting.
    const double frame = _kThumbW / 2 + _kThumbInset;
    final double fromX = fillFromFraction != null
        ? (innerLeft + fillFromFraction! * inner - frame).clamp(0.0, w)
        : (fillFromX ?? 0);
    final double toX =
        (innerLeft + fillToFraction * inner + frame).clamp(0.0, w);
    if (toX > fromX) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(fromX, 0, toX, h),
          Radius.circular(r),
        ),
        Paint()..color = fillColor,
      );
    }

    // Step dots (interior divisions).
    if (divisions != null && divisions! > 1) {
      for (int i = 1; i < divisions!; i++) {
        final double x = innerLeft + (i / divisions!) * inner;
        final bool on = x >= fromX && x <= toX;
        canvas.drawCircle(
          Offset(x, h / 2),
          1.5,
          Paint()..color = on ? stepOn : stepOff,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TrackPainter old) =>
      old.fillFromX != fillFromX ||
      old.fillFromFraction != fillFromFraction ||
      old.fillToFraction != fillToFraction ||
      old.active != active ||
      old.track != track ||
      old.enabled != enabled ||
      old.divisions != divisions;
}
