import 'package:cowboydodartinc/core/navigation/kasy_navigation_config.dart';
import 'package:cowboydodartinc/core/navigation/kasy_route_transition.dart';
import 'package:cowboydodartinc/core/navigation/kasy_transition_kind.dart';
import 'package:flutter/material.dart';

/// Legacy [MaterialPageRoute] that uses the same motion as GoRouter pages.
class KasyMaterialPageRoute<T> extends MaterialPageRoute<T> {
  KasyMaterialPageRoute({
    required super.builder,
    super.settings,
    KasyTransitionKind? transition,
    this.fillColor,
  }) : _kind = transition ?? KasyNavigationConfig.push;

  final KasyTransitionKind _kind;
  final Color? fillColor;

  @override
  Duration get transitionDuration => kasyTransitionDurationFor(_kind);

  @override
  Duration get reverseTransitionDuration =>
      kasyReverseTransitionDurationFor(_kind);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return kasyBuildRouteTransition(
      context: context,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
      kind: _kind,
      fillColor: fillColor,
    );
  }
}
