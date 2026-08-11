import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final metaAdsApiProvider = Provider<MetaAdsApi>(
  (ref) => MetaAdsApi(functions: FirebaseFunctions.instance),
);

/// Sends server-side events to Meta Conversions API via the
/// `meta-track-event` Firebase Cloud Function.
class MetaAdsApi {
  final FirebaseFunctions _functions;
  final _logger = Logger();

  MetaAdsApi({required FirebaseFunctions functions}) : _functions = functions;

  /// Track a `CompleteRegistration` event.
  /// Call this immediately after a user creates a new permanent account
  /// (email/password, Google, Apple or Facebook sign-up).
  Future<void> trackRegistration() => trackEvent('CompleteRegistration');

  /// Track a `MobileAppInstall` event.
  /// Call this on the very first app launch (use a persisted flag so it
  /// runs only once per device).
  Future<void> trackInstall() => trackEvent('MobileAppInstall');

  /// Track any supported Meta event by name.
  Future<void> trackEvent(
    String eventName, {
    Map<String, String>? customData,
  }) async {
    try {
      final callable = _functions.httpsCallable('meta-track-event');
      await callable.call({
        'event_name': eventName,
        if (customData != null) 'custom_data': customData,
      });
      _logger.d('[MetaAdsApi] $eventName sent');
    } catch (e, s) {
      // Never let tracking errors surface to the user.
      _logger.w('[MetaAdsApi] $eventName failed (non-fatal): $e', stackTrace: s);
    }
  }
}
