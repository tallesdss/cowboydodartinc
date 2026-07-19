import 'package:flutter/foundation.dart';

/// Base sealed class for all app events
sealed class AppEvent {
  /// Unique identifier for the event
  final String id;

  /// Timestamp when the event was created
  final DateTime timestamp;

  /// Optional payload data
  final Map<String, dynamic>? metadata;

  const AppEvent({required this.id, required this.timestamp, this.metadata});

  /// Factory to create event with auto-generated id and timestamp
  static T create<T extends AppEvent>(
    T Function(String id, DateTime timestamp) factory,
  ) {
    return factory(UniqueKey().toString(), DateTime.now());
  }
}

/// Navigation event for route changes
final class NavigationEvent extends AppEvent {
  final String route;
  final Map<String, dynamic>? arguments;

  const NavigationEvent({
    required super.id,
    required super.timestamp,
    required this.route,
    this.arguments,
    super.metadata,
  });

  @override
  String toString() => 'NavigationEvent(route: $route, arguments: $arguments)';

  factory NavigationEvent.create(
    String route, {
    Map<String, dynamic>? arguments,
  }) => AppEvent.create<NavigationEvent>(
    (id, timestamp) => NavigationEvent(
      id: id,
      timestamp: timestamp,
      route: route,
      arguments: arguments,
    ),
  );
}

/// User action event for tracking user interactions
final class UserActionEvent extends AppEvent {
  final String action;
  final String? target;

  const UserActionEvent({
    required super.id,
    required super.timestamp,
    required this.action,
    this.target,
    super.metadata,
  });

  factory UserActionEvent.create(String action, {String? target}) =>
      AppEvent.create<UserActionEvent>(
        (id, timestamp) => UserActionEvent(
          id: id,
          timestamp: timestamp,
          action: action,
          target: target,
        ),
      );
}

/// Event for app-wide start handling
final class OnAppStartEvent extends AppEvent {

  const OnAppStartEvent({
    required super.id,
    required super.timestamp,
    super.metadata,
  });

  factory OnAppStartEvent.create() =>
      AppEvent.create<OnAppStartEvent>(
        (id, timestamp) => OnAppStartEvent(
          id: id,
          timestamp: timestamp,
        ),
      );
}


/// Error event for app-wide error handling
final class ErrorEvent extends AppEvent {
  final Object error;
  final StackTrace? stackTrace;

  const ErrorEvent({
    required super.id,
    required super.timestamp,
    required this.error,
    this.stackTrace,
    super.metadata,
  });

  factory ErrorEvent.create(Object error, {StackTrace? stackTrace}) =>
      AppEvent.create<ErrorEvent>(
        (id, timestamp) => ErrorEvent(
          id: id,
          timestamp: timestamp,
          error: error,
          stackTrace: stackTrace,
        ),
      );
}