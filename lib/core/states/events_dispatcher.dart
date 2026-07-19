import 'dart:async';

import 'package:cowboydodartinc/core/states/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appEventsDispatcherProvider = Provider((ref) => AppEventsDispatcher());

/// Dispatches and manages app-wide events using a broadcast stream.
///
/// Features:
/// - Type-safe event publishing and listening
/// - Event history buffer for late subscribers
/// - Typed event filtering with [on<T>()]
class AppEventsDispatcher {
  final StreamController<AppEvent> _controller;
  late final Stream<AppEvent> _stream;

  /// Buffer for recent events (useful for late subscribers)
  final List<AppEvent> _eventHistory;
  final int _maxHistorySize;

  Stream<AppEvent> get stream => _stream;

  /// Get all events from history (read-only)
  List<AppEvent> get history => List.unmodifiable(_eventHistory);

  AppEventsDispatcher({int maxHistorySize = 50})
    : _eventHistory = [],
      _maxHistorySize = maxHistorySize,
      _controller = StreamController<AppEvent>() {
    _stream = _controller.stream.asBroadcastStream(
      onCancel: (c) => c.pause(),
      onListen: (el) {
        if (el.isPaused) el.resume();
      },
    );
  }

  void dispose() {
    _eventHistory.clear();
    _controller.close();
  }

  /// Publish an event to all listeners
  void publish(AppEvent event) {
    _addToHistory(event);
    _controller.add(event);
  }

  void _addToHistory(AppEvent event) {
    _eventHistory.add(event);
    if (_eventHistory.length > _maxHistorySize) {
      _eventHistory.removeAt(0);
    }
  }

  /// Listen to only a specific type of event
  Stream<T> on<T extends AppEvent>() {
    return _stream.where((event) => event is T).cast<T>();
  }

  /// Get the last event of a specific type from history
  T? lastEventOf<T extends AppEvent>() {
    for (var i = _eventHistory.length - 1; i >= 0; i--) {
      if (_eventHistory[i] is T) return _eventHistory[i] as T;
    }
    return null;
  }

  /// Get all events of a specific type from history
  List<T> eventsOf<T extends AppEvent>() {
    return _eventHistory.whereType<T>().toList();
  }
}

extension AppEventsDispatcherExtension on WidgetRef {
  AppEventsDispatcher get appEventsDispatcher =>
      read(appEventsDispatcherProvider);

  void publishAppEvent(AppEvent event) {
    if (!context.mounted) return;
    read(appEventsDispatcherProvider).publish(event);
  }

  /// Listen to specific event type
  Stream<T> onAppEvent<T extends AppEvent>() {
    return read(appEventsDispatcherProvider).on<T>();
  }
}

extension AppEventDispatcherRefExtension on Ref {
  AppEventsDispatcher get appEventsDispatcher =>
      read(appEventsDispatcherProvider);

  void publishAppEvent(AppEvent event) {
    read(appEventsDispatcherProvider).publish(event);
  }

  /// Listen to specific event type
  Stream<T> onAppEvent<T extends AppEvent>() {
    return read(appEventsDispatcherProvider).on<T>();
  }
}
