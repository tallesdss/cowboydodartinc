import 'package:cowboydodartinc/components/kasy_progress_bar.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/onboarding/providers/onboarding_provider.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_background.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_loader_orchestrator.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_loader_showcase.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_sticky_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingLoader extends ConsumerStatefulWidget {
  final bool preview;
  final VoidCallback onCompleted;

  const OnboardingLoader({
    super.key,
    this.preview = false,
    required this.onCompleted,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardingLoaderState();
}

class _OnboardingLoaderState extends ConsumerState<OnboardingLoader> {
  final OnboardingLoaderOrchestrator _orchestrator =
      OnboardingLoaderOrchestrator();
  late final OnboardingLoaderShowcase _smallShowcase;
  late final OnboardingLoaderShowcase _mediumShowcase;

  @override
  void initState() {
    super.initState();
    _orchestrator.isPreview = widget.preview;
    _smallShowcase = OnboardingLoaderShowcase(
      key: const ValueKey('onboarding_loader_showcase_small'),
      orchestrator: _orchestrator,
      preview: widget.preview,
    );
    _mediumShowcase = OnboardingLoaderShowcase(
      key: const ValueKey('onboarding_loader_showcase_medium'),
      orchestrator: _orchestrator,
      preview: widget.preview,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  Future<void> _prepare() async {
    final notifier = ref.onboardingNotifier;

    try {
      await _orchestrator.runStep(0, notifier.createGuestAccount);
      await _orchestrator.runStep(1, notifier.flushPendingUserInfo);
      await _orchestrator.runStep(2, notifier.refreshOnboardingUser);
      await _orchestrator.showWelcomeAndExit();
    } catch (e) {
      debugPrint('OnboardingLoader: completion error (continuing anyway): $e');
    }

    if (!mounted) return;
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Pin provider while the loader runs (autoDispose + read-only showcase).
    ref.watch(onboardingProvider);

    return OnboardingBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: ResponsiveBuilder(
                small: _smallShowcase,
                medium: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: _mediumShowcase,
                  ),
                ),
              ),
            ),
          ),
          OnboardingStickyFooter(
            animate: false,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: KasyProgressBar(
                    size: KasyProgressBarSize.sm,
                    trackColor: colors.primary.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
