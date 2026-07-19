import 'package:animations/animations.dart';
import 'package:cowboydodartinc/core/navigation/kasy_navigation_config.dart';
import 'package:cowboydodartinc/core/navigation/kasy_transition_kind.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Builds the animated child for routes, tabs, and legacy [PageRoute]s.
Widget kasyBuildRouteTransition({
  required BuildContext context,
  required Animation<double> animation,
  required Animation<double> secondaryAnimation,
  required Widget child,
  required KasyTransitionKind kind,
  Color? fillColor,
}) {
  if (kind == KasyTransitionKind.none) {
    return child;
  }
  final Animation<double> primary = CurvedAnimation(
    parent: animation,
    curve: KasyNavigationConfig.curve,
    reverseCurve: KasyNavigationConfig.reverseCurve,
  );
  final Animation<double> secondary = CurvedAnimation(
    parent: secondaryAnimation,
    curve: KasyNavigationConfig.curve,
    reverseCurve: KasyNavigationConfig.reverseCurve,
  );
  final Color resolvedFill = fillColor ?? context.colors.background;
  return switch (kind) {
    KasyTransitionKind.fade => FadeTransition(opacity: primary, child: child),
    KasyTransitionKind.fadeThrough => FadeThroughTransition(
      animation: primary,
      secondaryAnimation: secondary,
      fillColor: resolvedFill,
      child: child,
    ),
    KasyTransitionKind.sharedAxisScaled => SharedAxisTransition(
      animation: primary,
      secondaryAnimation: secondary,
      transitionType: SharedAxisTransitionType.scaled,
      fillColor: resolvedFill,
      child: child,
    ),
    KasyTransitionKind.sharedAxisHorizontal => SharedAxisTransition(
      animation: primary,
      secondaryAnimation: secondary,
      transitionType: SharedAxisTransitionType.horizontal,
      fillColor: resolvedFill,
      child: child,
    ),
    KasyTransitionKind.none => child,
  };
}

Duration kasyTransitionDurationFor(KasyTransitionKind kind) {
  if (kind == KasyTransitionKind.none) {
    return Duration.zero;
  }
  return KasyNavigationConfig.duration;
}

Duration kasyReverseTransitionDurationFor(KasyTransitionKind kind) {
  if (kind == KasyTransitionKind.none) {
    return Duration.zero;
  }
  return KasyNavigationConfig.reverseDuration;
}
