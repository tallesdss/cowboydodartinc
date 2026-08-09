import 'dart:async';

import 'package:bart/bart/bart_model.dart';
import 'package:bart/bart/widgets/side_bar/custom_sidebar.dart';
import 'package:cowboydodartinc/components/kasy_app_bar.dart';
import 'package:cowboydodartinc/components/kasy_avatar.dart';
import 'package:cowboydodartinc/components/kasy_avatar_presets.dart';
import 'package:cowboydodartinc/components/kasy_tabs.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_brand_logo.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens — HeroUI Figma Kit (node 4678:41088 light / 21964:53880 dark)
// ─────────────────────────────────────────────────────────────────────────────
// Figma sidebar is 223 wide; we run a touch wider for breathing room (and the
// web viewport scale of 0.93 trims it back to ~245 visually).
/// Open (expanded) width of the rail. Exposed so hosts that present it as a
/// drawer can size the drawer to match (e.g. the admin console on mobile).
const double kasySidebarWidth = 264.0;
const double _kWidthOpen = kasySidebarWidth;
const double _kWidthCollapsed = 64.0;
const double _kPadH = 16.0; // px-4
// Tighter horizontal gutter for the narrow collapsed rail, so a 64px rail keeps
// the 20px icons (44px active pill) centered without clipping.
const double _kCollapsedPadH = 10.0;
const double _kPadBottom = 16.0; // pb-4
// Top band that holds the logo. Matches [kasyAppBarApplicationHeight] so the
// sidebar's first divider lines up with the header's bottom border, and the
// panel toggle sits on the same vertical line as the header controls.
const double _kTopBandHeight = kasyAppBarApplicationHeight;
const double _kItemRadius = KasyRadius.md; // Figma radius/md (nav pill)
const double _kItemMinH = 36.0;
const double _kItemHPad = 12.0; // px-3
const double _kItemVPad = 6.0; // py-1.5
const double _kIconSize = 16.0;
const double _kIconGap = 12.0; // gap-3 (icon → label)
const double _kItemGap = 8.0; // gap between items (spacing/2)
const double _kHeaderGap = 24.0; // logo row → workspace selector (spacing/6)
const double _kDividerGap = 20.0; // gap around the section dividers (spacing/5)
const double _kNavGap = 20.0; // tabs → list (spacing/5)
const double _kFooterGap = 16.0; // bottom divider → search (spacing/4)
const double _kToggleSize = 36.0; // header panel-toggle button

// Submenu tree tokens (kept from the previous sidebar — still used by the
// connected/Income dropdown and its collapsed hover popup).
const double _kSubItemH = 36.0; // fits a 14px (Body sm) nav label + 8/8 padding
const double _kSubItemGap = 6.0; // breathing room between sub-items
const double _kSubIndent = 36.0;
const double _kTreeConnectorW = 13.0;
// Gap above the first sub-item so its hover/focus box never touches the parent
// group row (the line + items shift down together, staying connected).
const double _kSubTreeTopGap = 8.0;

/// Returns the height of the vertical tree line for [n] sub-items.
double _treeLineHeight(int n) =>
    (n * (_kSubItemH + _kSubItemGap) - _kSubItemGap) * 0.8627;

// ─────────────────────────────────────────────────────────────────────────────
// Color palette — every value derives from the global Kasy theme so the sidebar
// follows light/dark automatically (nothing hardcoded).
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarColors {
  const _SidebarColors({
    required this.bg,
    required this.border,
    required this.divider,
    required this.activeBg,
    required this.textMuted,
    required this.textActive,
    required this.logout,
    required this.isDark,
  });

  /// Maps the HeroUI Figma tokens onto the global [KasyColors]:
  /// `surface → surface`, `foreground → onSurface`, `foreground/muted → muted`,
  /// `border → border`, `separator → separator`, and `default →
  /// surfaceNeutralSoft` (hover/active fill). The segmented control is the
  /// shared [KasyTabs] component, which owns its own selected-thumb token.
  factory _SidebarColors.fromContext(BuildContext context) {
    final c = context.colors;
    final bool dark = context.isDark;
    return _SidebarColors(
      bg: c.surface,
      border: c.border,
      // Same token as the vertical edge line + the web header's bottom border,
      // so the top divider continues that line seamlessly across the chrome.
      divider: c.border,
      // Hover / active item fill + tabs track + kbd chip (default/default).
      activeBg: c.surfaceNeutralSoft,
      textMuted: c.muted,
      textActive: c.onSurface,
      logout: c.error,
      isDark: dark,
    );
  }

  final Color bg;
  final Color border;
  final Color divider;
  final Color activeBg;
  final Color textMuted;
  final Color textActive;
  final Color logout;

  /// True when the current theme is dark. Used by overlay widgets (tooltips,
  /// popups) that cannot rely on Theme.of(overlayContext) since overlay
  /// contexts may not inherit the app theme correctly.
  final bool isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// Popup shadow — simplified from 6-layer Figma spec
// ─────────────────────────────────────────────────────────────────────────────

const List<BoxShadow> _kPopupShadow = [
  BoxShadow(color: Color(0x12000000), blurRadius: 40, offset: Offset(0, 16)),
  BoxShadow(color: Color(0x0D000000), blurRadius: 17, offset: Offset(0, 8)),
  BoxShadow(color: Color(0x08000000), blurRadius: 5, offset: Offset(0, 2)),
];

// ─────────────────────────────────────────────────────────────────────────────
// Nav item model
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.id,
    required this.icon,
    required this.label,
    this.trailingControls = false,
  });

  final String id;
  final IconData icon;
  final String label;

  /// When true, the expanded row shows the lock + eye trailing controls
  /// (matches the active "Object 2" layer item in the Figma reference).
  final bool trailingControls;

  bool get hasSubmenu => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Showcase nav data (mirrors the HeroUI Figma layers list 1:1)
// ─────────────────────────────────────────────────────────────────────────────

const List<_NavItem> _kShowcaseItems = [
  _NavItem(id: 'camera1', icon: KasyIcons.settings, label: 'Camera 1'),
  _NavItem(id: 'domelight', icon: KasyIcons.lightMode, label: 'Dome Light'),
  _NavItem(id: 'keylight', icon: KasyIcons.idea, label: 'Key Light'),
  _NavItem(id: 'arealight', icon: KasyIcons.widgets, label: 'Area Light'),
  _NavItem(
    id: 'object2',
    icon: KasyIcons.packageOutline,
    label: 'Object 2',
    trailingControls: true,
  ),
  _NavItem(id: 'bg2', icon: KasyIcons.packageOutline, label: 'Background 2'),
  _NavItem(id: 'character', icon: KasyIcons.packageOutline, label: 'Character'),
  _NavItem(id: 'bg1', icon: KasyIcons.packageOutline, label: 'Background 1'),
];

// ─────────────────────────────────────────────────────────────────────────────
// KasySidebar — public widget
// ─────────────────────────────────────────────────────────────────────────────

/// Which screen edge the sidebar is anchored to.
///
/// Controls which edge receives the content-facing hairline + shadow nudge.
enum KasySidebarSide { left, right }

/// How the rail picks its initial width — the standard SaaS sidebar presets.
enum KasySidebarCollapseMode {
  /// Adapts to the viewport: wide on desktop, auto-collapses to a thin icon
  /// rail on tablet and mobile. The toggle overrides it on any breakpoint. This
  /// is the default and what a typical app navigation uses.
  responsive,

  /// Starts wide on every breakpoint (the "pinned" sidebar); the user collapses
  /// it to the thin rail via the toggle. Stays wide on mobile too.
  expanded,

  /// Starts as the thin icon rail (with hover tooltips); the user expands it via
  /// the toggle.
  collapsed,
}

/// One row in the sidebar's generic ([KasySidebar.items]) mode: an icon, a
/// label and a tap callback. Reuses the exact same row recipe as the app's real
/// navigation, so a host (e.g. the admin console) can drive the SAME sidebar
/// with its own screens instead of the Bart-connected app tabs.
///
/// When [children] is non-empty the row becomes an expandable group (the same
/// dropdown recipe as the connected "Income" submenu): tapping the row toggles
/// the sub-items, and [onTap] is ignored. A leaf row uses [onTap] to navigate
/// and [selected] to show the active pill.
class KasySidebarItem {
  final IconData icon;
  final String label;

  /// Leaf tap (navigate). Ignored when [children] is non-empty (a group only
  /// expands/collapses on tap).
  final VoidCallback? onTap;

  /// Highlights this leaf as the active screen.
  final bool selected;

  /// Sub-rows. When non-empty this item renders as an expandable group instead
  /// of a leaf.
  final List<KasySidebarSubItem> children;

  const KasySidebarItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.selected = false,
    this.children = const [],
  });

  bool get isGroup => children.isNotEmpty;
}

/// A sub-row under an expandable [KasySidebarItem] group (text-only, like the
/// connected "Income" submenu). [selected] highlights the active screen.
class KasySidebarSubItem {
  final String label;
  final VoidCallback onTap;
  final bool selected;
  const KasySidebarSubItem({
    required this.label,
    required this.onTap,
    this.selected = false,
  });
}

/// A SaaS-style sidebar modelled on the HeroUI Figma kit: brand logo + panel
/// toggle, a workspace selector, a segmented control, a navigable list with an
/// active pill, and a pinned ⌘K search row. Collapses to an icon rail (with
/// tooltips and a hover submenu popup) on narrow viewports or via the toggle.
///
/// Three modes, in priority order:
/// 1. **Generic** — pass [items] (+ [sectionLabel], [footerItems]) to drive the
///    rail with an arbitrary screen list (leaves and/or expandable groups). Used
///    by the admin console so it shares this exact component (logo, collapse,
///    tooltips, profile) instead of a bespoke copy.
/// 2. **Connected** — pass [routes]/[onTapItem]/[currentItem] for the real app
///    tabs (Bart navigation).
/// 3. **Showcase** — the HeroUI demo items (default).
///
/// Pass [onSettingsTap] to respond when the user taps Settings.
class KasySidebar extends StatefulWidget {
  const KasySidebar({
    super.key,
    this.onSettingsTap,
    this.onLogout,
    this.collapseMode = KasySidebarCollapseMode.responsive,
    this.isDrawer = false,
    this.side = KasySidebarSide.left,
    this.routes,
    this.onTapItem,
    this.currentItem,
    this.showProfile = true,
    this.profileName = 'Calvin Rice',
    this.profileEmail = 'calvin@email.com',
    this.profileAvatar,
    this.profileGradient = KasyAvatarGradients.indigo,
    this.onProfileTap,
    this.notificationsUnread = 0,
    this.items,
    this.sectionLabel,
    this.footerItems = const [],
    this.expansionListenable,
  });

  /// Generic nav rows. When non-null the sidebar runs in generic mode (renders
  /// these — leaves highlighted by their own [KasySidebarItem.selected], groups
  /// expandable) instead of connected/showcase.
  final List<KasySidebarItem>? items;

  /// Optional uppercase section label shown above [items] (e.g. "ADMIN").
  final String? sectionLabel;

  /// Rows pinned at the bottom of [items] mode (above the profile block), like
  /// the connected layout's Help/Logout — e.g. a "Back to app" action.
  final List<KasySidebarItem> footerItems;

  /// Unread notification count. When greater than zero, the Notifications nav
  /// item shows an unread dot (mirrors the bottom-bar badge). Purely an unread
  /// indicator — not tied to push (which is native-only).
  final int notificationsUnread;

  final VoidCallback? onSettingsTap;

  /// Whether the profile block is shown at the bottom of the rail. Set false to
  /// drop it entirely (e.g. when the web header already carries the avatar).
  final bool showProfile;

  /// Profile block (bottom of the rail) — display name + email.
  final String profileName;
  final String profileEmail;

  /// Custom avatar widget for the profile block — pass the signed-in user's
  /// avatar (e.g. `KasyUserAvatar`) to show their real photo. When null, a
  /// gradient-fill avatar ([profileGradient]) is shown instead.
  final Widget? profileAvatar;

  /// Gradient used for the profile avatar when no [profileAvatar] is given.
  final KasyAvatarGradientData profileGradient;

  /// Tap on the profile block (open account menu / profile).
  final VoidCallback? onProfileTap;

  /// Called when the user taps the Logout row in connected mode. The component
  /// is purely presentational — the host (feature) owns the actual logout flow
  /// (confirm dialog + sign-out). When null, the Logout row does nothing real.
  final VoidCallback? onLogout;

  /// How the rail picks its initial width (responsive / pinned-expanded /
  /// collapsed). See [KasySidebarCollapseMode].
  final KasySidebarCollapseMode collapseMode;

  /// Present the rail as a slide-in drawer (the mobile pattern): it always opens
  /// wide and hides the collapse toggle, regardless of viewport width. Use when
  /// opening the sidebar from an app-bar menu button on a phone.
  final bool isDrawer;

  /// The screen edge this sidebar is anchored to.
  final KasySidebarSide side;

  /// Bart bottom-bar routes to wire into the sidebar. When provided (along with
  /// [onTapItem] and [currentItem]) the sidebar runs in "connected" mode with
  /// real, navigable items. When null, it shows the HeroUI showcase items.
  final List<BartMenuRoute>? routes;

  /// Called with the route index when a real nav item is tapped.
  final OnTapItem? onTapItem;

  /// Bart's active-tab index notifier, used to highlight the current screen.
  final ValueNotifier<int>? currentItem;

  /// Optional shell notifier: `true` while this sidebar is wide. The tablet/
  /// desktop shell listens so the page app bar can hide the brand logo when
  /// the sidebar already shows it (one brand mark at a time).
  final ValueNotifier<bool>? expansionListenable;

  @override
  State<KasySidebar> createState() => _KasySidebarState();
}

class _KasySidebarState extends State<KasySidebar> {
  // User's explicit open/close preference, set by tapping the toggle button.
  // Null until they touch it, so the rail follows the viewport (auto-collapse on
  // narrow). Once set, the explicit choice wins over the viewport — which is
  // what lets a narrow-viewport rail be reopened by tapping the toggle.
  bool? _collapsePreference;

  // Computed at the start of build() — the user's explicit preference when set,
  // otherwise the viewport auto-collapse. All submethods read this field.
  bool _collapsed = false;

  bool _incomeExpanded = false;

  // Expanded groups in generic [items] mode, keyed by the group's label (labels
  // are unique per rail). A group is also shown expanded whenever one of its
  // children is the active screen (so the open submenu always reflects the URL).
  final Set<String> _expandedItemGroups = <String>{};

  // Snapshot of groups whose child was the active screen at the last build, so
  // navigation INTO a submenu auto-opens it exactly once (the user can then
  // collapse it even while sitting on one of its child screens).
  Set<String> _groupsWithActiveChild = <String>{};

  // Showcase state.
  int _showcaseTab = 0; // 0 = Layers, 1 = Assets
  late String _activeItemId;
  String _activeSubItem = '';

  /// Viewport width below which the sidebar auto-collapses (tablet breakpoint).
  static const double _kBreakpoint = 1024.0;

  /// Phone breakpoint. Below this the sidebar is always an overlay (drawer or
  /// full-screen preview), so the logo gets its mobile placement (nudged down,
  /// band trimmed). Above it the inline rail keeps its divider aligned with the
  /// page app bar / web header.
  static const double _kMobileBreakpoint = 768.0;


  /// True when wired to Bart's navigation (real, tappable screens).
  bool get _connected =>
      widget.routes != null &&
      widget.routes!.length >= 2 &&
      widget.onTapItem != null &&
      widget.currentItem != null;

  @override
  void initState() {
    super.initState();
    _collapsePreference = switch (widget.collapseMode) {
      KasySidebarCollapseMode.responsive => null,
      KasySidebarCollapseMode.expanded => false,
      KasySidebarCollapseMode.collapsed => true,
    };
    // Connected mode follows Bart's currentItem (empty highlight here); the
    // showcase defaults to the active layer from the Figma reference.
    _activeItemId = _connected ? '' : 'object2';

    // Open any group that already holds the active screen on first mount.
    _groupsWithActiveChild = _activeChildGroups();
    _expandedItemGroups.addAll(_groupsWithActiveChild);
  }

  @override
  void didUpdateWidget(covariant KasySidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Set<String> active = _activeChildGroups();
    // A group that just gained the active child (the URL moved into its
    // submenu) opens once; a group the user already collapsed is left alone, so
    // the submenu can be toggled freely even while on one of its child screens.
    for (final String label in active.difference(_groupsWithActiveChild)) {
      _expandedItemGroups.add(label);
    }
    _groupsWithActiveChild = active;
  }

  /// Labels of [KasySidebar.items]/[KasySidebar.footerItems] groups whose child
  /// is the active screen (drives the auto-open-on-navigation above).
  Set<String> _activeChildGroups() {
    final Set<String> result = <String>{};
    for (final KasySidebarItem item in <KasySidebarItem>[
      ...?widget.items,
      ...widget.footerItems,
    ]) {
      if (item.children.isNotEmpty &&
          item.children.any((KasySidebarSubItem s) => s.selected)) {
        result.add(item.label);
      }
    }
    return result;
  }

  /// Reveals/hides a submenu tree with the same top-anchored slide + fade the
  /// accordion uses, so the tree connector draws straight down instead of
  /// swinging in from the side. Vertically clipped, top-aligned; the left
  /// indent keeps the connector inside the clip bounds.
  Widget _animatedSubTree({required bool expanded, required Widget tree}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );
      },
      child: expanded
          ? KeyedSubtree(
              key: const ValueKey<String>('sub-open'),
              child: tree,
            )
          : const SizedBox.shrink(key: ValueKey<String>('sub-closed')),
    );
  }

  bool _isViewportNarrow(BuildContext context) =>
      MediaQuery.sizeOf(context).width < _kBreakpoint;

  /// Horizontal gutter for the rail content — tighter when collapsed so the
  /// icon rail stays narrow while keeping the icons centered.
  double get _railPadH => _collapsed ? _kCollapsedPadH : _kPadH;

  _SidebarColors get _colors => _SidebarColors.fromContext(context);

  // ── Actions ───────────────────────────────────────────────────────────────

  // Flip the currently visible state and pin it as the explicit preference, so
  // it overrides the viewport auto-collapse — this is what lets a narrow-
  // viewport rail be expanded back open from the toggle.
  void _toggleCollapse() {
    setState(() => _collapsePreference = !_collapsed);
    // Publish after the flag flips; build() recomputes [_collapsed] next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _publishExpansion();
    });
  }

  /// Keeps [KasySidebar.expansionListenable] in sync with the live wide/rail
  /// state so the page app bar can hide the brand logo while the sidebar shows
  /// it. No-op when the shell did not wire a notifier.
  void _publishExpansion() {
    final ValueNotifier<bool>? notifier = widget.expansionListenable;
    if (notifier == null) return;
    final bool expanded = !_collapsed;
    if (notifier.value != expanded) {
      notifier.value = expanded;
    }
  }

  /// Navigates to a real route via Bart and clears any static-item highlight.
  /// Moving to another screen also collapses an open submenu (e.g. Income) and
  /// drops its selected sub-item, so the sidebar always reflects the active
  /// screen rather than a left-over expanded menu.
  void _navigateTo(int index) {
    setState(() {
      _activeItemId = '';
      _incomeExpanded = false;
      _activeSubItem = '';
    });
    widget.onTapItem!(index);
  }

  void _activateItem(String id) {
    if (id == 'settings') {
      widget.onSettingsTap?.call();
    } else if (id == 'income') {
      setState(() => _incomeExpanded = !_incomeExpanded);
    }
    setState(() {
      _activeItemId = id;
      if (id != 'income') _activeSubItem = '';
    });
  }

  void _activateSubItem(String label) => setState(() {
    _activeSubItem = label;
    _activeItemId = 'income';
  });

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Only an explicit drawer ([isDrawer]) forces wide; everything else honours
    // the user's explicit choice, falling back to the auto-collapse on narrow
    // viewports. Mobile is NOT forced wide — a collapsed config stays thin there.
    _collapsed = !widget.isDrawer &&
        (_collapsePreference ?? _isViewportNarrow(context));
    // Sync after this frame so we never notify InheritedNotifiers mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _publishExpansion();
    });

    final c = _colors;
    final bool anchoredLeft = widget.side == KasySidebarSide.left;

    // Hairline on the content-facing edge (Figma `separator`).
    final Border edgeBorder = anchoredLeft
        ? Border(right: BorderSide(color: c.border, width: 0.5))
        : Border(left: BorderSide(color: c.border, width: 0.5));

    // No drop shadow: the rail separates from the content with the crisp 0.5px
    // edge hairline only (it also bled at the seam when the content area didn't
    // overpaint it). The hairline aligns with the web header's bottom border, so
    // the chrome reads as one clean line — no soft contour around the rail.
    final Widget content = widget.items != null
        ? _buildItemsContent(context, c)
        : _connected
            ? ValueListenableBuilder<int>(
                valueListenable: widget.currentItem!,
                builder: (_, currentIndex, _) =>
                    _buildConnectedContent(context, c, currentIndex),
              )
            : _buildShowcaseContent(context, c);

    return Material(
      type: MaterialType.transparency,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: _collapsed ? _kWidthCollapsed : _kWidthOpen,
        decoration: BoxDecoration(color: c.bg),
        foregroundDecoration: BoxDecoration(border: edgeBorder),
        clipBehavior: Clip.hardEdge,
        child: content,
      ),
    );
  }

  // ── Showcase layout (HeroUI Figma 1:1) ──────────────────────────────────────

  Widget _buildShowcaseContent(BuildContext context, _SidebarColors c) {
    return SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo band — 68px tall so the divider below aligns with the web
          // header's bottom border (one continuous line across the chrome).
          _buildTopBand(c),
          _buildDivider(c),
          // Nav: workspace selector + segmented tabs + the layers list.
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _railPadH),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top gap lives INSIDE the scroll view so the list scrolls
                    // flush under the top divider (symmetric with the bottom),
                    // instead of clipping a gap below it.
                    const SizedBox(height: _kDividerGap),
                    if (!_collapsed) ...[
                      _buildWorkspaceSelector(c),
                      const SizedBox(height: _kHeaderGap),
                      _buildTabs(),
                      const SizedBox(height: _kNavGap),
                    ],
                    for (final item in _kShowcaseItems)
                      _buildNavItem(context, item, c),
                  ],
                ),
              ),
            ),
          ),
          // Pinned ⌘K search row + profile block.
          _buildDivider(c),
          Padding(
            padding: EdgeInsets.fromLTRB(
              _railPadH,
              _kFooterGap,
              _railPadH,
              _kPadBottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItemRow(
                  c,
                  icon: KasyIcons.search,
                  label: 'Search',
                  isActive: false,
                  onTap: () {},
                  bottomGap: 0,
                  trailing: [_buildKbd(c)],
                ),
                if (widget.showProfile) _buildProfile(c),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Generic layout (host-provided items, e.g. admin console) ────────────────

  /// Same chrome as the connected layout (logo band, dividers, profile block,
  /// collapse + tooltips) but driven by [KasySidebar.items]/[footerItems], so a
  /// host reuses this exact component with its own screens.
  Widget _buildItemsContent(BuildContext context, _SidebarColors c) {
    final List<KasySidebarItem> items = widget.items!;
    return SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopBand(c),
          _buildDivider(c),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _railPadH),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top gap inside the scroll view so the list scrolls flush
                    // under the top divider (symmetric with the bottom).
                    const SizedBox(height: _kDividerGap),
                    if (!_collapsed && widget.sectionLabel != null) ...[
                      _buildSectionLabel(widget.sectionLabel!, c),
                      const SizedBox(height: _kItemGap),
                    ],
                    for (final item in items)
                      if (item.isGroup)
                        _buildItemsGroup(context, item, c)
                      else
                        _buildItemRow(
                          c,
                          icon: item.icon,
                          label: item.label,
                          isActive: item.selected,
                          onTap: () => _selectItemsLeaf(item.onTap),
                        ),
                  ],
                ),
              ),
            ),
          ),
          _buildDivider(c),
          const SizedBox(height: _kFooterGap),
          Padding(
            padding: EdgeInsets.fromLTRB(_railPadH, 0, _railPadH, _kPadBottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final f in widget.footerItems)
                  _buildItemRow(
                    c,
                    icon: f.icon,
                    label: f.label,
                    isActive: false,
                    onTap: () => _selectItemsLeaf(f.onTap),
                  ),
                if (widget.showProfile) _buildProfile(c),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Generic expandable group (items mode) ────────────────────────────────

  /// Navigating to a top-level (or footer) row collapses any open submenu group
  /// — matching the connected Income dropdown, which closes when you move to
  /// another screen. A group that holds the active screen re-opens on its own
  /// (via [KasySidebarSubItem.selected]), so this only closes a manually-opened
  /// one you're navigating away from.
  void _selectItemsLeaf(VoidCallback? onTap) {
    if (_expandedItemGroups.isNotEmpty) {
      setState(() => _expandedItemGroups.clear());
    }
    onTap?.call();
  }

  /// An expandable group row in [items] mode — the same dropdown recipe as the
  /// connected "Income" submenu, but driven by [KasySidebarItem.children].
  /// Shown expanded when the user toggled it open OR when one of its children
  /// is the active screen (so the open submenu always reflects the URL).
  Widget _buildItemsGroup(
    BuildContext context,
    KasySidebarItem item,
    _SidebarColors c,
  ) {
    final bool hasActiveChild = item.children.any((s) => s.selected);
    // Expansion is purely user-controlled: navigating into a child auto-opens
    // the group once (see didUpdateWidget), but the user can still collapse it
    // while on a child screen. (`|| hasActiveChild` here used to force it open,
    // so it could never be closed from inside the submenu.) The active-child
    // background below still flags "your screen lives here" when collapsed.
    final bool expanded = _expandedItemGroups.contains(item.label);
    final Color iconColor =
        (expanded || hasActiveChild) ? c.textActive : c.textMuted;

    // Collapsed icon rail: the children live in a hover popup (same as Income).
    if (_collapsed) {
      String activeLabel = '';
      for (final s in item.children) {
        if (s.selected) {
          activeLabel = s.label;
          break;
        }
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: _kItemGap),
        child: _ProHoverPopupIcon(
          icon: item.icon,
          iconBg: hasActiveChild ? c.activeBg : Colors.transparent,
          iconColor: iconColor,
          subItems: [for (final s in item.children) s.label],
          activeSubItem: activeLabel,
          colors: c,
          anchoredLeft: widget.side == KasySidebarSide.left,
          onSubItemTap: (label) {
            for (final s in item.children) {
              if (s.label == label) {
                s.onTap();
                break;
              }
            }
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KasyHover(
          borderRadius: BorderRadius.circular(_kItemRadius),
          hoverColor: c.activeBg,
          pressColor: c.textActive,
          focusable: true,
          focusGapColor: c.bg,
          onTap: () => setState(() {
            if (!_expandedItemGroups.remove(item.label)) {
              _expandedItemGroups.add(item.label);
            }
          }),
          child: Container(
            constraints: const BoxConstraints(minHeight: _kItemMinH),
            padding: const EdgeInsets.symmetric(
              horizontal: _kItemHPad,
              vertical: _kItemVPad,
            ),
            decoration: BoxDecoration(
              color: hasActiveChild ? c.activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(_kItemRadius),
            ),
            child: Row(
              children: [
                Icon(item.icon, size: _kIconSize, color: iconColor),
                const SizedBox(width: _kIconGap),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.kasyTextTheme.rowTitle.copyWith(
                      color: c.textActive,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    KasyIcons.chevronDown,
                    size: _kIconSize,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        _animatedSubTree(
          expanded: expanded,
          tree: _buildItemsSubTree(item.children, c),
        ),
        const SizedBox(height: _kItemGap),
      ],
    );
  }

  /// The connector tree under an expanded [items]-mode group (mirrors the
  /// connected Income tree, but generic over [KasySidebarSubItem]).
  Widget _buildItemsSubTree(
    List<KasySidebarSubItem> subItems,
    _SidebarColors c,
  ) {
    final double lineH = _treeLineHeight(subItems.length);
    return Padding(
      padding: const EdgeInsets.only(left: _kSubIndent, top: _kSubTreeTopGap),
      child: SizedBox(
        width: 172,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -_kTreeConnectorW,
              top: 0,
              child: Container(
                width: 1.5,
                height: lineH,
                decoration: BoxDecoration(
                  color: c.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Column(
              children: [
                for (int i = 0; i < subItems.length; i++)
                  _buildItemsSubItem(subItems[i], i == subItems.length - 1, c),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSubItem(
    KasySidebarSubItem sub,
    bool isLast,
    _SidebarColors c,
  ) {
    final bool isActive = sub.selected;
    final Color textColor = isActive ? c.textActive : c.textMuted;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : _kSubItemGap),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -_kTreeConnectorW,
            top: _kSubItemH / 2 - 4,
            child: Container(
              width: _kTreeConnectorW,
              height: 8,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: c.divider, width: 1.5),
                  bottom: BorderSide(color: c.divider, width: 1.5),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
          ),
          KasyHover(
            borderRadius: BorderRadius.circular(_kItemRadius),
            hoverColor: c.activeBg,
            pressColor: c.textActive,
            focusable: true,
            focusGapColor: c.bg,
            onTap: sub.onTap,
            child: Container(
              height: _kSubItemH,
              padding: const EdgeInsets.symmetric(
                horizontal: _kItemHPad,
                vertical: 8,
              ),
              // Active sub-item is shown by its LABEL only (bold + active color),
              // never a filled pill — exactly like the connected Income submenu
              // on Home. The pill is reserved for top-level screens.
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(_kItemRadius),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  sub.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // A sub-menu item is still a nav row: 14 (Body sm), not 12 —
                  // 12 reads as fine print. Indent + tree line + colour give the
                  // hierarchy; active state adds weight (w600), not size — and
                  // w600 matches the other two sub-item renderers below.
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                    letterSpacing: -0.24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Connected layout (real navigation) ──────────────────────────────────────

  Widget _buildConnectedContent(
    BuildContext context,
    _SidebarColors c,
    int currentIndex,
  ) {
    final int settingsIndex = widget.routes!.length - 1;
    final nav = context.t.navigation;
    final int mainCount = widget.routes!.length - 1; // exclude settings (last)

    return SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopBand(c),
          _buildDivider(c),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _railPadH),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top gap lives INSIDE the scroll view so the list scrolls
                    // flush under the top divider (symmetric with the bottom),
                    // instead of clipping a gap below it.
                    const SizedBox(height: _kDividerGap),
                    if (!_collapsed) ...[
                      _buildSectionLabel('MAIN', c),
                      const SizedBox(height: _kItemGap),
                    ],
                    // Real, navigable screens.
                    for (int i = 0; i < mainCount; i++)
                      _buildItemRow(
                        c,
                        icon: widget.routes![i].icon ?? KasyIcons.note,
                        label: widget.routes![i].label ?? '',
                        isActive: _activeItemId.isEmpty && currentIndex == i,
                        onTap: () => _navigateTo(i),
                      ),
                    const SizedBox(height: _kDividerGap),
                    if (!_collapsed) ...[
                      _buildSectionLabel('SETTINGS', c),
                      const SizedBox(height: _kItemGap),
                    ],
                    _buildItemRow(
                      c,
                      icon: KasyIcons.settings,
                      label: nav.settings,
                      isActive:
                          _activeItemId.isEmpty && currentIndex == settingsIndex,
                      onTap: () => _navigateTo(settingsIndex),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildDivider(c),
          const SizedBox(height: _kFooterGap),
          Padding(
            padding: EdgeInsets.fromLTRB(_railPadH, 0, _railPadH, _kPadBottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItemRow(
                  c,
                  icon: KasyIcons.logout,
                  label: nav.logout,
                  isActive: false,
                  isLogout: true,
                  bottomGap: 0,
                  onTap: () => widget.onLogout?.call(),
                ),
                if (widget.showProfile) _buildProfile(c),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top band (logo + panel toggle) ──────────────────────────────────────────

  /// The brand band at the top of the rail. Fixed to [_kTopBandHeight] (= web
  /// header height) so the divider underneath lines up with the header's bottom
  /// border. Content is vertically centred, mirroring the header's toolbar row.
  Widget _buildTopBand(_SidebarColors c) {
    // Keep the first divider on the same line as the content chrome's bottom
    // border: the web header (68) on desktop, but the shorter KasyAppBar on
    // tablet (medium), where the page keeps its own app bar instead of the
    // header. Without this the line breaks between the rail and the app bar.
    final double viewportWidth = MediaQuery.sizeOf(context).width;
    final bool isCompact = viewportWidth < _kBreakpoint;
    // On phones the sidebar is always an overlay (drawer or full-screen preview),
    // never the inline rail beside a page app bar — so mobile positioning is a
    // sidebar default keyed off the phone breakpoint, not isDrawer.
    final bool isMobile = viewportWidth < _kMobileBreakpoint;
    // Mobile trims a little off the band so there's less dead space below the
    // wordmark before the divider; the overlay has no app-bar line to align with.
    final double bandHeight = !isCompact
        ? _kTopBandHeight
        : kasyAppBarBodyTopOverlap(context) - (isMobile ? 26.0 : 0.0);
    // On mobile the band starts right under the status bar notch, so nudge the
    // brand (and the collapsed toggle, which shares this band) down to breathe.
    // Tablet/desktop keep it centred so the rail's divider stays aligned with the
    // app bar / web header.
    final double logoTopInset = isMobile ? 44.0 : 0.0;
    // The collapse toggle is available on every breakpoint so any config can be
    // switched thin↔wide — except a drawer, which is a dismissible overlay you
    // close whole rather than collapse in place.
    final bool showToggle = !widget.isDrawer;
    final bool anchoredLeft = widget.side == KasySidebarSide.left;
    // Same transparent wordmark as auth / Home app bar (`KasyBrandLogo`).
    final double logoCap = kasyBrandLogoSidebarHeight(context);
    final double logoHeight =
        bandHeight < logoCap ? bandHeight : logoCap;
    final Widget logo = KasyBrandLogo(height: logoHeight);
    // Left rail: wordmark then toggle (toggle hugs the content edge). The right
    // rail mirrors it so the toggle still hugs the content edge (now the left).
    // Row defaults to cross-axis center so the wordmark never drops the toggle
    // below the header toolbar line.
    final List<Widget> rowChildren = <Widget>[
      logo,
      if (showToggle) ...[const Spacer(), _buildToggleButton(c)],
    ];
    return Padding(
      padding: EdgeInsets.only(
        left: _railPadH,
        right: _railPadH,
        top: logoTopInset,
      ),
      child: SizedBox(
        height: bandHeight,
        child: _collapsed
            ? Center(child: _buildToggleButton(c))
            : Row(
                children:
                    anchoredLeft ? rowChildren : rowChildren.reversed.toList(),
              ),
      ),
    );
  }

  Widget _buildToggleButton(_SidebarColors c) {
    return KasyHover(
      borderRadius: BorderRadius.circular(_kToggleSize / 2),
      hoverColor: c.activeBg,
      pressColor: c.textActive,
      focusable: true,
      focusGapColor: c.bg,
      onTap: _toggleCollapse,
      child: Container(
        width: _kToggleSize,
        height: _kToggleSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_kToggleSize / 2),
        ),
        child: Icon(KasyIcons.panelLeft, size: _kIconSize, color: c.textMuted),
      ),
    );
  }

  // ── Workspace selector ──────────────────────────────────────────────────────

  Widget _buildWorkspaceSelector(_SidebarColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '3D Dog Character',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.kasyTextTheme.rowTitle.copyWith(
                  color: c.textActive,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Icon(KasyIcons.chevronDown, size: _kIconSize, color: c.textMuted),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '3D Design Project',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.kasyTextTheme.cardSubtitle.copyWith(
            color: c.textMuted,
          ),
        ),
      ],
    );
  }

  // ── Segmented tabs (Layers / Assets) ────────────────────────────────────────

  /// The showcase segment is the shared [KasyTabs] component (primary pill,
  /// fill mode) so the sidebar demos the real design-system control rather than
  /// a bespoke copy.
  Widget _buildTabs() {
    return KasyTabs(
      tabs: const ['Layers', 'Assets'],
      selectedIndex: _showcaseTab,
      onTabSelected: (index) => setState(() => _showcaseTab = index),
      mode: KasyTabsMode.fill,
    );
  }

  // ── ⌘K keyboard chip ─────────────────────────────────────────────────────────

  Widget _buildKbd(_SidebarColors c) {
    final TextStyle style = context.kasyTextTheme.rowTitle.copyWith(
      color: c.textMuted,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: c.activeBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('⌘', style: style),
          const SizedBox(width: 2),
          Text('K', style: style),
        ],
      ),
    );
  }

  // ── Profile block (bottom) ──────────────────────────────────────────────────

  /// Account row pinned at the bottom: the [KasySidebar.profileAvatar] (the
  /// signed-in user's photo) when provided, otherwise a gradient-fill avatar +
  /// name + email. Collapses to just the avatar on the narrow rail.
  Widget _buildProfile(_SidebarColors c) {
    final Widget avatar =
        widget.profileAvatar ??
        KasyAvatar(diameter: 36, backgroundGradient: widget.profileGradient);

    if (_collapsed) {
      return Padding(
        padding: const EdgeInsets.only(top: _kItemGap),
        child: Center(child: avatar),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: _kItemGap),
      child: KasyHover(
        borderRadius: BorderRadius.circular(_kItemRadius),
        hoverColor: c.activeBg,
        pressColor: c.textActive,
        focusable: true,
        focusGapColor: c.bg,
        onTap: widget.onProfileTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              avatar,
              const SizedBox(width: _kIconGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.profileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.kasyTextTheme.rowTitle.copyWith(
                        color: c.textActive,
                      ),
                    ),
                    Text(
                      widget.profileEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Divider ───────────────────────────────────────────────────────────────

  // 0.5px hairline — same width + colour as the vertical edge line and the web
  // header's bottom border, so all the chrome lines read identically.
  Widget _buildDivider(_SidebarColors c) =>
      Container(height: 0.5, color: c.divider);

  // ── Section label ─────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label, _SidebarColors c) {
    return Padding(
      padding: const EdgeInsets.only(left: _kItemHPad),
      child: Text(
        label,
        style: context.kasyTextTheme.sectionLabel.copyWith(
          color: c.textMuted,
        ),
      ),
    );
  }

  // ── Nav item dispatch ───────────────────────────────────────────────────────

  Widget _buildNavItem(BuildContext context, _NavItem item, _SidebarColors c) {
    final bool isActive = _activeItemId == item.id;
    return _buildItemRow(
      c,
      icon: item.icon,
      label: item.label,
      isActive: isActive,
      onTap: () => _activateItem(item.id),
      trailing: item.trailingControls
          ? [
              Icon(KasyIcons.security, size: _kIconSize, color: c.textMuted),
              const SizedBox(width: 12),
              Icon(KasyIcons.eye, size: _kIconSize, color: c.textMuted),
            ]
          : const [],
    );
  }

  // ── Generic row (expanded) / icon+tooltip (collapsed) ────────────────────────

  /// Overlays a small unread dot on the top-right of [child] when [show] is true.
  /// The dot carries a thin border in the sidebar background color so it reads
  /// cleanly over the icon.
  Widget _withBadgeDot({
    required Widget child,
    required bool show,
    required Color dotColor,
    required Color borderColor,
  }) {
    if (!show) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(
    _SidebarColors c, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool isLogout = false,
    bool showBadge = false,
    List<Widget> trailing = const [],
    double bottomGap = _kItemGap,
  }) {
    final Color fill = isActive ? c.activeBg : Colors.transparent;
    final Color iconColor = isLogout
        ? c.logout
        : (isActive ? c.textActive : c.textMuted);
    final Color labelColor = isLogout ? c.logout : c.textActive;

    if (_collapsed) {
      return Padding(
        padding: EdgeInsets.only(bottom: bottomGap),
        child: _withBadgeDot(
          show: showBadge,
          dotColor: c.logout,
          borderColor: c.bg,
          child: _ProTooltipIcon(
            icon: icon,
            label: label,
            iconBg: fill,
            iconColor: iconColor,
            activeBg: c.activeBg,
            colors: c,
            anchoredLeft: widget.side == KasySidebarSide.left,
            onTap: onTap,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: KasyHover(
        borderRadius: BorderRadius.circular(_kItemRadius),
        hoverColor: c.activeBg,
        pressColor: c.textActive,
        focusable: true,
        focusGapColor: c.bg,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: _kItemMinH),
          padding: const EdgeInsets.symmetric(
            horizontal: _kItemHPad,
            vertical: _kItemVPad,
          ),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(_kItemRadius),
          ),
          child: Row(
            children: [
              _withBadgeDot(
                show: showBadge,
                dotColor: c.logout,
                borderColor: c.bg,
                child: Icon(icon, size: _kIconSize, color: iconColor),
              ),
              const SizedBox(width: _kIconGap),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.kasyTextTheme.rowTitle.copyWith(
                    color: labelColor,
                  ),
                ),
              ),
              ...trailing,
            ],
          ),
        ),
      ),
    );
  }

  // ── Dropdown item (submenu — used by connected Income) ───────────────────────

  // ignore: unused_element
  Widget _buildDropdownItem(
    BuildContext context,
    _NavItem item,
    _SidebarColors c,
  ) {
    final bool isActive = _activeItemId == item.id;
    final Color bg = isActive ? c.activeBg : Colors.transparent;
    final Color iconColor = isActive ? c.textActive : c.textMuted;

    if (_collapsed) {
      return Padding(
        padding: const EdgeInsets.only(bottom: _kItemGap),
        child: _ProHoverPopupIcon(
          icon: item.icon,
          iconBg: bg,
          iconColor: iconColor,
          subItems: const [],
          activeSubItem: _activeSubItem,
          colors: c,
          anchoredLeft: widget.side == KasySidebarSide.left,
          onSubItemTap: _activateSubItem,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KasyHover(
          borderRadius: BorderRadius.circular(_kItemRadius),
          hoverColor: c.activeBg,
          pressColor: c.textActive,
          focusable: true,
          focusGapColor: c.bg,
          onTap: () => _activateItem(item.id),
          child: Container(
            constraints: const BoxConstraints(minHeight: _kItemMinH),
            padding: const EdgeInsets.symmetric(
              horizontal: _kItemHPad,
              vertical: _kItemVPad,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(_kItemRadius),
            ),
            child: Row(
              children: [
                Icon(item.icon, size: _kIconSize, color: iconColor),
                const SizedBox(width: _kIconGap),
                Expanded(
                  child: Text(
                    item.label,
                    style: context.kasyTextTheme.rowTitle.copyWith(
                      color: c.textActive,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _incomeExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    KasyIcons.chevronDown,
                    size: _kIconSize,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        _animatedSubTree(
          expanded: _incomeExpanded,
          tree: _buildSubItemsTree(c),
        ),
        const SizedBox(height: _kItemGap),
      ],
    );
  }

  // ── Sub-items tree ────────────────────────────────────────────────────────

  Widget _buildSubItemsTree(_SidebarColors c) {
    return const SizedBox.shrink();
  }

}

// ─────────────────────────────────────────────────────────────────────────────
// _ProHoverPopupIcon — collapsed icon that shows a floating submenu on hover
// ─────────────────────────────────────────────────────────────────────────────

class _ProHoverPopupIcon extends StatefulWidget {
  const _ProHoverPopupIcon({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.subItems,
    required this.activeSubItem,
    required this.colors,
    required this.anchoredLeft,
    required this.onSubItemTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final List<String> subItems;
  final String activeSubItem;
  final _SidebarColors colors;

  /// Whether the rail is on the left. The popup opens toward the content side
  /// (right of the icon on a left rail, left of the icon on a right rail) so it
  /// never spills off the screen edge.
  final bool anchoredLeft;

  final ValueChanged<String> onSubItemTap;

  @override
  State<_ProHoverPopupIcon> createState() => _ProHoverPopupIconState();
}

class _ProHoverPopupIconState extends State<_ProHoverPopupIcon> {
  final _overlayController = OverlayPortalController();
  final _layerLink = LayerLink();
  bool _onTrigger = false;
  bool _onPopup = false;

  void _scheduleHide() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!_onTrigger && !_onPopup && mounted) {
        _overlayController.hide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: _buildPopup,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: MouseRegion(
          onEnter: (_) {
            _onTrigger = true;
            _overlayController.show();
          },
          onExit: (_) {
            _onTrigger = false;
            _scheduleHide();
          },
          child: KasyHover(
            borderRadius: BorderRadius.circular(_kItemRadius),
            onTap: () {},
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: _kItemHPad,
                vertical: _kItemVPad,
              ),
              decoration: BoxDecoration(
                color: widget.iconBg,
                borderRadius: BorderRadius.circular(_kItemRadius),
              ),
              child: Icon(widget.icon, size: KasyIconSize.lg, color: widget.iconColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopup(BuildContext context) {
    final bool left = widget.anchoredLeft;
    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      targetAnchor: left ? Alignment.centerRight : Alignment.centerLeft,
      followerAnchor: left ? Alignment.centerLeft : Alignment.centerRight,
      offset: Offset(left ? 12 : -12, 0),
      child: Align(
        alignment: left ? Alignment.centerLeft : Alignment.centerRight,
        child: MouseRegion(
          onEnter: (_) => setState(() => _onPopup = true),
          onExit: (_) {
            setState(() => _onPopup = false);
            _scheduleHide();
          },
          child: _buildPopupCard(context),
        ),
      ),
    );
  }

  Widget _buildPopupCard(BuildContext context) {
    final c = widget.colors;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 172,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: c.bg,
          border: Border.all(color: c.border),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _kPopupShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.subItems.map((label) {
            final bool isActive = label == widget.activeSubItem;
            final Color bg = isActive ? c.activeBg : Colors.transparent;
            final Color textColor = isActive ? c.textActive : c.textMuted;

            return KasyHover(
              borderRadius: BorderRadius.circular(_kItemRadius),
              onTap: () => widget.onSubItemTap(label),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: _kItemHPad,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(_kItemRadius),
                ),
                child: Text(
                  label,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                    letterSpacing: -0.24,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProTooltipIcon — collapsed icon with Figma-matched name tooltip on hover
// ─────────────────────────────────────────────────────────────────────────────

class _ProTooltipIcon extends StatefulWidget {
  const _ProTooltipIcon({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.activeBg,
    required this.colors,
    required this.anchoredLeft,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final Color activeBg;
  final _SidebarColors colors;

  /// Whether the rail is on the left. The tooltip opens toward the content side
  /// (and its arrow points back at the icon) so it never spills off the screen
  /// edge on a right-anchored rail.
  final bool anchoredLeft;

  final VoidCallback onTap;

  @override
  State<_ProTooltipIcon> createState() => _ProTooltipIconState();
}

class _ProTooltipIconState extends State<_ProTooltipIcon> {
  final _overlayController = OverlayPortalController();
  final _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: _buildTooltip,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: MouseRegion(
          onEnter: (_) => _overlayController.show(),
          onExit: (_) => _overlayController.hide(),
          child: KasyHover(
            borderRadius: BorderRadius.circular(_kItemRadius),
            hoverColor: widget.activeBg,
            pressColor: widget.activeBg,
            focusable: true,
            focusGapColor: widget.colors.bg,
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: _kItemHPad,
                vertical: _kItemVPad,
              ),
              decoration: BoxDecoration(
                color: widget.iconBg,
                borderRadius: BorderRadius.circular(_kItemRadius),
              ),
              child: Icon(widget.icon, size: KasyIconSize.lg, color: widget.iconColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip(BuildContext context) {
    final bool left = widget.anchoredLeft;
    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      targetAnchor: left ? Alignment.centerRight : Alignment.centerLeft,
      followerAnchor: left ? Alignment.centerLeft : Alignment.centerRight,
      offset: Offset(left ? 4 : -4, 0),
      child: Align(
        alignment: left ? Alignment.centerLeft : Alignment.centerRight,
        child: _TooltipCard(
          label: widget.label,
          colors: widget.colors,
          pointsLeft: left,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TooltipCard — floating label card with left-pointing arrow (Figma spec)
// ─────────────────────────────────────────────────────────────────────────────

class _TooltipCard extends StatelessWidget {
  const _TooltipCard({
    required this.label,
    required this.colors,
    this.pointsLeft = true,
  });

  final String label;
  final _SidebarColors colors;

  /// Arrow points back at the icon: left when the rail is on the left (tooltip
  /// sits to the icon's right), right when the rail is on the right.
  final bool pointsLeft;

  static const double _arrowW = 13.0;
  static const double _arrowH = 26.0;
  static const double _arrowOverlap = 8.0;

  @override
  Widget build(BuildContext context) {
    // Use colors.isDark instead of Theme.of(context) — the overlay context
    // does not always inherit the app theme correctly. Colors come from the
    // global theme: an inverted tooltip in light mode (dark surface / light
    // text — Figma spec / industry standard), neutral surface in dark mode.
    final Color bg = colors.isDark ? colors.divider : colors.textActive;
    final Color textColor = colors.isDark ? colors.textActive : colors.bg;

    final Widget arrow = SizedBox(
      width: _arrowW,
      height: _arrowH,
      child: CustomPaint(
        painter: _TooltipArrowPainter(color: bg, pointsLeft: pointsLeft),
      ),
    );
    // Pull the card over the arrow's base so they read as one shape; the
    // direction of the overlap flips with the arrow side.
    final Widget card = Transform.translate(
      offset: Offset(pointsLeft ? -_arrowOverlap : _arrowOverlap, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 5,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: textColor,
          ),
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: pointsLeft ? <Widget>[arrow, card] : <Widget>[card, arrow],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TooltipArrowPainter — filled left-pointing triangle
// ─────────────────────────────────────────────────────────────────────────────

class _TooltipArrowPainter extends CustomPainter {
  const _TooltipArrowPainter({required this.color, this.pointsLeft = true});
  final Color color;
  final bool pointsLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    // Apex on the side it points to; base on the opposite (card) side.
    final path = pointsLeft
        ? (Path()
          ..moveTo(size.width, 0)
          ..lineTo(0, size.height / 2)
          ..lineTo(size.width, size.height)
          ..close())
        : (Path()
          ..moveTo(0, 0)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(0, size.height)
          ..close());
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TooltipArrowPainter old) =>
      old.color != color || old.pointsLeft != pointsLeft;
}
