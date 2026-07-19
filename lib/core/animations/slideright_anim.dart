
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SlideFromRightAnim extends StatelessWidget {
  final int? delayInMs;
  final Widget child;
  final AnimationController? controller;

  const SlideFromRightAnim({
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
          duration: const Duration(milliseconds: 500),
          curve: Curves.decelerate,
          begin: const Offset(200, 0),
          end: Offset.zero,
        ),
      ],
      child: child,
    );
  }
}