import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'haptic_feedback_notifier.g.dart';

@Riverpod(keepAlive: true)
class HapticFeedbackNotifier extends _$HapticFeedbackNotifier {
  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getHapticFeedbackEnabled();
  }

  Future<void> toggle() async {
    final newValue = !state;
    state = newValue;
    await ref.read(sharedPreferencesProvider).setHapticFeedbackEnabled(newValue);
  }
}
