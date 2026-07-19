import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final metaAdsApiProvider = Provider<MetaAdsApi>(
  (ref) => MetaAdsApi(client: Supabase.instance.client),
);

/// Sends server-side events to Meta Conversions API via the
/// `meta-track-event` Supabase Edge Function.
///
/// Subscription events (Subscribe, StartTrial, Purchase) are sent
/// automatically by the `revenuecat-webhook` edge function — do not
/// duplicate them here.
///
/// Typical usage:
/// ```dart
/// // On first launch / install
/// ref.read(metaAdsApiProvider).trackInstall();
///
/// // On email/social registration
/// ref.read(metaAdsApiProvider).trackRegistration();
///
/// // Custom events
/// ref.read(metaAdsApiProvider).trackEvent(
///   'AchieveLevel',
///   customData: {'level': '5'},
/// );
/// ```
///
/// Events are fire-and-forget: failures are logged but never rethrown,
/// so they never affect the user-facing flow.
class MetaAdsApi {
  final SupabaseClient _client;
  final _logger = Logger();

  MetaAdsApi({required SupabaseClient client}) : _client = client;

  /// Track a `CompleteRegistration` event.
  /// Call this immediately after a user creates a new permanent account
  /// (email/password, Google, Apple or Facebook sign-up).
  Future<void> trackRegistration() => trackEvent('CompleteRegistration');

  /// Track a `MobileAppInstall` event.
  /// Call this on the very first app launch (use a persisted flag so it
  /// runs only once per device).
  Future<void> trackInstall() => trackEvent('MobileAppInstall');

  /// Track any supported Meta event by name.
  ///
  /// [eventName] must be a valid Meta app event name, e.g.:
  ///   'CompleteRegistration', 'MobileAppInstall', 'AchieveLevel',
  ///   'UnlockAchievement', 'SpendCredits', 'ViewContent', 'Search'.
  ///
  /// [customData] is an optional map of string key-value pairs sent as
  /// Meta `custom_data` (e.g. `{'level': '5', 'currency': 'USD'}`).
  Future<void> trackEvent(
    String eventName, {
    Map<String, String>? customData,
  }) async {
    try {
      await _client.functions.invoke(
        'meta-track-event',
        body: {
          'event_name': eventName,
          if (customData != null) 'custom_data': customData,
        },
      );
      _logger.d('[MetaAdsApi] $eventName sent');
    } catch (e, s) {
      // Never let tracking errors surface to the user.
      _logger.w('[MetaAdsApi] $eventName failed (non-fatal): $e', stackTrace: s);
    }
  }
}
