import 'package:cowboydodartinc/core/initializer/models/run_state.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onstart_service.g.dart';

abstract class OnStartService {
  Future<void> init();
}

@Riverpod(keepAlive: true)
class OnStartNotifier extends _$OnStartNotifier {
  final List<OnStartService> _services = [];

  @override
  AppRunState build() {
    return const AppRunState.loading();
  }

  void register(OnStartService service) {
    _services.add(service);
  }

  void onEnded() {
    state = const AppRunState.ready();
  }

  void notifyError(String error) {
    state = AppRunState.error(error);
  }

  void printDebugState() {
    debugPrint('OnStartNotifier state');
    for (final el in _services) {
      debugPrint(' - ${el.runtimeType} started');
    }
  }
}
