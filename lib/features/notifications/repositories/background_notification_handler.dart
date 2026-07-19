import 'package:firebase_messaging/firebase_messaging.dart';

/// Background message handler — runs in a separate Dart isolate.
///
/// When the app is in background or terminated and a FCM message arrives with
/// a `notification` payload, the OS/FCM SDK displays the banner automatically
/// WITHOUT any Flutter code. This handler is only needed for *data-only*
/// messages (message.notification == null) that require custom processing.
@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  // Nothing to do: FCM auto-shows notification banners in background/terminated.
  // Add data-only message handling here if needed (message.notification == null).
}