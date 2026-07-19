import 'package:flutter/cupertino.dart';

/// Onboarding routes swap with NO page transition: tapping "Continue" lands on
/// the next screen instantly, so the step indicator's dot→bar advance reads
/// cleanly instead of being masked by a slide/fade. Each screen still plays its
/// own per‑item entrance animations once it's on.
class OnboardingRouteTransition extends CupertinoPageRoute<void> {
  OnboardingRouteTransition({
    required super.builder,
    super.settings,
  });

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Instant: hand back the child untouched (no fade/slide).
    return child;
  }
}
