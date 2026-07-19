import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/rating/models/rating.dart';
import 'package:cowboydodartinc/core/rating/providers/rating_repository.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef OnRateBannerCallback = void Function();

/// This widget will display a banner to ask the user to review and rate the app
/// on Apple Store or Play Store
/// This is one of the most important things to do to improve your app visibility
/// Tip : Ask for a review after a positive action from the user and not at the first launch
///
/// - It will be displayed only if the user is authenticated and if he has not
/// already rate the app
/// - It will be displayed only if the user has installed the app since a certain
/// amount of time
/// - It will be displayed only if the user has declined to rate the app since a
/// certain amount of time
/// You can customize this widget as you want
class RateBanner extends ConsumerStatefulWidget {
  final Duration? delayBeforeAsking;
  final Duration? delayBeforeAskingAgain;
  final String? title;
  final String? text;
  final String? rateButtonText;
  final String? laterButtonText;
  final bool forceInDebug;

  const RateBanner({
    super.key,
    this.delayBeforeAsking,
    this.delayBeforeAskingAgain,
    this.title,
    this.text,
    this.rateButtonText,
    this.laterButtonText,
    this.forceInDebug = false,
  });

  @override
  ConsumerState<RateBanner> createState() => _RateBannerState();
}

class _RateBannerState extends ConsumerState<RateBanner> {
  bool _shouldShowDebug = true;

  @override
  Widget build(BuildContext context) {
    final ratingRepository = ref.watch(ratingRepositoryProvider);
    final userState = ref.watch(userStateNotifierProvider);
    final ratingFuture = ratingRepository.get(userState.user);
    return FutureBuilder<Rating>(
      future: ratingFuture,
      builder: (context, snapshot) {
        final shouldAsk = snapshot.hasData && snapshot.data!.shouldAsk();
        final shouldForce =
            widget.forceInDebug && kDebugMode && _shouldShowDebug;

        if (!shouldAsk && !shouldForce) return const SizedBox();

        return RateBannerWidget(
          title: widget.title ?? t.rate_banner.title,
          text: widget.text ?? t.rate_banner.text,
          rateButtonText: widget.rateButtonText ?? t.rate_banner.rate_button,
          laterButtonText: widget.laterButtonText ?? t.rate_banner.later_button,
          onAccept: () async {
            await ratingRepository.rate();
            await snapshot.data!.openStoreListing();
            setState(() => _shouldShowDebug = false);
          },
          onDecline: () async {
            await ratingRepository.delay();
            setState(() => _shouldShowDebug = false);
          },
        );
      },
    );
  }
}

class RateBannerWidget extends StatelessWidget {
  final String title;
  final String text;
  final String rateButtonText;
  final String laterButtonText;
  final OnRateBannerCallback onAccept;
  final OnRateBannerCallback onDecline;

  const RateBannerWidget({
    super.key,
    required this.onAccept,
    required this.onDecline,
    required this.title,
    required this.text,
    required this.rateButtonText,
    required this.laterButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Design-system surface (elevated card: surface + hairline border + soft
    // shadow), instead of a hand-rolled Container reproducing the same look.
    return KasyCard(
      padding: const EdgeInsets.all(KasySpacing.lg),
      borderRadius: KasyRadius.lgBorderRadius,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(KasyIcons.star, color: cs.primary, size: KasyIconSize.xxl),
          ),
          const SizedBox(height: KasySpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.kasyTextTheme.sectionTitle.copyWith(
              color: cs.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: KasySpacing.xs),
          Text(
            text,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
              height: 1.4,
            ),
          ),
          const SizedBox(height: KasySpacing.lg),
          Row(
            children: [
              Expanded(
                child: KasyButton(
                  key: const ValueKey('later_button'),
                  label: laterButtonText,
                  variant: KasyButtonVariant.outline,
                  foregroundColor: cs.onSurface.withValues(alpha: 0.6),
                  borderColor: cs.outline,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  fontWeight: FontWeight.w500,
                  size: KasyButtonSize.large,
                  expand: true,
                  onPressed: onDecline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: KasyButton(
                  key: const ValueKey('positive_button'),
                  label: rateButtonText,
                  backgroundColor: cs.onSurface,
                  foregroundColor: cs.surface,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  fontWeight: FontWeight.w500,
                  size: KasyButtonSize.large,
                  expand: true,
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
