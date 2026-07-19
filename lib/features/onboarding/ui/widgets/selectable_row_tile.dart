import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/material.dart';

typedef OnSelectRow = void Function(int index, bool selected);

/// Ex of usage
/// SelectableRowGroup(
///   onSelect: (index, selected) => onSelect(snapshot.data![index]),
///   options: snapshot.data!
///       .map(
///         (e) => SelectableOption(
///           title: e.name,
///           subtitle: "Created on ${e.formattedCreationDate}",
///        ),
///       )
///       .toList(),
/// )
class OnboardingSelectableRowGroup extends StatefulWidget {
  final List<Widget> options;
  final List<Widget?>? onSelectInfoWidget;
  final OnSelectRow? onSelect;
  final int? initialSelectedIndex;
  final ScrollPhysics? physics;

  const OnboardingSelectableRowGroup({
    super.key,
    required this.options,
    this.onSelect,
    this.initialSelectedIndex,
    this.onSelectInfoWidget,
    this.physics,
  });

  @override
  State<OnboardingSelectableRowGroup> createState() =>
      _OnboardingSelectableRowGroupState();
}

class _OnboardingSelectableRowGroupState
    extends State<OnboardingSelectableRowGroup> {
  int? _selectedIndex;

  @override
  void initState() {
    _selectedIndex = widget.initialSelectedIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: widget.physics,
      shrinkWrap: true,
      separatorBuilder: (context, index) =>
          const SizedBox(height: KasySpacing.sm),
      itemCount: widget.options.length,
      itemBuilder: (context, index) {
        final hasOnSelectInfo =
            widget.onSelectInfoWidget != null &&
            widget.onSelectInfoWidget!.length > index &&
            widget.onSelectInfoWidget![index] != null;
        void selectRow() {
          if (_selectedIndex == index) {
            return;
          }
          setState(() {
            _selectedIndex = index;
          });
          widget.onSelect?.call(index, true);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SelectableTileInk(
              onTap: selectRow,
              borderRadius: KasyRadius.lgBorderRadius,
              child: widget.options[index],
            ),
            if (hasOnSelectInfo && _selectedIndex == index)
              Padding(
                padding: const EdgeInsets.only(
                  top: KasySpacing.sm,
                  bottom: KasySpacing.md,
                ),
                child: widget.onSelectInfoWidget![index],
              ),
          ],
        );
      },
    );
  }
}

class OnboardingMultiSelectableRowGroup extends StatefulWidget {
  final List<SelectableOption> options;
  final OnSelectRow? onSelect;
  final ScrollPhysics? physics;
  // final int? initialSelectedIndex;

  const OnboardingMultiSelectableRowGroup({
    super.key,
    required this.options,
    this.onSelect,
    this.physics,
  });

  @override
  State<OnboardingMultiSelectableRowGroup> createState() =>
      _OnboardingMultiSelectableRowGroupState();
}

class _OnboardingMultiSelectableRowGroupState
    extends State<OnboardingMultiSelectableRowGroup> {
  final Set<int> _selectedIndex = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: KasySpacing.sm,
      runSpacing: KasySpacing.sm,
      children: widget.options.map((option) {
        final index = widget.options.indexOf(option);
        void toggleSelection() {
          if (_selectedIndex.contains(index)) {
            _selectedIndex.remove(index);
            widget.onSelect?.call(index, false);
          } else {
            _selectedIndex.add(index);
            widget.onSelect?.call(index, true);
          }
          setState(() {});
        }

        return _SelectableTileInk(
          onTap: toggleSelection,
          // Match the tile's own lgBorderRadius so the hover veil and focus ring
          // hug its shape (the old InkWell clipped at md, a mismatch).
          borderRadius: KasyRadius.lgBorderRadius,
          child: SelectableRowTile(
            title: option.title,
            subtitle: option.subtitle,
            selected: _selectedIndex.contains(index),
            emoj: option.emoj,
          ),
        );
      }).toList(),
    );
  }
}

class SelectableOption {
  final String title;
  final String? subtitle;
  final String? emoj;
  final bool selected;

  const SelectableOption({
    required this.title,
    this.subtitle,
    this.selected = false,
    this.emoj,
  });
}

/// A pill‑shaped single‑choice option used by the onboarding questions in their
/// `wrap` layout. Filled with the brand color when selected, a clean outlined
/// surface otherwise. Visual only — taps/hover/focus are handled by the
/// enclosing [OnboardingSelectableChipGroup].
class SelectableChipTile extends StatelessWidget {
  final String label;
  final bool selected;

  const SelectableChipTile({
    super.key,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bool dark = context.isDark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.smd + 2,
        vertical: KasySpacing.sm,
      ),
      decoration: BoxDecoration(
        // Clean outlined selection: same surface as the rest, just a brand
        // outline + brand text. No fill — that would compete with the filled
        // primary "Continue" button below.
        color: colors.surface,
        borderRadius: KasyRadius.fullBorderRadius,
        border: Border.all(
          color: selected
              ? colors.primary
              : colors.outline.withValues(alpha: dark ? 0.9 : 0.7),
          width: selected ? 1.5 : 1,
        ),
        boxShadow: [
          // Only the unselected pills carry a soft depth; the selected one sits
          // flat, its brand outline doing the talking.
          if (!selected)
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.22 : 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        style: (context.textTheme.bodyMedium ?? const TextStyle()).copyWith(
          // Brand-colored text when selected (a touch bolder) reinforces the
          // outline without any fill.
          color: selected ? colors.primary : colors.onSurface,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        ),
        child: Text(label),
      ),
    );
  }
}

/// Single‑choice group that lays its (pre‑built, selection‑baked) chip options
/// out in a centered [Wrap]. Selection is parent‑driven: each chip reports its
/// tap via [onSelect]; the parent flips the selected state and rebuilds. Reuses
/// the same hover/focus/press affordance as the row tiles ([_SelectableTileInk]),
/// clipped to the pill shape.
class OnboardingSelectableChipGroup extends StatelessWidget {
  final List<Widget> options;
  final OnSelectRow? onSelect;
  final WrapAlignment alignment;

  /// Optional deterministic split: e.g. `[3, 2]` lays the first three chips on
  /// one centered row and the next two on the row below (instead of letting a
  /// [Wrap] decide, which is fragile at the pixel margin). Any options beyond
  /// the listed counts spill into a trailing wrapped row. Null → plain wrap.
  final List<int>? rowCounts;

  const OnboardingSelectableChipGroup({
    super.key,
    required this.options,
    this.onSelect,
    this.alignment = WrapAlignment.center,
    this.rowCounts,
  });

  Widget _chip(int i) => _SelectableTileInk(
        onTap: () => onSelect?.call(i, true),
        borderRadius: KasyRadius.fullBorderRadius,
        child: options[i],
      );

  @override
  Widget build(BuildContext context) {
    if (rowCounts == null) {
      // Full width so the centered rows sit in the middle of the screen, rather
      // than the Wrap shrinking to its content and hugging the left edge.
      return SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: alignment,
          spacing: KasySpacing.sm,
          runSpacing: KasySpacing.sm,
          children: <Widget>[for (int i = 0; i < options.length; i++) _chip(i)],
        ),
      );
    }

    final List<Widget> rows = <Widget>[];
    int idx = 0;
    for (final int count in rowCounts!) {
      final List<Widget> cells = <Widget>[];
      for (int k = 0; k < count && idx < options.length; k++, idx++) {
        if (cells.isNotEmpty) {
          cells.add(const SizedBox(width: KasySpacing.sm));
        }
        cells.add(_chip(idx));
      }
      if (cells.isEmpty) continue;
      if (rows.isNotEmpty) rows.add(const SizedBox(height: KasySpacing.sm));
      rows.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: cells));
    }
    // Leftovers (counts didn't cover everything) → a trailing centered wrap.
    if (idx < options.length) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: KasySpacing.sm));
      rows.add(Wrap(
        alignment: WrapAlignment.center,
        spacing: KasySpacing.sm,
        runSpacing: KasySpacing.sm,
        children: <Widget>[
          for (int i = idx; i < options.length; i++) _chip(i),
        ],
      ));
    }
    return Column(children: rows);
  }
}

/// Single row tile with a selectable radio box
class SelectableRowTile extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final String? emoj;
  final bool selected;
  final VoidCallback? onTap;

  const SelectableRowTile({
    super.key,
    this.title,
    this.subtitle,
    this.selected = false,
    this.onTap,
    this.emoj,
  });

  @override
  State<SelectableRowTile> createState() => _SelectableRowTileState();
}

class _SelectableRowTileState extends State<SelectableRowTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _iconSizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    _iconSizeAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    if (widget.selected) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant SelectableRowTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected && widget.selected) {
      _controller.forward();
    } else if (oldWidget.selected != widget.selected && !widget.selected) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.selected ? colors.primary : colors.outline,
          width: widget.selected ? 1.5 : 1,
        ),
        borderRadius: KasyRadius.lgBorderRadius,
        color: widget.selected ? colors.surfacePrimarySoft : colors.surface,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.md,
      ),
      child: Row(
        children: [
          if (widget.emoj != null)
            Flexible(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.only(right: KasySpacing.md),
                child: Text(
                  widget.emoj!,
                  style: context.textTheme.titleMedium
                      ?.copyWith(fontSize: 28), // design-check: ignore — emoji glyph
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      // Content-row title caps at w600 (selection feedback comes
                      // from the radio + border, not a heavier-than-régua w700).
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (widget.subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: KasySpacing.xs),
                    child: Text(
                      widget.subtitle!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: KasySpacing.sm),
          if (!widget.selected)
            Flexible(flex: 0, child: RoundRadioBox.unselected(context)),
          if (widget.selected)
            Flexible(
              flex: 0,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return RoundRadioBox.selected(
                    context,
                    iconOpacity: _opacityAnimation.value,
                    iconSize: _iconSizeAnimation.value,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Adds a web hover highlight, a keyboard focus ring and a click cursor on top
/// of an opaque selectable tile — no Material ripple.
///
/// Because the tile paints its own background, the hover veil is layered ABOVE
/// the child (clipped to [borderRadius]), the same approach the tappable
/// [KasyCard] uses; a [KasyHover]-style overlay would sit behind the opaque
/// surface and never show. The child keeps its own semantics (the option title),
/// so screen readers still announce the option, not a generic label.
class _SelectableTileInk extends StatefulWidget {
  const _SelectableTileInk({
    required this.onTap,
    required this.borderRadius,
    required this.child,
  });

  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  State<_SelectableTileInk> createState() => _SelectableTileInkState();
}

class _SelectableTileInkState extends State<_SelectableTileInk> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    // Subtle tint that fades in on hover (web/desktop) and deepens briefly on
    // press; invisible at rest. On touch _hovered never becomes true.
    final double alpha = _pressed
        ? (dark ? 0.10 : 0.06)
        : (_hovered ? (dark ? 0.06 : 0.04) : 0.0);

    final Widget veiled = Stack(
      children: <Widget>[
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: context.colors.onSurface.withValues(alpha: alpha),
                borderRadius: widget.borderRadius,
              ),
            ),
          ),
        ),
      ],
    );

    return KasyFocusRing(
      onActivate: widget.onTap,
      borderRadius: widget.borderRadius,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: veiled,
        ),
      ),
    );
  }
}

class RoundRadioBox extends StatelessWidget {
  final Color bgColor;
  final Color borderColor;
  final IconData? icon;
  final double iconOpacity;
  final double iconSize;

  const RoundRadioBox({
    super.key,
    required this.bgColor,
    required this.borderColor,
    this.iconOpacity = 1,
    this.iconSize = 1,
    this.icon,
  });

  factory RoundRadioBox.selected(
    BuildContext context, {
    double iconOpacity = 1,
    double iconSize = 1,
  }) {
    return RoundRadioBox(
      bgColor: context.colors.primary,
      borderColor: context.colors.primary,
      icon: KasyIcons.check,
      iconOpacity: iconOpacity,
      iconSize: iconSize,
    );
  }

  // ignore: avoid_unused_constructor_parameters
  factory RoundRadioBox.unselected(BuildContext context) {
    return RoundRadioBox(
      bgColor: Colors.transparent,
      borderColor: context.colors.outlineButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: icon != null
            ? Opacity(
                opacity: iconOpacity,
                child: Transform.scale(
                  scale: iconSize,
                  child: Icon(icon, color: context.colors.onPrimary, size: KasyIconSize.sm),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
