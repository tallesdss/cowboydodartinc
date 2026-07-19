import 'dart:ui';

import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/config/features.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/email.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/password.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/signin_state.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/signup_state.dart';
import 'package:cowboydodartinc/features/authentication/providers/signin_state_provider.dart';
import 'package:cowboydodartinc/features/authentication/providers/signup_state_provider.dart';
import 'package:cowboydodartinc/features/authentication/ui/widgets/auth_account_switch_prompt.dart';
import 'package:cowboydodartinc/features/authentication/ui/widgets/auth_card_scaffold.dart';
import 'package:cowboydodartinc/features/authentication/ui/widgets/auth_page_back_button.dart';
import 'package:cowboydodartinc/features/authentication/ui/widgets/social_separator.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _formKey = GlobalKey<FormState>();
const double _authFieldSpacing = KasySpacing.md;
const double _authFieldToActionSpacing = KasySpacing.lg;

class SignupPage extends ConsumerWidget {
  final bool canDismiss;

  const SignupPage({super.key, this.canDismiss = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateNotifierProvider).user;
    redirectIfAuthenticated(context, user);
    if (user is AuthenticatedUserData) {
      return const Scaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox.shrink(),
      );
    }
    final signupState = ref.watch(signupStateProvider);
    final isSignupSending = signupState is SignupStateSending;
    final isSocialSending =
        ref.watch(signinStateProvider) is SigninStateSending;
    final isSending = isSignupSending || isSocialSending;
    final showBack = shouldShowAuthBackButton(context);
    return PopScope(
      canPop: showBack || canDismiss,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Form(
                autovalidateMode: AutovalidateMode.disabled,
                key: _formKey,
                child: AuthCardScaffold(
                  title: t.auth.signup.title,
                  subtitle: t.auth.signup.subtitle,
                  children: [
                      KasyTextField(
                        variant: KasyTextFieldVariant.flat,
                        key: const Key('email_input'),
                        onChanged: (value) => ref
                            .read(signupStateProvider.notifier)
                            .setEmail(value),
                        hint: t.auth.signin.email_hint,
                        label: t.auth.signin.email_label,
                        contentType: KasyTextFieldContentType.email,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          try {
                            signupState.email.validate();
                          } on EmailException catch (_) {
                            return t.auth.signin.email_invalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: _authFieldSpacing),
                      KasyTextField(
                        variant: KasyTextFieldVariant.flat,
                        key: const Key('password_input'),
                        onChanged: (newValue) => ref
                            .read(signupStateProvider.notifier)
                            .setPassword(newValue),
                        hint: t.auth.signin.password_hint,
                        label: t.auth.signin.password_label,
                        textInputAction: TextInputAction.done,
                        contentType: KasyTextFieldContentType.password,
                        onSubmitted: isSignupSending
                            ? null
                            : (_) {
                                if (!_formKey.currentState!.validate()) return;
                                FocusScope.of(context).unfocus();
                                ref.read(signupStateProvider.notifier).signup();
                              },
                        validator: (value) {
                          try {
                            signupState.password.validate();
                          } on PasswordException catch (_) {
                            if (value == null || value.trim().isEmpty) {
                              return t.auth.signin.password_required;
                            }
                            return t.auth.signin.password_too_short;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: _authFieldToActionSpacing),
                      KasyButton(
                        key: const Key('send_button'),
                        label: t.auth.signup.submit,
                        isLoading: isSignupSending,
                        onPressed: isSignupSending
                            ? null
                            : () {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                FocusScope.of(context).unfocus();
                                ref.read(signupStateProvider.notifier).signup();
                              },
                        expand: true,
                      ),
                      // Figma Sign Up mirrors Sign In: Gap xs under CTA.
                      const SizedBox(height: KasySpacing.xs),
                      const _SigninPrompt(),
                      const SizedBox(height: KasySpacing.lg),
                      const SocialSeparator(),
                      const SizedBox(height: KasySpacing.md),
                      const _SocialSignupRow(),
                  ],
                ),
              ),
              const AuthPageBackButton(),
              if (isSending)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: ColoredBox(
                          color: Colors.black.withValues(alpha: 0.15),
                          child: const Center(child: KasySpinner()),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
  }
}

class _SigninPrompt extends StatelessWidget {
  const _SigninPrompt();

  @override
  Widget build(BuildContext context) {
    return AuthAccountSwitchPrompt(
      lead: t.auth.signup.have_account,
      linkLabel: t.auth.signup.signin_link,
      onLinkPressed: () => context.pushReplacement('/signin'),
    );
  }
}

class _SocialSignupRow extends ConsumerWidget {
  const _SocialSignupRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signinStateProvider);
    final isSending = state is SigninStateSending;
    // Apple sign-in is reliable only on Apple-native platforms (iOS/macOS). On web
    // it needs a paid Apple Service ID + manual console setup (see auth docs), gated
    // by withAppleWebSignin (off by default). On Android it needs the same Service ID
    // and the Supabase/API native flow throws, so Apple is hidden there.
    final bool showApple = kIsWeb
        ? withAppleWebSignin
        : (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);
    Widget slot({required bool fixed, required Widget child}) {
      return Expanded(child: child);
    }

    return Row(
      children: [
        slot(
          fixed: true,
          child: KasySocialAuthButton(
            label: t.auth.signin.google,
            iconAsset: 'assets/icons/google.svg',
            onPressed: isSending
                ? null
                : () =>
                      ref.read(signinStateProvider.notifier).signinWithGoogle(),
          ),
        ),
        if (showApple) ...[
          const SizedBox(width: KasySpacing.sm),
          slot(
            fixed: true,
            child: KasySocialAuthButton(
              label: t.auth.signin.apple,
              // Apple's mark is officially black-on-light / white-on-dark, so
              // pick the variant that stays visible on the current theme.
              iconAsset: context.isDark
                  ? 'assets/icons/apple_white.svg'
                  : 'assets/icons/apple_black.svg',
              onPressed: isSending
                  ? null
                  : () => ref
                        .read(signinStateProvider.notifier)
                        .signinWithApple(),
            ),
          ),
        ],
      ],
    );
  }
}

