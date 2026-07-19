import 'package:cowboydodartinc/core/navigation/kasy_navigation_config.dart';
import 'package:cowboydodartinc/core/navigation/kasy_page_transition.dart';
import 'package:cowboydodartinc/core/navigation/kasy_transition_kind.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kasyTransitionPage uses zero duration for none', () {
    final page = kasyTransitionPage<void>(
      key: const ValueKey('test'),
      child: const SizedBox(),
      transition: KasyTransitionKind.none,
    );
    expect(page.transitionDuration, Duration.zero);
    expect(page.reverseTransitionDuration, Duration.zero);
  });

  test('kasyTransitionPage uses config duration for fade', () {
    final page = kasyTransitionPage<void>(
      key: const ValueKey('test'),
      child: const SizedBox(),
      transition: KasyTransitionKind.fade,
    );
    expect(page.transitionDuration, KasyNavigationConfig.duration);
    expect(
      page.reverseTransitionDuration,
      KasyNavigationConfig.reverseDuration,
    );
  });
}
