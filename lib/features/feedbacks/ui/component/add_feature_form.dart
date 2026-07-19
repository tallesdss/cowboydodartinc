import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/toast/toast_service.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/feedbacks/providers/feedback_page_notifier.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the "submit an idea" form. Mobile/tablet use a bottom sheet (touch);
/// desktop (>= 1024) shows the same form inside a centered [KasyDialog].
Future<bool?> showAddFeatureSheet(BuildContext context) {
  final bool isDesktop =
      MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;
  // Start the surface synchronously (before the await) so context isn't used
  // across the async gap; only context.mounted guards the toast afterwards.
  if (isDesktop) {
    return showKasyBlurDialog<bool>(
      context: context,
      builder: (_) => const _AddFeatureForm(asDialog: true),
    );
  }
  return showKasyBlurBottomSheet<bool>(
    context: context,
    builder: (_) => const _AddFeatureForm(asDialog: false),
  );
}

class _AddFeatureForm extends ConsumerStatefulWidget {
  /// When true, render inside a centered [KasyDialog] (desktop); otherwise a
  /// [KasyBottomSheet] (mobile/tablet). The form logic is identical either way.
  final bool asDialog;

  const _AddFeatureForm({required this.asDialog});

  @override
  ConsumerState<_AddFeatureForm> createState() => _AddFeatureFormState();
}

class _AddFeatureFormState extends ConsumerState<_AddFeatureForm> {
  String title = '';
  String description = '';
  bool locked = false;

  bool get _titleFilled => title.trim().isNotEmpty;
  bool get _descriptionValid => description.length >= 40;
  bool get canSubmit => _titleFilled && _descriptionValid && !locked;

  void _onSubmitAttempt() {
    final tr = Translations.of(context).feature_requests.add_feature;
    if (!_titleFilled || description.trim().isEmpty) {
      ref.read(toastProvider).error(title: tr.error_title, text: tr.error_required);
      return;
    }
    if (!_descriptionValid) {
      ref.read(toastProvider).error(title: tr.error_title, text: tr.error_too_short);
      return;
    }
  }

  void _submit() {
    if (locked) return;
    final tr = Translations.of(context).feature_requests.add_feature;
    FocusScope.of(context).unfocus();
    setState(() => locked = true);
    ref
        .read(feedbackPageProvider.notifier)
        .createFeatureSuggestion(title: title, description: description)
        .then(
          (_) {
            if (!mounted) return;
            Navigator.of(context).pop(true);
          },
          onError: (_) {
            if (!mounted) return;
            setState(() => locked = false);
            ref.read(toastProvider).error(title: tr.error_title, text: tr.error_sending);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).feature_requests.add_feature;

    final Widget fields = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KasyTextField(
          label: tr.title_label,
          hint: tr.title_hint,
          showRequiredIndicator: true,
          onChanged: (v) => setState(() => title = v),
          textInputAction: TextInputAction.next,
          maxLength: 40,
        ),
        const SizedBox(height: KasySpacing.md),
        KasyTextField(
          label: tr.description_label,
          hint: tr.description_hint,
          showRequiredIndicator: true,
          minLines: 5,
          maxLines: 5,
          onChanged: (v) => setState(() => description = v),
          textInputAction: TextInputAction.done,
          maxLength: 1000,
        ),
      ],
    );

    final Widget submitButton = KasyButton(
      key: const ValueKey('add-feature-submit'),
      label: tr.save_button,
      expand: true,
      isLoading: locked,
      onPressed: canSubmit ? _submit : null,
    );

    if (widget.asDialog) {
      return KasyDialog(
        title: tr.title,
        showCloseButton: false,
        body: fields,
        actionsAxis: Axis.horizontal,
        actions: [
          KasyButton(
            key: const ValueKey('add-feature-cancel'),
            label: tr.cancel,
            variant: KasyButtonVariant.outline,
            expand: true,
            onPressed: locked ? null : () => Navigator.of(context).pop(false),
          ),
          if (canSubmit)
            submitButton
          else
            GestureDetector(onTap: _onSubmitAttempt, child: submitButton),
        ],
      );
    }

    return KasyBottomSheet(
      title: tr.title,
      message: tr.description,
      addKeyboardInset: true,
      body: fields,
      actions: [
        if (canSubmit)
          submitButton
        else
          GestureDetector(onTap: _onSubmitAttempt, child: submitButton),
      ],
    );
  }
}
