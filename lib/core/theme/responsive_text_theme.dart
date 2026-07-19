import 'package:cowboydodartinc/core/theme/texts.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';

/// Republishes the app's typography for the current breakpoint — without
/// touching a single call site.
///
/// It reads the effective viewport width, picks the [DeviceType], and rebuilds
/// the Material `textTheme` and the [KasyTextTheme] extension from the
/// per-breakpoint [KasyTypeScale] ramp. Headings step down from desktop to
/// mobile; body and labels stay constant. Colours are kept from the base theme
/// (the ramp is colourless), so every `context.textTheme.*` and
/// `context.kasyTextTheme.*` below inherits the breakpoint's sizes.
///
/// Placed as the innermost wrapper of the app (inside `WebViewportScale` and
/// `DevicePreview`), so it reads the *same* width the screens lay out against:
/// the type bucket always matches the layout bucket. Desktop is the authored
/// baseline, so it is a pass-through there.
class ResponsiveTextTheme extends StatelessWidget {
  final Widget child;

  const ResponsiveTextTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final DeviceType device =
        DeviceType.fromWidth(MediaQuery.sizeOf(context).width);

    // Desktop is the authored baseline (the base theme built in main.dart) — no
    // rebuild needed.
    if (device != DeviceType.small && device != DeviceType.medium) {
      return child;
    }

    final ThemeData theme = Theme.of(context);
    final KasyTextTheme ramp = KasyTextTheme.build(device);
    final TextTheme base = theme.textTheme;

    // Take size/weight/line-height from the ramp, keep colour from the base
    // (the ramp is colourless, so merge preserves the base slot's colour).
    final TextTheme rebuilt = TextTheme(
      displayLarge: base.displayLarge?.merge(ramp.displayLarge),
      displayMedium: base.displayMedium?.merge(ramp.displayMedium),
      displaySmall: base.displaySmall?.merge(ramp.displaySmall),
      headlineLarge: base.headlineLarge?.merge(ramp.headlineLarge),
      headlineMedium: base.headlineMedium?.merge(ramp.headlineMedium),
      headlineSmall: base.headlineSmall?.merge(ramp.headlineSmall),
      titleLarge: base.titleLarge?.merge(ramp.titleLarge),
      titleMedium: base.titleMedium?.merge(ramp.titleMedium),
      titleSmall: base.titleSmall?.merge(ramp.titleSmall),
      bodyLarge: base.bodyLarge?.merge(ramp.bodyLarge),
      bodyMedium: base.bodyMedium?.merge(ramp.bodyMedium),
      bodySmall: base.bodySmall?.merge(ramp.bodySmall),
      labelLarge: base.labelLarge?.merge(ramp.labelLarge),
      labelMedium: base.labelMedium?.merge(ramp.labelMedium),
      labelSmall: base.labelSmall?.merge(ramp.labelSmall),
    );

    // Replace only the KasyTextTheme extension; keep every other extension.
    final List<ThemeExtension<dynamic>> extensions = theme.extensions.values
        .map((e) => e is KasyTextTheme ? ramp : e)
        .toList();

    return Theme(
      data: theme.copyWith(textTheme: rebuilt, extensions: extensions),
      child: child,
    );
  }
}
