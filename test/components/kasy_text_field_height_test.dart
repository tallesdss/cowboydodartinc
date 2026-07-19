import 'package:cowboydodartinc/components/kasy_text_field.dart';
import 'package:cowboydodartinc/core/theme/colors.dart';
import 'package:cowboydodartinc/core/theme/providers/theme_provider.dart';
import 'package:cowboydodartinc/core/theme/responsive_text_theme.dart';
import 'package:cowboydodartinc/core/theme/texts.dart';
import 'package:cowboydodartinc/core/theme/universal_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../device_test_utils.dart';

/// A single-line [KasyTextField] must render at exactly
/// [KasyTextField.singleLineHeight] on EVERY breakpoint. The height is locked
/// with a forced strut (see kasy_text_field.dart) precisely so it cannot drift
/// between renderers (web CanvasKit vs native) or viewport widths. Run this on
/// the VM and with `--platform chrome` to cover both renderers.
void main() {
  Widget appWithField() {
    return Builder(builder: (context) {
      return MaterialApp(
        theme: ThemeProvider.of(context).light,
        home: const ResponsiveTextTheme(
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: KasyTextField(
                  hint: 'Email',
                  variant: KasyTextFieldVariant.flat,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  testWidgets('single-line field height stays locked across breakpoints',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    final widget = ThemeProvider(
      notifier: AppTheme.uniform(
        sharedPreferences: sharedPrefs,
        themeFactory: const UniversalThemeFactory(),
        lightColors: KasyColors.light(),
        darkColors: KasyColors.dark(),
        textTheme: KasyTextTheme.build(),
        defaultMode: ThemeMode.light,
      ),
      child: appWithField(),
    );

    const breakpoints = <Device>[
      Device(name: 'mobile', width: 375, height: 812, pixelDensity: 3),
      Device(name: 'tablet', width: 800, height: 1024, pixelDensity: 2),
      Device(name: 'desktop', width: 1400, height: 900, pixelDensity: 1),
    ];

    for (final device in breakpoints) {
      await tester.setScreenSize(device);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      final double boxHeight =
          tester.getSize(find.byType(TextField).first).height;
      expect(
        boxHeight,
        KasyTextField.singleLineHeight,
        reason: 'field box should be ${KasyTextField.singleLineHeight}px on '
            '${device.name} (${device.width}px wide), got $boxHeight',
      );
    }
  });
}
