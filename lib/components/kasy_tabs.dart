import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────
/// Data model for a single tab item.
class KasyTabItem {
  /// Visible text. Leave empty for an icon-only tab (requires [icon]).
  final String label;
  final IconData? icon;
  final bool enabled;

  /// Accessibility label read by screen readers. Falls back to [label] when
  /// not provided; required (in spirit) for icon-only tabs, which have no text.
  final String? semanticLabel;

  const KasyTabItem({
    this.label = '',
    this.icon,
    this.enabled = true,
    this.semanticLabel,
  }) : assert(
          label != '' || icon != null,
          'KasyTabItem needs a label, an icon, or both.',
        );
}

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

/// Visual style for [KasyTabs].
enum KasyTabsVariant {
  /// Sliding white pill on a gray container.
  primary,

  /// Blue underline indicator with a bottom divider.
  secondary,
}

/// Sizing mode for [KasyTabs].
enum KasyTabsMode {
  /// Wraps content (intrinsic width tabs). Scrolls horizontally if needed.
  hug,

  /// Each tab stretches to fill the available width equally.
  fill,
}

// ─────────────────────────────────────────────────────────────────────────────
// KasyTabs
// ─────────────────────────────────────────────────────────────────────────────

/// Animated tab bar with primary (pill) and secondary (underline) variants.
///
/// Usage:
/// ```dart
/// KasyTabs(
///   tabs: ['General', 'Appearance', 'Notifications'],
///   selectedIndex: _index,
///   onTabSelected: (i) => setState(() => _index = i),
/// )
/// ```
///
/// Supports [KasyTabItem] for per-tab icons and disabled state. The short-form
/// constructor accepts plain [String] labels.
class KasyTabs extends StatefulWidget {
  /// Plain-string convenience constructor.
  ///
  /// Converts each string to a [KasyTabItem] with default settings.
  KasyTabs({
    super.key,
    required List<String> tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.variant = KasyTabsVariant.primary,
    this.mode = KasyTabsMode.hug,
  }) : items = tabs.map((l) => KasyTabItem(label: l)).toList();

  /// Full constructor accepting [KasyTabItem] instances (supports icons/disabled).
  const KasyTabs.items({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
    this.variant = KasyTabsVariant.primary,
    this.mode = KasyTabsMode.hug,
  });

  final List<KasyTabItem> items;

  /// Index of the currently selected tab.
  final int selectedIndex;

  /// Called when the user taps an enabled tab.
  final ValueChanged<int> onTabSelected;

  final KasyTabsVariant variant;
  final KasyTabsMode mode;

  @override
  State<KasyTabs> createState() => _KasyTabsState();
}

class _KasyTabsState extends State<KasyTabs> {
  // One GlobalKey per tab to measure position/size after layout.
  late List<GlobalKey> _keys;

  // Key for the inner indicator Stack — used as the coordinate reference
  // for measurements, ensuring correctness even when wrapped in a ScrollView.
  final GlobalKey _stackKey = GlobalKey();

  // Controls horizontal scrolling in hug mode so we can snap to the
  // beginning/end when the first/last tab is selected (clears container
  // padding and the pill overflow that extends 4px past tab edges).
  final ScrollController _scrollController = ScrollController();

  // Indicator geometry (left offset, width) resolved from measured keys.
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;

  // Slide duration for a genuine tab *selection* change.
  static const Duration _kSelectionSlide = Duration(milliseconds: 250);

  // Duration applied to the indicator's implicit animation. A tab *selection*
  // slides (250ms); a *layout resize* (e.g. a sidebar animating from narrow to
  // wide) snaps instantly so the pill tracks the new width frame-by-frame
  // instead of lagging behind with a stray slide. Starts at zero so the very
  // first paint places the pill without animating in.
  Duration _indicatorDuration = Duration.zero;

  // Whether we have a valid measurement yet.
  bool _measured = false;

  // Last layout width seen. The pill/underline geometry is measured from the
  // laid-out tab boxes, so it must be recomputed whenever the bar's own width
  // changes — e.g. when a collapsing sidebar animates the tabs open, the first
  // measure happens at the narrow start width and would otherwise stay stuck in
  // the corner until the next selection. Re-measuring per resize lets the
  // indicator track the animation smoothly.
  double? _lastLayoutWidth;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(
      widget.items.length,
      (_) => GlobalKey(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(KasyTabs old) {
    super.didUpdateWidget(old);
    // Rebuild keys list if tab count changes.
    if (old.items.length != widget.items.length) {
      _keys = List.generate(
        widget.items.length,
        (_) => GlobalKey(),
      );
      _measured = false;
    }
    // Re-measure whenever selected index changes or keys were rebuilt. Only a
    // selection change slides the indicator; a key rebuild snaps into place.
    final bool selectionChanged = old.selectedIndex != widget.selectedIndex;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _measure(animate: selectionChanged),
    );
  }

  void _measure({bool animate = false}) {
    if (!mounted) return;
    if (widget.items.isEmpty) return;

    final int clampedIndex = widget.selectedIndex.clamp(
      0,
      widget.items.length - 1,
    );

    // Measure relative to the inner Stack, not the outermost widget.
    // This stays correct even when the component is inside a ScrollView.
    final RenderBox? containerBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (containerBox == null) return;

    final GlobalKey key = _keys[clampedIndex];
    final RenderBox? tabBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (tabBox == null) return;

    final Offset tabOffset = tabBox.localToGlobal(
      Offset.zero,
      ancestor: containerBox,
    );

    final double newLeft = tabOffset.dx;
    final double newWidth = tabBox.size.width;

    if (!_measured ||
        (_indicatorLeft - newLeft).abs() > 0.1 ||
        (_indicatorWidth - newWidth).abs() > 0.1) {
      setState(() {
        _indicatorLeft = newLeft;
        _indicatorWidth = newWidth;
        // Slide only for a real selection change; a resize snaps instantly.
        _indicatorDuration = animate ? _kSelectionSlide : Duration.zero;
        _measured = true;
      });
    }

    // In hug mode, scroll the selected tab into view (handles overflow).
    if (widget.mode == KasyTabsMode.hug) {
      _ensureSelectedVisible(clampedIndex);
    }
  }

  /// Scrolls the inner [SingleChildScrollView] so the selected tab is visible.
  ///
  /// Only the component's OWN horizontal controller is moved — never an
  /// ancestor scrollable. (Using [Scrollable.ensureVisible] here would bubble
  /// up and scroll the enclosing page vertically, e.g. nudging the Settings
  /// list down when picking a middle tab.) First/last tab snap to the scroll
  /// extremes so the container padding and the 4px pill overflow aren't clipped.
  void _ensureSelectedVisible(int index) {
    if (!_scrollController.hasClients) return;

    final ScrollPosition position = _scrollController.position;
    final double min = position.minScrollExtent;
    final double max = position.maxScrollExtent;
    // No horizontal overflow: leave every scroll position untouched.
    if (max <= min) return;

    const Duration duration = Duration(milliseconds: 250);
    const Curve curve = Curves.easeInOut;
    final int lastIndex = widget.items.length - 1;

    final double target;
    if (index == 0) {
      target = min;
    } else if (index == lastIndex) {
      target = max;
    } else {
      // Centre the selected tab in the viewport. Measured geometry is relative
      // to the inner Stack, which sits 8px in from the scrollable content edge
      // (the tabsContent horizontal padding).
      const double horizontalPadding = 8;
      final double tabCentre =
          horizontalPadding + _indicatorLeft + _indicatorWidth / 2;
      target = (tabCentre - position.viewportDimension / 2).clamp(min, max);
    }
    _scrollController.animateTo(target, duration: duration, curve: curve);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        // Re-measure on every width change (e.g. a sidebar animating open) so
        // the indicator follows instead of sticking at its first-frame spot.
        if (_lastLayoutWidth == null ||
            (_lastLayoutWidth! - width).abs() > 0.5) {
          _lastLayoutWidth = width;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _measure();
          });
        }
        return widget.variant == KasyTabsVariant.primary
            ? _buildPrimary(context)
            : _buildSecondary(context);
      },
    );
  }

  // ── Primary (pill indicator) ───────────────────────────────────────────────

  Widget _buildPrimary(BuildContext context) {
    final KasyColors c = context.colors;
    final bool isFill = widget.mode == KasyTabsMode.fill;
    final BorderRadius pillRadius = BorderRadius.circular(KasyRadius.full);

    final Widget tabsContent = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.sm,
        vertical: KasySpacing.xs,
      ),
      child: Stack(
        key: _stackKey,
        // Allow pill to extend 4px beyond each tab edge (Figma: inset 0 -4px).
        clipBehavior: Clip.none,
        children: [
          // Animated pill background.
          if (_measured)
            AnimatedPositioned(
              duration: _indicatorDuration,
              curve: Curves.easeInOut,
              // Extends 4px on each side beyond the measured tab.
              left: _indicatorLeft - 4,
              top: 0,
              bottom: 0,
              width: _indicatorWidth + 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(KasyRadius.full),
                  boxShadow: KasyShadows.tabOf(context),
                ),
              ),
            ),
          // Tab labels (on top of the pill).
          Row(
            mainAxisSize: isFill ? MainAxisSize.max : MainAxisSize.min,
            children: [
              for (int i = 0; i < widget.items.length; i++) ...[
                // 2px gap between adjacent tabs — per Figma spec.
                if (i > 0) const SizedBox(width: 2),
                _PrimaryTab(
                  key: _keys[i],
                  item: widget.items[i],
                  selected: i == widget.selectedIndex,
                  expand: isFill,
                  onTap: widget.items[i].enabled
                      ? () => widget.onTabSelected(i)
                      : null,
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (!isFill) {
      // Hug mode + horizontal overflow: keep the rounded container fixed at
      // the parent's width and scroll only the tab strip INSIDE it. Putting
      // the DecoratedBox inside the SingleChildScrollView (the previous
      // structure) made the entire pill background scroll along with the
      // tabs, so once the user scrolled the rounded corners were pushed off-
      // screen and the visible portion looked like a flat-sided rectangle.
      // Now the corners stay visible at the viewport edges no matter where
      // the strip is scrolled, and ClipRRect masks any tab content that
      // would otherwise leak past the rounded edges.
      return DecoratedBox(
        decoration: BoxDecoration(
          color: c.avatarFallbackFill,
          borderRadius: pillRadius,
        ),
        child: ClipRRect(
          borderRadius: pillRadius,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: tabsContent,
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.avatarFallbackFill,
        borderRadius: pillRadius,
      ),
      child: tabsContent,
    );
  }

  // ── Secondary (underline indicator) ───────────────────────────────────────

  Widget _buildSecondary(BuildContext context) {
    final KasyColors c = context.colors;
    final bool isFill = widget.mode == KasyTabsMode.fill;

    final Widget inner = Stack(
      key: _stackKey,
      clipBehavior: Clip.none,
      children: [
        // Full-width bottom divider.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.outline.withValues(alpha: 0.2),
            ),
            child: const SizedBox(height: 1),
          ),
        ),
        // Animated underline indicator.
        if (_measured)
          AnimatedPositioned(
            duration: _indicatorDuration,
            curve: Curves.easeInOut,
            left: _indicatorLeft,
            bottom: 0,
            width: _indicatorWidth,
            height: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        // Tab labels.
        Row(
          mainAxisSize: isFill ? MainAxisSize.max : MainAxisSize.min,
          children: List.generate(widget.items.length, (i) {
            final KasyTabItem item = widget.items[i];
            final bool selected = i == widget.selectedIndex;
            return _SecondaryTab(
              key: _keys[i],
              item: item,
              selected: selected,
              expand: isFill,
              onTap: item.enabled ? () => widget.onTabSelected(i) : null,
            );
          }),
        ),
      ],
    );

    // Same as primary: hug mode sizes to content via ScrollView.
    if (!isFill) {
      return SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: inner,
      );
    }

    return inner;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal tab widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Adds a pointer (click) cursor and reports hover changes on web/desktop.
/// Disabled tabs keep the default cursor and never report hover.
class _TabHoverRegion extends StatelessWidget {
  const _TabHoverRegion({
    required this.enabled,
    required this.onHover,
    required this.child,
  });

  final bool enabled;
  final ValueChanged<bool> onHover;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: enabled ? (_) => onHover(true) : null,
      onExit: enabled ? (_) => onHover(false) : null,
      child: child,
    );
  }
}

class _PrimaryTab extends StatefulWidget {
  const _PrimaryTab({
    super.key,
    required this.item,
    required this.selected,
    required this.expand,
    required this.onTap,
  });

  final KasyTabItem item;
  final bool selected;
  final bool expand;
  final VoidCallback? onTap;

  @override
  State<_PrimaryTab> createState() => _PrimaryTabState();
}

class _PrimaryTabState extends State<_PrimaryTab> {
  bool _hovered = false;

  Widget _tabContent(BuildContext context) {
    final KasyColors c = context.colors;
    final KasyTabItem item = widget.item;
    final bool selected = widget.selected;
    final bool disabled = !item.enabled;
    final bool hasLabel = item.label.isNotEmpty;
    final bool iconOnly = item.icon != null && !hasLabel;
    // Fill mode with a label + icon uses a vertical (Column) layout per Figma
    // spec: icon stacked above label, 12px all-sides padding, 12px font size.
    final bool verticalLayout = widget.expand && item.icon != null && hasLabel;

    // On web/desktop, hovering an inactive tab lifts its foreground toward the
    // selected color so it reads as interactive (mobile keeps the flat look).
    final Color fg = (selected || _hovered) ? c.onSurface : c.muted;

    final Widget iconWidget = item.icon != null
        ? Opacity(
            opacity: disabled ? 0.4 : 1.0,
            child: Icon(
              item.icon,
              size: KasyIconSize.sm,
              color: fg,
            ),
          )
        : const SizedBox.shrink();

    final Widget labelWidget = Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: Text(
        item.label,
        textAlign: TextAlign.center,
        // Fill mode gives each tab an equal share of the width; a long label
        // (often a longer localized string) ellipsizes within its slot instead
        // of overflowing the row. Hug mode is intrinsic + scrollable, so the
        // single line never clips there.
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        // labelLarge = HeroUI Body sm medium (14 / w500). No weight override —
        // the theme token is the source of truth.
        style: context.textTheme.labelLarge?.copyWith(
          color: fg,
          // Stacked icon+label layout drops to 12 (Body xs) — per Figma spec.
          fontSize: verticalLayout ? 12 : null,
        ),
      ),
    );

    final Widget gesture = KasyFocusRing(
      enabled: widget.onTap != null,
      onActivate: widget.onTap,
      borderRadius: BorderRadius.circular(KasyRadius.sm),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: verticalLayout
              // Fill+icon: 12px all sides — per Figma spec.
              ? const EdgeInsets.all(KasySpacing.smd)
              // Default: 6px vertical, 12px horizontal — per Figma spec.
              : const EdgeInsets.symmetric(
                  vertical: KasySpacing.xs + 2,
                  horizontal: KasySpacing.smd,
                ),
          child: verticalLayout
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    iconWidget,
                    const SizedBox(height: KasySpacing.xs + 2),
                    labelWidget,
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.icon != null) iconWidget,
                    if (item.icon != null && hasLabel)
                      const SizedBox(width: 6),
                    // Constrain the label only in fill mode (bounded width via
                    // Expanded). Hug mode lays out in an unbounded scroll view,
                    // where a Flexible child would have no bound to flex within.
                    if (hasLabel)
                      widget.expand
                          ? Flexible(child: labelWidget)
                          : labelWidget,
                  ],
                ),
        ),
      ),
    );

    final Widget hoverable = _TabHoverRegion(
      enabled: !disabled,
      onHover: (value) => setState(() => _hovered = value),
      child: gesture,
    );

    // Icon-only tabs carry no text, so expose the selection state and a label
    // to screen readers explicitly (labelled tabs are described by their Text).
    if (iconOnly) {
      return Semantics(
        button: true,
        selected: selected,
        label: item.semanticLabel,
        child: hoverable,
      );
    }
    return hoverable;
  }

  @override
  Widget build(BuildContext context) {
    final Widget inner = _tabContent(context);
    return widget.expand ? Expanded(child: inner) : inner;
  }
}

class _SecondaryTab extends StatefulWidget {
  const _SecondaryTab({
    super.key,
    required this.item,
    required this.selected,
    required this.expand,
    required this.onTap,
  });

  final KasyTabItem item;
  final bool selected;
  final bool expand;
  final VoidCallback? onTap;

  @override
  State<_SecondaryTab> createState() => _SecondaryTabState();
}

class _SecondaryTabState extends State<_SecondaryTab> {
  bool _hovered = false;

  Widget _tabContent(BuildContext context) {
    final KasyColors c = context.colors;
    final KasyTabItem item = widget.item;
    final bool selected = widget.selected;
    final bool disabled = !item.enabled;
    final bool hasLabel = item.label.isNotEmpty;
    final bool iconOnly = item.icon != null && !hasLabel;

    // On web/desktop, hovering an inactive tab lifts its foreground toward the
    // selected color so it reads as interactive (mobile keeps the flat look).
    final Color fg = (selected || _hovered) ? c.onSurface : c.muted;

    final Widget gesture = KasyFocusRing(
      enabled: widget.onTap != null,
      onActivate: widget.onTap,
      borderRadius: BorderRadius.circular(KasyRadius.sm),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          // top:4 bottom:6 horizontal:12 — per Figma spec.
          // Extra bottom padding visually balances the 2px underline indicator.
          padding: const EdgeInsets.only(
            top: 4,
            bottom: 6,
            left: 12,
            right: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.icon != null) ...[
                Opacity(
                  opacity: disabled ? 0.4 : 1.0,
                  child: Icon(
                    item.icon,
                    size: KasyIconSize.sm,
                    color: fg,
                  ),
                ),
                if (hasLabel) const SizedBox(width: 6),
              ],
              if (hasLabel)
                // Fill mode constrains the label to its equal slot (ellipsis on
                // overflow); hug mode stays intrinsic + scrollable. See the
                // primary variant for the unbounded-width rationale.
                Builder(builder: (context) {
                  final Widget label = Opacity(
                    opacity: disabled ? 0.4 : 1.0,
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // Use labelLarge as defined in the Kasy theme (14px/w600).
                      style: context.textTheme.labelLarge?.copyWith(
                        color: fg,
                      ),
                    ),
                  );
                  return widget.expand ? Flexible(child: label) : label;
                }),
            ],
          ),
        ),
      ),
    );

    final Widget hoverable = _TabHoverRegion(
      enabled: !disabled,
      onHover: (value) => setState(() => _hovered = value),
      child: gesture,
    );

    // Icon-only tabs carry no text, so expose the selection state and a label
    // to screen readers explicitly (labelled tabs are described by their Text).
    if (iconOnly) {
      return Semantics(
        button: true,
        selected: selected,
        label: item.semanticLabel,
        child: hoverable,
      );
    }
    return hoverable;
  }

  @override
  Widget build(BuildContext context) {
    final Widget inner = _tabContent(context);
    return widget.expand ? Expanded(child: inner) : inner;
  }
}
