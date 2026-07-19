import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/authentication/providers/phone_auth_notifier.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpVerificationComponent extends ConsumerStatefulWidget {
  const OtpVerificationComponent({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OtpVerificationComponentState();
}

class _OtpVerificationComponentState
    extends ConsumerState<OtpVerificationComponent> {
  String _otp = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(phoneAuthProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: KasySpacing.lg),
        Icon(KasyIcons.sms, size: KasyIconSize.hero, color: context.colors.primary),
        const SizedBox(height: KasySpacing.lg),
        Text(
          t.phone_auth.verification_code,
          style: context.kasyTextTheme.pageTitle.copyWith(
            color: context.colors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KasySpacing.smd),
        Text(
          t.phone_auth.code_sent(phone: state.phoneNumber),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.muted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KasySpacing.xl),
        KasyTextFieldOTP(
          autofocus: true,
          onChanged: (value) => setState(() => _otp = value),
          onCompleted: (otp) {
            if (!state.isLoading) {
              ref.read(phoneAuthProvider.notifier).verifyOtp(otp);
            }
          },
        ),
        if (state.error != null) ...[
          const SizedBox(height: KasySpacing.md),
          Text(
            state.error!,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: KasySpacing.lg),
        KasyButton(
          label: t.phone_auth.verify_code,
          isLoading: state.isLoading,
          expand: true,
          onPressed: () {
            final otp = _otp.trim();
            if (otp.length == 6) {
              ref.read(phoneAuthProvider.notifier).verifyOtp(otp);
            } else {
              ref.read(phoneAuthProvider.notifier).setValidationError(
                t.phone_auth.enter_all_digits,
              );
            }
          },
        ),
        const SizedBox(height: KasySpacing.md),
        KasyButton(
          label: t.phone_auth.resend_code,
          variant: KasyButtonVariant.soft,
          isLoading: state.isLoading,
          expand: true,
          onPressed: () {
            ref.read(phoneAuthProvider.notifier).sendOtp(state.phoneNumber);
          },
        ),
      ],
    );
  }
}
