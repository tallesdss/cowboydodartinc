import 'package:cowboydodartinc/core/states/translations.dart';
import 'package:cowboydodartinc/core/toast/toast_service.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/email.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/recover_state.dart';
import 'package:cowboydodartinc/features/authentication/repositories/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recover_provider.g.dart';

@Riverpod()
class RecoverStateNotifier extends _$RecoverStateNotifier {
  AuthenticationRepository get authRepository =>
      ref.read(authRepositoryProvider);

  @override
  RecoverState build() {
    return RecoverState(email: Email(''));
  }

  void setEmail(String? value) {
    final email = Email(value ?? '');
    if (email == state.email) {
      return;
    }
    state = state.copyWith(email: email);
  }

  Future<void> send() async {
    if (state is RecoverStateSending) {
      return;
    }
    try {
      state.email.validate();
      state = RecoverState.sending(email: state.email);
      await authRepository.recoverPassword(state.email.value);
      // lets fake a delay to prevent spamming the signup button
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!ref.mounted) return;
      state = RecoverState.sent(email: state.email);
    } catch (e, trace) {
      debugPrint("Error while signing up: $e, $trace");
      state = RecoverState(email: state.email);
      final t = ref.read(translationsProvider);
      ref.read(toastProvider).error(
        title: t.auth.recover.error_title,
        text: t.auth.recover.error_text,
      );
    }
  }
}
