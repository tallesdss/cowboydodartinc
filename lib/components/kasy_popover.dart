import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KasyPopover — a menu anchored next to the control the user clicked.
//
// A popover opens right beside its trigger, like a native menu, instead of
// dimming the whole screen. Position is computed from the trigger's render box —
// no LayerLink wiring at the call site — so any `onTap` that still has the
// trigger's BuildContext can anchor one. It flips above the trigger when there's
// no room below, clamps to the viewport, and dismisses on tap-outside / Esc.
//
// Used by [showKasyMenu] for its [KasyMenuPresentation.popover] form; callers
// normally go through that, not this directly.
// ─────────────────────────────────────────────────────────────────────────────
/// Horizontal anchoring of the popover panel relative to its trigger.
enum KasyPopoverAlign {
  /// Panel's left edge aligns with the trigger's left edge.
  start,

  /// Panel's right edge aligns with the trigger's right edge (menus that hang
  /// off a right-aligned value, e.g. a settings row).
  end,

  /// Panel is centered horizontally on the trigger.
  center,
}

/// Side of the trigger the popover opens toward. Each side flips to its opposite
/// when there isn't room (e.g. [bottom] flips to top near the screen edge).
enum KasyPopoverPlacement { bottom, top, left, right }

const double _kPopoverDefaultWidth = 220;
const double _kPopoverGap = 6;
// Breathing room kept between the panel and every screen edge. Only kicks in
// near an edge (mid-screen the panel just aligns to its trigger); 16 keeps the
// menu from looking glued to the corner, matching iOS context-menu insets.
const double _kViewportMargin = 16;

// Below this much room on the chosen side we consider flipping to the opposite.
const double _kFlipThreshold = 220;

/// Presents [builder] as a floating panel anchored to the widget that owns
/// [anchorContext] (the control the user clicked). The content is wrapped in a
/// [KasyPopoverSurface] automatically, so [builder] returns the bare menu body.
///
/// [placement] picks the side it opens toward (default below the trigger);
/// [align] sets cross-axis alignment for top/bottom placements. Pop the panel
/// with a value (`Navigator.pop(context, value)`) to return it through the
/// future, mirroring [showModalBottomSheet].
Future<T?> showKasyPopover<T>({
  required BuildContext anchorContext,
  required WidgetBuilder builder,
  KasyPopoverAlign align = KasyPopoverAlign.start,
  KasyPopoverPlacement placement = KasyPopoverPlacement.bottom,
  double width = _kPopoverDefaultWidth,
  double gap = _kPopoverGap,
}) {
  // Snapshot the trigger geometry at open time (global coords). A transient menu
  // doesn't need to follow scroll — tap-outside closes it.
  final RenderBox? anchorBox = anchorContext.findRenderObject() as RenderBox?;
  final Size viewport = MediaQuery.sizeOf(anchorContext);
  final Offset anchorTopLeft =
      anchorBox?.localToGlobal(Offset.zero) ??
      Offset(viewport.width / 2, viewport.height / 2);
  final Size anchorSize = anchorBox?.size ?? Size.zero;

  return showGeneralDialog<T>(
    context: anchorContext,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(
      anchorContext,
    ).modalBarrierDismissLabel,
    // No scrim: a desktop popover keeps the page visible behind it.
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (ctx, animation, _) => _KasyPopoverLayout(
      anchorTopLeft: anchorTopLeft,
      anchorSize: anchorSize,
      width: width,
      gap: gap,
      align: align,
      placement: placement,
      animation: animation,
      child: Builder(builder: builder),
    ),
    transitionBuilder: (_, _, _, child) => child,
  );
}

/// Positions and animates the popover panel over a full-screen, transparent
/// layer. Resolves [placement] (flipping to the opposite side when room is
/// tight) and clamps the panel within the viewport.
class _KasyPopoverLayout extends StatelessWidget {
  final Offset anchorTopLeft;
  final Size anchorSize;
  final double width;
  final double gap;
  final KasyPopoverAlign align;
  final KasyPopoverPlacement placement;
  final Animation<double> animation;
  final Widget child;

  const _KasyPopoverLayout({
    required this.anchorTopLeft,
    required this.anchorSize,
    required this.width,
    required this.gap,
    required this.align,
    required this.placement,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Size viewport = MediaQuery.sizeOf(context);
    final EdgeInsets safe = MediaQuery.viewPaddingOf(context);
    final double anchorRight = anchorTopLeft.dx + anchorSize.width;
    final double anchorBottom = anchorTopLeft.dy + anchorSize.height;

    final double spaceBelow = viewport.height - safe.bottom - anchorBottom;
    final double spaceAbove = anchorTopLeft.dy - safe.top;
    final double spaceRight = viewport.width - _kViewportMargin - anchorRight;
    final double spaceLeft = anchorTopLeft.dx - _kViewportMargin;

    // Resolve the effective side, flipping to the opposite when too tight.
    final KasyPopoverPlacement side = switch (placement) {
      KasyPopoverPlacement.bottom =>
        spaceBelow < _kFlipThreshold && spaceAbove > spaceBelow
            ? KasyPopoverPlacement.top
            : KasyPopoverPlacement.bottom,
      KasyPopoverPlacement.top =>
        spaceAbove < _kFlipThreshold && spaceBelow > spaceAbove
            ? KasyPopoverPlacement.bottom
            : KasyPopoverPlacement.top,
      KasyPopoverPlacement.right =>
        spaceRight < width + gap && spaceLeft > spaceRight
            ? KasyPopoverPlacement.left
            : KasyPopoverPlacement.right,
      KasyPopoverPlacement.left =>
        spaceLeft < width + gap && spaceRight > spaceLeft
            ? KasyPopoverPlacement.right
            : KasyPopoverPlacement.left,
    };

    double? left;
    double? top;
    double? right;
    double? bottom;
    double maxHeight;
    Alignment scaleAlign;

    final bool vertical =
        side == KasyPopoverPlacement.bottom || side == KasyPopoverPlacement.top;
    if (vertical) {
      left = switch (align) {
        KasyPopoverAlign.start => anchorTopLeft.dx,
        KasyPopoverAlign.end => anchorRight - width,
        KasyPopoverAlign.center =>
          anchorTopLeft.dx + (anchorSize.width - width) / 2,
      }.clamp(_kViewportMargin, viewport.width - width - _kViewportMargin);
      if (side == KasyPopoverPlacement.bottom) {
        top = anchorBottom + gap;
        maxHeight = spaceBelow - gap - _kViewportMargin;
        scaleAlign = Alignment.topCenter;
      } else {
        bottom = viewport.height - (anchorTopLeft.dy - gap);
        maxHeight = spaceAbove - gap - _kViewportMargin;
        scaleAlign = Alignment.bottomCenter;
      }
    } else {
      // Left / right: align the panel's top with the trigger, clamped so it
      // never runs past the bottom edge.
      top = anchorTopLeft.dy.clamp(
        safe.top + _kViewportMargin,
        viewport.height - safe.bottom - _kViewportMargin,
      );
      maxHeight = viewport.height - safe.bottom - top - _kViewportMargin;
      if (side == KasyPopoverPlacement.right) {
        left = anchorRight + gap;
        scaleAlign = Alignment.centerLeft;
      } else {
        right = viewport.width - (anchorTopLeft.dx - gap);
        scaleAlign = Alignment.centerRight;
      }
    }

    final CurvedAnimation curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeIn,
    );

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
              alignment: scaleAlign,
              child: KasyPopoverSurface(
                width: width,
                maxHeight: maxHeight.clamp(0, viewport.height),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Floating surface chrome for popover content: design-system surface tone,
/// fully-rounded corners, hairline border and elevation shadow, with an internal
/// scroll so tall menus never overflow. Mirrors the dropdown panel look.
class KasyPopoverSurface extends StatelessWidget {
  final Widget child;
  final double width;
  final double maxHeight;

  const KasyPopoverSurface({
    super.key,
    required this.child,
    this.width = _kPopoverDefaultWidth,
    this.maxHeight = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(KasyRadius.xl);
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: width,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: radius,
          // Adaptive hairline (dark line on light, light line on dark) so the
          // panel separates even when it opens over a surface of its own tone.
          border: Border.all(
            color: context.colors.borderSoft,
          ),
          boxShadow: KasyShadows.overlayPanel(context),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: SingleChildScrollView(
            child: child,
          ),
        ),
      ),
    );
  }
}
