import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/authentication/providers/phone_auth_notifier.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneInputComponent extends ConsumerStatefulWidget {
  const PhoneInputComponent({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PhoneInputComponentState();
}

class _PhoneInputComponentState extends ConsumerState<PhoneInputComponent> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(phoneAuthProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: KasySpacing.lg),
          Icon(KasyIcons.phoneAndroid, size: KasyIconSize.hero, color: context.colors.primary),
          const SizedBox(height: KasySpacing.lg),
          Text(
            t.phone_auth.subtitle_input,
            style: context.kasyTextTheme.pageTitle.copyWith(
              color: context.colors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KasySpacing.smd),
          Text(
            t.phone_auth.description_input,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onBackground.withValues(alpha: .7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KasySpacing.xl),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: KasySpacing.xl),
              child: Container(
                padding: const EdgeInsets.all(KasySpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.error,
                  borderRadius: KasyRadius.mdBorderRadius,
                ),
                child: Text(
                  state.error!,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.background,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          KasyTextField(
            variant: KasyTextFieldVariant.flat,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            label: t.phone_auth.phone_label,
            hint: t.phone_auth.phone_hint,
            prefix: const Icon(KasyIcons.phone),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return t.phone_auth.error_empty;
              }
              if (value.replaceAll(RegExp('[^0-9+]'), '').length < 7) {
                return t.phone_auth.error_invalid;
              }
              return null;
            },
          ),
          const SizedBox(height: KasySpacing.lg),
          KasyButton(
            label: t.phone_auth.continue_btn,
            isLoading: state.isLoading,
            expand: true,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ref
                    .read(phoneAuthProvider.notifier)
                    .sendOtp(_phoneController.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }
}
