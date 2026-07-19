import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/icons/kasy_icons.dart';
import 'package:cowboydodartinc/core/theme/colors.dart';
import 'package:cowboydodartinc/core/theme/texts.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The keyboard focus ring must hug the round orb (a square box), not the
  // taller tap target the pressable stretches to — otherwise it draws an oval
  // around the circular send button. Regression guard for that.
  testWidgets('icon-only button focus ring stays square', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            KasyColors.light(),
            KasyTextTheme.build(),
          ],
        ),
        home: Scaffold(
          body: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // A taller neighbour forces the row taller than the orb, which
                // is exactly what made the ring stretch into an oval.
                const Expanded(child: SizedBox(height: 80)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: KasyButton.iconOnly(
                    icon: KasyIcons.arrowUp,
                    onPressed: () {},
                    size: KasyButtonSize.small,
                    iconOnlyLayoutExtent: 36,
                    iconGlyphSize: 18,
                    semanticLabel: 'send',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Size ringSize = tester.getSize(find.byType(KasyFocusRing));
    expect(ringSize.width, ringSize.height,
        reason: 'focus ring around a round orb must be square, got $ringSize');
    expect(ringSize.width, 36);
  });
}
