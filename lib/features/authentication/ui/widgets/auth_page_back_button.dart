import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Back control for login/signup when opened from in-app navigation (e.g. settings).
///
/// Hidden on web: entry is usually `/signin` or `/signup` with nothing to pop to.
bool shouldShowAuthBackButton(BuildContext context) {
  return !kIsWeb && context.canPop();
}

void onAuthBackPressed(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  }
}

/// Sends authenticated users away from login/signup routes.
void redirectIfAuthenticated(BuildContext context, User user) {
  if (user is! AuthenticatedUserData) {
    return;
  }
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      context.go('/');
    }
  });
}

EdgeInsets authFormListPadding(BuildContext context) {
  const double horizontal = KasySpacing.pageHorizontalGutter;
  // Figma `spacing/auth-top`: content starts at y=75 from the frame top
  // (status-bar band included). Keep at least that inset; when the OS already
  // reports a safe top, pad with [KasySpacing.md] under it and never go below
  // [KasySpacing.authContentTop].
  const double authContentTop = KasySpacing.authContentTop;
  if (shouldShowAuthBackButton(context)) {
    return EdgeInsets.fromLTRB(
      horizontal,
      kasyAppBarBodyTopOverlap(context),
      horizontal,
      0,
    );
  }
  final EdgeInsets safePadding = MediaQuery.paddingOf(context);
  final double top = (safePadding.top + KasySpacing.md) > authContentTop
      ? safePadding.top + KasySpacing.md
      : authContentTop;
  if (kIsWeb) {
    return EdgeInsets.fromLTRB(
      horizontal,
      top,
      horizontal,
      safePadding.bottom + KasySpacing.md,
    );
  }
  return EdgeInsets.fromLTRB(
    horizontal,
    top,
    horizontal,
    0,
  );
}

/// Scrolls login/signup forms only when content does not fit vertically.
class AuthFormScrollView extends StatelessWidget {
  const AuthFormScrollView({
    super.key,
    required this.children,
    this.maxContentWidth = 460,
  });

  final List<Widget> children;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final EdgeInsets padding = authFormListPadding(context);
        final double minContentHeight =
            (constraints.maxHeight - padding.vertical).clamp(
              0.0,
              double.infinity,
            );
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minContentHeight),
            child: Align(
              alignment: kIsWeb ? Alignment.center : Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Transparent chrome: only the orb back button (no frost, no title).
class AuthPageBackButton extends StatelessWidget {
  const AuthPageBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!shouldShowAuthBackButton(context)) {
      return const SizedBox.shrink();
    }
    final Color orbFg = context.colors.onSurface;
    final Color orbFill = kasyChromeOrbFillColor(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            KasySpacing.pageHorizontalGutter,
            kasyAppBarChromePaddingTop,
            KasySpacing.pageHorizontalGutter,
            kasyAppBarChromePaddingBottom,
          ),
          child: SizedBox(
            height: kasyAppBarToolbarRowHeight,
            child: Row(
              children: [
                KasyChromeOrbIconButton(
                  icon: KasyIcons.arrowBackIos,
                  iconSize: 18,
                  foregroundColor: orbFg,
                  fillColor: orbFill,
                  onPressed: () => onAuthBackPressed(context),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                ),
                const Spacer(),
                const SizedBox(width: 44),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
