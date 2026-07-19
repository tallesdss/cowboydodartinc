import 'package:cowboydodartinc/core/states/translations.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/toast/toast_service.dart';
import 'package:cowboydodartinc/features/authentication/navigation/post_login_navigation.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/email.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/password.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/signup_state.dart';
import 'package:cowboydodartinc/features/authentication/repositories/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signup_state_provider.g.dart';

@Riverpod()
class SignupStateNotifier extends _$SignupStateNotifier {
  AuthenticationRepository get _authRepository =>
      ref.read(authRepositoryProvider);

  UserStateNotifier get _userStateNotifier =>
      ref.read(userStateNotifierProvider.notifier);

  @override
  SignupState build() {
    return SignupState(email: Email(''), password: Password(''));
  }

  void setEmail(String? value) {
    final email = Email(value ?? '');
    if (email == state.email) {
      return;
    }
    state = state.copyWith(email: email);
  }

  void setPassword(String? pwd) {
    final password = Password(pwd ?? '');
    if (password == state.password) {
      return;
    }
    state = state.copyWith(password: password);
  }

  Future<void> signup() async {
    if (state is SignupStateSending) {
      return;
    }
    try {
      state.email.validate();
      state.password.validate();
      state = SignupState.sending(email: state.email, password: state.password);
      await _authRepository.signup(state.email.value, state.password.value);
      // lets fake a delay to prevent spamming the signup button
      await Future.delayed(const Duration(milliseconds: 1500));
      await _userStateNotifier.onSignin();
      if (!ref.mounted) return;
      goHomeAfterLogin(ref);
    } catch (e, trace) {
      debugPrint("Error while signing up: $e, $trace");
      state = SignupState(email: state.email, password: state.password);
      final t = ref.read(translationsProvider);
      ref.read(toastProvider).error(
        title: t.auth.signup.error_title,
        text: t.auth.signup.error_text,
      );
    }
  }
}
