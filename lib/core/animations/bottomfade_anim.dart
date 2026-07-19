import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BottomMoveFadeAnim extends StatelessWidget {
  final int? delayInMs;
  final Widget child;
  final AnimationController? controller;

  const BottomMoveFadeAnim({
    super.key,
    required this.child,
    this.delayInMs,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      controller: controller,
      effects: [
        FadeEffect(
          delay: Duration(milliseconds: delayInMs ?? 0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        ),
        MoveEffect(
          delay: Duration(milliseconds: delayInMs ?? 0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.decelerate,
          begin: const Offset(0, 50),
          end: Offset.zero,
        ),
      ],
      child: child,
    );
  }
}