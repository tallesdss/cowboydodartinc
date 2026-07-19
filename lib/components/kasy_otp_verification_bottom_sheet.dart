import 'package:cowboydodartinc/components/kasy_bottom_sheet.dart';
import 'package:cowboydodartinc/components/kasy_button.dart';
import 'package:cowboydodartinc/components/kasy_text_field_otp.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/material.dart';

/// Built-in layouts for [showKasyOtpVerificationBottomSheet].
enum KasyOtpVerificationSheetPreset {
  /// Six digits, grouped 3–3, SMS footer + resend (demo phone line).
  phoneVerification,

  /// Four digits, flat neutral cells, minimal footer — PIN-style flow.
  pinDigits,
}

/// Opens the OTP / PIN verification [KasyBottomSheet] (keyboard-aware,
/// neutral-flat cells, no placeholder dashes).
Future<T?> showKasyOtpVerificationBottomSheet<T>({
  required BuildContext context,
  KasyOtpVerificationSheetPreset preset =
      KasyOtpVerificationSheetPreset.phoneVerification,
}) {
  return showKasyBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext sheetCtx) => KasyOtpVerificationBottomSheet(
      sheetContext: sheetCtx,
      preset: preset,
    ),
  );
}

/// Sheet body for OTP or PIN entry — use via [showKasyOtpVerificationBottomSheet]
/// or embed in your own modal.
class KasyOtpVerificationBottomSheet extends StatefulWidget {
  final BuildContext sheetContext;
  final KasyOtpVerificationSheetPreset preset;

  const KasyOtpVerificationBottomSheet({
    super.key,
    required this.sheetContext,
    this.preset = KasyOtpVerificationSheetPreset.phoneVerification,
  });

  @override
  State<KasyOtpVerificationBottomSheet> createState() =>
      _KasyOtpVerificationBottomSheetState();
}

class _KasyOtpVerificationBottomSheetState
    extends State<KasyOtpVerificationBottomSheet> {
  String _code = '';
  bool _isVerifying = false;
  bool _isVerified = false;

  bool get _phoneMode =>
      widget.preset == KasyOtpVerificationSheetPreset.phoneVerification;

  int get _otpLength => _phoneMode ? 6 : 4;

  int? get _separatorAfterIndex => _phoneMode ? 2 : null;

  bool get _isComplete => _code.length == _otpLength;

  Future<void> _verify() async {
    if (_isVerifying) return;
    if (!_isComplete) {
      await KasyHaptics.selection(context);
      return;
    }
    setState(() {
      _isVerifying = true;
      _isVerified = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _isVerifying = false;
      _isVerified = true;
    });
    await KasyHaptics.selection(context);
  }

  @override
  Widget build(BuildContext context) {
    final BuildContext sheetContext = widget.sheetContext;
    final String buttonLabel = _isVerified
        ? (_phoneMode ? 'Verified' : 'Done')
        : _isVerifying
        ? (_phoneMode ? 'Verifying...' : 'Checking...')
        : (_phoneMode ? 'Verify Code' : 'Continue');
    final String title = _phoneMode
        ? 'Verify your phone number'
        : 'Enter your PIN';
    final String message = _phoneMode
        ? 'We sent a verification code to'
        : 'Confirm with your 4-digit PIN.';
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: KasyBottomSheet(
        icon: _isVerified ? KasyIcons.checkCircle : KasyIcons.check,
        title: title,
        message: message,
        addKeyboardInset: true,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_phoneMode) ...[
              Text(
                '+1 234 567 8900',
                style: sheetContext.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: sheetContext.colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KasySpacing.xl),
            ] else ...[
              const SizedBox(height: KasySpacing.sm),
            ],
            Center(
              child: KasyTextFieldOTP(
                length: _otpLength,
                separatorAfterIndex: _separatorAfterIndex,
                neutralFlatCells: true,
                onChanged: (String value) {
                  setState(() {
                    _code = value;
                    _isVerified = false;
                  });
                },
                onCompleted: (_) => KasyHaptics.selection(context),
              ),
            ),
            SizedBox(height: _phoneMode ? KasySpacing.xl : KasySpacing.lg),
            if (_phoneMode) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: sheetContext.textTheme.bodyMedium?.copyWith(
                      color: sheetContext.colors.muted,
                    ),
                  ),
                  _SheetResendCodeLink(
                    onTap: () => KasyHaptics.selection(context),
                  ),
                ],
              ),
              const SizedBox(height: KasySpacing.xl),
              Text(
                'By continuing, you agree to receive SMS messages for verification. '
                'Message and data rates may apply.',
                style: sheetContext.textTheme.bodySmall?.copyWith(
                  color: sheetContext.colors.muted,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                'Never share your PIN with anyone.',
                style: sheetContext.textTheme.bodySmall?.copyWith(
                  color: sheetContext.colors.muted,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          KasyButton(
            label: buttonLabel,
            variant: _isComplete || _isVerified
                ? KasyButtonVariant.primary
                : KasyButtonVariant.soft,
            isLoading: _isVerifying,
            expand: true,
            onPressed: _verify,
          ),
        ],
      ),
    );
  }
}

class _SheetResendCodeLink extends StatefulWidget {
  final VoidCallback onTap;

  const _SheetResendCodeLink({required this.onTap});

  @override
  State<_SheetResendCodeLink> createState() => _SheetResendCodeLinkState();
}

class _SheetResendCodeLinkState extends State<_SheetResendCodeLink> {
  bool _pressed = false;

  Future<void> _handleTap() async {
    setState(() => _pressed = true);
    await KasyHaptics.selection(context);
    await Future<void>.delayed(const Duration(milliseconds: 130));
    if (mounted) setState(() => _pressed = false);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return KasyFocusRing(
      onActivate: _handleTap,
      borderRadius: BorderRadius.circular(KasyRadius.sm),
      child: GestureDetector(
        onTap: _handleTap,
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: _pressed ? 0.55 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Text(
              'Resend code',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onBackground,
                // Uncolored emphasis link: w600 (same as the auth "Sign up /
                // Sign in" links), not the w700 heading weight.
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
