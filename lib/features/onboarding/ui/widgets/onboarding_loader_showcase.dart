import 'dart:async';

import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/onboarding/models/user_info.dart';
import 'package:cowboydodartinc/features/onboarding/providers/onboarding_provider.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_loader_orchestrator.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _SetupPhase { pending, active, done }

/// Loader hero — steps follow real account work; welcome exits to the right.
class OnboardingLoaderShowcase extends ConsumerStatefulWidget {
  const OnboardingLoaderShowcase({
    super.key,
    required this.orchestrator,
    this.preview = false,
  });

  final OnboardingLoaderOrchestrator orchestrator;
  /// Authoritative preview flag from the route — do not rely on provider alone.
  final bool preview;

  /// Production: keep the checklist snappy while real account work runs.
  static const Duration _welcomeHold = Duration(milliseconds: 900);
  /// Admin preview skips real work, so hold longer so each stage is reviewable.
  static const Duration _previewWelcomeHold = Duration(milliseconds: 3800);
  static const Duration _welcomeExit = Duration(milliseconds: 260);
  static const Duration _minActive = Duration(milliseconds: 750);
  static const Duration _previewMinActive = Duration(milliseconds: 4200);

  @override
  ConsumerState<OnboardingLoaderShowcase> createState() =>
      _OnboardingLoaderShowcaseState();
}

class _OnboardingLoaderShowcaseState extends ConsumerState<OnboardingLoaderShowcase>
    with TickerProviderStateMixin
    implements OnboardingLoaderShowcaseBinding {
  final List<_SetupPhase> _phases = [
    _SetupPhase.pending,
    _SetupPhase.pending,
    _SetupPhase.pending,
  ];

  List<String>? _labels;
  Gender? _welcomeGender;
  bool _showWelcome = false;
  bool _welcomeExiting = false;
  late final AnimationController _welcomeEnterController;
  late final AnimationController _welcomeExitController;

  @override
  void initState() {
    super.initState();
    widget.orchestrator.binding = this;
    _welcomeEnterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _welcomeExitController = AnimationController(
      vsync: this,
      duration: OnboardingLoaderShowcase._welcomeExit,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _labels ??= [
      Translations.of(context).onboarding.loading.steps.account,
      Translations.of(context).onboarding.loading.steps.preferences,
      Translations.of(context).onboarding.loading.steps.ready,
    ];
    _cacheWelcomeGender();
  }

  void _cacheWelcomeGender() {
    if (_welcomeGender != null) return;
    for (final info in ref.read(onboardingProvider).pendingUserInfo) {
      if (info is UserGenderInfo) {
        _welcomeGender = info.value;
        break;
      }
    }
  }

  bool get _isPreview =>
      widget.preview || ref.read(onboardingProvider).preview;

  Duration _resolvedMinActive(Duration requested) {
    if (!_isPreview) return requested;
    // Preview work is a no-op; ensure the step stays visible long enough to review.
    if (requested < OnboardingLoaderShowcase._previewMinActive) {
      return OnboardingLoaderShowcase._previewMinActive;
    }
    return requested;
  }

  @override
  Future<void> runStep(
    int index,
    Future<void> Function() work, {
    Duration minActive = OnboardingLoaderShowcase._minActive,
  }) async {
    if (!mounted || index < 0 || index >= _phases.length) return;

    final Duration effectiveMin = _resolvedMinActive(minActive);
    setState(() => _phases[index] = _SetupPhase.active);
    unawaited(KasyHaptics.light(context));

    final Stopwatch elapsed = Stopwatch()..start();
    await work();
    final Duration remaining = effectiveMin - elapsed.elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted) return;
    setState(() => _phases[index] = _SetupPhase.done);
    unawaited(KasyHaptics.light(context));
  }

  @override
  Future<void> showWelcomeAndExit() async {
    if (!mounted) return;
    unawaited(KasyHaptics.medium(context));
    setState(() => _showWelcome = true);
    await _welcomeEnterController.forward();
    if (!mounted) return;
    final Duration hold = _isPreview
        ? OnboardingLoaderShowcase._previewWelcomeHold
        : OnboardingLoaderShowcase._welcomeHold;
    await Future<void>.delayed(hold);
    if (!mounted) return;
    setState(() => _welcomeExiting = true);
    await _welcomeExitController.forward();
  }

  String _welcomeText() {
    final loading = Translations.of(context).onboarding.loading;

    return switch (_welcomeGender) {
      Gender.female => loading.welcome_female,
      Gender.male => loading.welcome_male,
      _ => loading.welcome,
    };
  }

  @override
  void dispose() {
    widget.orchestrator.binding = null;
    _welcomeEnterController.dispose();
    _welcomeExitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _welcomeEnterController,
      curve: Curves.easeOutCubic,
    ));
    final enterFade = CurvedAnimation(
      parent: _welcomeEnterController,
      curve: Curves.easeOut,
    );

    final exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.35, 0),
    ).animate(CurvedAnimation(
      parent: _welcomeExitController,
      curve: Curves.easeInCubic,
    ));
    final exitFade = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
      parent: _welcomeExitController,
      curve: Curves.easeIn,
    ));

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: KasySpacing.xl),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _showWelcome
              ? AnimatedBuilder(
                  key: const ValueKey('welcome'),
                  animation: _welcomeExitController,
                  builder: (context, child) {
                    final slide = _welcomeExiting ? exitSlide : enterSlide;
                    final opacity =
                        _welcomeExiting ? exitFade : enterFade;

                    return SlideTransition(
                      position: slide,
                      child: FadeTransition(
                        opacity: opacity,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _welcomeText(),
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: colors.onBackground,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                )
              : Column(
                  key: const ValueKey('steps'),
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_phases.length, (index) {
                    final phase = _phases[index];
                    if (phase == _SetupPhase.pending) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < _phases.length - 1 ? 14 : 0,
                      ),
                      child: _SetupStepRow(
                        label: _labels![index],
                        phase: phase,
                      ),
                    );
                  }),
                ),
        ),
      ),
    );
  }
}

class _SetupStepRow extends StatelessWidget {
  const _SetupStepRow({
    required this.label,
    required this.phase,
  });

  final String label;
  final _SetupPhase phase;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepCheck(phase: phase),
        const SizedBox(width: 12),
        Flexible(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            style: context.textTheme.bodyLarge!.copyWith(
              color: phase == _SetupPhase.active
                  ? colors.onBackground
                  : colors.muted,
              fontWeight:
                  phase == _SetupPhase.active ? FontWeight.w600 : FontWeight.w500,
              height: 1.3,
            ),
            child: Text(label),
          ),
        ),
      ],
    );
  }
}

class _StepCheck extends StatelessWidget {
  const _StepCheck({required this.phase});

  final _SetupPhase phase;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: phase == _SetupPhase.done ? colors.success : Colors.transparent,
        border: Border.all(
          color: switch (phase) {
            _SetupPhase.pending => colors.outline.withValues(alpha: 0.35),
            _SetupPhase.active => colors.primary,
            _SetupPhase.done => colors.success,
          },
          width: phase == _SetupPhase.active ? 2 : 1.5,
        ),
      ),
      child: switch (phase) {
        _SetupPhase.pending => null,
        _SetupPhase.active => Padding(
            padding: const EdgeInsets.all(5),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          ),
        _SetupPhase.done => Icon(
            Icons.check_rounded,
            size: 15,
            color: colors.successForeground,
          ),
      },
    );
  }
}
