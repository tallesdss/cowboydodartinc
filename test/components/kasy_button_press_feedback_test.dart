import 'package:cowboydodartinc/components/kasy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('custom border wins over dark label for press tint', () {
    expect(
      resolveKasyButtonPressFeedbackTint(
        paletteBackground: const Color(0xFFFFF8E6),
        paletteForeground: const Color(0xFF0D0D12),
        paletteBorder: const Color(0xFFFFB900),
        customBackground: const Color(0xFFFFF8E6),
        customBorder: const Color(0xFFFFB900),
      ),
      const Color(0xFFFFB900),
    );
  });

  test('light custom fill tints toward darker same family without border', () {
    final Color tint = resolveKasyButtonPressFeedbackTint(
      paletteBackground: Colors.transparent,
      paletteForeground: const Color(0xFF0D0D12),
      paletteBorder: Colors.transparent,
      customBackground: const Color(0xFFFFF8E6),
    );
    expect(tint, isNot(const Color(0xFF0D0D12)));
    expect(tint.computeLuminance(), lessThan(const Color(0xFFFFF8E6).computeLuminance()));
  });

  test('on-brand primary still uses label colour', () {
    expect(
      resolveKasyButtonPressFeedbackTint(
        paletteBackground: const Color(0xFF0485F7),
        paletteForeground: Colors.white,
        paletteBorder: Colors.transparent,
      ),
      Colors.white,
    );
  });

  testWidgets('press overlay override is respected', (tester) async {
    const Color override = Color(0x1AFFB900);
    late Color resolved;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            resolved = resolveKasyButtonPressOverlayColor(
              context: context,
              paletteBackground: const Color(0xFFFFF8E6),
              paletteForeground: const Color(0xFF0D0D12),
              paletteBorder: const Color(0xFFFFB900),
              customBackground: const Color(0xFFFFF8E6),
              customBorder: const Color(0xFFFFB900),
              override: override,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(resolved, override);
  });
}
