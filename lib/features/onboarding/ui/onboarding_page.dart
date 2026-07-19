import 'package:cowboydodartinc/core/data/api/analytics_api.dart';
import 'package:cowboydodartinc/features/onboarding/providers/onboarding_provider.dart';
import 'package:cowboydodartinc/features/onboarding/ui/animations/page_transitions.dart';
import 'package:cowboydodartinc/features/onboarding/ui/components/onboarding_att_setup.dart';
import 'package:cowboydodartinc/features/onboarding/ui/components/onboarding_features.dart';
import 'package:cowboydodartinc/features/onboarding/ui/components/onboarding_loader.dart';
import 'package:cowboydodartinc/features/onboarding/ui/components/onboarding_notifications_setup.dart';
import 'package:cowboydodartinc/features/onboarding/ui/components/onboarding_questions.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_routes.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/premium_page.dart';
import 'package:cowboydodartinc/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  /// Preview mode: the flow is opened from the admin Debug screen just to walk
  /// the screens. Real side effects are suppressed (see [OnboardingNotifier])
  /// and the flow returns to Debug instead of Home/paywall.
  final bool preview;

  const OnboardingPage({super.key, this.preview = false});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Riverpod forbids notifier writes during initState/build. One frame later
      // is still early enough; loader timings use widget.preview directly.
      ref.read(onboardingProvider.notifier).setPreview(widget.preview);
      // Warm the questions' hero into the image cache while the user is still on
      // the first screens, so it's already decoded when they reach the gender /
      // age steps.
      precacheImage(const AssetImage(kQuestionsHeroImage), context);
    });
  }

  /// Where the flow lands when finished: back to the admin Debug screen in
  /// preview, Home otherwise.
  void _exit() => ref
      .read(goRouterProvider)
      .go(widget.preview ? adminRouteDebug : '/');

  @override
  Widget build(BuildContext context) {
    final bool preview = widget.preview;
    // [onboardingProvider] is autoDispose and nothing else watches it during the
    // walkthrough. Without pinning it here, preview + buffered answers reset
    // before the loader and admin preview burns through the checklist.
    ref.watch(onboardingProvider);
    return Navigator(
      initialRoute: 'feature_1',
      // No analytics in preview — walking the flow from Debug must not pollute
      // real onboarding funnels.
      observers: [
        if (!preview)
          AnalyticsObserver(
            prefix: 'userOnboarding/',
            analyticsApi: MixpanelAnalyticsApi.instance(),
          ),
      ],
      onGenerateRoute: (settings) => switch (settings.name) {
        'feature_1' => OnboardingRouteTransition(
            builder: (context) => OnboardingFeatureOne(
              nextRoute: 'feature_2',
              onSkip: () => Navigator.of(context).pushReplacementNamed(
                'skip_loader',
              ),
              // In preview, leaving to the real sign-in screen would break the
              // "everything just returns to Debug" contract, so go back instead.
              onLogin: () => preview
                  ? _exit()
                  : ref.read(goRouterProvider).go('/signin'),
            ),
            settings: settings,
          ),
        'feature_2' => OnboardingRouteTransition(
            builder: (context) => OnboardingFeatureTwo(
              nextRoute: 'feature_3',
              // Only the second screen offers a way back (to the welcome step).
              onBack: () =>
                  Navigator.of(context).pushReplacementNamed('feature_1'),
            ),
            settings: settings,
          ),
        'feature_3' => OnboardingRouteTransition(
            builder: (context) => const OnboardingFeatureThree(
              nextRoute: 'gender_question',
            ),
            settings: settings,
          ),
        'gender_question' => OnboardingRouteTransition(
            builder: (context) => const UserGenderOnboardingQuestion(
              nextRoute: 'age_question',
            ),
            settings: settings,
          ),
        'age_question' => OnboardingRouteTransition(
            builder: (context) => const UserAgeOnboardingQuestion(
              nextRoute: 'notifications',
            ),
            settings: settings,
          ),
        
        'notifications' => OnboardingRouteTransition(
            builder: (context) => NotificationsPermissionStep(
              // ATT is an iOS-only screen in production, but in preview we always
              // route through it so the developer can see/design every onboarding
              // screen (the request itself is a no-op in preview).
              nextRoute:
                  preview || defaultTargetPlatform == TargetPlatform.iOS
                      ? 'att_consent'
                      : 'loader',
            ),
            settings: settings,
          ),
          'att_consent' => OnboardingRouteTransition(
            builder: (context) => const AttPermissionStep(
              nextRoute: 'loader',
            ),
            settings: settings,
          ),
        'loader' => OnboardingRouteTransition(
            builder: (context) => OnboardingLoader(
              preview: preview,
              // Preview stops here (the paywall has its own admin preview) and
              // returns to Debug; the real flow continues to the paywall.
              onCompleted: () => preview
                  ? _exit()
                  : Navigator.of(context).pushReplacementNamed('paywall'),
            ),
            settings: settings,
          ),
        'skip_loader' => OnboardingRouteTransition(
            builder: (context) => OnboardingLoader(
              preview: preview,
              onCompleted: () {
                ref.onboardingNotifier.skipOnboarding();
                _exit();
              },
            ),
            settings: settings,
          ),
        'paywall' => OnboardingRouteTransition(
            builder: (context) => const PremiumPage(
              paywall: PaywallFactory.unlock,
              args: PremiumPageArgs(
                redirect: '/',
              ),
            ),
            settings: settings,
          ),
        String() || null => throw 'Unimplemented route: $settings.name',
      },
    );
  }
}
