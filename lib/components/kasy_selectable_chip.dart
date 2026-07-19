import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// A single selectable pill chip — the kit's flicker-free building block for
/// option groups (priority pickers, filters, tag selectors).
///
/// At rest it mirrors [KasyStatusTag] (soft-tinted pill + optional leading dot +
/// label), but it is interactive: [selected] drives a soft accent fill with a
/// coloured dot and label; an unselected chip reads as a quiet neutral pill.
/// Lay several out in a [Wrap] or [Row] for a single- or multi-choice group.
///
/// **Why this is a component and not an inline chip.** Switching selection in a
/// hand-rolled group of chips visibly "blinks". This bakes in the whole
/// no-flicker recipe so call sites never reproduce it:
/// - **Fixed label weight** — selection reads from colour + fill, never a heavier
///   glyph, so the chip's width is stable and the surrounding [Wrap] never
///   reflows when the selection moves (that reflow is the visible "jump").
/// - **Animated dot / label colour** — they track the fill instead of snapping.
/// - **Border fades to its own hue at `alpha 0`** — never `Colors.transparent`,
///   which is transparent *black* and lerps through dark intermediates (the same
///   rule [KasyHover] follows).
///
/// In a list, give each chip a stable [Key] (e.g. `ValueKey(value)`) so a rebuild
/// never reconciles one chip into another and carries stale state for a frame.
class KasySelectableChip extends StatelessWidget {
  const KasySelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
    this.showDot = true,
  });

  /// Text shown in the pill.
  final String label;

  /// Whether this option is currently chosen.
  final bool selected;

  /// Tap handler (selection is parent-driven — flip the state and rebuild).
  final VoidCallback onTap;

  /// Accent used while [selected] (dot + label + soft fill). Defaults to
  /// [KasyColors.primary]. Pass a semantic colour (e.g. a priority token) so the
  /// chosen chip matches the matching display tag.
  final Color? color;

  /// Whether to show the leading status dot. Turn off for a neutral option such
  /// as "None" that should not carry a coloured marker.
  final bool showDot;

  static const Duration _kAnim = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final Color accent = color ?? context.colors.primary;
    final Color dotColor =
        selected ? accent : context.colors.muted.withValues(alpha: 0.45);
    final Color labelColor = selected ? accent : context.colors.muted;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: _kAnim,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: context.isDark ? 0.16 : 0.1)
                : context.colors.surfaceNeutralSoft,
            borderRadius: KasyRadius.fullBorderRadius,
            border: Border.all(
              // Fade to the same hue at alpha 0 when selected — not
              // Colors.transparent (which lerps through black and flickers).
              color: selected
                  ? context.colors.outline.withValues(alpha: 0)
                  : context.colors.outline.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDot) ...[
                AnimatedContainer(
                  duration: _kAnim,
                  curve: Curves.easeOut,
                  width: 6,
                  height: 6,
                  decoration:
                      BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
              ],
              AnimatedDefaultTextStyle(
                duration: _kAnim,
                curve: Curves.easeOut,
                // Fixed weight: selection is signalled by colour + fill, so the
                // glyph width never changes and the group never reflows.
                style: context.kasyTextTheme.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
