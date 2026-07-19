import 'package:cowboydodartinc/components/kasy_spinner.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum RouterType {
  goRouter,
  normal,
}

class Guard extends StatelessWidget {
  final Future<bool> canActivate;
  final Widget child;
  final Widget? loading;
  final String fallbackRoute;
  final RouterType routerType;
  final VoidCallback? onRedirect;

  const Guard({
    super.key,
    required this.canActivate,
    required this.child,
    required this.fallbackRoute,
    this.loading,
    this.routerType = RouterType.goRouter,
    this.onRedirect,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: canActivate,
      builder: (_, result) {
        if (!result.hasData || result.hasError) {
          return _loadingScreen(context);
        }
        final bool canActivate = result.data!;
        if (canActivate) {
          return child;
        }
        redirect(context);
        return loading ?? _loadingScreen(context);
      },
    );
  }

  /// Themed placeholder shown while the guard resolves or redirects. Never a
  /// bare [Container] (which paints nothing and shows the black window behind).
  Widget _loadingScreen(BuildContext context) {
    return Material(
      color: context.colors.background,
      child: const Center(child: KasySpinner()),
    );
  }

  void redirect(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!context.mounted) return;
      switch (routerType) {
        case RouterType.goRouter:
          final currentRoute = GoRouter.of(context)
              .routerDelegate //
              .currentConfiguration
              .fullPath;
          debugPrint(
            "...current page is $currentRoute ==> redirecting to $fallbackRoute",
          );
          if (currentRoute == fallbackRoute) {
            debugPrint("Already on the fallback route, skipping redirect");
            return;
          }
          onRedirect?.call();
          context.pushReplacement(fallbackRoute);
        case RouterType.normal:
          Navigator.of(context).pushReplacementNamed(fallbackRoute);
      }
    });
    // addPostFrameCallback does not schedule a frame on its own; if the app is
    // idle the redirect would otherwise wait until the next input event (the
    // "stuck until you tap the screen" symptom). Force a frame so it runs now.
    WidgetsBinding.instance.scheduleFrame();
  }
}
