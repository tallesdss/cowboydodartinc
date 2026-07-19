import 'package:flutter/foundation.dart';

/// Paywall renewal footnote: App Store / Play Store on native, account settings
/// on web (Stripe Customer Portal from Settings).
String resolvePaywallBillingNote({
  required String storeNote,
  required String webNote,
}) {
  return kIsWeb ? webNote : storeNote;
}
