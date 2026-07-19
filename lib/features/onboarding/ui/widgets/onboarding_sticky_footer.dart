import 'package:cowboydodartinc/core/animations/movefade_anim.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Sticky onboarding footer: background down to the bottom edge + entrance animation.
class OnboardingStickyFooter extends StatelessWidget {
  const OnboardingStickyFooter({
    super.key,
    required this.children,
    this.animate = true,
    this.animationDelayMs = 400,
    this.horizontalPadding = KasySpacing.lg,
    this.maxContentWidth,
  });

  final List<Widget> children;
  final bool animate;
  final int animationDelayMs;
  final double horizontalPadding;

  /// Maximum content width (e.g. 600 on medium screens).
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );

    if (maxContentWidth != null) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth!),
          child: content,
        ),
      );
    }

    // No dividing container: the actions sit directly on the page background,
    // with no hairline border or drop shadow above them.
    Widget footer = Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        KasySpacing.md,
        horizontalPadding,
        KasySpacing.md +
            bottomInset +
            (defaultTargetPlatform == TargetPlatform.android
                ? KasySpacing.sm
                : 0),
      ),
      child: content,
    );

    if (animate) {
      footer = MoveFadeAnim(
        delayInMs: animationDelayMs,
        child: footer,
      );
    }

    return footer;
  }
}
