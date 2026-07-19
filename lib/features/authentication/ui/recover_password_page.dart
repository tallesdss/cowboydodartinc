import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/page_background.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/email.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/recover_state.dart';
import 'package:cowboydodartinc/features/authentication/providers/recover_provider.dart';
import 'package:cowboydodartinc/features/authentication/ui/widgets/auth_account_switch_prompt.dart';
import 'package:cowboydodartinc/features/authentication/ui/widgets/auth_card_scaffold.dart';
import 'package:cowboydodartinc/features/authentication/ui/widgets/recover_password_result.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _formKey = GlobalKey<FormState>();

/// Reset-password screen. Mirrors the sign-in / sign-up layout: a centered
/// card (logo, title, single email field, button) on a plain background, so it
/// looks identical to those pages on web/desktop instead of a stretched mobile
/// sub-page.
class RecoverPasswordPage extends ConsumerWidget {
  const RecoverPasswordPage({super.key});

  void _submit(BuildContext context, WidgetRef ref) {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(recoverStateProvider.notifier).send();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recoverStateProvider);
    final bool isSending = state is RecoverStateSending;
    final bool isSent = state is RecoverStateSent;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        ref.invalidate(recoverStateProvider);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            if (isSent)
              const Background(child: RecoverPasswordSent())
            else
              Form(
                key: _formKey,
                child: AuthCardScaffold(
                  title: t.auth.recover.title,
                  subtitle: t.auth.recover.subtitle,
                  children: [
                    KasyTextField(
                      variant: KasyTextFieldVariant.flat,
                      key: const Key('email_input'),
                      label: t.auth.recover.email_label,
                      contentType: KasyTextFieldContentType.email,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        try {
                          state.email.validate();
                        } on EmailException catch (_) {
                          return t.auth.signin.email_invalid;
                        }
                        return null;
                      },
                      onChanged: (value) => ref
                          .read(recoverStateProvider.notifier)
                          .setEmail(value),
                      onSubmitted:
                          isSending ? null : (_) => _submit(context, ref),
                    ),
                    const SizedBox(height: KasySpacing.lg),
                    KasyButton(
                      key: const Key('recover_button'),
                      label: t.auth.recover.submit,
                      isLoading: isSending,
                      onPressed:
                          isSending ? null : () => _submit(context, ref),
                      expand: true,
                    ),
                    // Same CTA→prompt rhythm as Sign In (Gap xs + 44 touch row).
                    const SizedBox(height: KasySpacing.xs),
                    const _BackToSigninPrompt(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Text link back to sign‑in, styled like the "Don't have an account? Sign up"
/// prompts. Replaces the old floating back orb so reaching login is one obvious
/// tap right under the action.
class _BackToSigninPrompt extends StatelessWidget {
  const _BackToSigninPrompt();

  @override
  Widget build(BuildContext context) {
    return AuthAccountSwitchPrompt(
      lead: t.auth.recover.remember,
      linkLabel: t.auth.recover.signin_link,
      onLinkPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/signin');
        }
      },
    );
  }
}

