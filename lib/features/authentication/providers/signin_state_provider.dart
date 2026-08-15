import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/states/translations.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/toast/toast_service.dart';
import 'package:cowboydodartinc/features/authentication/navigation/post_login_navigation.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/email.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/password.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/signin_state.dart';
import 'package:cowboydodartinc/features/authentication/repositories/authentication_repository.dart';
import 'package:cowboydodartinc/features/authentication/repositories/exceptions/authentication_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signin_state_provider.g.dart';

@Riverpod()
class SigninStateNotifier extends _$SigninStateNotifier {
  AuthenticationRepository get _authRepository =>
      ref.read(authRepositoryProvider);

  UserStateNotifier get _userStateNotifier =>
      ref.read(userStateNotifierProvider.notifier);

  @override
  SigninState build() {
    return SigninState(email: Email(""), password: Password(""));
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

  Future<void> signin() async {
    if (state is SigninStateSending) {
      return;
    }
    try {
      state = SigninState.sending(email: state.email, password: state.password);
      await _authRepository.signin(state.email.value, state.password.value);
      if (!ref.mounted) return;
      await _userStateNotifier.onSignin();
      if (!ref.mounted) return;
      goHomeAfterLogin(ref);
    } catch (e, trace) {
      debugPrint("Error while signing in: $e, $trace");
      if (!ref.mounted) return;
      state = SigninState(email: state.email, password: state.password);
      final t = ref.read(translationsProvider);
      ref.read(toastProvider).error(
        title: t.auth.signin.error_title,
        text: t.auth.signin.error_text,
      );
    }
  }

  Future<void> signinWithGoogle() async {
    if (state is SigninStateSending) {
      return;
    }
    try {
      state = SigninState.sending(email: state.email, password: state.password);
      final currentUser = ref.read(userStateNotifierProvider).user;
      if (currentUser is AnonymousUserData) {
        // Anonymous user: link Google to preserve data (same UID kept)
        await _authRepository.signupFromAnonymousWithGoogle();
      } else {
        // Returning user or unauthenticated: regular sign-in
        await _authRepository.signinWithGoogle();
      }
      if (!ref.mounted) return;
      await _userStateNotifier.onSignin();
      if (!ref.mounted) return;
      goHomeAfterLogin(ref);
    } catch (e, trace) {
      if (!ref.mounted) return;
      state = SigninState(email: state.email, password: state.password);
      if (e is UserCancelledSignInException) return;
      debugPrint("Error while signing up: $e, $trace");
      final tr = ref.read(translationsProvider).auth.signin;
      ref.read(toastProvider).error(
            title: tr.error_title,
            text: e is EmailAlreadyRegisteredException
                ? tr.email_already_registered
                : tr.social_error(provider: 'Google'),
          );
    }
  }

  Future<void> signinWithGooglePlayGames() async {
    if (state is SigninStateSending) {
      return;
    }
    try {
      state = SigninState.sending(email: state.email, password: state.password);
      await _authRepository.signinWithGooglePlayGames();
      if (!ref.mounted) return;
      await _userStateNotifier.onSignin();
      if (!ref.mounted) return;
      goHomeAfterLogin(ref);
    } catch (e, trace) {
      if (!ref.mounted) return;
      state = SigninState(email: state.email, password: state.password);
      if (e is UserCancelledSignInException) return;
      debugPrint("Error while signing up: $e, $trace");
      final tr = ref.read(translationsProvider).auth.signin;
      ref.read(toastProvider).error(
            title: tr.error_title,
            text: e is EmailAlreadyRegisteredException
                ? tr.email_already_registered
                : tr.social_error(provider: 'Google Play Games'),
          );
    }
  }

  Future<void> signinWithApple() async {
    if (state is SigninStateSending) {
      return;
    }
    try {
      state = SigninState.sending(email: state.email, password: state.password);
      final currentUser = ref.read(userStateNotifierProvider).user;
      if (currentUser is AnonymousUserData) {
        await _authRepository.signupFromAnonymousWithApple();
      } else {
        await _authRepository.signinWithApple();
      }
      if (!ref.mounted) return;
      await _userStateNotifier.onSignin();
      if (!ref.mounted) return;
      goHomeAfterLogin(ref);
    } catch (e, trace) {
      if (!ref.mounted) return;
      state = SigninState(email: state.email, password: state.password);
      if (e is UserCancelledSignInException) return;
      debugPrint("Error while signing up: $e, $trace");
      final tr = ref.read(translationsProvider).auth.signin;
      ref.read(toastProvider).error(
            title: tr.error_title,
            text: e is EmailAlreadyRegisteredException
                ? tr.email_already_registered
                : tr.social_error(provider: 'Apple'),
          );
    }
  }

  Future<void> signinWithFacebook() async {
    if (state is SigninStateSending) {
      return;
    }
    try {
      state = SigninState.sending(email: state.email, password: state.password);
      final currentUser = ref.read(userStateNotifierProvider).user;
      if (currentUser is AnonymousUserData) {
        await _authRepository.signupFromAnonymousWithFacebook();
      } else {
        await _authRepository.signinWithFacebook();
      }
      if (!ref.mounted) return;
      await _userStateNotifier.onSignin();
      if (!ref.mounted) return;
      goHomeAfterLogin(ref);
    } catch (e, trace) {
      if (!ref.mounted) return;
      state = SigninState(email: state.email, password: state.password);
      if (e is UserCancelledSignInException) return;
      debugPrint("Error while signing up: $e, $trace");
      final tr = ref.read(translationsProvider).auth.signin;
      ref.read(toastProvider).error(
            title: tr.error_title,
            text: e is EmailAlreadyRegisteredException
                ? tr.email_already_registered
                : tr.social_error(provider: 'Facebook'),
          );
    }
  }
}
