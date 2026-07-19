import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/bottom_menu/bart_inner_navigation.dart';
import 'package:cowboydodartinc/core/config/features.dart';
import 'package:cowboydodartinc/core/data/api/analytics_api.dart';
import 'package:cowboydodartinc/core/rating/models/review.dart';
import 'package:cowboydodartinc/core/rating/providers/rating_repository.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_routes.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

/// Shows the in-app review funnel. Prefer a stable [context] (not a sheet that
/// will be popped before the async work finishes).
///
/// Two-step "rating protection" funnel:
///   1. A sentiment gate ("Enjoying the app?") with a positive / negative pick.
///   2a. Positive → a gold-star [KasyDialog] that sends the user to the store
///       (App Store / Play Store) to write a public review.
///   2b. Negative → the private feedback screen, so an unhappy user vents to
///       us instead of leaving a low public rating.
///
/// Dismissing any step just defers the next ask and keeps the user where they
/// are. Returns true once the funnel was shown (regardless of the branch taken).
Future<bool> showReviewDialog(
  BuildContext context,
  WidgetRef ref, {
  bool force = false,
}) async {
  // Store reviews are native-only (App Store / Play Store). In production the
  // auto prompt never shows on web (nowhere to send the user). But a forced
  // call — the admin preview — still shows the funnel on web so its design can
  // be reviewed there; only the store action won't do anything.
  if (kIsWeb && !force) {
    return false;
  }
  if (!context.mounted) {
    return false;
  }

  final ratingRepository = ref.read(ratingRepositoryProvider);
  final analytics = ref.read(analyticsApiProvider);
  final userState = ref.read(userStateNotifierProvider);
  final rating = await ratingRepository.getReview(userState.user);

  final shouldAsk = rating.shouldAsk();
  Logger().d('should Ask for review: $shouldAsk');
  if (!shouldAsk && !force) {
    return false;
  }
  if (!context.mounted) {
    return false;
  }

  // Defer the next ask up front, so any outcome (dismiss, positive, negative)
  // counts as "asked" and we don't pester the user again right away.
  await rating.delay();
  analytics.logEvent('rating_funnel_open', {});
  if (!context.mounted) {
    return false;
  }

  // Step 1 — sentiment gate.
  final bool? enjoying = await _askEnjoying(context, analytics);
  if (enjoying == null) {
    return true; // dismissed without choosing
  }

  // Step 2b — negative branch: keep the bad review private.
  if (!enjoying) {
    analytics.logEvent('rating_funnel_negative', {});
    if (context.mounted) {
      await _openFeedbackAfterNegative(context, force: force);
    }
    return true;
  }

  // Step 2a — positive branch: send the happy user to the store.
  analytics.logEvent('rating_funnel_positive', {});
  if (!context.mounted) {
    return true;
  }
  await _askStoreReview(context, ratingRepository, rating, analytics);
  return true;
}

/// Opens Feedback without tearing Admin (or the active tab) apart.
///
/// - **Admin / force preview:** remember the admin URL and open the settings
///   feedback entry so back returns to Admin (not a desynced `/settings` shell).
/// - **User in BottomMenu:** push the settings inner route on the existing
///   shell navigator (same path as Settings → Send feedback).
/// - **No shell:** top-level `/feedback` with return to Home.
Future<void> _openFeedbackAfterNegative(
  BuildContext context, {
  required bool force,
}) async {
  if (!withFeedback) {
    return;
  }

  final String location = GoRouter.of(context).state.matchedLocation;
  final bool fromAdmin = force || location.startsWith('/admin');

  if (fromAdmin) {
    final String returnTo =
        location.startsWith('/admin') ? location : adminRouteDebug;
    setSettingsInnerReturnPath(returnTo);
    await context.push(settingsInnerPath('feedback'));
    return;
  }

  final BuildContext? shell = kasyShellNavigatorKey.currentContext;
  if (shell != null && shell.mounted) {
    final String? returnPath = _shellReturnPathForReview(location);
    pushSettingsInnerRoute(
      shell,
      'feedback',
      returnPath: returnPath,
    );
    return;
  }

  setSettingsInnerReturnPath('/');
  await context.push('/feedback');
}

/// Where back should land after Feedback when the review funnel opened from
/// inside the main shell. Null = default (Settings tab).
String? _shellReturnPathForReview(String location) {
  if (location == '/' || location == '/home') {
    return '/';
  }
  if (location == '/notifications' || location.startsWith('/notifications')) {
    return '/notifications';
  }
  if (location == '/support' || location.startsWith('/support')) {
    return '/support';
  }
  // Already under Settings (or its inner routes): back stays on Settings.
  return null;
}

/// Step 1: the sentiment gate. Returns true (enjoying), false (could be better)
/// or null (dismissed without choosing).
Future<bool?> _askEnjoying(BuildContext context, AnalyticsApi analytics) {
  return showKasyDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final t = Translations.of(dialogContext).review_popup;
      return KasyDialog(
        leadingIcon: KasyIcons.favorite,
        iconTone: KasyDialogIconTone.info,
        title: t.question_title,
        // Default left align (same as Dialog "Basic" preview with leading
        // icon). Do not set titleCentered: the icon row is left/right chrome;
        // centering only the message left title and body fighting each other.
        message: t.question_description,
        onClose: () {
          analytics.logEvent('rating_funnel_dismiss', {});
          Navigator.of(dialogContext).pop();
        },
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KasyButton(
              label: t.question_positive,
              expand: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
            const SizedBox(height: KasySpacing.sm),
            // Secondary choice: ghost (no fill), same family as sheet "Later"
            // / rate_popup cancel. Soft fill is for soft-primary accents.
            KasyButton(
              label: t.question_negative,
              variant: KasyButtonVariant.ghost,
              expand: true,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
          ],
        ),
      );
    },
  );
}

/// Step 2a (positive branch): the celebratory store-review dialog.
Future<void> _askStoreReview(
  BuildContext context,
  RatingRepository ratingRepository,
  Review rating,
  AnalyticsApi analytics,
) {
  return showKasyDialog<void>(
    context: context,
    builder: (dialogContext) {
      final t = Translations.of(dialogContext).review_popup;
      return KasyDialog(
        leadingIcon: KasyIcons.star,
        // Gold/amber star via KasyDialog's default `warning` tone — the design
        // system's amber (#F5A524 light / #F7B750 dark), the natural colour for
        // a rating star.
        title: t.title,
        message: t.description,
        onClose: () {
          analytics.logEvent('rating_popup_close', {});
          Navigator.of(dialogContext).pop();
        },
        footer: KasyButton(
          label: t.rate_button,
          expand: true,
          onPressed: () {
            analytics.logEvent('rating_popup_show', {});
            ratingRepository.rate().then((_) => rating.review()).then((_) {
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
            });
          },
        ),
      );
    },
  );
}
