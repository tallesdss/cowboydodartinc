import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/material.dart';

/// Surface styling of a [KasyTag] (HeroUI Tag variant).
///
/// [neutral] is the standard grey fill (HeroUI "default"); [surface] is white,
/// for tags sitting on a secondary/tinted surface that needs more contrast.
enum KasyTagVariant { neutral, surface }

/// Size of a [KasyTag]. Heights 20 / 24 / 32.
enum KasyTagSize { sm, md, lg }

extension _KasyTagSizeX on KasyTagSize {
  double get height => switch (this) {
        KasyTagSize.sm => 20,
        KasyTagSize.md => 24,
        KasyTagSize.lg => 32,
      };

  double get paddingH => switch (this) {
        KasyTagSize.sm => 4,
        KasyTagSize.md => 6,
        KasyTagSize.lg => 10,
      };

  double get fontSize => this == KasyTagSize.lg ? 14 : 12;
  double get lineHeight => this == KasyTagSize.lg ? 20 / 14 : 16 / 12;
  double get iconSize => this == KasyTagSize.lg ? 14 : 12;
  double get radius => this == KasyTagSize.lg ? 16 : 12;
}

/// Kasy-styled tag (HeroUI Tag) — a compact, optionally interactive chip used
/// inside a [KasyTagGroup] for categorising, filtering or labelling.
///
/// Pass [onPressed] to make it selectable ([selected] paints the soft-accent
/// state) and/or [onRemove] to show a trailing remove (×) affordance. Disabled
/// ([enabled] false) drops to 50% opacity.
class KasyTag extends StatefulWidget {
  const KasyTag({
    super.key,
    required this.label,
    this.variant = KasyTagVariant.neutral,
    this.size = KasyTagSize.md,
    this.selected = false,
    this.onPressed,
    this.onRemove,
    this.prefixIcon,
    this.enabled = true,
    this.semanticLabel,
  });

  final String label;
  final KasyTagVariant variant;
  final KasyTagSize size;
  final bool selected;

  /// Makes the tag selectable; called on tap.
  final VoidCallback? onPressed;

  /// Shows a trailing × that removes the tag when tapped.
  final VoidCallback? onRemove;

  final IconData? prefixIcon;
  final bool enabled;
  final String? semanticLabel;

  bool get _interactive => enabled && onPressed != null;

  @override
  State<KasyTag> createState() => _KasyTagState();
}

class _KasyTagState extends State<KasyTag> {
  bool _hovered = false;

  Color _backgroundColor(KasyColors c) {
    final bool hovered = _hovered && widget._interactive;
    if (widget.selected) {
      return hovered ? c.primarySoftHover : c.primarySoft;
    }
    switch (widget.variant) {
      case KasyTagVariant.neutral:
        return hovered ? c.neutralHover : c.neutral;
      case KasyTagVariant.surface:
        return hovered ? c.neutral : c.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final KasyTagSize size = widget.size;
    final Color fg = widget.selected ? c.primarySoftForeground : c.onSurface;

    final TextStyle textStyle =
        (context.textTheme.bodySmall ?? const TextStyle()).copyWith(
      fontSize: size.fontSize,
      height: size.lineHeight,
      fontWeight: FontWeight.w500,
      color: fg,
    );

    final List<Widget> children = <Widget>[
      if (widget.prefixIcon != null)
        Icon(widget.prefixIcon, size: size.iconSize, color: fg),
      Text(widget.label, style: textStyle),
      if (widget.onRemove != null)
        _RemoveButton(
          size: size.iconSize,
          color: fg,
          enabled: widget.enabled,
          onRemove: widget.onRemove!,
        ),
    ];

    Widget tag = Container(
      height: size.height,
      padding: EdgeInsets.symmetric(horizontal: size.paddingH),
      decoration: BoxDecoration(
        color: _backgroundColor(c),
        borderRadius: BorderRadius.circular(size.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 4,
        children: children,
      ),
    );

    if (!widget.enabled) {
      tag = Opacity(opacity: 0.5, child: tag);
    }

    final BorderRadius radius = BorderRadius.circular(size.radius);

    // Only the whole tag is a tap target when selectable; a remove-only tag
    // leaves interactivity to its × button.
    if (!widget._interactive) {
      return Semantics(
        label: widget.semanticLabel ?? widget.label,
        child: tag,
      );
    }

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.semanticLabel ?? widget.label,
      child: KasyFocusRing(
        onActivate: widget.onPressed,
        borderRadius: radius,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: widget.onPressed,
            behavior: HitTestBehavior.opaque,
            child: tag,
          ),
        ),
      ),
    );
  }
}

/// The trailing × affordance, its own tap target so removing doesn't trigger the
/// tag's selection.
class _RemoveButton extends StatelessWidget {
  const _RemoveButton({
    required this.size,
    required this.color,
    required this.enabled,
    required this.onRemove,
  });

  final double size;
  final Color color;
  final bool enabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Remove',
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          onTap: enabled ? onRemove : null,
          behavior: HitTestBehavior.opaque,
          child: Icon(KasyIcons.close, size: size, color: color),
        ),
      ),
    );
  }
}
