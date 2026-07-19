import 'package:cowboydodartinc/core/navigation/kasy_transition_kind.dart';
import 'package:flutter/material.dart';

/// Global navigation motion defaults for the Kasy kit.
///
/// Change [push] (or [duration]) here to update most full-screen routes at once.
/// Per-route overrides go through [kasyTransitionPage].
abstract final class KasyNavigationConfig {
  const KasyNavigationConfig._();
  /// Opening a screen on top of another (e.g. Settings → Feedback).
  static KasyTransitionKind push = KasyTransitionKind.fade;

  /// Replacing the current route (e.g. Guard → /signin).
  static KasyTransitionKind replace = KasyTransitionKind.fade;

  /// Sibling auth screens (login ↔ signup).
  static KasyTransitionKind authPeer = KasyTransitionKind.sharedAxisScaled;

  /// Bottom navigation tabs (Bart).
  static KasyTransitionKind bottomTab = KasyTransitionKind.fade;

  /// Onboarding step navigator.
  static KasyTransitionKind onboardingStep = KasyTransitionKind.fade;

  static const Duration duration = Duration(milliseconds: 250);
  static const Duration reverseDuration = Duration(milliseconds: 220);
  static const Curve curve = Curves.easeOutCubic;
  static const Curve reverseCurve = Curves.easeInCubic;
}
