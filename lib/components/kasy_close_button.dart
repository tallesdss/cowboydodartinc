import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/material.dart';

/// Kasy-styled close button (HeroUI CloseButton) — a circular neutral surface
/// with an `xmark` glyph, for dismissing dialogs, sheets, cards, toasts.
///
/// **States**: default (neutral fill), hover (darker fill), focus (accent ring),
/// disabled ([onPressed] == null). Icon-only by design — pass a custom [icon]
/// only to swap the glyph.
class KasyCloseButton extends StatefulWidget {
  const KasyCloseButton({
    super.key,
    this.onPressed,
    this.size = 24,
    this.icon = KasyIcons.close,
    this.semanticLabel = 'Close',
  });

  final VoidCallback? onPressed;

  /// Diameter of the circular surface (HeroUI default 24).
  final double size;

  final IconData icon;
  final String? semanticLabel;

  bool get _enabled => onPressed != null;

  @override
  State<KasyCloseButton> createState() => _KasyCloseButtonState();
}

class _KasyCloseButtonState extends State<KasyCloseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final double size = widget.size;
    final Color bg = (_hovered && widget._enabled) ? c.neutralHover : c.neutral;

    final Widget circle = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(
        widget.icon,
        // HeroUI: 16px glyph inside a 24px surface.
        size: size * (16 / 24),
        color: widget._enabled
            ? c.onSurface
            : c.onSurface.withValues(alpha: 0.4),
      ),
    );

    return Semantics(
      button: true,
      enabled: widget._enabled,
      label: widget.semanticLabel,
      child: KasyFocusRing(
        enabled: widget._enabled,
        onActivate: widget.onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: MouseRegion(
          cursor: widget._enabled
              ? SystemMouseCursors.click
              : MouseCursor.defer,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: widget.onPressed,
            behavior: HitTestBehavior.opaque,
            child: circle,
          ),
        ),
      ),
    );
  }
}
