import 'package:cowboydodartinc/core/navigation/kasy_navigation_config.dart';
import 'package:flutter/material.dart';

/// Fallback [PageTransitionsTheme] builder — same fade on every platform.
class KasyFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const KasyFadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: KasyNavigationConfig.curve,
      reverseCurve: KasyNavigationConfig.reverseCurve,
    );
    return FadeTransition(opacity: curved, child: child);
  }
}

const PageTransitionsTheme kasyPageTransitionsTheme = PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: KasyFadePageTransitionsBuilder(),
    TargetPlatform.iOS: KasyFadePageTransitionsBuilder(),
    TargetPlatform.macOS: KasyFadePageTransitionsBuilder(),
    TargetPlatform.linux: KasyFadePageTransitionsBuilder(),
    TargetPlatform.windows: KasyFadePageTransitionsBuilder(),
    TargetPlatform.fuchsia: KasyFadePageTransitionsBuilder(),
  },
);
