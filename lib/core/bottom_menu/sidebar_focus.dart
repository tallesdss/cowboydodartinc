import 'package:cowboydodartinc/core/bottom_menu/web_content_wrapper.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keeps the initial keyboard Tab focus anchored on the sidebar — on every
/// screen, like Stripe/Linear — and hosts the "skip to content" link.
///
/// Why this exists: a page rendered inside a nested [Navigator] has its OWN
/// FocusScope and claims the primary focus the moment a route mounts. A plain
/// `autofocus` on a sidebar item loses that race — the Navigator overwrites it in
/// the same frame.
///
/// The fix is a tiny non-traversable [Focus] anchor inside the sidebar. A
/// post-frame callback (runs AFTER the Navigator has claimed focus) moves focus
/// to that anchor, pulling the primary focus out of the Navigator's scope and
/// back onto the sidebar. Because the anchor sets `skipTraversal: true`, it is
/// skipped by Tab, so the very first Tab lands on the first real sidebar item and
/// then flows on to the header and content — nothing is trapped.
///
/// Re-anchors whenever [currentItem] fires (a tab/section navigation) so a fresh
/// screen also starts at the sidebar. When [currentItem] is null it anchors once,
/// on mount. The ring only paints during keyboard navigation, so this is
/// invisible to mouse/touch users.
///
/// Shared by the app shell (bottom_menu.dart) and the admin console, so both get
/// the exact same keyboard behaviour from one implementation.
class KasyFocusableSidebar extends StatefulWidget {
  final Widget child;

  /// Fires on navigation to re-anchor focus to the sidebar. Optional: when null,
  /// focus is anchored only once, on mount.
  final Listenable? currentItem;

  const KasyFocusableSidebar({
    super.key,
    required this.child,
    this.currentItem,
  });

  @override
  State<KasyFocusableSidebar> createState() => _KasyFocusableSidebarState();
}

class _KasyFocusableSidebarState extends State<KasyFocusableSidebar> {
  final FocusNode _anchor = FocusNode(
    debugLabel: 'sidebarFocusAnchor',
    skipTraversal: true,
  );

  @override
  void initState() {
    super.initState();
    widget.currentItem?.addListener(_anchorFocus);
    _anchorFocus();
  }

  @override
  void didUpdateWidget(KasyFocusableSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentItem != widget.currentItem) {
      oldWidget.currentItem?.removeListener(_anchorFocus);
      widget.currentItem?.addListener(_anchorFocus);
    }
  }

  // Defer to after the frame so we win the race against the nested Navigator,
  // which claims focus for its own scope while the route is mounting.
  void _anchorFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _anchor.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.currentItem?.removeListener(_anchorFocus);
    _anchor.dispose();
    super.dispose();
  }

  // "Skip to content" jumps focus straight to the FIRST real control in the
  // routed content. The content target is a skipTraversal region (tabindex=-1
  // style), so stepping once past it lands on a visible control immediately,
  // instead of focusing the invisible region and needing a second Tab. Falls
  // back to the region itself if the page has no focusable control.
  void _skipToContent() {
    final FocusNode? target = kasyContentFocusTarget;
    if (target == null) return;
    if (!target.nextFocus()) target.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    // Reading-order group (NOT an ordered policy): this is the exact structure
    // that made the anchor hold the initial focus. The anchor sits at (0,0) and
    // is skipped by Tab; the skip link is positioned at the very top, so reading
    // order makes it the FIRST Tab stop, then the sidebar items, then (via the
    // scaffold) the header and content. Swapping in an OrderedTraversalPolicy
    // here broke the anchor, so we keep reading order and rely on position.
    return FocusTraversalGroup(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          // Zero-size sibling; only holds the initial keyboard focus.
          Focus(focusNode: _anchor, child: const SizedBox.shrink()),
          // Topmost on screen, so reading order makes it the first Tab stop.
          Positioned(
            top: KasySpacing.sm,
            left: KasySpacing.sm,
            child: _SkipToContentLink(onSkip: _skipToContent),
          ),
        ],
      ),
    );
  }
}

/// The "skip to content" link (WCAG 2.4.1 "Bypass Blocks"). It is the first Tab
/// stop on every screen: pressing Tab once reveals it above the sidebar, Enter
/// jumps focus into the content, and pressing Tab again moves on to the sidebar.
/// It only paints while focused via the keyboard, so pointer/touch users never
/// see it. Mirrors the pattern used by Stripe, GitHub, etc.
class _SkipToContentLink extends StatefulWidget {
  final VoidCallback onSkip;

  const _SkipToContentLink({required this.onSkip});

  @override
  State<_SkipToContentLink> createState() => _SkipToContentLinkState();
}

class _SkipToContentLinkState extends State<_SkipToContentLink> {
  bool _show = false;
  final OverlayPortalController _overlay = OverlayPortalController();
  final LayerLink _link = LayerLink();

  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  };

  void _setShown(bool show) {
    if (!mounted || show == _show) return;
    setState(() => _show = show);
    show ? _overlay.show() : _overlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    // Colours/text are resolved here, in the sidebar's context, and passed into
    // the overlay below — an overlay context doesn't reliably inherit the app
    // theme (same reason the collapsed-rail tooltip does it).
    final KasyColors c = context.colors;
    final String label = context.t.navigation.skip_to_content;
    final TextStyle? labelStyle = context.textTheme.bodyMedium?.copyWith(
      color: c.onSurface,
      fontWeight: FontWeight.w600,
    );

    // The focusable node lives here so the link stays the first Tab stop, but
    // the visible card is painted in the root Overlay, anchored to this spot via
    // [_link]. The collapsed sidebar is narrower than the card, so an inline
    // card would be clipped at the rail's edge; the overlay floats above
    // everything and is never clipped. The inline child is zero-size, so the
    // detector also no longer overflows onto the panel toggle (dismiss-on-click
    // is handled globally by FocusVisibility).
    return FocusableActionDetector(
      shortcuts: _shortcuts,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onSkip();
            return null;
          },
        ),
      },
      onShowFocusHighlight: _setShown,
      child: CompositedTransformTarget(
        link: _link,
        child: OverlayPortal(
          controller: _overlay,
          overlayChildBuilder: (_) => CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            child: Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: widget.onSkip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KasySpacing.md,
                      vertical: KasySpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(KasyRadius.md),
                      border: Border.all(color: c.primary, width: 1.5),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: c.onSurface.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(label, style: labelStyle),
                  ),
                ),
              ),
            ),
          ),
          child: const SizedBox.shrink(),
        ),
      ),
    );
  }
}
