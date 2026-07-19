import 'package:cowboydodartinc/components/kasy_toggle_button.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// How many toggles in a [KasyToggleButtonGroup] can be on at once.
enum KasyToggleGroupSelection { single, multiple }

/// One option inside a [KasyToggleButtonGroup].
class KasyToggleButtonItem {
  const KasyToggleButtonItem({
    this.label,
    this.icon,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  }) : assert(
          label != null || icon != null,
          'Provide a label or an icon for the toggle.',
        );

  final String? label;
  final IconData? icon;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool enabled;
}

/// Kasy-styled toggle button group (HeroUI ToggleButtonGroup) — arranges several
/// [KasyToggleButton]s into one control for single- or multi-select.
///
/// [isAttached] true is a segmented control: cells sit flush inside one rounded
/// container, split by hairline dividers. False spaces the toggles as separate
/// pills. Works on either [orientation]; [expand] stretches cells to fill width.
class KasyToggleButtonGroup extends StatelessWidget {
  const KasyToggleButtonGroup({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.selectionMode = KasyToggleGroupSelection.single,
    this.isAttached = true,
    this.orientation = Axis.horizontal,
    this.size = KasyToggleButtonSize.md,
    this.expand = false,
  });

  final List<KasyToggleButtonItem> items;

  /// Indices currently selected.
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  final KasyToggleGroupSelection selectionMode;
  final bool isAttached;
  final Axis orientation;
  final KasyToggleButtonSize size;

  /// Stretch the cells to fill the available main-axis space.
  final bool expand;

  bool get _horizontal => orientation == Axis.horizontal;

  double get _height => switch (size) {
        KasyToggleButtonSize.sm => 32,
        KasyToggleButtonSize.md => 36,
        KasyToggleButtonSize.lg => 40,
      };

  void _onToggle(int index, bool willSelect) {
    final Set<int> next = <int>{...selected};
    if (selectionMode == KasyToggleGroupSelection.single) {
      next
        ..clear()
        ..add(index);
    } else if (willSelect) {
      next.add(index);
    } else {
      next.remove(index);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      final KasyToggleButtonItem item = items[i];
      final Widget toggle = KasyToggleButton(
        label: item.label,
        icon: item.icon,
        prefixIcon: item.prefixIcon,
        suffixIcon: item.suffixIcon,
        size: size,
        // Attached cells are flush and transparent-at-rest (ghost) so the
        // group's neutral surface reads as one continuous segmented control;
        // detached toggles are standalone filled pills.
        variant: isAttached
            ? KasyToggleButtonVariant.ghost
            : KasyToggleButtonVariant.filled,
        borderRadius: isAttached ? BorderRadius.zero : null,
        selected: selected.contains(i),
        onChanged: item.enabled ? (v) => _onToggle(i, v) : null,
      );
      children.add(expand ? Expanded(child: toggle) : toggle);
      if (isAttached && i < items.length - 1) {
        children.add(_GroupDivider(horizontal: _horizontal, extent: _height));
      }
    }

    final Widget flex = Flex(
      direction: orientation,
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: isAttached ? 0 : KasySpacing.xs,
      children: children,
    );

    // Bound the cross axis so `stretch` resolves to the tallest cell instead of
    // forcing an infinite extent (which crashes under an unbounded parent).
    final Widget bounded = _horizontal
        ? IntrinsicHeight(child: flex)
        : IntrinsicWidth(child: flex);

    if (!isAttached) return bounded;

    // Segmented control: one rounded, clipped neutral surface behind the cells.
    final BorderRadius radius = BorderRadius.circular(_height / 2);
    return ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.neutral,
          borderRadius: radius,
        ),
        child: bounded,
      ),
    );
  }
}

/// Hairline divider between attached cells, inset along its length like HeroUI.
class _GroupDivider extends StatelessWidget {
  const _GroupDivider({required this.horizontal, required this.extent});

  final bool horizontal;
  final double extent;

  @override
  Widget build(BuildContext context) {
    final double inset = extent / 4;
    final Color color = context.colors.separatorSecondary;
    return Padding(
      padding: horizontal
          ? EdgeInsets.symmetric(vertical: inset)
          : EdgeInsets.symmetric(horizontal: inset),
      child: SizedBox(
        width: horizontal ? 1 : null,
        height: horizontal ? null : 1,
        child: ColoredBox(color: color),
      ),
    );
  }
}
