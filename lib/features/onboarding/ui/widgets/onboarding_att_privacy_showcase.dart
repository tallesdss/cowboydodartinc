import 'dart:async';

import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_phone_frame.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Privacy card rising from the bottom gradient on the ATT step.
class OnboardingAttPrivacyShowcase extends StatefulWidget {
  const OnboardingAttPrivacyShowcase({super.key});

  @override
  State<OnboardingAttPrivacyShowcase> createState() =>
      _OnboardingAttPrivacyShowcaseState();
}

class _OnboardingAttPrivacyShowcaseState extends State<OnboardingAttPrivacyShowcase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 640),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    Future<void>.delayed(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      unawaited(KasyHaptics.medium(context));
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = Translations.of(context).onboarding.att.card;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double heroHeight = constraints.maxHeight;
          final double gradientHeight = heroHeight * 0.58;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: gradientHeight,
                child: const OnboardingPhoneBottomBleed(),
              ),
              Positioned(
                left: KasySpacing.lg,
                right: KasySpacing.lg,
                bottom: heroHeight * 0.15,
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Center(
                      child: KasySpotlightCard.icon(
                        maxWidth: 266,
                        tag: card.tag,
                        icon: Icons.shield_outlined,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
