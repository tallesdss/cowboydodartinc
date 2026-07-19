import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/material.dart';

/// When the link underline is painted.
enum KasyLinkUnderline {
  /// Always on (Figma `kasy/Link sm` / HeroUI Link). Default for standalone links.
  always,

  /// Only while hovered. Prefer for inline auth prompts ("Sign up", "Sign in")
  /// where a permanent underline fights the surrounding muted sentence.
  /// On touch-only surfaces there is no hover, so the link stays clean and
  /// relies on colour / weight.
  hover,

  /// Never underlined.
  never,
}

/// Kasy-styled text link (HeroUI Link) — a minimal, text-first anchor for
/// navigation or secondary actions. Not a primary CTA: reach for [KasyButton]
/// when the action is the main thing on the screen.
///
/// **States**: default (underline per [underline]), hover (icon/decoration lift),
/// focus (accent ring), disabled ([onPressed] == null → 50% opacity). An optional
/// trailing [icon] (e.g. [KasyIcons.northEast] for an external link) sits after
/// the label.
class KasyLink extends StatefulWidget {
  const KasyLink({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.focusable = true,
    this.underline = KasyLinkUnderline.always,
    this.fontWeight,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Optional trailing glyph, e.g. an external-link arrow.
  final IconData? icon;

  /// Text/icon colour. Defaults to the HeroUI link foreground (onSurface).
  final Color? color;

  /// Whether the link takes keyboard focus (a Tab stop with a focus ring). Set
  /// false for secondary links that should stay out of the traversal order
  /// (e.g. a "forgot password" beside a field).
  final bool focusable;

  /// Underline behaviour. Defaults to [KasyLinkUnderline.always] to match the
  /// Figma Link styles. Use [KasyLinkUnderline.hover] for inline auth prompts.
  final KasyLinkUnderline underline;

  /// Optional weight override. Defaults to the Link sm Medium (w500) from
  /// [KasyTextTheme.rowTitle]. Auth switchers use [FontWeight.w600] to match
  /// Figma ("Cadastre-se" / "Entrar").
  final FontWeight? fontWeight;

  final String? semanticsLabel;

  bool get _enabled => onPressed != null;

  @override
  State<KasyLink> createState() => _KasyLinkState();
}

class _KasyLinkState extends State<KasyLink> {
  bool _hovered = false;

  bool get _showUnderline {
    switch (widget.underline) {
      case KasyLinkUnderline.always:
        return true;
      case KasyLinkUnderline.never:
        return false;
      case KasyLinkUnderline.hover:
        // Pointer devices (web / desktop): underline on hover.
        // Touch-only: no permanent line (colour + weight carry affordance).
        return _hovered && widget._enabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final Color base = widget.color ?? c.onSurface;
    final bool enabled = widget._enabled;
    final bool hovered = _hovered && enabled;
    final bool showUnderline = _showUnderline;

    // Link sm: 14 / 20. Weight defaults to Medium; auth switchers pass SemiBold.
    TextStyle textStyle = context.kasyTextTheme.rowTitle.copyWith(
      color: base,
      decoration: showUnderline ? TextDecoration.underline : TextDecoration.none,
      decorationColor: base,
      decorationThickness: 1.2,
    );
    if (widget.fontWeight != null) {
      textStyle = textStyle.withWeight(widget.fontWeight!);
    }

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: textStyle),
        if (widget.icon != null) ...[
          const SizedBox(width: 2),
          Padding(
            // Nudge the glyph down to sit on the text baseline, as in Figma.
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              widget.icon,
              size: 14,
              // Icon rides at 60% by default and lifts to full on hover.
              color: base.withValues(alpha: hovered ? 1.0 : 0.6),
            ),
          ),
        ],
      ],
    );

    final Widget semantics = Semantics(
      link: true,
      enabled: enabled,
      label: widget.semanticsLabel ?? widget.label,
      child: content,
    );

    // Disabled: 50% opacity, no interaction.
    if (!enabled) {
      return Opacity(opacity: 0.5, child: semantics);
    }

    Widget interactive = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        // Hover dims the whole link to 80%, matching HeroUI.
        child: hovered ? Opacity(opacity: 0.8, child: semantics) : semantics,
      ),
    );

    // Tab stop + focus ring, unless the link is deliberately out of traversal.
    if (widget.focusable) {
      interactive = KasyFocusRing(
        onActivate: widget.onPressed,
        borderRadius: BorderRadius.circular(4),
        child: interactive,
      );
    }
    return interactive;
  }
}
