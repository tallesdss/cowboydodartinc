import 'dart:async';

import 'package:cowboydodartinc/core/states/events_dispatcher.dart';
import 'package:cowboydodartinc/core/states/models/event_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A component that can show widgets conditionally based on events.
/// THe first widget that returns true for its condition will be shown.
/// Other will be ignored.
/// This can be used to show modals, bottom sheets, pages, etc based on events.
///
/// Ex of usage:
/// @override
///  Widget build(BuildContext context) {
///    return ConditionalWidgetsEvents(
///      eventWidgets: [
///        MaybeShowPremiumPage(),
///        MaybeShowAttPermission(),
///        MaybeAskForReview(),
///        MaybeAskForRating(),
///      ],
///      child: ...,
///    );
///  }
/// A widget that can be shown or not based on a condition.
sealed class MaybeShow {}

/// A widget that can be shown or not based on a condition.
abstract class MaybeShowNoContext extends MaybeShow {
  Future<bool> handle(AppEvent event);
}

/// A widget that can be shown or not based on a condition.
abstract class MaybeShowWithContext extends MaybeShow {
  Future<bool> handle(BuildContext context, AppEvent event);
}

abstract class MaybeShowWithRef extends MaybeShow {
  Future<bool> handle(WidgetRef ref, AppEvent event);
}

/// Orchestrates a list of [MaybeShowWidget] and stops at the first one that
class ConditionnalWidgetOrchestrator {
  final List<MaybeShow> widgets;

  ConditionnalWidgetOrchestrator(this.widgets);

  Future<void> handle(WidgetRef ref, AppEvent event) async {
    for (final widget in widgets) {
      final shown = await switch (widget) {
        MaybeShowNoContext() => widget.handle(event),
        MaybeShowWithContext() => widget.handle(ref.context, event),
        MaybeShowWithRef() => widget.handle(ref, event),
      };
      if (shown) {
        return;
      }
    }
  }
}

/// A wrapper
class ConditionalWidgetsEvents extends ConsumerStatefulWidget {
  final Widget child;
  final List<MaybeShow> eventWidgets;

  const ConditionalWidgetsEvents({
    super.key,
    required this.child,
    required this.eventWidgets,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConditionalWidgetsEventsState();
}

class _ConditionalWidgetsEventsState
    extends ConsumerState<ConditionalWidgetsEvents> {
  ConditionnalWidgetOrchestrator? orchestrator;
  StreamSubscription<AppEvent?>? subscription;

  @override
  void initState() {
    super.initState();
    orchestrator = ConditionnalWidgetOrchestrator(widget.eventWidgets);
    subscription = ref.appEventsDispatcher.stream.listen(_onEvent);
  }

  Future<void> _onEvent(AppEvent? event) async {
    if (event == null) return;
    await orchestrator?.handle(ref, event);
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
