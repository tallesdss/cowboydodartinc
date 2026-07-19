import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/rating/providers/rating_repository.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

void showRatingPopup(WidgetRef ref) {
  final ratingRepository = ref.watch(ratingRepositoryProvider);
  final userState = ref.watch(userStateNotifierProvider);
  final ratingFuture = ratingRepository.get(userState.user);

  ratingFuture.then((rating) {
    final shouldAsk = rating.shouldAsk();
    Logger().d('should Ask for rating: $shouldAsk');
    if (shouldAsk && ref.context.mounted) {
      showKasyDialog<void>(
        context: ref.context,
        builder: (dialogCtx) {
          ratingRepository.delay();
          final translations = Translations.of(dialogCtx).rate_popup;
          return KasyDialog(
            title: translations.title,
            message: translations.description,
            showCloseButton: false,
            footer: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                KasyButton(
                  variant: KasyButtonVariant.ghost,
                  label: translations.cancel_button,
                  size: KasyButtonSize.small,
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                ),
                const SizedBox(width: KasySpacing.sm),
                KasyButton(
                  label: translations.rate_button,
                  size: KasyButtonSize.small,
                  onPressed: () async {
                    Navigator.of(dialogCtx).pop();
                    await ratingRepository.rate();
                    await rating.showRatingDialog();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  });
}
