import 'package:bart/bart.dart' as bart;
import 'package:bart/bart/bart_model.dart';
import 'package:bart/bart/router_delegate.dart';
import 'package:bart/bart/widgets/bottom_bar/styles/bottom_bar_custom.dart';
import 'package:cowboydodartinc/core/bottom_menu/active_tab_notifier.dart';
import 'package:cowboydodartinc/core/chrome/chrome_visibility.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Side breathing room so the floating bar never touches the screen edges.
const double _kFloatingSideMargin = 28;

/// Gap above the bar (separates it from the page content).
const double _kFloatingTopGap = 6;

/// Minimum gap under the bar when the device has no bottom safe-area inset
/// (Android with gesture nav / no system bar). On notched devices the real
/// inset is used instead so the home indicator stays clear.
const double _kFloatingMinBottomGap = 16;

/// Corner radius of the floating pill (HeroUI `rounded-2.5xl`).
const double _kFloatingRadius = KasyRadius.rounded2_5xl;

/// Bar (pill) inner height — the row of tab items.
const double _kBarHeight = 54;

/// Tab icon size.
const double _kNavIconSize = 22;

/// Gap between a tab's icon and its label.
const double _kNavLabelGap = 3;

/// Tab label size. Fixed (not derived from the text theme) so every label —
/// "Início" and "Configurações" alike — reads at the exact same size and the
/// longer ones don't get clipped with an ellipsis on narrow phones.
const double _kNavLabelSize = 11;

/// Selection color-fade timing (muted ↔ primary highlight).
const Duration _kSelectDuration = Duration(milliseconds: 200);
const Curve _kSelectCurve = Curves.easeOut;

/// Subtle "pop" the icon does when its tab becomes active: a gentle scale-up
/// with a slight overshoot that settles — modern, not bouncy.
const Duration _kPopDuration = Duration(milliseconds: 260);
const Curve _kPopCurve = Curves.easeOutBack;
const double _kPopScale = 0.12;

/// [BartScaffold] requires a [bart.BartBottomBar]. This factory draws a single,
/// custom navigation bar (same look on iOS and Android) wrapped in a floating,
/// fully rounded surface that hovers above the screen edges with a safe-area
/// aware gap underneath (iPhone home indicator / Android nav). Each tab is an
/// icon over its label; the selected one is highlighted in the primary color.
final class KasyPaddedSurfaceBottomBarFactory extends BartBottomBarFactory {
  const KasyPaddedSurfaceBottomBarFactory();

  @override
  Widget create({
    required BuildContext context,
    required List<BartMenuRoute> routes,
    required void Function(int) onTap,
    required int currentIndex,
  }) {
    return TooltipVisibility(
      visible: false,
      child: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final MenuRouter menuRouter = MenuRouter.of(context);
    void handleTap(int index) {
      if (menuRouter.indexNotifier.value == index &&
          menuRouter.routingTypeNotifier.value ==
              BartMenuRouteType.bottomNavigation) {
        return;
      }
      KasyHaptics.selection(context);
      final nestedContext = menuRouter.navigationKey.currentContext;
      if (nestedContext != null) {
        final String path = menuRouter.routesBuilder()[index].path;
        // Record the selected tab synchronously, so the remembered tab can never
        // lag behind the displayed one. On a hot reload Bart re-forces the
        // highlight to the remembered tab; a stale value made it jump (e.g. to
        // Settings while sitting on Home).
        rememberActiveTab(path);
        Navigator.of(nestedContext).pushReplacementNamed(path);
      }
    }

    final Widget barCore = SizedBox(
      height: _kBarHeight,
      child: ValueListenableBuilder<int>(
        valueListenable: menuRouter.indexNotifier,
        builder: (context, currentIndex, _) {
          // [currentIndex] / [handleTap] address the full route list, so map each
          // tab back to its full-list index (robust to any non-tab route).
          final List<BartMenuRoute> allRoutes = menuRouter.routesBuilder();
          final List<BartMenuRoute> navRoutes = allRoutes
              .where((r) => r.type == BartMenuRouteType.bottomNavigation)
              .toList();
          return Row(
            children: [
              for (final route in navRoutes)
                Expanded(
                  child: _KasyNavItem(
                    route: route,
                    selected: allRoutes.indexOf(route) == currentIndex,
                    onTap: () => handleTap(allRoutes.indexOf(route)),
                  ),
                ),
            ],
          );
        },
      ),
    );

    return _floating(context, barCore);
  }

  /// Wraps [barCore] in a floating, fully rounded surface with side margins and
  /// a safe-area-aware bottom gap, over a fade that lets scrolling content melt
  /// into the page background before it reaches the bar.
  Widget _floating(BuildContext context, Widget barCore) {
    final KasyColors colors = context.colors;
    // Real bottom safe area (home indicator / system nav). [viewPaddingOf] keeps
    // reporting it even though we strip it from the inner bar below.
    final double safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final double bottomGap =
        safeBottom > 0 ? safeBottom : _kFloatingMinBottomGap;
    const BorderRadius radius = BorderRadius.all(
      Radius.circular(_kFloatingRadius),
    );

    // In dark mode the cards use `surface`, so a `surface` bar melts into them.
    // A one-step-lighter surface lifts the floating bar above the content and
    // reads as elevated. In light mode the white `surface` already pops against
    // the grey canvas, so it stays as is.
    final Color pillColor =
        context.isDark ? colors.surfaceSecondary : colors.surface;

    final Widget pill = Container(
      decoration: BoxDecoration(
        color: pillColor,
        borderRadius: radius,
        // Single, very light shadow — just enough to lift the pill off the canvas.
        boxShadow: [
          KasyShadows.component(
            context,
            blurRadius: 12,
            spreadRadius: -7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // Border drawn on top of the child so the clip never eats the hairline.
      // A soft contour that reads in both themes: a faint light edge in dark
      // mode, a faint dark edge in light mode.
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: context.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: barCore,
      ),
    );

    // Slide the pill down as the chrome collapses, in lock-step with the top
    // app bar (same notifier). Travel covers the whole floating height so the
    // pill fully clears the screen edge when hidden. No bottom wash: the pill
    // just slides off (and never goes translucent).
    final double travel = _kFloatingTopGap + _kBarHeight + bottomGap;
    return ValueListenableBuilder<double>(
      valueListenable: KasyChromeVisibility.instance.reveal,
      builder: (BuildContext context, double reveal, Widget? child) {
        final double hidden = 1 - reveal;
        return Transform.translate(
          offset: Offset(0, travel * hidden),
          child: child,
        );
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: _kFloatingSideMargin,
          right: _kFloatingSideMargin,
          top: _kFloatingTopGap,
          bottom: bottomGap,
        ),
        child: pill,
      ),
    );
  }
}

/// A single bottom-bar tab: icon over its label. Selected is highlighted in the
/// primary color (icon + label); unselected is muted. Selection fades the color.
class _KasyNavItem extends StatelessWidget {
  final BartMenuRoute route;
  final bool selected;
  final VoidCallback onTap;

  const _KasyNavItem({
    required this.route,
    required this.selected,
    required this.onTap,
  });

  Widget _icon(BuildContext context, Color color) {
    final Widget raw = route.iconBuilder != null
        ? route.iconBuilder!(context, selected)
        : Icon(route.icon);
    return IconTheme.merge(
      data: IconThemeData(color: color, size: _kNavIconSize),
      child: raw,
    );
  }

  @override
  Widget build(BuildContext context) {
    final KasyColors colors = context.colors;
    final TextStyle labelBase =
        context.textTheme.labelMedium ?? const TextStyle();
    final String label = route.label ?? '';

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: selected ? 1.0 : 0.0),
            duration: _kSelectDuration,
            curve: _kSelectCurve,
            builder: (context, t, _) {
              final Color color = Color.lerp(colors.muted, colors.primary, t)!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gentle scale pop when the tab becomes active.
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: selected ? 1.0 : 0.0),
                    duration: _kPopDuration,
                    curve: _kPopCurve,
                    builder: (context, p, child) => Transform.scale(
                      scale: 1 + _kPopScale * p,
                      child: child,
                    ),
                    child: _icon(context, color),
                  ),
                  const SizedBox(height: _kNavLabelGap),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: labelBase.copyWith(
                      color: color,
                      fontSize: _kNavLabelSize,
                      height: 1.0,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

bart.BartBottomBar kasyPaddedSurfaceBottomBar() {
  return bart.BartBottomBar.custom(
    bottomBarFactory: const KasyPaddedSurfaceBottomBarFactory(),
  );
}
