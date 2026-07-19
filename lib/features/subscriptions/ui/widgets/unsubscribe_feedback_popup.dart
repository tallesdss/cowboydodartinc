import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

const int kMinimumUnsubscribeReasonLength = 6;
const int kMaximumUnsubscribeReasonLength = 300;

typedef OnUnsubscribeConfirm = void Function(String reason);

class UnsubscribeFeedbackPopup extends StatefulWidget {
  final OnUnsubscribeConfirm onConfirm;
  final VoidCallback onCancel;

  const UnsubscribeFeedbackPopup({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  static Future<void> show({
    required BuildContext context,
    required OnUnsubscribeConfirm onConfirm,
    required VoidCallback onCancel,
  }) {
    return showKasyBlurDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return UnsubscribeFeedbackPopup(
          onConfirm: onConfirm,
          onCancel: onCancel,
        );
      },
    );
  }

  @override
  State<UnsubscribeFeedbackPopup> createState() =>
      _UnsubscribeFeedbackPopupState();
}

class _UnsubscribeFeedbackPopupState extends State<UnsubscribeFeedbackPopup> {
  final TextEditingController _reasonController = TextEditingController();
  bool _canUnsubscribe = false;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(_onReasonChanged);
  }

  @override
  void dispose() {
    _reasonController.removeListener(_onReasonChanged);
    _reasonController.dispose();
    super.dispose();
  }

  void _onReasonChanged() {
    final bool hasMinimumLength =
        _reasonController.text.trim().length >= kMinimumUnsubscribeReasonLength;
    if (hasMinimumLength != _canUnsubscribe) {
      setState(() => _canUnsubscribe = hasMinimumLength);
    }
  }

  void _handleUnsubscribe() {
    if (_canUnsubscribe) {
      _confirmed = true;
      widget.onConfirm(_reasonController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context).activePremium;

    return PopScope(
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop && !_confirmed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onCancel();
          });
        }
      },
      child: KasyDialog(
        title: translations.unsubscribe_feedback_title,
        closeAboveTitle: true,
        closeButtonStyle: KasyDialogCloseButtonStyle.filledNeutral,
        closeFilledButtonExtent: 36,
        closeFilledIconGlyphSize: 14,
        body: KasyTextField(
          controller: _reasonController,
          maxLines: 3,
          autofocus: true,
          variant: KasyTextFieldVariant.secondary,
          hint: translations.unsubscribe_feedback_hint,
          maxLength: kMaximumUnsubscribeReasonLength,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
        ),
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            KasyButton(
              label: translations.cancel_button,
              variant: KasyButtonVariant.ghost,
              size: KasyButtonSize.small,
              onPressed: () => Navigator.maybePop(context),
            ),
            const SizedBox(width: KasySpacing.sm),
            KasyButton(
              label: translations.unsubscribe_confirm_button,
              size: KasyButtonSize.small,
              onPressed: !_canUnsubscribe ? null : _handleUnsubscribe,
            ),
          ],
        ),
      ),
    );
  }
}
