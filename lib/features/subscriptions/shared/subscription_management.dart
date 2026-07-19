import 'package:cowboydodartinc/features/subscriptions/api/entities/subscription_entity.dart';
import 'package:flutter/foundation.dart';

/// Where a subscription can be managed / cancelled from the *current* device.
enum ManageLocation {
  /// Manageable right here — open the store page (mobile) or Stripe Customer
  /// Portal (web).
  here,

  /// Bought on another platform. Show an informational dialog and let the user
  /// manage it where they purchased. We must NOT open an external payment link
  /// from inside a native app (App Store / Play Store policy).
  elsewhere,
}

/// Decide where to manage a subscription based on its origin ([store]) and the
/// platform the user is currently on.
///
/// Example: a user who subscribed on the web (Stripe) and opens the iOS app
/// gets [ManageLocation.elsewhere] — the app explains the subscription was made
/// in the browser instead of (illegally) linking out to Stripe.
ManageLocation resolveManageLocation(SubscriptionStore? store) {
  // Unknown / legacy records (no origin saved): manage here, routing by the
  // current platform — preserves the previous behavior.
  if (store == null || store == SubscriptionStore.unknown) {
    return ManageLocation.here;
  }
  if (kIsWeb) {
    return store == SubscriptionStore.STRIPE
        ? ManageLocation.here
        : ManageLocation.elsewhere;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return store == SubscriptionStore.APPLE_STORE
          ? ManageLocation.here
          : ManageLocation.elsewhere;
    case TargetPlatform.android:
      return store == SubscriptionStore.PLAY_STORE
          ? ManageLocation.here
          : ManageLocation.elsewhere;
    default:
      return ManageLocation.elsewhere;
  }
}
