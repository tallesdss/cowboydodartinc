import 'dart:ui';

import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/bottom_menu/web_url.dart';
import 'package:cowboydodartinc/core/config/features.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/environments.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/email.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/password.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/signin_state.dart';
import 'package:cowboydodartinc/features/authentication/providers/signin_state_provider.dart';
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

class SigninPage extends ConsumerWidget {
  final bool canDismiss;

  const SigninPage({super.key, this.canDismiss = true});

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
    // Web: the sign-in screen is reached via the router redirect (e.g. after a
    // logout), where Bart may have left a stale tab path in the address bar
    // (it writes tab URLs directly via pushState). Pin the URL to '/signin' so
    // it matches the screen actually shown. No-op on native.
    if (kIsWeb) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => syncBrowserUrl('/signin'));
    }
    final state = ref.watch(signinStateProvider);
    final isSending = state is SigninStateSending;
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
                  title: t.auth.signin.title,
                  subtitle: t.auth.signin.subtitle,
                  children: [
                      KasyTextField(
                        variant: KasyTextFieldVariant.flat,
                        key: const Key('email_input'),
                        onChanged: (value) => ref
                            .read(signinStateProvider.notifier)
                            .setEmail(value),
                        hint: t.auth.signin.email_hint,
                        label: t.auth.signin.email_label,
                        contentType: KasyTextFieldContentType.email,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          try {
                            state.email.validate();
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
                            .read(signinStateProvider.notifier)
                            .setPassword(newValue),
                        hint: t.auth.signin.password_hint,
                        label: t.auth.signin.password_label,
                        textInputAction: TextInputAction.done,
                        contentType: KasyTextFieldContentType.password,
                        onSubmitted: isSending
                            ? null
                            : (_) {
                                if (!_formKey.currentState!.validate()) return;
                                FocusScope.of(context).unfocus();
                                ref.read(signinStateProvider.notifier).signin();
                              },
                        // Secondary link: intentionally NOT a Tab stop
                        // (focusable: false), so Tab/next flows email →
                        // password → submit → social buttons. Still tappable by
                        // mouse/touch and announced to screen readers.
                        labelTrailing: KasyLink(
                          label: t.auth.signin.forgot_password,
                          color: context.colors.muted,
                          focusable: false,
                          underline: KasyLinkUnderline.hover,
                          onPressed: () => context.push('/recover_password'),
                        ),
                        validator: (value) {
                          try {
                            state.password.validate();
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
                        label: t.auth.signin.submit,
                        isLoading: isSending,
                        onPressed: isSending
                            ? null
                            : () {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                FocusScope.of(context).unfocus();
                                ref.read(signinStateProvider.notifier).signin();
                              },
                        expand: true,
                      ),
                      // Figma 52:86 "Gap xs · CTA→signup" = 4. Visual breathing
                      // room comes from the 44px touch row around the prompt.
                      const SizedBox(height: KasySpacing.xs),
                      const _SignupPrompt(),
                      // Figma 52:92 "Gap lg · signup→separator" = 24.
                      const SizedBox(height: KasySpacing.lg),
                      const SocialSeparator(),
                      const SizedBox(height: KasySpacing.md),
                      const _SocialSigninRow(),
                      // Guest path: only on native in anonymous mode (on web the
                      // app requires sign-in), and only when there's no identity
                      // yet (post-logout / first run). A user who is already an
                      // anonymous guest opened sign-in to UPGRADE their account
                      // (link email/social), so "continue without account" would
                      // be nonsense for them — hide it.
                      if (!kIsWeb &&
                          user.idOrNull == null &&
                          ref
                                  .watch(environmentProvider)
                                  .authenticationMode ==
                              AuthenticationMode.anonymous) ...[
                        const SizedBox(height: KasySpacing.md),
                        const _GuestContinueButton(),
                      ],
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

class _SignupPrompt extends StatelessWidget {
  const _SignupPrompt();

  @override
  Widget build(BuildContext context) {
    return AuthAccountSwitchPrompt(
      lead: t.auth.signin.no_account,
      linkLabel: t.auth.signin.signup_link,
      onLinkPressed: () => context.pushReplacement('/signup'),
    );
  }
}

/// "Continue as guest" — creates the anonymous account on demand and navigates
/// into the app. Shown only on native in anonymous mode (see the build
/// condition in [SigninPage]).
class _GuestContinueButton extends ConsumerStatefulWidget {
  const _GuestContinueButton();

  @override
  ConsumerState<_GuestContinueButton> createState() =>
      _GuestContinueButtonState();
}

class _GuestContinueButtonState extends ConsumerState<_GuestContinueButton> {
  bool _loading = false;

  Future<void> _continue() async {
    // Capture the app-level router BEFORE the await. Creating the guest account
    // flips this button's visibility condition (it only shows while there's no
    // identity), so the widget is disposed the moment the account exists — after
    // that `context`/`ref`/`mounted` are gone. The router survives, so navigate
    // through the captured instance.
    //
    // We navigate explicitly because the redirect intentionally only bounces
    // *authenticated* users off the auth routes (so a guest can still open
    // sign-in to upgrade); it won't carry a freshly-created anonymous guest home.
    final router = GoRouter.of(context);
    setState(() => _loading = true);
    try {
      await ref.read(userStateNotifierProvider.notifier).continueAsGuest();
      router.go('/');
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      showKasyToast(
        context,
        title: t.auth.signin.error_title,
        tone: KasyToastTone.danger,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return KasyButton(
      label: t.auth.signin.continue_without,
      // Most subtle variant in the button preview: it's a tertiary action that
      // should sit quietly below sign-in / social, not compete with them.
      variant: KasyButtonVariant.ghost,
      expand: true,
      isLoading: _loading,
      onPressed: _loading ? null : _continue,
    );
  }
}

class _SocialSigninRow extends ConsumerWidget {
  const _SocialSigninRow();

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
    // Figma Sign In: Google/Apple fixed 114 when Facebook is present; Facebook
    // flexes. When Facebook is hidden, remaining buttons share the row equally.
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

