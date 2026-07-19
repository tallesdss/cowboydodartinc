import 'package:cowboydodartinc/core/navigation/kasy_navigation_config.dart';
import 'package:cowboydodartinc/core/navigation/kasy_route_transition.dart';
import 'package:cowboydodartinc/core/navigation/kasy_transition_kind.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Transparent overlay route: previous screen stays visible under blur dialogs.
///
/// Used on web for paywalls that render as centered modals over the page the
/// user came from (solo/trial desktop). Full-screen paywall layouts still paint
/// an opaque canvas and cover the stack normally.
CustomTransitionPage<T> kasyModalOverlayPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    opaque: false,
    barrierColor: Colors.transparent,
    reverseTransitionDuration: const Duration(milliseconds: 260),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(opacity: curved, child: pageChild);
    },
  );
}

/// Paywall routes on desktop web: transparent overlay so modal layouts can
/// blur the page underneath ([PaywallDesktopModalShell]). Native and mobile web
/// keep the standard opaque push transition.
CustomTransitionPage<T> kasyPaywallRoutePage<T>({
  required BuildContext context,
  required LocalKey key,
  required Widget child,
}) {
  if (kIsWeb &&
      MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint) {
    return kasyModalOverlayPage<T>(key: key, child: child);
  }
  return kasyTransitionPage<T>(key: key, child: child);
}

/// Instant swap for nested admin drill-downs (catalog → preview / design system).
///
/// Avoids the push transition painting the catalog and the drill-down header
/// at the same time, which read as a flicker at the breadcrumb/title row.
CustomTransitionPage<T> kasyAdminDrillDownPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) =>
        pageChild,
  );
}

/// GoRouter page with a [KasyNavigationConfig]-driven transition.
CustomTransitionPage<T> kasyTransitionPage<T>({
  required LocalKey key,
  required Widget child,
  KasyTransitionKind? transition,
  Color? fillColor,
  Duration? transitionDuration,
  Duration? reverseTransitionDuration,
}) {
  final KasyTransitionKind kind = transition ?? KasyNavigationConfig.push;
  return CustomTransitionPage<T>(
    key: key,
    transitionDuration:
        transitionDuration ?? kasyTransitionDurationFor(kind),
    reverseTransitionDuration:
        reverseTransitionDuration ?? kasyReverseTransitionDurationFor(kind),
    child: child,
    transitionsBuilder: (
      context,
      animation,
      secondaryAnimation,
      pageChild,
    ) {
      return kasyBuildRouteTransition(
        context: context,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: pageChild,
        kind: kind,
        fillColor: fillColor,
      );
    },
  );
}
