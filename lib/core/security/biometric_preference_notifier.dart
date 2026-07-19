import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'biometric_preference_notifier.g.dart';

@Riverpod(keepAlive: true)
class BiometricPreferenceNotifier extends _$BiometricPreferenceNotifier {
  @override
  bool build() {
    return ref.read(sharedPreferencesProvider).getBiometricEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await ref.read(sharedPreferencesProvider).setBiometricEnabled(enabled);
  }
}
