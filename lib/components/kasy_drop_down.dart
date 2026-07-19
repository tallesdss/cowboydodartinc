import 'package:cowboydodartinc/components/kasy_text_field.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KasyDropDown — design-system dropdown (HeroUI "Select"). Single-select by
// default; [KasyDropDown.multiple] picks several values (panel stays open, every
// selected row shows a check, the trigger summarizes the picks).
//
// Two parts, mirroring the Figma spec:
//   • Trigger  — reuses [KasyTextField] in read-only mode, so it inherits the
//                kit input look (label, placeholder, border, shadow, focus
//                affordance). Shows the selected option or a placeholder, plus
//                a chevron that flips while open.
//   • Dropdown — a floating panel anchored to the trigger via [OverlayPortal]
//                (not a Material PopupMenu). The popover lives under the app's
//                Overlay, so it inherits the real light/dark theme — fixing the
//                classic "white menu in dark mode" of raw PopupMenuButton. Opens
//                downward by default, or upward when there isn't room below.
//
// Usage:
//   KasyDropDown<String>(
//     label: 'State',
//     hint: 'Select one',
//     showRequiredIndicator: true,
//     value: selected,
//     items: const [
//       KasyDropDownItem(value: 'fl', label: 'Florida'),
//       KasyDropDownItem(value: 'tx', label: 'Texas'),
//     ],
//     onChanged: (v) => setState(() => selected = v),
//   )
// ─────────────────────────────────────────────────────────────────────────────
/// One selectable option in a [KasyDropDown].
class KasyDropDownItem<T> {
  const KasyDropDownItem({
    required this.value,
    required this.label,
    this.icon,
    this.subtitle,
    this.enabled = true,
  });

  /// The value reported through [KasyDropDown.onChanged] when this option is
  /// picked. Must be unique within the list.
  final T value;

  /// Primary text shown for the option (and in the trigger once selected).
  final String label;

  /// Optional leading icon, rendered before the label.
  final IconData? icon;

  /// Optional secondary line below the label (muted).
  final String? subtitle;

  /// When false, the option is dimmed and not selectable.
  final bool enabled;
}

/// Design-system single-select dropdown. See file header for the anatomy.
class KasyDropDown<T> extends StatefulWidget {
  const KasyDropDown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.showRequiredIndicator = false,
    this.description,
    this.errorText,
    this.isInvalid = false,
    this.enabled = true,
    this.leadingIcon,
    this.variant = KasyTextFieldVariant.primary,
    this.focusBorder = true,
    this.showSelectedCheck = true,
    this.maxPanelHeight = 280,
    this.semanticLabel,
    this.closeOnSelect = true,
    this.searchable = false,
    this.searchHint,
  })  : multiple = false,
        values = null,
        onSelectionChanged = null,
        multiSummary = null;

  /// Multi-select variant. Several options can be picked at once: the panel
  /// stays open as you toggle items (each selected row shows a check) and the
  /// trigger summarizes the picks (labels joined, or [multiSummary]).
  const KasyDropDown.multiple({
    super.key,
    required this.items,
    required this.values,
    required this.onSelectionChanged,
    this.label,
    this.hint,
    this.showRequiredIndicator = false,
    this.description,
    this.errorText,
    this.isInvalid = false,
    this.enabled = true,
    this.leadingIcon,
    this.variant = KasyTextFieldVariant.primary,
    this.focusBorder = true,
    this.showSelectedCheck = true,
    this.maxPanelHeight = 280,
    this.semanticLabel,
    this.multiSummary,
    this.closeOnSelect = false,
    this.searchable = false,
    this.searchHint,
  })  : multiple = true,
        value = null,
        onChanged = null;

  /// The options to choose from.
  final List<KasyDropDownItem<T>> items;

  /// Called with the picked value. Pass null to render a read-only dropdown.
  final ValueChanged<T>? onChanged;

  /// Currently selected value (matched against [KasyDropDownItem.value]).
  final T? value;

  /// Label rendered above the trigger.
  final String? label;

  /// Placeholder shown in the trigger while nothing is selected.
  final String? hint;

  /// Shows a danger `*` after the [label].
  final bool showRequiredIndicator;

  /// Helper text rendered below the trigger (hidden when [errorText] is set).
  final String? description;

  /// Error text rendered below the trigger; also flips the field to invalid.
  final String? errorText;

  /// Forces the invalid (danger) styling even without [errorText].
  final bool isInvalid;

  /// When false, the trigger is dimmed and won't open.
  final bool enabled;

  /// Optional leading icon shown inside the trigger.
  final IconData? leadingIcon;

  /// Trigger fill style — mirrors [KasyTextField.variant].
  final KasyTextFieldVariant variant;

  /// Whether the trigger paints the primary "active" border while open.
  final bool focusBorder;

  /// Whether the selected option shows a trailing check in the panel.
  final bool showSelectedCheck;

  /// Whether picking an option closes the panel. Defaults to true for
  /// single-select and false for multi-select (keep open while picking); either
  /// can override it.
  final bool closeOnSelect;

  /// Whether the panel shows a search field on top that filters items (by label
  /// and subtitle) as you type. Good for long lists.
  final bool searchable;

  /// Placeholder for the search field (defaults to "Search").
  final String? searchHint;

  /// Maximum height of the dropdown panel before it scrolls internally.
  final double maxPanelHeight;

  /// Accessibility label for the trigger (falls back to [label]/[hint]).
  final String? semanticLabel;

  /// Whether this is a multi-select dropdown (built via [KasyDropDown.multiple]).
  final bool multiple;

  /// Selected values in multi-select mode (matched against item values).
  final Set<T>? values;

  /// Called with the new selection set whenever a row is toggled (multi-select).
  final ValueChanged<Set<T>>? onSelectionChanged;

  /// Optional trigger summary for multi-select (default: selected labels joined
  /// with ", "). Receives the selected items in their list order.
  final String Function(List<KasyDropDownItem<T>> selected)? multiSummary;

  @override
  State<KasyDropDown<T>> createState() => _KasyDropDownState<T>();
}

class _KasyDropDownState<T> extends State<KasyDropDown<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _portalController = OverlayPortalController();

  // Groups the trigger + panel for TapRegion so a tap inside either is "inside".
  final Object _tapGroupId = Object();

  // Measures the trigger width when opening so the panel matches it.
  final GlobalKey _fieldKey = GlobalKey();

  // Trigger text mirrors the selected label (empty → hint renders).
  late final TextEditingController _displayController;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  bool _isOpen = false;

  // Drives the trigger's "active" border while the panel is open — from state,
  // not real focus (see KasyDatePicker for the rationale).
  bool _triggerActive = false;

  // Trigger width + open direction, read at open time.
  double _panelWidth = 256;
  bool _openUp = false;

  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController(text: _displayText());
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant KasyDropDown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the trigger text in sync when the selection or items change upstream.
    if (oldWidget.value != widget.value ||
        oldWidget.items != widget.items ||
        oldWidget.values != widget.values) {
      _displayController.text = _displayText();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _displayController.dispose();
    super.dispose();
  }

  KasyDropDownItem<T>? get _selectedItem {
    for (final item in widget.items) {
      if (item.value == widget.value) return item;
    }
    return null;
  }

  // Trigger text: the selected label (single), or a summary of the picks
  // (multi: labels joined, or the caller's [multiSummary]).
  String _displayText() {
    if (widget.multiple) {
      final List<KasyDropDownItem<T>> selected = widget.items
          .where((KasyDropDownItem<T> i) => widget.values?.contains(i.value) ?? false)
          .toList();
      if (selected.isEmpty) return '';
      final String Function(List<KasyDropDownItem<T>>)? summary =
          widget.multiSummary;
      if (summary != null) return summary(selected);
      return selected.map((KasyDropDownItem<T> i) => i.label).join(', ');
    }
    return _selectedItem?.label ?? '';
  }

  void _toggle() {
    if (!widget.enabled || widget.items.isEmpty) return;
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    final RenderBox? fieldBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    _panelWidth = fieldBox?.size.width ?? 256;

    // Estimate the panel height so we can flip up when there's no room below.
    final double estimatedHeight = _estimatedPanelHeight();
    bool openUp = false;
    if (fieldBox != null) {
      final Offset fieldTopLeft = fieldBox.localToGlobal(Offset.zero);
      final Size viewport = MediaQuery.sizeOf(context);
      final EdgeInsets safe = MediaQuery.viewPaddingOf(context);
      final double fieldBottom = fieldTopLeft.dy + fieldBox.size.height;
      final double spaceBelow = viewport.height - safe.bottom - fieldBottom;
      final double spaceAbove = fieldTopLeft.dy - safe.top;
      if (spaceBelow < estimatedHeight + 8 && spaceAbove > spaceBelow) {
        openUp = true;
      }
    }
    _openUp = openUp;

    _portalController.show();
    _animCtrl.forward();
    setState(() {
      _isOpen = true;
      _triggerActive = true;
    });
  }

  void _close() {
    _animCtrl.reverse().then((_) {
      if (!mounted) return;
      _portalController.hide();
      setState(() => _triggerActive = false);
    });
    setState(() => _isOpen = false);
  }

  void _select(KasyDropDownItem<T> item) {
    if (!item.enabled) return;
    if (widget.multiple) {
      // Toggle membership; keep the panel open unless closeOnSelect is set.
      final Set<T> next = Set<T>.of(widget.values ?? const <Never>{});
      if (!next.remove(item.value)) next.add(item.value);
      widget.onSelectionChanged?.call(next);
      if (widget.closeOnSelect) _close();
      return;
    }
    widget.onChanged?.call(item.value);
    if (widget.closeOnSelect) _close();
  }

  // Selected values as a set, unifying single (0/1) and multi for the panel.
  Set<T> _selectedValues() {
    if (widget.multiple) return widget.values ?? const <Never>{};
    final T? v = widget.value;
    return v == null ? const <Never>{} : <T>{v};
  }

  // Roughly: item rows (36 each) + panel padding (+ search field), capped at
  // maxPanelHeight.
  double _estimatedPanelHeight() {
    const double rowHeight = 38;
    const double panelPadding = KasySpacing.xs * 2;
    final double search = widget.searchable ? 56 : 0;
    final double raw = widget.items.length * rowHeight + panelPadding + search;
    return raw.clamp(0, widget.maxPanelHeight);
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: _tapGroupId,
      child: OverlayPortal(
        controller: _portalController,
        overlayChildBuilder: _buildOverlay,
        child: _buildTrigger(context),
      ),
    );
  }

  // ── Trigger ────────────────────────────────────────────────────────────────
  Widget _buildTrigger(BuildContext context) {
    final KasyColors c = context.colors;
    final bool isDisabled = !widget.enabled;
    final bool hasErrorText =
        widget.errorText != null && widget.errorText!.isNotEmpty;
    final bool hasInvalidState = widget.isInvalid || hasErrorText;
    final String? footerText =
        hasErrorText ? widget.errorText : widget.description;
    final Color labelColor = hasInvalidState ? c.error : c.fieldLabel;

    Color dimDisabled(Color base, {double alpha = 0.55}) {
      if (!isDisabled) return base;
      return Color.alphaBlend(base.withValues(alpha: alpha), c.surface);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null && widget.label!.trim().isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: KasySpacing.sm - 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label!,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: dimDisabled(labelColor),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.showRequiredIndicator)
                  Text(
                    ' *',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: c.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: KasySpacing.xs),
        ],
        // Only this rectangle is the popover anchor — label and footer are
        // siblings so they don't shift the panel's open position.
        CompositedTransformTarget(
          link: _layerLink,
          child: MouseRegion(
            cursor: widget.enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: KasyFocusRing(
              onActivate: _toggle,
              borderRadius: BorderRadius.circular(KasyRadius.md),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggle,
                child: IgnorePointer(
                  child: KasyTextField(
                    key: _fieldKey,
                    controller: _displayController,
                    readOnly: true,
                    enabled: widget.enabled,
                    hint: widget.hint,
                    isInvalid: hasInvalidState,
                    variant: widget.variant,
                    focusBorder: widget.focusBorder,
                    forceFocusBorder: widget.focusBorder && _triggerActive,
                    enableInteractiveSelection: false,
                    semanticLabel:
                        widget.semanticLabel ?? widget.label ?? widget.hint,
                    prefix: widget.leadingIcon == null
                        ? null
                        : Icon(widget.leadingIcon, size: KasyIconSize.sm),
                    suffix: AnimatedRotation(
                      turns: _isOpen ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 160),
                      child: const Icon(KasyIcons.chevronDown),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (footerText != null && footerText.isNotEmpty) ...[
          const SizedBox(height: KasySpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KasySpacing.sm - 2),
            child: Text(
              footerText,
              style: context.textTheme.bodySmall?.copyWith(
                color: hasErrorText ? c.error : c.muted,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Dropdown panel (popover) ─────────────────────────────────────────────────
  Widget _buildOverlay(BuildContext context) {
    return TapRegion(
      groupId: _tapGroupId,
      onTapOutside: (_) => _close(),
      child: Stack(
        children: [
          CompositedTransformFollower(
            link: _layerLink,
            targetAnchor:
                _openUp ? Alignment.topLeft : Alignment.bottomLeft,
            followerAnchor:
                _openUp ? Alignment.bottomLeft : Alignment.topLeft,
            // 6px gap between trigger and panel.
            offset: _openUp ? const Offset(0, -6) : const Offset(0, 6),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                alignment:
                    _openUp ? Alignment.bottomCenter : Alignment.topCenter,
                child: _DropDownPanel<T>(
                  width: _panelWidth,
                  maxHeight: widget.maxPanelHeight,
                  items: widget.items,
                  selectedValues: _selectedValues(),
                  showSelectedCheck: widget.showSelectedCheck,
                  searchable: widget.searchable,
                  searchHint: widget.searchHint,
                  onSelected: _select,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DropDownPanel — the floating list surface
// ─────────────────────────────────────────────────────────────────────────────

class _DropDownPanel<T> extends StatefulWidget {
  const _DropDownPanel({
    required this.width,
    required this.maxHeight,
    required this.items,
    required this.selectedValues,
    required this.showSelectedCheck,
    required this.searchable,
    required this.searchHint,
    required this.onSelected,
  });

  final double width;
  final double maxHeight;
  final List<KasyDropDownItem<T>> items;
  final Set<T> selectedValues;
  final bool showSelectedCheck;
  final bool searchable;
  final String? searchHint;
  final ValueChanged<KasyDropDownItem<T>> onSelected;

  @override
  State<_DropDownPanel<T>> createState() => _DropDownPanelState<T>();
}

class _DropDownPanelState<T> extends State<_DropDownPanel<T>> {
  // Panel-local query — lives here so it survives the host's rebuilds (e.g. a
  // multi-select pick) but resets when the panel closes and reopens.
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Items matching the query (by label and subtitle, case-insensitive).
  List<KasyDropDownItem<T>> get _filtered {
    final String q = _query.trim().toLowerCase();
    if (!widget.searchable || q.isEmpty) return widget.items;
    return widget.items.where((KasyDropDownItem<T> i) {
      return i.label.toLowerCase().contains(q) ||
          (i.subtitle ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final List<KasyDropDownItem<T>> items = _filtered;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: widget.width,
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        padding: const EdgeInsets.all(KasySpacing.xs),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(KasyRadius.xl),
          border: Border.all(color: context.colors.borderSoft),
          boxShadow: KasyShadows.overlayPanel(context),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(KasyRadius.xl - KasySpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.searchable) ...[
                Padding(
                  // Equal inset on all sides; matches the list's horizontal
                  // inset below so the field and the row hover line up, and the
                  // inset keeps the field's corners inside the rounded clip.
                  padding: const EdgeInsets.all(KasySpacing.sm),
                  child: KasyTextField(
                    controller: _searchCtrl,
                    variant: KasyTextFieldVariant.flat,
                    focusBorder: false,
                    hint: widget.searchHint ?? 'Search',
                    prefix: const Icon(KasyIcons.search, size: KasyIconSize.sm),
                    onChanged: (String v) => setState(() => _query = v),
                  ),
                ),
              ],
              Flexible(
                child: items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KasySpacing.smd,
                          vertical: KasySpacing.md,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              KasyIcons.searchEmpty,
                              size: KasyIconSize.sm,
                              color: c.muted,
                            ),
                            const SizedBox(width: KasySpacing.smd),
                            Text(
                              'No results',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: c.muted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          // When searchable, match the search field's horizontal
                          // inset so the row hover aligns with the field; without
                          // it, the rows stay full width (unchanged).
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.searchable ? KasySpacing.sm : 0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final KasyDropDownItem<T> item in items)
                                _DropDownTile<T>(
                                  item: item,
                                  selected: widget.selectedValues.contains(
                                    item.value,
                                  ),
                                  showSelectedCheck: widget.showSelectedCheck,
                                  onTap: () => widget.onSelected(item),
                                ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DropDownTile — a single option row
// ─────────────────────────────────────────────────────────────────────────────

class _DropDownTile<T> extends StatelessWidget {
  const _DropDownTile({
    required this.item,
    required this.selected,
    required this.showSelectedCheck,
    required this.onTap,
  });

  final KasyDropDownItem<T> item;
  final bool selected;
  final bool showSelectedCheck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final bool isDisabled = !item.enabled;
    final Color foreground = selected ? c.primary : c.onSurface;
    final Color resolved = isDisabled
        ? Color.alphaBlend(foreground.withValues(alpha: 0.45), c.surface)
        : foreground;

    final Widget row = Row(
      children: [
        if (item.icon != null) ...[
          Icon(
            item.icon,
            size: KasyIconSize.sm,
            color: isDisabled
                ? Color.alphaBlend(c.muted.withValues(alpha: 0.5), c.surface)
                : (selected ? c.primary : c.muted),
          ),
          const SizedBox(width: KasySpacing.smd),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: resolved,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (item.subtitle != null && item.subtitle!.isNotEmpty)
                Text(
                  item.subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(color: c.muted),
                ),
            ],
          ),
        ),
        if (selected && showSelectedCheck) ...[
          const SizedBox(width: KasySpacing.smd),
          Icon(KasyIcons.check, size: KasyIconSize.sm, color: c.primary),
        ],
      ],
    );

    if (isDisabled) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.smd,
          vertical: 6,
        ),
        child: row,
      );
    }

    return KasyHover(
      onTap: onTap,
      focusable: true,
      semanticLabel: item.label,
      // Floating-panel item highlight: shared with [KasyMenu] at md so the
      // dropdown and menu read as one family (rounded2_5xl looked pill-like).
      borderRadius: BorderRadius.circular(KasyRadius.md),
      hoverColor: selected ? c.primarySoft : c.surfaceSecondary,
      pressColor: c.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.smd,
        vertical: 6,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 24),
        child: Align(alignment: Alignment.centerLeft, child: row),
      ),
    );
  }
}
