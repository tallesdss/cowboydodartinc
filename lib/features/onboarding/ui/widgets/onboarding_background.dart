import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

class OnboardingBackground extends StatelessWidget {
  final Widget child;
  final String? bgImagePath;
  final double bgImageOpacity;
  final Color? bgColor;

  const OnboardingBackground({
    super.key,
    required this.child,
    this.bgImagePath,
    this.bgColor,
    this.bgImageOpacity = .15,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (bgImagePath != null)
          Positioned.fill(
            child: Opacity(
              opacity: bgImageOpacity,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(bgImagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        // Flat background: no top gradient. 100% solid (white in light mode),
        // or [bgColor] once a custom canvas color is provided.
        Positioned.fill(
          child: ColoredBox(
            color: bgColor ?? context.colors.background,
          ),
        ),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Material supplies DefaultTextStyle. Without it, WidgetsApp's
              // fallback error style paints yellow double-underlines on Text
              // (visible on the push-banner mock and any other bare Text).
              return Material(
                type: MaterialType.transparency,
                child: SizedBox(
                  key: const ValueKey("background"),
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: child,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
