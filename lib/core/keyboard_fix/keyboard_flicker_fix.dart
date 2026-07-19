import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Prevents the keyboard from flickering when the user taps between TextFields.
///
/// Root cause: Flutter stable 3.41.x sends TextInput.clearClient before
/// TextInput.setClient during focus transitions, so the platform briefly
/// dismisses the keyboard before reopening it. Fixed in master (PR #182661)
/// but not yet in stable.
///
/// How it works: intercepts clearClient at the BinaryMessenger layer and holds
/// it for up to [_holdDelay]. If setClient arrives within that window, the
/// clearClient is dropped entirely. If no setClient comes, it is forwarded
/// normally (user tapped outside all fields).
///
/// Remove this file once Flutter stable ships the engine fix.
class _KeyboardFlickerFixMessenger extends BinaryMessenger {
  _KeyboardFlickerFixMessenger(this._delegate);

  final BinaryMessenger _delegate;

  static const String _channel = 'flutter/textinput';

  // flutter/textinput uses JSONMethodCodec, not StandardMethodCodec.
  static const JSONMethodCodec _codec = JSONMethodCodec();

  // 80 ms gives enough time for setClient to arrive after clearClient
  // while being imperceptible to the user if no setClient comes.
  static const Duration _holdDelay = Duration(milliseconds: 80);

  Timer? _pendingTimer;
  Completer<ByteData?>? _pendingCompleter;
  ByteData? _pendingMessage;

  @override
  Future<ByteData?>? send(String channel, ByteData? message) {
    if (channel != _channel || message == null) {
      return _delegate.send(channel, message);
    }

    final MethodCall call;
    try {
      call = _codec.decodeMethodCall(message);
    } catch (_) {
      return _delegate.send(channel, message);
    }

    switch (call.method) {
      case 'TextInput.clearClient':
        return _holdClearClient(message);

      case 'TextInput.setClient':
        _cancelPending();
        return _delegate.send(channel, message);

      case 'TextInput.hide':
        _forwardNow();
        return _delegate.send(channel, message);

      default:
        return _delegate.send(channel, message);
    }
  }

  Future<ByteData?> _holdClearClient(ByteData message) {
    _forwardNow(); // flush any previously held clearClient first

    final completer = Completer<ByteData?>();
    _pendingCompleter = completer;
    _pendingMessage = message;

    debugPrint('[KasyBinding] clearClient held');

    _pendingTimer = Timer(_holdDelay, () {
      debugPrint('[KasyBinding] clearClient forwarded (no setClient came)');
      _forwardNow();
    });

    return completer.future;
  }

  void _cancelPending() {
    if (_pendingMessage == null) return;
    debugPrint('[KasyBinding] setClient arrived - clearClient cancelled');
    _pendingTimer?.cancel();
    _pendingTimer = null;
    _pendingMessage = null;
    if (_pendingCompleter != null && !_pendingCompleter!.isCompleted) {
      _pendingCompleter!.complete(null);
    }
    _pendingCompleter = null;
  }

  void _forwardNow() {
    final message = _pendingMessage;
    final completer = _pendingCompleter;
    _pendingTimer?.cancel();
    _pendingTimer = null;
    _pendingMessage = null;
    _pendingCompleter = null;

    if (message == null) {
      if (completer != null && !completer.isCompleted) {
        completer.complete(null);
      }
      return;
    }

    final result = _delegate.send(_channel, message);
    if (completer == null || completer.isCompleted) return;
    if (result == null) {
      completer.complete(null);
    } else {
      result.then(completer.complete, onError: completer.completeError);
    }
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) =>
      _delegate.setMessageHandler(channel, handler);

  @override
  @Deprecated(
    'Instead of calling this method, use ServicesBinding.instance.channelBuffers.push. '
    'This feature was deprecated after v3.9.0-19.0.pre.',
  )
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    ui.PlatformMessageResponseCallback? callback,
  ) {
    // ignore: deprecated_member_use
    return _delegate.handlePlatformMessage(channel, data, callback);
  }
}

/// Custom binding that installs [_KeyboardFlickerFixMessenger].
///
/// Replace [WidgetsFlutterBinding.ensureInitialized] with this in main():
/// ```dart
/// KasyBinding.ensureInitialized();
/// ```
class KasyBinding extends WidgetsFlutterBinding {
  @override
  BinaryMessenger createBinaryMessenger() {
    debugPrint('[KasyBinding] installing keyboard flicker fix');
    return _KeyboardFlickerFixMessenger(super.createBinaryMessenger());
  }

  static WidgetsBinding ensureInitialized() {
    try {
      // Throws FlutterError in debug / returns non-null in release
      // when binding is already initialized.
      return WidgetsBinding.instance;
    } catch (_) {
      return KasyBinding();
    }
  }
}

