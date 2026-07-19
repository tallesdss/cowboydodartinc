import 'package:cowboydodartinc/features/onboarding/models/user_info.dart';

class OnboardingState {
  DateTime? reminder;

  /// Answers collected before the anonymous account exists. The account is now
  /// created lazily at the end of onboarding (the loader screen), so the
  /// question screens have no user id to write to yet — we buffer the answers
  /// here and flush them once the account is created.
  final List<UserInfoDetail> pendingUserInfo;

  /// Preview mode: the flow is being walked from the admin Debug screen just to
  /// see the screens. Every real side effect (guest account creation, profile
  /// writes, permission prompts, the onboarded flag) is suppressed and the flow
  /// returns to Debug instead of Home. See [OnboardingNotifier].
  final bool preview;

  OnboardingState({
    this.reminder,
    this.pendingUserInfo = const [],
    this.preview = false,
  });

  OnboardingState copyWith({
    DateTime? reminder,
    List<UserInfoDetail>? pendingUserInfo,
    bool? preview,
  }) {
    return OnboardingState(
      reminder: reminder ?? this.reminder,
      pendingUserInfo: pendingUserInfo ?? this.pendingUserInfo,
      preview: preview ?? this.preview,
    );
  }
}
