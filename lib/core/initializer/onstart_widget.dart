import 'package:cowboydodartinc/core/initializer/models/run_state.dart';
import 'package:cowboydodartinc/core/initializer/onstart_service.dart';
import 'package:cowboydodartinc/core/initializer/pending_notification_handler.dart';
import 'package:cowboydodartinc/core/states/events_dispatcher.dart';
import 'package:cowboydodartinc/core/states/models/event_model.dart';
import 'package:cowboydodartinc/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

typedef OnInitErrorBuilder =
    Widget Function(BuildContext context, String error);

class Initializer extends ConsumerStatefulWidget {
  final Widget onReady;
  final Widget onLoading;
  final OnInitErrorBuilder? onError;
  final List<ProviderListenable<OnStartService>> services;

  const Initializer({
    super.key,
    required this.onReady,
    required this.onLoading,
    this.onError,
    this.services = const [],
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InitializerState();
}

class _InitializerState extends ConsumerState<Initializer> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      try {
        final onStartHandler = ref.read(onStartProvider.notifier);
        for (final service in widget.services) {
          final serviceInstance = ref.read(service);
          debugPrint('- Initializing service: ${serviceInstance.runtimeType}');
          await serviceInstance.init();
          onStartHandler.register(serviceInstance); // useless now
        }
        onStartHandler.onEnded();

        final pendingNotificationHandler = ref.read(pendingNotificationHandlerProvider);
        final pendingNotification = await pendingNotificationHandler.fetchNotificationToProcess();
        if (pendingNotification != null) {
          Future.delayed(const Duration(milliseconds: 2000), () async {
            try {
              await pendingNotification.onTap();
            } catch (e, s) {
              Sentry.captureException(e, stackTrace: s);
            }
          });
        }

        ref.publishAppEvent(OnAppStartEvent.create());
      } catch (e,s) {
        Sentry.captureException(e, stackTrace: s);
        ref.read(onStartProvider.notifier).notifyError(e.toString());
      } finally {
        // Defer splash removal until after the next frame is painted so the
        // onReady widget renders under the splash before it disappears.
        // Without this, the splash is removed before the new frame paints,
        // briefly revealing the onLoading widget (visible flash).
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FlutterNativeSplash.remove();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final onStartState = ref.watch(onStartProvider);

    return switch (onStartState) {
      AppLoadingState() => widget.onLoading,
      AppReadyState() => widget.onReady,
      AppErrorState(:final error) => widget.onError?.call(context, error) 
        ?? AppErrorWidget(error: FlutterErrorDetails(exception: error, stack: StackTrace.current)),
    };
  }
}
