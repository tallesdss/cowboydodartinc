import 'package:cowboydodartinc/components/kasy_spinner.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/security/biometric_service.dart';
import 'package:cowboydodartinc/core/security/biometric_ui_bundle.dart';
import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'biometric_guard.g.dart';

/// Tracks whether biometric was verified in the current session.
@Riverpod(keepAlive: true)
class BiometricSessionNotifier extends _$BiometricSessionNotifier {
  @override
  bool build() => false;

  void markVerified() => state = true;
}

/// Wraps its [child] and demands biometric authentication on app start
/// whenever the user is authenticated and biometric lock is enabled.
class BiometricGuard extends ConsumerStatefulWidget {
  final Widget child;

  const BiometricGuard({super.key, required this.child});

  @override
  ConsumerState<BiometricGuard> createState() => _BiometricGuardState();
}

class _BiometricGuardState extends ConsumerState<BiometricGuard> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final alreadyVerified = ref.read(biometricSessionProvider);
      if (alreadyVerified) return;

      final prefsNotifier = ref.read(sharedPreferencesProvider);
      if (!prefsNotifier.getBiometricEnabled()) return;

      final user = ref.read(userStateNotifierProvider).user;
      if (user is! AuthenticatedUserData) return;

      /// Let the navigator / theme settle so iOS/Android can present the
      /// system biometric sheet; calling too early sometimes never completes.
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 280));

      if (!mounted) return;

      final service = ref.read(biometricServiceProvider);
      final platform = Theme.of(context).platform;
      final slot = await ref.read(biometricCopySlotFamily(platform).future);
      if (!mounted) return;
      final reason = BioBundle.fromSlot(context, slot).loginReason;

      final success = await service
          .authenticate(localizedReason: reason)
          .timeout(
            const Duration(seconds: 90),
            onTimeout: () {
              debugPrint('BiometricGuard: authenticate timed out');
              return false;
            },
          );

      if (!mounted) return;

      if (success) {
        ref.read(biometricSessionProvider.notifier).markVerified();
      } else {
        await _safeLogout();
      }
    } catch (e, st) {
      debugPrint('BiometricGuard error: $e');
      debugPrint('$st');
      await _safeLogout();
    } finally {
      _done();
    }
  }

  Future<void> _safeLogout() async {
    try {
      await ref.read(userStateNotifierProvider.notifier).onLogout();
    } catch (e, st) {
      debugPrint('BiometricGuard.logout: $e\n$st');
    }
  }

  void _done() {
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: const Center(child: KasySpinner()),
      );
    }
    return widget.child;
  }
}
