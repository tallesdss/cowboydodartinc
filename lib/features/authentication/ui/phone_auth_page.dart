import 'package:cowboydodartinc/components/kasy_app_bar.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_scroll_behavior.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/authentication/providers/models/phone_signin_state.dart';
import 'package:cowboydodartinc/features/authentication/providers/phone_auth_notifier.dart';
import 'package:cowboydodartinc/features/authentication/ui/components/otp_verification.dart';
import 'package:cowboydodartinc/features/authentication/ui/components/phone_input.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneAuthPage extends ConsumerStatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  ConsumerState<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends ConsumerState<PhoneAuthPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(phoneAuthProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: KasyOverlayScaffold(
        title: switch (state) {
          PhoneAuthInputPhoneState() => t.phone_auth.title_input,
          PhoneAuthVerifyOtpState() => t.phone_auth.title_verify,
        },
        appBarStyle: KasyAppBarStyle.subpageSimple,
        onBack: switch (state) {
          PhoneAuthInputPhoneState() => null,
          PhoneAuthVerifyOtpState() => () {
              ref.read(phoneAuthProvider.notifier).reset();
            },
        },
        slivers: [
          SliverToBoxAdapter(
            child: LargeLayoutContainer(
              child: ScrollConfiguration(
                behavior: const KasyKitScrollBehavior(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: KasySpacing.lg,
                  ),
                  child: switch (state) {
                    PhoneAuthInputPhoneState() => const PhoneInputComponent(),
                    PhoneAuthVerifyOtpState() => const OtpVerificationComponent(),
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
