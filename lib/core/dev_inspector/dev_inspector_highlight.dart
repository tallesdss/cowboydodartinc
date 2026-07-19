import 'package:flutter/material.dart';

class DevInspectorHighlight extends StatefulWidget {
  const DevInspectorHighlight({super.key, required this.rect});

  final Rect rect;

  @override
  State<DevInspectorHighlight> createState() => _DevInspectorHighlightState();
}

class _DevInspectorHighlightState extends State<DevInspectorHighlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) {
        return CustomPaint(
          painter: _HighlightPainter(
            rect: widget.rect,
            fillOpacity: _opacity.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _HighlightPainter extends CustomPainter {
  const _HighlightPainter({required this.rect, required this.fillOpacity});

  final Rect rect;
  final double fillOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      rect,
      Paint()..color = const Color(0xFF2196F3).withValues(alpha: fillOpacity),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFF2196F3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    final labelTop = rect.top - 22.0;
    if (labelTop > 0) {
      canvas.drawRect(
        Rect.fromLTWH(
          rect.left,
          labelTop,
          rect.width.clamp(0, size.width - rect.left),
          20,
        ),
        Paint()..color = const Color(0xFF2196F3),
      );
    }
  }

  @override
  bool shouldRepaint(_HighlightPainter old) =>
      old.rect != rect || old.fillOpacity != fillOpacity;
}
