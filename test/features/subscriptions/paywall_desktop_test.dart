import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_desktop.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_solo_desktop.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_trial_desktop.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_unlock_desktop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils.dart';
import 'api/fake_revenuecat_product.dart';

void main() {
  const viewport = Size(1280, 900);

  testWidgets('PaywallCompareDesktop renders plan columns at desktop width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(viewport);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpPage(
      home: SizedBox(
        width: viewport.width,
        height: viewport.height,
        child: PaywallCompareDesktop(
          offers: [
            FakeRevenueCatProduct.month(),
            FakeRevenueCatProduct.year(),
          ],
          selectedOffer: FakeRevenueCatProduct.year(),
          onSelectItem: (_) {},
          onTap: () {},
          onTapRestore: () {},
          onSkip: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PaywallCompareDesktop), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('PaywallUnlockDesktop keeps premium subscribe button key', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(viewport);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpPage(
      home: SizedBox(
        width: viewport.width,
        height: viewport.height,
        child: PaywallUnlockDesktop(
          offers: [
            FakeRevenueCatProduct.month(),
            FakeRevenueCatProduct.year(),
          ],
          selectedOffer: FakeRevenueCatProduct.year(),
          onSelectItem: (_) {},
          onTap: () {},
          onTapRestore: () {},
          onSkip: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('premium_subscribe_button')),
      findsOneWidget,
    );
  });

  testWidgets('PaywallTrialDesktop renders split modal content', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(viewport);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpPage(
      home: SizedBox(
        width: viewport.width,
        height: viewport.height,
        child: PaywallTrialDesktop(
          offers: [FakeRevenueCatProduct.year()],
          selectedOffer: FakeRevenueCatProduct.year(),
          onSelectItem: (_) {},
          onTap: () {},
          onTapRestore: () {},
          onSkip: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(PaywallTrialDesktop), findsOneWidget);
  });

  testWidgets('PaywallSoloDesktop renders hero modal content', (tester) async {
    await tester.binding.setSurfaceSize(viewport);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpPage(
      home: SizedBox(
        width: viewport.width,
        height: viewport.height,
        child: PaywallSoloDesktop(
          offers: [FakeRevenueCatProduct.month()],
          selectedOffer: FakeRevenueCatProduct.month(),
          onSelectItem: (_) {},
          onTap: () {},
          onTapRestore: () {},
          onSkip: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(PaywallSoloDesktop), findsOneWidget);
    expect(find.text('Subscribe now'), findsOneWidget);
  });
}
