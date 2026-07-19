/// Implemented by [OnboardingLoaderShowcase] state.
abstract class OnboardingLoaderShowcaseBinding {
  Future<void> runStep(
    int index,
    Future<void> Function() work, {
    Duration minActive,
  });

  Future<void> showWelcomeAndExit();
}

/// Bridges [OnboardingLoader] work phases to [OnboardingLoaderShowcase] UI.
class OnboardingLoaderOrchestrator {
  OnboardingLoaderShowcaseBinding? binding;

  /// Admin preview walkthrough — must match [OnboardingLoaderShowcase] pacing.
  bool isPreview = false;

  static const Duration _bindingWait = Duration(milliseconds: 50);
  static const int _bindingAttempts = 40;
  static const Duration _previewMinActive = Duration(milliseconds: 4200);
  static const Duration _previewWelcomeHold = Duration(milliseconds: 3800);

  /// Waits for the showcase to mount before skipping UI (race on first frame
  /// when prepare runs from a post-frame callback). Up to ~2s so preview never
  /// burns through steps without the checklist binding.
  Future<OnboardingLoaderShowcaseBinding?> _awaitBinding() async {
    OnboardingLoaderShowcaseBinding? showcaseBinding = binding;
    for (int i = 0; showcaseBinding == null && i < _bindingAttempts; i++) {
      await Future<void>.delayed(_bindingWait);
      showcaseBinding = binding;
    }
    return showcaseBinding;
  }

  Duration _resolvedMinActive(Duration requested) {
    if (!isPreview) return requested;
    if (requested < _previewMinActive) {
      return _previewMinActive;
    }
    return requested;
  }

  Future<void> _holdRemaining(Duration minActive, Stopwatch elapsed) async {
    final Duration remaining = minActive - elapsed.elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
  }

  Future<void> runStep(
    int index,
    Future<void> Function() work, {
    Duration minActive = const Duration(milliseconds: 750),
  }) async {
    final OnboardingLoaderShowcaseBinding? showcaseBinding =
        await _awaitBinding();
    if (showcaseBinding != null) {
      await showcaseBinding.runStep(index, work, minActive: minActive);
      return;
    }
    // No checklist mounted — still pace admin preview so stages are reviewable.
    final Duration effectiveMin = _resolvedMinActive(minActive);
    final Stopwatch elapsed = Stopwatch()..start();
    await work();
    if (isPreview) {
      await _holdRemaining(effectiveMin, elapsed);
    }
  }

  Future<void> showWelcomeAndExit() async {
    final OnboardingLoaderShowcaseBinding? showcaseBinding =
        await _awaitBinding();
    if (showcaseBinding != null) {
      await showcaseBinding.showWelcomeAndExit();
      return;
    }
    if (isPreview) {
      await Future<void>.delayed(_previewWelcomeHold);
    }
  }
}
