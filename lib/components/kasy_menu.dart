import 'dart:async';

import 'package:cowboydodartinc/components/kasy_bottom_sheet.dart';
import 'package:cowboydodartinc/components/kasy_popover.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KasyMenu — design-system action menu (HeroUI "Dropdown" / Menu).
//
// A list of contextual actions presented in a floating panel. Mirrors the
// HeroUI Menu anatomy and reuses the visual language of [KasyDropDown] (panel
// radius, item radius, 14px medium labels, selected check, "Danger zone"
// grouping) so the kit stays consistent.
//
// Anatomy:
//   • KasyMenuItem    — one actionable row: prefix icon (or selection check),
//                       title, optional description, optional suffix (keyboard
//                       shortcut / submenu chevron / custom), tone (initial |
//                       danger), selected / disabled states, optional submenu.
//   • KasyMenuSection — a group of items with an optional muted label; sections
//                       are separated by a divider (e.g. "Actions"/"Danger zone").
//   • KasyMenu        — the chrome-less panel that stacks sections. The floating
//                       surface (border, shadow, scroll) is supplied by the
//                       presenter, so the menu never double-draws a card.
//
// Present it with [showKasyMenu]. Pick the form explicitly with
// [KasyMenuPresentation]: a popover anchored to the trigger (default) or a
// bottom sheet. Items can close the menu on tap or stay open ([closeOnSelect]).
// ─────────────────────────────────────────────────────────────────────────────
/// Visual type of a [KasyMenuItem] (HeroUI: Initial | Danger).
enum KasyMenuItemTone {
  /// Default neutral action.
  initial,

  /// Destructive / irreversible action (delete, remove) — rendered in the error
  /// color. Use sparingly, in its own ("Danger zone") [KasyMenuSection].
  danger,
}

/// Row density. [compact] matches the HeroUI desktop spec (36px rows, 14px
/// labels, 16px icons); [comfortable] enlarges rows for touch on mobile.
enum KasyMenuDensity { compact, comfortable }

/// Selection indicator a [KasyMenuSection] draws for its selected items.
enum KasyMenuSelectionMode {
  /// Plain action items — no selection indicator.
  none,

  /// One choice at a time — the selected item shows a filled radio dot.
  single,

  /// Several choices at once — each selected item shows a check.
  multiple,
}

/// How [showKasyMenu] presents the menu. Picked explicitly by the caller; the
/// menu never switches form on its own.
enum KasyMenuPresentation {
  /// A popover anchored to the trigger (every screen size).
  popover,

  /// A bottom sheet sliding up from the bottom (every screen size).
  bottomSheet,
}

/// One actionable row in a [KasyMenu].
class KasyMenuItem {
  /// Main action label (required).
  final String title;

  /// Optional supporting line beneath the title (muted).
  final String? description;

  /// Optional leading icon (HeroUI "Prefix"). Omitted on selectable items, where
  /// the prefix slot shows a check for the selected row instead.
  final IconData? icon;

  /// Optional keyboard shortcut shown as a trailing chip (HeroUI "Kbd"), e.g.
  /// '⌘ B'. Ignored when [trailing] or [submenu] is set.
  final String? shortcut;

  /// Optional custom trailing widget (HeroUI "Suffix"). Overrides [shortcut].
  final Widget? trailing;

  /// Initial (neutral) or danger (destructive) styling.
  final KasyMenuItemTone tone;

  /// Marks the row as the current selection (primary label + leading check).
  final bool selected;

  /// When false the row is dimmed and not tappable.
  final bool enabled;

  /// When set, the row opens a nested menu instead of acting; a trailing chevron
  /// is shown. Where there's room it cascades as a side flyout (desktop); on a
  /// narrow screen it expands inline beneath the row (accordion).
  final List<KasyMenuSection>? submenu;

  /// Whether tapping this row closes the menu. Null inherits the menu-level
  /// [KasyMenu.closeOnSelect]. Set false for toggles that keep the menu open.
  final bool? closeOnSelect;

  /// Invoked when the row is tapped (after the menu closes, if it closes).
  final VoidCallback? onTap;

  const KasyMenuItem({
    required this.title,
    this.description,
    this.icon,
    this.shortcut,
    this.trailing,
    this.tone = KasyMenuItemTone.initial,
    this.selected = false,
    this.enabled = true,
    this.submenu,
    this.closeOnSelect,
    this.onTap,
  });
}

/// A labelled group of [KasyMenuItem]s. Sections are divided from each other so
/// destructive actions can sit in their own ("Danger zone") group.
class KasyMenuSection {
  /// Optional muted group header (HeroUI "Groups", e.g. "Actions").
  final String? label;

  /// Selection indicator for this group's selected items (check vs radio dot).
  final KasyMenuSelectionMode selectionMode;
  final List<KasyMenuItem> items;

  const KasyMenuSection({
    this.label,
    this.selectionMode = KasyMenuSelectionMode.none,
    required this.items,
  });
}

/// The chrome-less menu panel: stacks [sections] with group labels and dividers.
/// Wrap it in a floating surface to display (the presenters do this for you).
class KasyMenu extends StatelessWidget {
  final List<KasyMenuSection> sections;
  final KasyMenuDensity density;

  /// Whether tapping a row closes the menu by default (rows can override).
  final bool closeOnSelect;

  /// How to dismiss the menu when a row closes it. [KasyMenuAnchor] passes its
  /// own close (it lives in an overlay, not a route); when null the menu assumes
  /// it's a route and pops the navigator (the [showKasyMenu] popover / sheet).
  final VoidCallback? onClose;

  /// Shared [TapRegion] group of the presenter. A submenu flyout joins this
  /// group so tapping inside it counts as "inside" the menu and never dismisses
  /// the parent. Null for a route-based menu (the route's barrier handles taps).
  final Object? tapGroupId;

  const KasyMenu({
    super.key,
    required this.sections,
    this.density = KasyMenuDensity.compact,
    this.closeOnSelect = true,
    this.onClose,
    this.tapGroupId,
  });

  /// Convenience for a single ungrouped menu.
  factory KasyMenu.items(
    List<KasyMenuItem> items, {
    Key? key,
    KasyMenuDensity density = KasyMenuDensity.compact,
    bool closeOnSelect = true,
    VoidCallback? onClose,
    Object? tapGroupId,
  }) =>
      KasyMenu(
        key: key,
        sections: [KasyMenuSection(items: items)],
        density: density,
        closeOnSelect: closeOnSelect,
        onClose: onClose,
        tapGroupId: tapGroupId,
      );

  @override
  Widget build(BuildContext context) {
    final bool compact = density == KasyMenuDensity.compact;
    final List<Widget> children = [];

    for (int s = 0; s < sections.length; s++) {
      final KasyMenuSection section = sections[s];
      // Reserve the prefix slot for every row in the group when any row carries
      // an icon or a selection indicator, so labels stay aligned (HeroUI).
      final bool reserveLeading =
          section.selectionMode != KasyMenuSelectionMode.none ||
          section.items.any((i) => i.icon != null || i.selected);
      if (s > 0) children.add(_MenuDivider());
      final String? label = section.label;
      if (label != null && label.trim().isNotEmpty) {
        children.add(_MenuGroupLabel(label: label, compact: compact));
      }
      for (final KasyMenuItem item in section.items) {
        children.add(
          _MenuItemRow(
            item: item,
            compact: compact,
            reserveLeading: reserveLeading,
            selectionMode: section.selectionMode,
            menuCloseOnSelect: closeOnSelect,
            onClose: onClose,
            tapGroupId: tapGroupId,
          ),
        );
      }
    }

    return Padding(
      // HeroUI: 4px panel inset so a hovered row's rounded fill never touches
      // the panel edge.
      padding: const EdgeInsets.all(KasySpacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Presents [sections] as a [KasyMenu].
///
/// [presentation] picks the form. The default — [KasyMenuPresentation.popover] —
/// shows a floating menu anchored to [anchorContext] on every platform (mobile
/// and desktop). Opt into [bottomSheet] to slide it up from the bottom instead,
/// or [auto] to adapt per platform (popover on desktop, bottom sheet on mobile).
/// [closeOnSelect] is the default for whether tapping a row dismisses the menu.
Future<T?> showKasyMenu<T>({
  required BuildContext context,
  required List<KasyMenuSection> sections,
  BuildContext? anchorContext,
  KasyPopoverAlign desktopAlign = KasyPopoverAlign.start,
  KasyPopoverPlacement placement = KasyPopoverPlacement.bottom,
  double desktopWidth = 240,
  KasyMenuPresentation presentation = KasyMenuPresentation.popover,
  bool closeOnSelect = true,
}) {
  final bool asPopover = switch (presentation) {
    KasyMenuPresentation.popover => true,
    KasyMenuPresentation.bottomSheet => false,
  };

  if (asPopover) {
    return showKasyPopover<T>(
      anchorContext: anchorContext ?? context,
      align: desktopAlign,
      placement: placement,
      width: desktopWidth,
      builder: (_) => KasyMenu(sections: sections, closeOnSelect: closeOnSelect),
    );
  }

  final bool dark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: dark ? 0.6 : 0.45),
    // Same compact, elegant menu — only the container changes (sheet vs popover).
    // The bottom sheet must NOT enlarge the rows.
    builder: (_) => KasySheetSurface(
      child: KasyMenu(sections: sections, closeOnSelect: closeOnSelect),
    ),
  );
}

/// Declarative trigger that opens a [KasyMenu] glued to itself.
///
/// The panel is centered on the trigger and hangs just below it, flipping to
/// hang above when there isn't room. It rides a [LayerLink] +
/// [CompositedTransformFollower] hosted by an [OverlayPortal] (the [KasyDropDown]
/// mechanism): the panel is pinned to the trigger at the compositor level, so it
/// stays glued even under an ancestor that scales or offsets the subtree (the
/// device-preview frame, an animated page), and the framework owns the overlay's
/// lifecycle so there's no manual entry juggling to corrupt the element tree.
///
/// [builder] renders the trigger and receives an `open` callback to wire to its
/// tap. Set [presentation] to [KasyMenuPresentation.bottomSheet] to slide the
/// menu up from the bottom instead of anchoring it.
class KasyMenuAnchor extends StatefulWidget {
  final List<KasyMenuSection> sections;

  /// Builds the trigger; call `open` to show the menu.
  final Widget Function(BuildContext context, VoidCallback open) builder;
  final double width;
  final bool closeOnSelect;
  final KasyMenuPresentation presentation;

  /// Horizontal anchoring of the panel to the trigger. [center] (default) keeps
  /// the legacy behaviour; [end] lines the panel's right edge up with the
  /// trigger's right edge (a value on the right of a row), opening inward.
  final KasyPopoverAlign align;

  const KasyMenuAnchor({
    super.key,
    required this.sections,
    required this.builder,
    this.width = 240,
    this.closeOnSelect = true,
    this.presentation = KasyMenuPresentation.popover,
    this.align = KasyPopoverAlign.center,
  });

  @override
  State<KasyMenuAnchor> createState() => _KasyMenuAnchorState();
}

class _KasyMenuAnchorState extends State<KasyMenuAnchor>
    with SingleTickerProviderStateMixin {
  // LayerLink glues the panel to the trigger at the compositor level, so it
  // can't drift even under the device-preview frame's scale/offset. OverlayPortal
  // hosts the panel declaratively — the framework owns its element lifecycle, so
  // there's no manual insert/remove that can corrupt the element tree.
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();
  // Groups trigger + panel so a tap on either counts as "inside" for TapRegion.
  final Object _tapGroupId = Object();
  // Owns keyboard focus for the open panel: arrow keys move between items, Esc
  // closes, Enter/Space activates (the rows' own focus ring). Set on open.
  final FocusScopeNode _menuScope = FocusScopeNode(debugLabel: 'KasyMenu');

  // Arrow keys walk the items (directional traversal); Esc dismisses.
  static const Map<ShortcutActivator, Intent> _menuShortcuts =
      <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(
          TraversalDirection.down,
        ),
        SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(
          TraversalDirection.up,
        ),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      };

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  // Whether the panel hangs above the trigger (no room below), set at open time.
  bool _openUp = false;
  // Horizontal nudge (overlay space) that keeps the centered panel on-screen
  // when the trigger sits near a left/right edge, set at open time.
  double _shiftX = 0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    _menuScope.dispose();
    super.dispose();
  }

  void _open() {
    if (widget.presentation == KasyMenuPresentation.bottomSheet) {
      _openSheet();
      return;
    }
    setState(() {
      _openUp = _resolveOpenUp();
      _shiftX = _resolveShiftX();
    });
    _portal.show();
    _anim.forward(from: 0);
    // Move keyboard focus onto the first item once the panel is laid out, so
    // arrow keys / Enter work immediately (the ring only paints on key input).
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusFirstItem());
  }

  void _focusFirstItem() {
    if (!mounted || !_portal.isShowing) return;
    for (final FocusNode node in _menuScope.traversalDescendants) {
      if (node.canRequestFocus && !node.skipTraversal) {
        node.requestFocus();
        return;
      }
    }
  }

  // Keep the centered panel on-screen near an edge. The panel is centered on the
  // trigger; if that pushes it past the viewport margin (a corner button), shift
  // it back in. Measured in the overlay's space — the same space the follower
  // offset applies in — so it stays correct under the device-preview frame.
  double _resolveShiftX() {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final RenderBox? overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box == null || overlayBox == null) return 0;
    final double overlayWidth = overlayBox.size.width;
    // Breathing room from the screen edge so a corner menu doesn't hug it.
    const double margin = KasySpacing.md;
    // Viewport too narrow for the panel: nothing to clamp against, stay centered.
    if (overlayWidth < widget.width + margin * 2) return 0;
    final Offset topLeft = box.localToGlobal(Offset.zero, ancestor: overlayBox);
    final double triggerCenterX = topLeft.dx + box.size.width / 2;
    final double desiredLeft = triggerCenterX - widget.width / 2;
    final double clampedLeft = desiredLeft.clamp(
      margin,
      overlayWidth - widget.width - margin,
    );
    return clampedLeft + widget.width / 2 - triggerCenterX;
  }

  // Decide the open direction only. Position is handled by the LayerLink, so a
  // slightly-off estimate just flips the menu — it always stays glued. Mirrors
  // [KasyDropDown]: measure against the viewport minus the safe-area insets
  // (notch / home indicator) so the panel never opens under them.
  bool _resolveOpenUp() {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return false;
    final Offset topLeft = box.localToGlobal(Offset.zero);
    final Size viewport = MediaQuery.sizeOf(context);
    final EdgeInsets safe = MediaQuery.viewPaddingOf(context);
    final double triggerBottom = topLeft.dy + box.size.height;
    final double spaceBelow = viewport.height - safe.bottom - triggerBottom;
    final double spaceAbove = topLeft.dy - safe.top;
    return spaceBelow < _estimatedHeight() + 8 && spaceAbove > spaceBelow;
  }

  Future<void> _openSheet() {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: dark ? 0.6 : 0.45),
      builder: (_) => KasySheetSurface(
        child: KasyMenu(
          sections: widget.sections,
          closeOnSelect: widget.closeOnSelect,
        ),
      ),
    );
  }

  void _close() {
    _anim.reverse().then((_) {
      if (mounted) _portal.hide();
    });
  }

  // Rough panel height (rows + labels + dividers + padding), enough to decide
  // the flip — the real layout still clamps to the viewport.
  double _estimatedHeight() {
    double h = KasySpacing.xs * 2;
    for (int s = 0; s < widget.sections.length; s++) {
      final KasyMenuSection section = widget.sections[s];
      if (s > 0) h += 17;
      final String? label = section.label;
      if (label != null && label.trim().isNotEmpty) h += 28;
      for (final KasyMenuItem item in section.items) {
        final bool hasDesc =
            item.description != null && item.description!.isNotEmpty;
        h += hasDesc ? 52 : 40;
      }
    }
    return h;
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: _tapGroupId,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildOverlay,
        child: CompositedTransformTarget(
          link: _link,
          child: widget.builder(context, _open),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    // Pick the trigger/panel anchor edges from [align] (and flip vertically when
    // there's no room below). The LayerLink does the positioning; we only pick
    // the anchors, so it stays glued under scale/offset ancestors.
    final (Alignment target, Alignment follower) = switch (widget.align) {
      KasyPopoverAlign.start => _openUp
          ? (Alignment.topLeft, Alignment.bottomLeft)
          : (Alignment.bottomLeft, Alignment.topLeft),
      KasyPopoverAlign.end => _openUp
          ? (Alignment.topRight, Alignment.bottomRight)
          : (Alignment.bottomRight, Alignment.topRight),
      KasyPopoverAlign.center => _openUp
          ? (Alignment.topCenter, Alignment.bottomCenter)
          : (Alignment.bottomCenter, Alignment.topCenter),
    };
    // The on-screen horizontal shift only applies to the centered panel; a
    // start/end panel hugs the trigger edge and opens inward, so no shift.
    final Offset offset = Offset(
      widget.align == KasyPopoverAlign.center ? _shiftX : 0,
      _openUp ? -6 : 6,
    );
    final Size viewport = MediaQuery.sizeOf(context);

    return TapRegion(
      groupId: _tapGroupId,
      onTapOutside: (_) => _close(),
      child: Stack(
        children: [
          CompositedTransformFollower(
            link: _link,
            targetAnchor: target,
            followerAnchor: follower,
            offset: offset,
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                alignment: follower,
                child: FocusScope(
                  node: _menuScope,
                  child: Shortcuts(
                    shortcuts: _menuShortcuts,
                    child: Actions(
                      actions: <Type, Action<Intent>>{
                        DismissIntent: CallbackAction<DismissIntent>(
                          onInvoke: (_) {
                            _close();
                            return null;
                          },
                        ),
                      },
                      child: KasyPopoverSurface(
                        width: widget.width,
                        maxHeight: viewport.height * 0.8,
                        child: KasyMenu(
                          sections: widget.sections,
                          closeOnSelect: widget.closeOnSelect,
                          onClose: _close,
                          tapGroupId: _tapGroupId,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Internals ────────────────────────────────────────────────────────────────

/// Side a submenu flyout opens toward, or [none] when neither side has room (the
/// row then presents its submenu as a sheet instead of a clipped flyout).
enum _FlyoutSide { left, right, none }

class _MenuGroupLabel extends StatelessWidget {
  final String label;
  final bool compact;

  const _MenuGroupLabel({required this.label, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // HeroUI: pt 10 / pb 4 / px 12 for group headers.
      padding: EdgeInsets.fromLTRB(
        KasySpacing.smd,
        compact ? 10 : KasySpacing.smd,
        KasySpacing.smd,
        KasySpacing.xs,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.smd,
        vertical: KasySpacing.xs,
      ),
      child: Container(
        height: 1,
        color: context.colors.onSurface.withValues(alpha: 0.08),
      ),
    );
  }
}

/// Trailing keyboard shortcut (HeroUI "Kbd", light variant). No filled pill —
/// just the muted command glyphs, as the Figma menu uses.
class _MenuShortcut extends StatelessWidget {
  final String label;
  final bool compact;

  const _MenuShortcut({required this.label, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style:
          (compact ? context.textTheme.bodyMedium : context.textTheme.bodyLarge)
              ?.copyWith(
        color: context.colors.muted,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _MenuItemRow extends StatefulWidget {
  final KasyMenuItem item;
  final bool compact;
  final bool reserveLeading;
  final KasyMenuSelectionMode selectionMode;
  final bool menuCloseOnSelect;
  final VoidCallback? onClose;

  /// Shared [TapRegion] group (from the presenter), so this row's submenu flyout
  /// is "inside" the menu and doesn't dismiss the parent when tapped.
  final Object? tapGroupId;

  const _MenuItemRow({
    required this.item,
    required this.compact,
    required this.reserveLeading,
    required this.selectionMode,
    required this.menuCloseOnSelect,
    this.onClose,
    this.tapGroupId,
  });

  @override
  State<_MenuItemRow> createState() => _MenuItemRowState();
}

class _MenuItemRowState extends State<_MenuItemRow>
    with SingleTickerProviderStateMixin {
  // Submenu flyout machinery — created only when the row has a submenu. It rides
  // the same LayerLink + OverlayPortal mechanism as [KasyMenuAnchor] so the
  // nested menu stays glued to this row (compositor level) and opens to its
  // side, like a desktop cascade, even inside the scaled device-preview frame.
  static const double _submenuWidth = 224;
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();
  AnimationController? _anim;
  // Assigned in initState only for submenu rows; read only from the submenu
  // overlay, which exists solely on that path.
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  // Whether the flyout opens to the left of the row (no room on the right).
  bool _openLeft = false;
  // Whether the submenu is expanded inline beneath the row (the narrow-screen
  // accordion fallback, when there's no room for a side cascade).
  bool _inlineExpanded = false;
  // Grace delay so the cascade doesn't snap shut while the pointer travels from
  // the parent row across the gap into the submenu (desktop hover).
  Timer? _hoverCloseTimer;

  bool get _hasSubmenu => widget.item.submenu != null;

  @override
  void initState() {
    super.initState();
    if (_hasSubmenu) {
      _anim = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
      );
      _fade = CurvedAnimation(parent: _anim!, curve: Curves.easeOut);
      _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
        CurvedAnimation(parent: _anim!, curve: Curves.easeOutCubic),
      );
    }
  }

  @override
  void dispose() {
    _hoverCloseTimer?.cancel();
    _anim?.dispose();
    super.dispose();
  }

  // Desktop hover: open the cascade when the pointer enters a submenu row. Only
  // cascades (never the inline accordion) — and onEnter never fires on touch, so
  // this stays a pointer-only affordance. Tap still toggles, as a fallback.
  void _openSubmenuOnHover() {
    _hoverCloseTimer?.cancel();
    if (!_hasSubmenu || _portal.isShowing || _inlineExpanded) return;
    final _FlyoutSide side = _resolveSide();
    if (side == _FlyoutSide.none) return;
    setState(() => _openLeft = side == _FlyoutSide.left);
    _portal.show();
    _anim!.forward(from: 0);
  }

  // Close shortly after the pointer leaves — the grace delay lets it cross the
  // gap into the flyout (whose own MouseRegion cancels this) without flicker.
  void _scheduleHoverClose() {
    _hoverCloseTimer?.cancel();
    _hoverCloseTimer = Timer(const Duration(milliseconds: 180), () {
      if (mounted && _portal.isShowing) _closeSubmenu();
    });
  }

  // Toggle the submenu. With room on a side it cascades as a flyout (desktop);
  // on a narrow screen it expands inline beneath the row (the accordion the
  // NN/g mobile-subnavigation guidance recommends for a handful of items —
  // lowest interaction cost, no disorienting second surface).
  void _toggleSubmenu() {
    if (_portal.isShowing) {
      _closeSubmenu();
      return;
    }
    if (_inlineExpanded) {
      setState(() => _inlineExpanded = false);
      return;
    }
    final _FlyoutSide side = _resolveSide();
    if (side == _FlyoutSide.none) {
      setState(() => _inlineExpanded = true);
      return;
    }
    setState(() => _openLeft = side == _FlyoutSide.left);
    _portal.show();
    _anim!.forward(from: 0);
  }

  void _closeSubmenu() {
    _anim!.reverse().then((_) {
      if (mounted) _portal.hide();
    });
  }

  // Pick the side with room for the flyout, or [none] when neither fits (the
  // caller then falls back to a sheet). Position is the LayerLink's job — this
  // only decides the side, measured in the overlay's space.
  _FlyoutSide _resolveSide() {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final RenderBox? overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box == null || overlayBox == null) return _FlyoutSide.right;
    final Offset topLeft = box.localToGlobal(Offset.zero, ancestor: overlayBox);
    final double spaceRight =
        overlayBox.size.width - (topLeft.dx + box.size.width);
    final double spaceLeft = topLeft.dx;
    const double needed = _submenuWidth + 12;
    if (spaceRight >= needed) return _FlyoutSide.right;
    if (spaceLeft >= needed) return _FlyoutSide.left;
    return _FlyoutSide.none;
  }

  void _handleTap() {
    if (_hasSubmenu) {
      _toggleSubmenu();
      return;
    }
    // Close first (mirrors the call-site ordering that avoids a Navigator lock
    // when the action triggers a rebuild), then run the action. An overlay-based
    // menu ([KasyMenuAnchor]) supplies onClose; a route-based one pops itself.
    final bool close = widget.item.closeOnSelect ?? widget.menuCloseOnSelect;
    if (close) {
      _bubbleClose();
    }
    widget.item.onTap?.call();
  }

  // Dismiss the whole menu chain. Overlay-based menus pass an onClose; a
  // route-based menu pops the navigator itself.
  void _bubbleClose() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  // Given to the submenu: when one of its rows closes the menu, fold the flyout
  // away and bubble the close up so the entire chain dismisses together.
  void _closeChain() {
    if (_portal.isShowing) _closeSubmenu();
    _bubbleClose();
  }

  Widget _buildSubmenuOverlay(BuildContext context) {
    // Anchor the flyout to this row's side: right edge → left edge (or mirrored
    // when flipped). Nudge up by the panel inset so the first submenu row lines
    // up with the tapped row. The LayerLink does the positioning.
    final Alignment target = _openLeft ? Alignment.topLeft : Alignment.topRight;
    final Alignment follower =
        _openLeft ? Alignment.topRight : Alignment.topLeft;
    final Offset offset = _openLeft
        ? const Offset(-KasySpacing.xs, -KasySpacing.xs)
        : const Offset(KasySpacing.xs, -KasySpacing.xs);
    final Size viewport = MediaQuery.sizeOf(context);

    return TapRegion(
      groupId: widget.tapGroupId,
      onTapOutside: (_) => _closeSubmenu(),
      child: Stack(
        children: [
          CompositedTransformFollower(
            link: _link,
            targetAnchor: target,
            followerAnchor: follower,
            offset: offset,
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                alignment: follower,
                // Pointer inside the flyout cancels the pending close; leaving
                // it re-arms the grace timer (desktop hover).
                child: MouseRegion(
                  onEnter: (_) => _hoverCloseTimer?.cancel(),
                  onExit: (_) => _scheduleHoverClose(),
                  child: KasyPopoverSurface(
                    width: _submenuWidth,
                    maxHeight: viewport.height * 0.8,
                    child: KasyMenu(
                      sections: widget.item.submenu!,
                      closeOnSelect: widget.menuCloseOnSelect,
                      onClose: _closeChain,
                      tapGroupId: widget.tapGroupId,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final KasyMenuItem item = widget.item;
    final bool compact = widget.compact;
    final KasyMenuSelectionMode selectionMode = widget.selectionMode;
    final KasyColors c = context.colors;
    final bool disabled = !item.enabled;
    final bool danger = item.tone == KasyMenuItemTone.danger;

    final Color baseColor = danger ? c.error : c.onSurface;
    final Color fg = item.selected ? c.primary : baseColor;
    final Color resolvedFg = disabled
        ? Color.alphaBlend(fg.withValues(alpha: 0.45), c.surface)
        : fg;
    final Color leadColor = item.selected
        ? c.primary
        : (danger ? c.error : c.muted);
    final Color resolvedLead = disabled
        ? Color.alphaBlend(leadColor.withValues(alpha: 0.45), c.surface)
        : leadColor;

    final double iconSize = compact ? KasyIconSize.sm : KasyIconSize.lg;
    final double iconGap = compact ? KasySpacing.smd : KasySpacing.sm;
    final EdgeInsets itemPadding = EdgeInsets.symmetric(
      horizontal: KasySpacing.smd,
      vertical: compact ? 6 : KasySpacing.smd,
    );

    final TextStyle? titleStyle =
        (compact ? context.textTheme.bodyMedium : context.textTheme.bodyLarge)
            ?.copyWith(
      color: resolvedFg,
      fontWeight: item.selected ? FontWeight.w600 : FontWeight.w500,
    );

    // Prefix slot: an icon, a selection indicator (check for multi-select, a
    // filled dot for single-select), or reserved empty space so the group's
    // labels stay aligned.
    Widget? leading;
    if (item.icon != null) {
      leading = Icon(item.icon, size: iconSize, color: resolvedLead);
    } else if (item.selected) {
      leading = selectionMode == KasyMenuSelectionMode.single
          ? SizedBox(
              width: iconSize,
              height: iconSize,
              child: Center(
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: c.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
          : Icon(KasyIcons.check, size: iconSize, color: c.primary);
    } else if (widget.reserveLeading) {
      leading = SizedBox(width: iconSize);
    }

    // Suffix slot: submenu chevron, custom trailing, or a shortcut chip. The
    // chevron rotates a quarter turn down while the submenu is expanded inline,
    // so the row reads like an accordion header.
    Widget? trailing;
    if (item.submenu != null) {
      trailing = AnimatedRotation(
        turns: _inlineExpanded ? 0.25 : 0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Icon(
          KasyIcons.chevronRight,
          size: KasyIconSize.sm,
          color: resolvedLead,
        ),
      );
    } else if (item.trailing != null) {
      trailing = item.trailing;
    } else if (item.shortcut != null) {
      trailing = _MenuShortcut(label: item.shortcut!, compact: compact);
    }

    final bool hasDescription =
        item.description != null && item.description!.isNotEmpty;
    // With a description the row is two lines; align the icon and shortcut to the
    // title line (a 2px nudge centers a 16px glyph on the 20px title), as the
    // HeroUI menu does. Single-line rows stay vertically centered.
    Widget alignToTitle(Widget w) => hasDescription
        ? Padding(padding: const EdgeInsets.only(top: 2), child: w)
        : w;

    final Widget row = Row(
      crossAxisAlignment: hasDescription
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          alignToTitle(leading),
          SizedBox(width: iconGap),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.title, style: titleStyle),
              if (hasDescription)
                Text(
                  item.description!,
                  style: context.textTheme.bodySmall?.copyWith(color: c.muted),
                ),
            ],
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: iconGap),
          alignToTitle(trailing),
        ],
      ],
    );

    if (disabled) {
      return Padding(padding: itemPadding, child: row);
    }

    final Widget hover = KasyHover(
      onTap: _handleTap,
      focusable: true,
      semanticLabel: item.title,
      focusGapColor: c.surface,
      // A moderate row radius — the panel-concentric rounded2_5xl reads too
      // pill-like on a menu row, and a square full-bleed highlight would clash
      // with the rounded popover corners. md sits cleanly in both forms.
      borderRadius: BorderRadius.circular(KasyRadius.md),
      hoverColor: item.selected ? c.primarySoft : c.surfaceSecondary,
      pressColor: danger ? c.error : c.primary,
      padding: itemPadding,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: compact ? 24 : 32),
        child: Align(alignment: Alignment.centerLeft, child: row),
      ),
    );

    // A plain row needs no overlay machinery.
    if (!_hasSubmenu) return hover;

    // The trigger carries the LayerLink so a side cascade can anchor to it, and
    // a MouseRegion opens the cascade on hover (desktop; never fires on touch).
    Widget child = CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) => _openSubmenuOnHover(),
        onExit: (_) => _scheduleHoverClose(),
        child: hover,
      ),
    );

    // Narrow screens expand the submenu inline, indented beneath the row (so the
    // nested items align under the title). Mutually exclusive with the cascade.
    if (_inlineExpanded) {
      final double indent = iconSize + iconGap;
      child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          child,
          Padding(
            padding: EdgeInsets.only(left: indent),
            child: KasyMenu(
              sections: item.submenu!,
              density: widget.compact
                  ? KasyMenuDensity.compact
                  : KasyMenuDensity.comfortable,
              closeOnSelect: widget.menuCloseOnSelect,
              onClose: _closeChain,
              tapGroupId: widget.tapGroupId,
            ),
          ),
        ],
      );
    }

    // A submenu row hosts its side flyout through an OverlayPortal.
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildSubmenuOverlay,
      child: child,
    );
  }
}
