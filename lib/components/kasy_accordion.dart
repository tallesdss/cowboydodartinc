import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Visual style variants for [KasyAccordion].
enum KasyAccordionVariant {
  /// Flat list with separators.
  defaultList,

  /// Card-like container with border and soft shadow.
  surface,

  /// FAQ-style elevated card: larger radius, stronger shadow, vertical chevron.
  elevatedCard,
}

/// Whether tapping an item behaves like a classic accordion or allows several
/// panels open at once.
enum KasyAccordionExpansionMode {
  /// At most one item expanded; tapping another closes the previous one.
  single,

  /// Any number of items may be expanded.
  multiple,
}

/// Data model for one accordion row.
class KasyAccordionItemData {
  final IconData? icon;
  final String title;
  final String description;

  const KasyAccordionItemData({
    this.icon,
    required this.title,
    required this.description,
  });
}

/// Kasy design-system accordion with controlled expanded state.
///
/// Use one of the constructors for a clear mental model:
/// - [KasyAccordion.single] — only one section open at a time.
/// - [KasyAccordion.multiple] — several sections open (e.g. FAQ with
///   [KasyAccordionVariant.elevatedCard]).
class KasyAccordion extends StatelessWidget {
  final List<KasyAccordionItemData> items;
  final Set<int> expandedIndices;
  final ValueChanged<Set<int>> onExpandedIndicesChanged;
  final KasyAccordionExpansionMode expansionMode;
  final KasyAccordionVariant variant;
  final double surfaceRadius;

  const KasyAccordion._({
    super.key,
    required this.items,
    required this.expandedIndices,
    required this.expansionMode,
    required this.onExpandedIndicesChanged,
    this.variant = KasyAccordionVariant.defaultList,
    this.surfaceRadius = KasyRadius.xl,
  });

  /// Single expansion: [expandedIndex] is `-1` when nothing is open.
  factory KasyAccordion.single({
    Key? key,
    required List<KasyAccordionItemData> items,
    required int expandedIndex,
    required ValueChanged<int> onExpandedIndexChanged,
    KasyAccordionVariant variant = KasyAccordionVariant.defaultList,
    double surfaceRadius = KasyRadius.xl,
  }) {
    return KasyAccordion._(
      key: key,
      items: items,
      variant: variant,
      surfaceRadius: surfaceRadius,
      expansionMode: KasyAccordionExpansionMode.single,
      expandedIndices: expandedIndex < 0 ? <int>{} : <int>{expandedIndex},
      onExpandedIndicesChanged: (Set<int> next) {
        final int resolved = next.isEmpty ? -1 : next.first;
        onExpandedIndexChanged(resolved);
      },
    );
  }

  /// Multiple sections may stay expanded at once.
  factory KasyAccordion.multiple({
    Key? key,
    required List<KasyAccordionItemData> items,
    required Set<int> expandedIndices,
    required ValueChanged<Set<int>> onExpandedIndicesChanged,
    KasyAccordionVariant variant = KasyAccordionVariant.elevatedCard,
    double surfaceRadius = KasyRadius.xl,
  }) {
    return KasyAccordion._(
      key: key,
      items: items,
      variant: variant,
      surfaceRadius: surfaceRadius,
      expansionMode: KasyAccordionExpansionMode.multiple,
      expandedIndices: expandedIndices,
      onExpandedIndicesChanged: onExpandedIndicesChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool wrapsSurface =
        variant == KasyAccordionVariant.surface ||
        variant == KasyAccordionVariant.elevatedCard;
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(items.length, (int index) {
        return _KasyAccordionRow(
          data: items[index],
          accordionVariant: variant,
          isExpanded: expandedIndices.contains(index),
          showDivider: index < items.length - 1,
          hasTopPadding: index == 0,
          rowHorizontalPadding: variant == KasyAccordionVariant.elevatedCard
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: KasySpacing.smd),
          onTap: () {
            final Set<int> next = _toggleIndices(
              expandedIndices,
              index,
              expansionMode,
            );
            onExpandedIndicesChanged(next);
          },
        );
      }),
    );
    if (!wrapsSurface) {
      return content;
    }
    final EdgeInsets outerPadding = variant == KasyAccordionVariant.elevatedCard
        ? const EdgeInsets.all(KasySpacing.md)
        : const EdgeInsets.all(KasySpacing.sm);
    final Decoration decoration = variant == KasyAccordionVariant.elevatedCard
        ? BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(surfaceRadius),
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.33),
            ),
            boxShadow: [KasyShadows.component(context)],
          )
        : BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(surfaceRadius),
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.22),
            ),
            boxShadow: [KasyShadows.component(context)],
          );
    return DecoratedBox(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(surfaceRadius),
        child: Padding(padding: outerPadding, child: content),
      ),
    );
  }

  /// Computes the next expanded set after [tappedIndex] is toggled (same rules
  /// as the widget applies on tap).
  static Set<int> toggleExpansion(
    Set<int> expandedIndices,
    int tappedIndex,
    KasyAccordionExpansionMode mode,
  ) {
    return _toggleIndices(expandedIndices, tappedIndex, mode);
  }
}

Set<int> _toggleIndices(
  Set<int> expandedIndices,
  int tappedIndex,
  KasyAccordionExpansionMode expansionMode,
) {
  final Set<int> next = Set<int>.from(expandedIndices);
  if (expansionMode == KasyAccordionExpansionMode.single) {
    if (next.contains(tappedIndex)) {
      next.clear();
    } else {
      next
        ..clear()
        ..add(tappedIndex);
    }
    return next;
  }
  if (next.contains(tappedIndex)) {
    next.remove(tappedIndex);
  } else {
    next.add(tappedIndex);
  }
  return next;
}

class _KasyAccordionRow extends StatelessWidget {
  static const double _contentVerticalPadding = KasySpacing.smd;
  static const double _dividerVerticalSpacing = KasySpacing.md;
  static const double _leadingIconLogicalSize = 15.5;

  final KasyAccordionItemData data;
  final KasyAccordionVariant accordionVariant;
  final bool isExpanded;
  final bool showDivider;
  final bool hasTopPadding;
  final EdgeInsets rowHorizontalPadding;
  final VoidCallback onTap;

  const _KasyAccordionRow({
    required this.data,
    required this.accordionVariant,
    required this.isExpanded,
    required this.showDivider,
    required this.hasTopPadding,
    required this.rowHorizontalPadding,
    required this.onTap,
  });

  double _descriptionLeadingInset() {
    final bool alignsWithTitle =
        accordionVariant == KasyAccordionVariant.elevatedCard;
    if (!alignsWithTitle) {
      return 30;
    }
    if (data.icon != null) {
      return _leadingIconLogicalSize + KasySpacing.smd;
    }
    return 0;
  }

  double _dividerAlpha(BuildContext context) {
    switch (accordionVariant) {
      case KasyAccordionVariant.elevatedCard:
        return 0.14;
      case KasyAccordionVariant.surface:
      case KasyAccordionVariant.defaultList:
        return 0.36;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget row = MergeSemantics(
      child: Semantics(
        button: true,
        expanded: isExpanded,
        label: data.title,
        onTapHint: isExpanded ? 'Collapse item' : 'Expand item',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: rowHorizontalPadding,
            child: Column(
              children: [
                if (hasTopPadding)
                  const SizedBox(height: _contentVerticalPadding),
                Row(
                  children: [
                    if (data.icon != null)
                      Icon(
                        data.icon,
                        size: _leadingIconLogicalSize,
                        color: context.colors.muted,
                      ),
                    if (data.icon != null)
                      const SizedBox(width: KasySpacing.smd),
                    Expanded(
                      child: Text(
                        data.title,
                        // Inline row header = HeroUI "Body base medium": 16 /
                        // w500 (content emphasis, not the 18 heading step and
                        // not w600), matching the alert header and settings rows.
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.colors.onSurface,
                        ),
                      ),
                    ),
                    _TrailingChevron(
                      accordionVariant: accordionVariant,
                      isExpanded: isExpanded,
                    ),
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axisAlignment: -1,
                            child: child,
                          ),
                        );
                      },
                  child: isExpanded
                      ? Padding(
                          key: ValueKey<String>('open_${data.title}'),
                          padding: EdgeInsets.only(
                            top: KasySpacing.smd,
                            left: _descriptionLeadingInset(),
                            right: KasySpacing.sm,
                            bottom: KasySpacing.smd,
                          ),
                          child: Text(
                            data.description,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurface.withValues(
                                alpha:
                                    accordionVariant ==
                                        KasyAccordionVariant.elevatedCard
                                    ? 0.56
                                    : 0.62,
                              ),
                              height: 1.45,
                            ),
                          ),
                        )
                      : const SizedBox(key: ValueKey<String>('closed')),
                ),
                if (showDivider)
                  const SizedBox(height: _dividerVerticalSpacing),
                if (showDivider)
                  Container(
                    height: 1,
                    color: context.colors.outline.withValues(
                      alpha: _dividerAlpha(context),
                    ),
                  ),
                if (showDivider)
                  const SizedBox(height: _dividerVerticalSpacing),
                if (!showDivider)
                  const SizedBox(height: _contentVerticalPadding),
              ],
            ),
          ),
        ),
      ),
    );
    if (!kIsWeb) return row;
    return MouseRegion(cursor: SystemMouseCursors.click, child: row);
  }
}

class _TrailingChevron extends StatelessWidget {
  final KasyAccordionVariant accordionVariant;
  final bool isExpanded;

  const _TrailingChevron({
    required this.accordionVariant,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    if (accordionVariant == KasyAccordionVariant.elevatedCard) {
      return AnimatedRotation(
        turns: isExpanded ? -0.5 : 0,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          KasyIcons.chevronDown,
          size: KasyIconSize.md,
          color: context.colors.muted,
        ),
      );
    }
    return AnimatedRotation(
      turns: isExpanded ? -0.25 : 0.25,
      duration: const Duration(milliseconds: 200),
      child: Icon(
        KasyIcons.chevronRight,
        size: KasyIconSize.md,
        color: context.colors.muted,
      ),
    );
  }
}
