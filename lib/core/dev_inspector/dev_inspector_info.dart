import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

@immutable
class DevInspectorInfo {
  const DevInspectorInfo({
    required this.widgetType,
    required this.boundingBox,
    required this.properties,
    required this.ancestors,
    required this.widgetPath,
    this.screenHint,
    this.semanticWidget,
    this.visibleLabel,
    this.iconHint,
    this.contextLabels = const <String>[],
  });

  final String widgetType;
  final Rect boundingBox;
  final List<String> properties;
  final List<String> ancestors;
  final List<String> widgetPath;
  final String? screenHint;
  final String? semanticWidget;

  /// Visible text the widget renders (button label, list title, …) or, for a
  /// Kasy component, its `semanticLabel`. Captured by walking the selected
  /// widget's own subtree, so it survives even when the glyph lives in a
  /// child. This is the strongest signal for telling look-alike widgets apart.
  final String? visibleLabel;

  /// Icon codepoint (e.g. `U+E5CD`), only set for icon-only controls that have
  /// no readable label. A weak disambiguator, but it separates two glyph
  /// buttons that would otherwise look identical to the AI.
  final String? iconHint;

  /// A few short, distinct texts from the section/card that CONTAINS the
  /// selection (e.g. `["Anual", "R$ 199,00"]` for the annual plan card). This
  /// is what tells apart two otherwise-identical widgets — the decisive signal
  /// when a screen has look-alike buttons.
  final List<String> contextLabels;

  /// Known kit screens → source file (best-effort for AI navigation). Only
  /// real, verified paths live here: a wrong path misleads the AI worse than
  /// no path, so unknown screens fall back to a `grep class <Screen>` hint
  /// instead of a fabricated file name.
  static const Map<String, String> _sourceFileByScreen = {
    'SettingsPage': 'lib/features/settings/settings_page.dart',
    'HomePage': 'lib/features/home/home_page.dart',
    'NotificationsPage':
        'lib/features/notifications/ui/notifications_page.dart',
    'FeedbackPage': 'lib/features/feedbacks/ui/feedback_page.dart',
    'ReminderPage': 'lib/features/local_reminders/ui/reminder_page.dart',
    'PremiumPage': 'lib/features/subscriptions/ui/premium_page.dart',
    'AiChatPage': 'lib/features/ai_chat/ai_chat_page.dart',
    'SigninPage': 'lib/features/authentication/ui/signin_page.dart',
    'SignupPage': 'lib/features/authentication/ui/signup_page.dart',
    'OnboardingPage': 'lib/features/onboarding/ui/onboarding_page.dart',
    'AdminShell': 'lib/features/settings/ui/components/admin/admin_page.dart',
    'SendPushNotificationPage':
        'lib/features/settings/ui/components/admin/send_push_notification_page.dart',
  };

  /// The screen's real source file, or null when we can't be sure. Never
  /// guesses a path.
  String? get knownSourceFile {
    final String? screen = resolvedScreen;
    if (screen == null) return null;
    final String key = screen.startsWith('_') ? screen.substring(1) : screen;
    return _sourceFileByScreen[key];
  }

  /// Best screen name for clipboard navigation. Prefers a concrete `*Page` in
  /// the widget path over an outer `*Shell` hint (e.g. `SendPushNotificationPage`
  /// inside `AdminShell`).
  String? get resolvedScreen {
    final String? page = _firstPageInPath();
    final String? hint = screenHint ?? _firstScreenInPath();
    if (page != null) {
      if (hint != null && hint.endsWith('Shell') && page.endsWith('Page')) {
        return page;
      }
      if (hint == null) return page;
    }
    return hint;
  }

  String? _firstPageInPath() {
    final RegExp pageRx = RegExp(r'(Page|Screen)$');
    for (final String segment in widgetPath) {
      final String base = segment.split('<').first;
      if (pageRx.hasMatch(base)) return base;
    }
    for (final String segment in ancestors.reversed) {
      final String base = segment.split('<').first;
      if (pageRx.hasMatch(base)) return base;
    }
    return null;
  }

  String? _firstScreenInPath() {
    final RegExp screenRx = RegExp(r'(Page|Screen|View|Tab|Shell)$');
    for (final String segment in widgetPath) {
      if (screenRx.hasMatch(segment)) return segment;
    }
    for (final String segment in ancestors.reversed) {
      if (screenRx.hasMatch(segment)) return segment;
    }
    return semanticWidget;
  }

  String get sizeLabel {
    final String w = boundingBox.width.toStringAsFixed(0);
    final String h = boundingBox.height.toStringAsFixed(0);
    return '$w×${h}px';
  }

  /// Framework / layout scaffolding omitted from the copied path — the agent
  /// only needs the screen anchor through the nearest named section.
  static const Set<String> _pathNoise = <String>{
    'AbsorbPointer',
    'Builder',
    'Center',
    'CustomScrollView',
    'Directionality',
    'IgnorePointer',
    'KeyedSubtree',
    'KasyOverlayScaffold',
    'Listener',
    'Material',
    'Padding',
    'SafeArea',
    'Scaffold',
    'SliverToBoxAdapter',
    'WebContentWrapper',
    '_EffectiveTickerMode',
    '_CustomNavigator',
    '_Theater',
  };

  /// Short ancestor chain for the clipboard [Path] line. Drops scaffolding and
  /// the screen name (already on the [Locate] line), keeps intermediate
  /// sections between the screen and the selected widget.
  List<String> clipboardWidgetPath() {
    final List<String> cleaned = widgetPath
        .map((String s) => s.split('<').first)
        .where((String s) => !_pathNoise.contains(s))
        .toList();
    if (cleaned.isEmpty) {
      return widgetPath.map((String s) => s.split('<').first).toList();
    }
    final String? screen = resolvedScreen;
    int start = 0;
    if (screen != null) {
      final int idx = cleaned.indexWhere((String s) => s == screen);
      if (idx >= 0) start = idx + 1;
    }
    if (start >= cleaned.length) {
      start = 0;
      final String? anchor = _nearestUserClass;
      if (anchor != null) {
        final int idx = cleaned.lastIndexWhere((String s) => s == anchor);
        if (idx >= 0) start = idx;
      }
    }
    return cleaned.sublist(start);
  }

  /// Screen-center percentages — only used when section text cannot break ties
  /// between look-alike widgets.
  String? _compactPosition(Size? screen) {
    if (screen == null || screen.width <= 0 || screen.height <= 0) {
      return null;
    }
    final Offset center = boundingBox.center;
    final int xPct = (center.dx / screen.width * 100).clamp(0, 100).round();
    final int yPct = (center.dy / screen.height * 100).clamp(0, 100).round();
    return 'x$xPct% y$yPct%';
  }

  /// Compact, English-only pointer for an AI coding agent. Keeps only what is
  /// needed to land on the exact widget; drops route, kit rules and properties
  /// the agent will read from source once it opens the file.
  String toAIClipboard({String? routePath, Size? screenSize}) {
    final StringBuffer buf = StringBuffer();

    final String? screen = resolvedScreen;
    final String? userClass = _nearestUserClass;

    // 1) What was picked — page is always named when known; section when deeper.
    final String? readableLabel = _readableVisibleLabel;
    final List<String> target = <String>[widgetType];
    if (readableLabel != null) {
      target.add('"$readableLabel"');
    } else if (iconHint != null) {
      target.add('icon $iconHint');
    }
    buf.writeln(
      'Inspect: ${target.join(' · ')}${_inspectLocation(screen, userClass)}',
    );

    // 2) Page file + optional grep anchor for the nearest named widget.
    final String? file = knownSourceFile;
    if (screen != null && file != null) {
      if (userClass != null && userClass != screen) {
        buf.writeln(
          'Locate: $screen → `$file` · grep `class $userClass`',
        );
      } else {
        buf.writeln('Locate: $screen → `$file`');
      }
    } else if (userClass != null && file != null) {
      buf.writeln('Locate: grep `class $userClass` → `$file`');
    } else if (screen != null && screen.isNotEmpty) {
      buf.writeln('Locate: grep `class $screen`');
    } else if (userClass != null) {
      buf.writeln('Locate: grep `class $userClass`');
    }

    // 3) Deeper path when more than one hop separates anchor and widget.
    final List<String> path = clipboardWidgetPath();
    if (path.length > 2) {
      buf.writeln('Path: ${path.join(' › ')}');
    }

    // 4) Section text — breaks ties between look-alike widgets in one screen.
    final List<String> ctxLabels = contextLabels
        .where((String s) => s.trim().isNotEmpty && !_isIconFontGlyph(s))
        .toList();
    if (ctxLabels.isNotEmpty) {
      final String near = ctxLabels.map((String s) => '"$s"').join(' · ');
      buf.writeln('Near: $near');
    }

    // 5) Position — last resort when Inspect has no label, icon or deep path.
    final bool needsPosition = ctxLabels.isEmpty &&
        readableLabel == null &&
        iconHint == null &&
        path.length <= 2;
    if (needsPosition) {
      final String? at = _compactPosition(screenSize);
      if (at != null) buf.writeln('At: $at');
    }

    buf.writeln('Edit only this widget.');
    return buf.toString();
  }

  /// ` on SettingsPage` or ` on SettingsPage in _AccountAvatarHeader`.
  static String _inspectLocation(String? screen, String? userClass) {
    if (screen != null) {
      if (userClass != null && userClass != screen) {
        return ' on $screen in $userClass';
      }
      return ' on $screen';
    }
    if (userClass != null) return ' in $userClass';
    return '';
  }

  /// Icon fonts (Lucide, Material icons, …) are a single PUA codepoint — not
  /// human-readable section context.
  static bool _isIconFontGlyph(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return true;
    if (trimmed.runes.length != 1) return false;
    final int cp = trimmed.runes.first;
    return cp >= 0xE000 && cp <= 0xF8FF;
  }

  /// Human-readable label, or null when [visibleLabel] is an icon-font glyph.
  String? get _readableVisibleLabel {
    final String? label = visibleLabel?.trim();
    if (label == null || label.isEmpty || _isIconFontGlyph(label)) return null;
    return label;
  }

  /// Nearest app-defined widget in the path (private `_Xxx` or a public
  /// feature/section widget like `NotificationTile`) — the best grep target,
  /// since `class <name>` maps to exactly one source file. Skips kit
  /// components (`Kasy*`) and framework text primitives.
  String? get _nearestUserClass {
    const Set<String> primitives = <String>{
      'Text', 'RichText', 'Icon', 'Image', 'RawImage',
    };
    for (final String segment in widgetPath.reversed) {
      final String base = segment.split('<').first; // drop generics
      if (base.startsWith('Kasy') || base.startsWith('_Kasy')) continue;
      if (primitives.contains(base)) continue;
      return base;
    }
    return null;
  }
}
