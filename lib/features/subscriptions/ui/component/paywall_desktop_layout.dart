import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:flutter/foundation.dart';

/// True on web viewports at the desktop breakpoint (>= 1024).
///
/// Native iOS/Android (including tablet) and web phone/tablet keep the
/// standard mobile paywall layouts. Stripe vs RevenueCat is unchanged.
bool shouldUsePaywallDesktopLayout(double width) {
  return kIsWeb && width >= DeviceType.large.breakpoint;
}
