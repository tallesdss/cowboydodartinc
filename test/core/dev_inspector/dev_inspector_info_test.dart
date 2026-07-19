import 'package:cowboydodartinc/core/dev_inspector/dev_inspector_info.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DevInspectorInfo.toAIClipboard', () {
    test('camera icon on settings avatar — compact English pointer', () {
      const DevInspectorInfo info = DevInspectorInfo(
        widgetType: 'Icon',
        boundingBox: Rect.fromLTWH(248, 238, 12, 12),
        properties: <String>[],
        ancestors: <String>[],
        widgetPath: <String>[
          'SettingsPage',
          'KasyOverlayScaffold',
          'Scaffold',
          '_AccountAvatarHeader',
          'Icon',
        ],
        screenHint: 'SettingsPage',
        iconHint: 'U+E064',
      );

      final String clip = info.toAIClipboard(screenSize: const Size(390, 844));

      expect(
        clip,
        '''
Inspect: Icon · icon U+E064 on SettingsPage in _AccountAvatarHeader
Locate: SettingsPage → `lib/features/settings/settings_page.dart` · grep `class _AccountAvatarHeader`
Edit only this widget.
''',
      );
      expect(clip.contains('Route:'), isFalse);
      expect(clip.contains('KasyOverlayScaffold'), isFalse);
      expect(clip.contains('context.t'), isFalse);
    });

    test('position only when no label, icon or deep path', () {
      const DevInspectorInfo info = DevInspectorInfo(
        widgetType: 'Icon',
        boundingBox: Rect.fromLTWH(248, 238, 12, 12),
        properties: <String>[],
        ancestors: <String>[],
        widgetPath: <String>['SettingsPage', '_AvatarRing', 'Icon'],
        screenHint: 'SettingsPage',
      );

      final String clip = info.toAIClipboard(screenSize: const Size(390, 844));

      expect(clip, contains('At: x65% y29%'));
    });

    test('Near line drops icon-font glyphs from section context', () {
      const DevInspectorInfo info = DevInspectorInfo(
        widgetType: 'Icon',
        boundingBox: Rect.fromLTWH(248, 238, 12, 12),
        properties: <String>[],
        ancestors: <String>[],
        widgetPath: <String>[
          'SettingsPage',
          '_AccountAvatarHeader',
          'Icon',
        ],
        screenHint: 'SettingsPage',
        iconHint: 'U+E064',
        contextLabels: <String>['\uE064'],
      );

      final String clip = info.toAIClipboard();

      expect(clip.contains('Near:'), isFalse);
    });

    test('icon font glyph in visibleLabel falls back to icon codepoint', () {
      const DevInspectorInfo info = DevInspectorInfo(
        widgetType: 'Icon',
        boundingBox: Rect.fromLTWH(248, 238, 12, 12),
        properties: <String>[],
        ancestors: <String>[],
        widgetPath: <String>[
          'SettingsPage',
          'KasyOverlayScaffold',
          'Scaffold',
          '_AccountAvatarHeader',
          'Icon',
        ],
        screenHint: 'SettingsPage',
        visibleLabel: '\uE064',
        iconHint: 'U+E064',
      );

      final String clip = info.toAIClipboard(screenSize: const Size(390, 844));

      expect(clip, contains('Inspect: Icon · icon U+E064 on SettingsPage'));
      expect(clip.contains('Near:'), isFalse);
    });

    test('labeled button — no position line needed', () {
      const DevInspectorInfo info = DevInspectorInfo(
        widgetType: 'KasyButton',
        boundingBox: Rect.fromLTWH(24, 400, 120, 44),
        properties: <String>[],
        ancestors: <String>[],
        widgetPath: <String>[
          'SettingsPage',
          'KasyOverlayScaffold',
          'Scaffold',
          '_LogoutRow',
          'KasyButton',
        ],
        screenHint: 'SettingsPage',
        visibleLabel: 'Sign out',
      );

      final String clip = info.toAIClipboard(screenSize: const Size(390, 844));

      expect(clip, contains('Inspect: KasyButton · "Sign out" on SettingsPage'));
      expect(clip, contains('Locate: SettingsPage →'));
      expect(clip, contains('grep `class _LogoutRow`'));
      expect(clip.contains('At:'), isFalse);
    });

    test('look-alike widgets — Near line, no position', () {
      const DevInspectorInfo info = DevInspectorInfo(
        widgetType: 'KasyButton',
        boundingBox: Rect.fromLTWH(40, 300, 100, 44),
        properties: <String>[],
        ancestors: <String>[],
        widgetPath: <String>[
          'PremiumPage',
          'KasyOverlayScaffold',
          'Scaffold',
          '_AnnualPlanCard',
          '_PlanCta',
          'KasyButton',
        ],
        screenHint: 'PremiumPage',
        visibleLabel: 'Unlock',
        contextLabels: <String>['Annual', r'$ 199.00'],
      );

      final String clip = info.toAIClipboard(screenSize: const Size(390, 844));

      expect(clip, contains('Inspect: KasyButton · "Unlock" on PremiumPage'));
      expect(clip, contains('Locate: PremiumPage →'));
      expect(
        clip,
        contains('Path: _AnnualPlanCard › _PlanCta › KasyButton'),
      );
      expect(clip, contains('Near: "Annual" · "\$ 199.00"'));
      expect(clip.contains('At:'), isFalse);
    });

    test('admin shell hint resolves to nested page file', () {
      const DevInspectorInfo info = DevInspectorInfo(
        widgetType: 'Text',
        boundingBox: Rect.fromLTWH(100, 120, 120, 18),
        properties: <String>[],
        ancestors: <String>[],
        widgetPath: <String>[
          'AdminShell',
          'SendPushNotificationPage',
          '_NotificationPreview',
          'Text',
        ],
        screenHint: 'AdminShell',
        visibleLabel: 'Notification title',
      );

      expect(info.resolvedScreen, 'SendPushNotificationPage');
      expect(
        info.knownSourceFile,
        'lib/features/settings/ui/components/admin/send_push_notification_page.dart',
      );

      final String clip = info.toAIClipboard();
      expect(clip, contains('on SendPushNotificationPage'));
      expect(clip, contains('grep `class _NotificationPreview`'));
    });

    test('deep path — Path line when more than two hops below screen', () {
      const DevInspectorInfo info = DevInspectorInfo(
        widgetType: 'Text',
        boundingBox: Rect.fromLTWH(40, 200, 80, 20),
        properties: <String>[],
        ancestors: <String>[],
        widgetPath: <String>[
          'AdminShell',
          'KasyOverlayScaffold',
          '_OverviewMetricsPanel',
          '_StatCard',
          'Text',
        ],
        screenHint: 'AdminShell',
        visibleLabel: '1,234',
      );

      final String clip = info.toAIClipboard();

      expect(
        clip,
        contains('Path: _OverviewMetricsPanel › _StatCard › Text'),
      );
      expect(clip, contains('on AdminShell'));
    });

    test('send push title counter — page always named', () {
      const DevInspectorInfo info = DevInspectorInfo(
        widgetType: 'Text',
        boundingBox: Rect.fromLTWH(300, 200, 40, 16),
        properties: <String>[],
        ancestors: <String>[],
        widgetPath: <String>[
          'SendPushNotificationPage',
          'KasyOverlayScaffold',
          '_FormSection',
          'KasyTextField',
          'Text',
        ],
        screenHint: 'SendPushNotificationPage',
        visibleLabel: '0/64',
        contextLabels: <String>['Title *', 'e.g. New update available'],
      );

      final String clip = info.toAIClipboard();

      expect(
        clip,
        contains(
          'Inspect: Text · "0/64" on SendPushNotificationPage in _FormSection',
        ),
      );
      expect(
        clip,
        contains(
          'Locate: SendPushNotificationPage → '
          '`lib/features/settings/ui/components/admin/send_push_notification_page.dart`',
        ),
      );
      expect(clip, contains('grep `class _FormSection`'));
      expect(clip, contains('Path: _FormSection › KasyTextField › Text'));
      expect(clip, contains('Near: "Title *"'));
    });
  });

  group('DevInspectorInfo.clipboardWidgetPath', () {
    test('strips scaffolding and screen prefix', () {
      const DevInspectorInfo info = DevInspectorInfo(
        widgetType: 'Icon',
        boundingBox: Rect.zero,
        properties: <String>[],
        ancestors: <String>[],
        widgetPath: <String>[
          'SettingsPage',
          'KasyOverlayScaffold',
          'Scaffold',
          '_AccountAvatarHeader',
          'Icon',
        ],
        screenHint: 'SettingsPage',
      );

      expect(
        info.clipboardWidgetPath(),
        <String>['_AccountAvatarHeader', 'Icon'],
      );
    });

    test('keeps intermediate sections below the screen', () {
      const DevInspectorInfo info = DevInspectorInfo(
        widgetType: 'KasyButton',
        boundingBox: Rect.zero,
        properties: <String>[],
        ancestors: <String>[],
        widgetPath: <String>[
          'PremiumPage',
          'KasyOverlayScaffold',
          '_AnnualPlanCard',
          '_PlanCta',
          'KasyButton',
        ],
        screenHint: 'PremiumPage',
      );

      expect(
        info.clipboardWidgetPath(),
        <String>['_AnnualPlanCard', '_PlanCta', 'KasyButton'],
      );
    });
  });
}
