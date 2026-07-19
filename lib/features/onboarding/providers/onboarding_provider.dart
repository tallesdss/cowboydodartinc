import 'dart:async';

import 'package:cowboydodartinc/core/data/api/analytics_api.dart';
import 'package:cowboydodartinc/core/data/api/tracking_api.dart';
import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/notification.dart';
import 'package:cowboydodartinc/features/notifications/repositories/notifications_repository.dart';
import 'package:cowboydodartinc/features/onboarding/models/user_info.dart';
import 'package:cowboydodartinc/features/onboarding/providers/onboarding_model.dart';
import 'package:cowboydodartinc/features/onboarding/repositories/user_infos_repository.dart';
import 'package:cowboydodartinc/features/subscriptions/repositories/subscription_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_provider.g.dart';

extension OnboardingNotifierExt on WidgetRef {
  OnboardingNotifier get onboardingNotifier =>
      read(onboardingProvider.notifier);

  OnboardingState? get onboardingState$ => watch(onboardingProvider);

  OnboardingNotifier get onboardingState =>
      read(onboardingProvider.notifier);
}

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() {
    return OnboardingState();
  }

  /// Enter/leave preview mode. Called once when [OnboardingPage] mounts: the
  /// admin Debug "Test onboarding" entry sets `true`, the real flow sets
  /// `false`, so the flag is always correct on every entry.
  void setPreview(bool value) {
    if (state.preview == value) return;
    state = state.copyWith(preview: value);
  }

  Future<void> onAnsweredQuestion(UserInfoDetail value) async {
    // Preview: never touch the admin's real profile. Buffer the answer so the
    // question screens still behave (selection persists across steps), but it's
    // discarded with the provider state once the preview ends.
    if (state.preview) {
      final others = state.pendingUserInfo
          .where((info) => info.runtimeType != value.runtimeType)
          .toList();
      state = state.copyWith(pendingUserInfo: [...others, value]);
      return;
    }
    final userId = ref.read(userStateNotifierProvider).user.idOrNull;
    if (userId != null) {
      // Account already exists (e.g. a returning guest re-onboarding): save now.
      await ref.read(userInfosRepositoryProvider).save(userId, value);
      return;
    }
    // No account yet — it's created at the end of onboarding. Buffer the answer
    // (replacing any previous answer of the same kind) so it isn't lost; it's
    // flushed in [onOnboardingCompleted] once the account exists.
    final others = state.pendingUserInfo
        .where((info) => info.runtimeType != value.runtimeType)
        .toList();
    state = state.copyWith(pendingUserInfo: [...others, value]);
  }

  Future<void> setupNotifications() async {
    // Preview: don't fire the real OS permission dialog or log analytics — the
    // permission screen is shown for review only.
    if (state.preview) return;

    final userStateNotifier = ref.read(userStateNotifierProvider.notifier);
    final notificationsRepository = ref.read(notificationRepositoryProvider);

    // Onboarding is the first automatic push prompt. Mark it done so the
    // notifications screen (which shares this flag) won't auto-prompt again right
    // after — avoiding a duplicate ask for users who finished onboarding. Read
    // the prefs and set the flag before the OS dialog sends the app to
    // background, since [ref] may be disposed by the time the dialog returns.
    await ref.read(sharedPreferencesProvider).setPushAutoRequested(true);

    try {
      var permission = await notificationsRepository.getPermissionStatus();
      await permission.maybeAsk();

      // The system permission dialog causes the app to go to background.
      // The provider may have been disposed while waiting — bail out if so.
      if (!ref.mounted) return;

      permission = await notificationsRepository.getPermissionStatus();

      if (permission is NotificationPermissionGranted) {
        unawaited(
          ref
              .read(analyticsApiProvider)
              .logEvent('setup_notifications_accepted', {}),
        );
      }

      await userStateNotifier.refresh();
    } catch (_) {
      // Notification setup must not block onboarding progression.
    }
  }

  /// Request iOS App Tracking Transparency (IDFA) and wire the granted id into
  /// subscriptions + Facebook events. Mirrors [setupNotifications]: a no‑op in
  /// preview, so the ATT screen can be walked for review without firing the real
  /// OS dialog (which doesn't exist off‑iOS anyway).
  Future<void> requestAtt() async {
    if (state.preview) return;

    final Map<Permission, PermissionStatus> permission = await [
      Permission.appTrackingTransparency,
    ].request();
    final bool isGranted =
        permission.values.first == PermissionStatus.granted;
    ref.read(analyticsApiProvider).logEvent('att_request', {
      'granted': isGranted,
    });
    final userId = ref.read(userStateNotifierProvider).user.idOrNull;
    if (userId != null) {
      ref.read(subscriptionRepositoryProvider).initUser(userId).ignore();
      ref.read(facebookEventApiProvider).initUser(userId).ignore();
    }
  }

  Future<void> onOnboardingCompleted() async {
    await createGuestAccount();
    await flushPendingUserInfo();
    await refreshOnboardingUser();
  }

  /// Loader step 1 — anonymous guest account.
  Future<void> createGuestAccount() async {
    if (state.preview) return;
    await ref.read(userStateNotifierProvider.notifier).continueAsGuest();
  }

  /// Loader step 2 — gender/age answers collected before the account existed.
  Future<void> flushPendingUserInfo() async {
    if (state.preview) return;

    final userId = ref.read(userStateNotifierProvider).user.idOrNull;
    final pending = state.pendingUserInfo;
    if (userId == null || pending.isEmpty) return;

    final repository = ref.read(userInfosRepositoryProvider);
    for (final info in pending) {
      try {
        await repository.save(userId, info);
      } catch (e) {
        Logger().w('Failed to save onboarding answer: $e');
      }
    }
    state = state.copyWith(pendingUserInfo: const []);
  }

  /// Loader step 3 — refresh session after profile writes.
  Future<void> refreshOnboardingUser() async {
    if (state.preview) return;
    await ref.read(userStateNotifierProvider.notifier).refresh();
  }

  /// Skip onboarding: mark as onboarded instantly (optimistic) and navigate
  /// to home. Permissions (push + ATT) are requested on the home screen.
  void skipOnboarding() {
    // Preview: skipping must not mark the real user as onboarded.
    if (state.preview) return;
    ref.read(userStateNotifierProvider.notifier).onSkippedOnboarding();
  }
}
