import 'package:cowboydodartinc/core/dev_inspector/dev_inspector_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class DevInspectorService {
  DevInspectorService._();

  static const _screenRegex = r'(Page|Screen|Route|View|Tab|Shell)$';

  // A real screen is a Page/Screen/Shell — narrower than [_screenRegex], used
  // to pick the screen segment of the widget path.
  static final RegExp _pageRx = RegExp(r'(Page|Screen|Shell)$');

  // Section-level widgets (cards, tiles, list rows, dialogs, …) and the
  // boundary at which "containing context" text is gathered.
  static final RegExp _sectionRx = RegExp(
    '(Page|Screen|View|Card|Tile|Item|Section|Panel|Group|Cell|Sheet|'
    'Dialog|Banner|Chip|Field|Row|Header|Footer|Form|Tab|Shell|Menu|Scaffold|'
    // Responsive variant widgets (`PaywallUnlockDesktop`, `HomeMobile`, …) name
    // the feature/variant — e.g. which of several paywalls this screen is.
    'Desktop|Mobile|Tablet|Compact|Wide)\$',
  );

  // Button / CTA wrappers hold only the label we already captured — never the
  // text that tells two look-alike controls apart, so context-gathering skips
  // them and climbs to the real card/section.
  static final RegExp _ctaLikeRx = RegExp(r'(Cta|Button|Action|Link|Fab)$');

  // Zero-width space / joiners / BOM that `trim()` doesn't strip. Some
  // layouts use them as invisible baseline anchors, which would otherwise
  // surface as empty `""` context entries.
  static const Set<int> _zeroWidthCodeUnits = <int>{
    0x200B, 0x200C, 0x200D, 0xFEFF,
  };

  // Kit components (`KasyButton`, `KasyCard`, …) are never screens.
  static bool _isKasyComponent(String base) =>
      base.startsWith('Kasy') || base.startsWith('_Kasy');

  /// Strips generic type arguments so `PopupMenuItem<bool>` matches against
  /// `PopupMenuItem`, `Router<Object>` against `Router`, etc. Set / regex
  /// lookups all compare against this base name.
  static String _baseName(String typeName) {
    final i = typeName.indexOf('<');
    return i < 0 ? typeName : typeName.substring(0, i);
  }

  // Widgets we refuse to return — even after climbing.
  static const _skipSet = <String>{
    'RenderView',
    'WidgetInspector',
    'CheckedModeBanner',
    'Banner',
    'DevInspector',
  };

  // Widgets we climb past while looking for a meaningful target. These are
  // framework-level wrappers (layout primitives, decorations, animations,
  // scroll machinery, theming, etc.) — selecting them is rarely useful.
  static const _climbPastSet = <String>{
    // Repaint / physical
    'RepaintBoundary', 'PhysicalModel', 'PhysicalShape', 'CustomPaint',

    // Layout primitives
    'Padding', 'Container', 'SizedBox', 'Center', 'Align',
    'Expanded', 'Flexible', 'Spacer',
    'ConstrainedBox', 'UnconstrainedBox', 'FractionallySizedBox',
    'AspectRatio', 'LimitedBox', 'OverflowBox', 'FittedBox', 'Baseline',
    'IntrinsicWidth', 'IntrinsicHeight',
    'DecoratedBox', 'ColoredBox', 'DecoratedBoxTransition',

    // Multi-child layout
    'Column', 'Row', 'Stack', 'Wrap', 'Flow', 'IndexedStack',
    'Positioned', 'PositionedDirectional',

    // Material / Ink
    'Material', 'Ink', 'InkWell', 'InkResponse',

    // Interaction wrappers (focus / hover / press / actions). These wrap every
    // tappable Kasy component, so selecting them is never useful — climb past
    // them to reach the real component (KasyButton, list rows, …).
    'FocusableActionDetector',
    'KasyFocusRing', 'KasyHover', 'KasyPressableDepth',

    // Pointer-related
    'GestureDetector', 'RawGestureDetector', 'MouseRegion',
    'Listener', 'AbsorbPointer', 'IgnorePointer', 'PointerInterceptor',

    // Builders
    'Builder', 'LayoutBuilder', 'StreamBuilder', 'FutureBuilder',
    'ValueListenableBuilder', 'ListenableBuilder',
    'OrientationBuilder', 'MediaQuery',

    // Animations
    'AnimatedContainer', 'AnimatedOpacity', 'AnimatedSize',
    'AnimatedSwitcher', 'AnimatedDefaultTextStyle',
    'AnimatedPhysicalModel', 'AnimatedBuilder', 'AnimatedAlign',
    'AnimatedPositioned', 'AnimatedPadding', 'AnimatedTheme',
    'TweenAnimationBuilder',
    'FadeTransition', 'SlideTransition', 'ScaleTransition',
    'RotationTransition', 'SizeTransition',
    'PositionedTransition', 'RelativePositionedTransition',
    'AlignTransition', 'DefaultTextStyleTransition',

    // Transforms / effects
    'Transform', 'Opacity', 'BackdropFilter', 'ImageFiltered',
    'ClipRect', 'ClipRRect', 'ClipOval', 'ClipPath',

    // Context propagation
    'Theme', 'DefaultTextStyle', 'IconTheme', 'IconButtonTheme',
    'CupertinoTheme', 'InheritedCupertinoTheme', 'CupertinoUserInterfaceLevel',
    'ResponsiveTextTheme',
    'Localizations', 'Directionality', 'Title',
    'DefaultSelectionStyle', 'SelectionContainer', 'AnnotatedRegion',

    // App-root / navigation / overlay scaffolding (framework + go_router +
    // project shell). Selecting these is never useful — they're plumbing.
    'Router', 'InheritedGoRouter', 'GoRouterStateRegistryScope',
    'StatefulNavigationShell', 'Navigator', 'Overlay', 'OverlayPortal',
    'CustomMultiChildLayout', 'CustomSingleChildLayout', 'LayoutId',
    'ScaffoldMessenger', 'TapRegion', 'TapRegionSurface',
    'ShortcutRegistrar', 'DefaultTextEditingShortcuts', 'ExcludeFocus',
    'FocusVisibility', 'Initializer',

    // Framework app-root + dev wrappers (the engine's View/RootWidget, the app
    // widget, Riverpod/i18n providers, and the device_preview chrome used on
    // web). None is ever a meaningful selection or a "screen".
    'RootWidget', 'View', 'RawView', 'ViewAnchor',
    'WidgetsApp', 'MaterialApp', 'CupertinoApp', 'MyApp',
    'RootRestorationScope', 'SharedAppData',
    'TranslationProvider', 'InheritedLocaleData',
    'ProviderScope', 'UncontrolledProviderScope',
    'ThemeProvider', 'ChangeNotifierProvider', 'MediaQueryObserver',
    'WebDevicePreview', 'DevicePreview', 'DeviceFrame', 'VirtualKeyboard',
    'RotatedBox',

    // Routing / storage
    'KeyedSubtree', 'AutomaticKeepAlive', 'KeepAlive', 'TickerMode',
    'Offstage', 'PageStorage', 'RestorationScope',
    'UnmanagedRestorationScope', 'HeroControllerScope', 'HeroMode',
    'PopScope', 'WillPopScope', 'BackButtonListener', 'Visibility',
    'NavigatorPopHandler',

    // Scroll / slivers
    'NotificationListener', 'SafeArea',
    'SliverPadding', 'SliverToBoxAdapter', 'SliverList', 'SliverGrid',
    'SliverFillRemaining', 'SliverFillViewport', 'SliverFixedExtentList',
    'SliverPrototypeExtentList', 'SliverMainAxisGroup', 'SliverCrossAxisGroup',
    'CustomScrollView', 'NestedScrollView', 'SingleChildScrollView',
    'ListView', 'GridView', 'PageView', 'ListWheelScrollView', 'TabBarView',
    'ReorderableListView', 'AnimatedList', 'Scrollbar', 'RawScrollbar',
    'PrimaryScrollController', 'ScrollConfiguration', 'Scrollable',
    'ScrollNotificationObserver', 'Viewport', 'ShrinkWrappingViewport',

    // Focus / semantics / actions
    'Focus', 'FocusScope', 'FocusTraversalOrder', 'FocusTraversalGroup',
    'Actions', 'Shortcuts', 'CallbackShortcuts',
    'Semantics', 'BlockSemantics', 'ExcludeSemantics', 'MergeSemantics',
    'IndexedSemantics',

    // Atomic-but-noisy
    'RichText', 'RawMaterialButton', 'RawImage',
  };

  static bool _shouldClimbPast(String typeName) =>
      _climbPastSet.contains(_baseName(typeName));

  // Used by ancestor-list builders (kept as-is — affects displayed tree only).
  static bool _isGenericUi(String typeName) => _shouldClimbPast(typeName);

  /// Private widgets we DO want to skip — usually framework internals that
  /// add noise (focus scopes, restoration scopes, builder wrappers, …).
  /// Anything else starting with `_` is treated as a user-defined private
  /// widget (e.g. `_HomeCard`, `_NavItem`) and is fully selectable.
  static const _privateFrameworkSet = <String>{
    '_FocusInheritedScope', '_FocusScopeMarker', '_FocusMarker',
    '_InheritedTheme', '_InheritedAnimatedTheme',
    '_RestorationScope', '_UnmanagedRestorationScope',
    '_NestedHero', '_HeroFlightManifest',
    '_BodyBuilder', '_ScaffoldSlot',
    '_ActionsScope', '_ShortcutsMarker',
    '_LocalizationsScope', '_DirectionalityScope',
    '_MediaQueryFromView', '_MediaQueryFromWindow',
    '_OverlayEntryWidget', '_OverlayState',
    '_ModalScope', '_ModalScopeStatus', '_RouteEntry',
    '_BannerWidget', '_CheckedModeBanner',
    '_TickerModeMarker',
    '_Pending', '_LinearProgressIndicator', '_CircularProgressIndicator',
    '_ScrollNotificationObserverScope',
    '_PrimaryScrollControllerScope',
    '_TapRegionRegistry', '_TapRegionSurface',
    '_KeyedSubtree',
    // Semantics / pointer / scroll internals that wrap every tappable widget.
    // Stopping here yields a useless `_GestureSemantics`/`_ScrollableScope`
    // instead of the real widget.
    '_GestureSemantics', '_InkResponseStateWidget', '_ScrollableScope',
    '_RenderScrollSemantics',
    // Material ink / shape-border paint layers injected around every Material
    // surface and InkWell — pure plumbing, never a meaningful target.
    '_InkFeatures', '_RenderInkFeatures', '_ShapeBorderPaint',
    '_ParentInkResponseProvider', '_InkResponseState',
    '_MaterialScrollbar', '_SingleChildViewport',
    // App-root / Riverpod / focus scopes that sit near the top of the tree.
    '_ViewScope', '_PipelineOwnerScope', '_UncontrolledProviderScope',
    '_FocusScopeWithExternalFocusNode',
    '_SharedAppModel',
  };

  /// Private framework plumbing usually ends in one of these — a private
  /// widget named `_SomethingScope`/`_SomethingOwner`/… is never a meaningful
  /// selection. User widgets (`_ProfileCard`, `_NavItem`) don't match.
  static final RegExp _privateNoiseSuffix = RegExp(
    r'(Scope|Owner|Registry|Marker|Boundary|Observer|Node|KeepAlive|Semantics)$',
  );

  static bool _shouldSkip(String typeName) {
    final base = _baseName(typeName);
    if (_skipSet.contains(base) || _privateFrameworkSet.contains(base)) {
      return true;
    }
    // Kit-internal private widgets (`_KasyButtonShell`, …) are implementation
    // detail — the user means the public component (`KasyButton`).
    if (base.startsWith('_Kasy')) return true;
    if (base.startsWith('_') && _privateNoiseSuffix.hasMatch(base)) return true;
    return false;
  }

  static List<String> _extractProperties(Element element) {
    final props = <String>[];
    try {
      final node = element.widget.toDiagnosticsNode();
      for (final prop in node.getProperties()) {
        final name = prop.name;
        if (name == null || name.isEmpty) continue;
        final val = prop.toDescription();
        if (val.isEmpty || val == 'null' || val == 'false') continue;
        if (val.contains('Closure') && val.length > 40) continue;
        props.add('$name: $val');
        if (props.length >= 10) break;
      }
    } catch (_) {}
    return props;
  }

  static List<String> _extractAncestors(
    Element element, {
    bool includePrivate = false,
  }) {
    final ancestors = <String>[];
    try {
      element.visitAncestorElements((ancestor) {
        if (ancestors.length >= 30) return false;
        final name = ancestor.widget.runtimeType.toString();
        if (_shouldSkip(name)) return true;
        if (!includePrivate && name.startsWith('_')) return true;
        if (!_isGenericUi(name)) {
          ancestors.add(name);
        }
        return true;
      });
    } catch (_) {}
    return ancestors;
  }

  static String? _extractScreenHint(Element element, List<String> ancestors) {
    final route = ModalRoute.of(element);
    final routeName = route?.settings.name;
    if (routeName != null && routeName.isNotEmpty && routeName != '/') {
      return routeName;
    }

    // Scan innermost-first so the most specific screen wins (e.g. the active
    // `AdminUsersTab` rather than the surrounding `AdminShell`). Keep the real
    // class name (incl. a leading `_`) so a `class _DebugTab` grep hint works.
    final privateAwareAncestors = _extractAncestors(
      element,
      includePrivate: true,
    );
    final regex = RegExp('^_?[A-Za-z0-9]+$_screenRegex');
    for (final type in privateAwareAncestors) {
      if (_isKasyComponent(_baseName(type))) continue;
      if (regex.hasMatch(type)) return type.trim();
    }
    for (final type in ancestors) {
      if (_isKasyComponent(_baseName(type))) continue;
      if (regex.hasMatch(type)) return type.trim();
    }
    return null;
  }

  static String? _extractSemanticWidget(
    String widgetType,
    List<String> ancestors,
  ) {
    final chain = <String>[widgetType, ...ancestors];
    final featureRegex = RegExp(
      r'(Page|Screen|Card|Tile|Item|Section|Panel|Dialog|Modal|Header|Footer|Widget|Component)$',
    );

    // 1) Prioritize feature-level widgets/classes first.
    for (final type in chain) {
      if (_shouldSkip(type)) continue;
      if (_shouldClimbPast(type)) continue;
      if (featureRegex.hasMatch(_baseName(type))) return type;
    }

    // 2) Fallback to first non-generic non-skipped widget.
    for (final type in chain) {
      if (_shouldSkip(type)) continue;
      if (_shouldClimbPast(type)) continue;
      return type;
    }
    return null;
  }

  /// Global bounds for inspector selection (boxes, slivers, and other targets).
  static Rect _globalBoundingRect(RenderObject target) {
    if (target is RenderBox) {
      final Offset globalOffset = target.localToGlobal(Offset.zero);
      return globalOffset & target.size;
    }
    try {
      final Matrix4 transform = target.getTransformTo(null);
      return MatrixUtils.transformRect(transform, target.paintBounds);
    } catch (_) {
      return Rect.zero;
    }
  }

  static DevInspectorInfo? _extractFromRenderObject(RenderObject target) {
    final creator = target.debugCreator;
    if (creator == null) return null;

    Element? element;
    try {
      // ignore: avoid_dynamic_calls
      element = (creator as dynamic).element as Element?;
    } catch (_) {
      return null;
    }
    if (element == null) return null;

    var typeName = element.widget.runtimeType.toString();
    var activeElement = element;

    // Climb past framework wrappers (layout, decoration, animation, scroll,
    // theming, etc.) to reach the most meaningful widget — typically a custom
    // widget from the user's project or a semantic widget (Text, Icon, Card,
    // Button, …).
    if (_shouldClimbPast(typeName) || _shouldSkip(typeName)) {
      Element? found;
      String? foundName;
      element.visitAncestorElements((ancestor) {
        final name = ancestor.widget.runtimeType.toString();
        if (_shouldSkip(name)) return true;
        if (_shouldClimbPast(name)) return true;
        found = ancestor;
        foundName = name;
        return false;
      });
      if (found == null || foundName == null) return null;
      typeName = foundName!;
      activeElement = found!;
    }

    if (_shouldSkip(typeName)) return null;

    final RenderObject? activeRender = activeElement.findRenderObject();
    final Rect rect = activeRender != null && activeRender.attached
        ? _globalBoundingRect(activeRender)
        : _globalBoundingRect(target);
    final ancestors = _extractAncestors(activeElement);
    final properties = _extractProperties(activeElement);
    final screenHint = _extractScreenHint(activeElement, ancestors);
    final semanticWidget = _extractSemanticWidget(typeName, ancestors);
    final content = _extractContent(activeElement);
    final contextLabels = _extractContextLabels(activeElement, content.label);
    final widgetPath = _buildWidgetPath(typeName, element);

    return DevInspectorInfo(
      widgetType: typeName,
      boundingBox: rect,
      properties: properties,
      ancestors: ancestors,
      widgetPath: widgetPath,
      screenHint: screenHint,
      semanticWidget: semanticWidget,
      visibleLabel: content.label,
      iconHint: content.icon,
      contextLabels: contextLabels,
    );
  }

  /// Short, high-signal chain `screen › nearest sections › widget` for AI
  /// prompts. Biased to the INNERMOST meaningful widgets (the screen and the
  /// section that directly contains the selection) — never the framework
  /// scopes at the top of the tree, which say nothing about where the widget
  /// lives.
  static List<String> _buildWidgetPath(String widgetType, Element element) {
    // Innermost-first; already free of framework noise and generic wrappers.
    final List<String> ancestors = _extractAncestors(
      element,
      includePrivate: true,
    );

    String? screen;
    final List<String> sections = <String>[]; // nearest-first, max 3
    for (final String name in ancestors) {
      if (name == widgetType) continue;
      final String base = _baseName(name);
      final bool isPrivate = base.startsWith('_'); // user-defined widget
      final bool isSection = _sectionRx.hasMatch(base);
      if (!isPrivate && !isSection) continue;

      if (screen == null &&
          !_isKasyComponent(base) &&
          _pageRx.hasMatch(base)) {
        screen = name;
        continue;
      }
      if (sections.length < 3) sections.add(name);
    }

    return <String>[
      if (screen != null) screen,
      ...sections.reversed, // outer → inner
      widgetType,
    ];
  }

  /// Hit-tests inside [contentBox] at [globalPosition] and returns the
  /// inspector info plus the underlying render object. Starting the hit test
  /// from the content box (instead of the root render view) skips the
  /// DevInspector's own overlay subtree.
  static ({DevInspectorInfo info, RenderObject renderObject})? pickAtInBox(
    RenderBox contentBox,
    Offset globalPosition,
  ) {
    if (!kDebugMode) return null;
    if (!contentBox.attached) return null;
    try {
      final Offset local = contentBox.globalToLocal(globalPosition);
      final result = BoxHitTestResult();
      contentBox.hitTest(result, position: local);
      // Path is deepest → shallowest; return the first meaningful target.
      for (final HitTestEntry entry in result.path) {
        if (entry.target is! RenderObject) continue;
        final RenderObject candidate = entry.target as RenderObject;
        final DevInspectorInfo? info = _extractFromRenderObject(candidate);
        if (info != null) {
          return (info: info, renderObject: candidate);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Re-measures the global bounding rect of a previously picked render
  /// object. Returns null if it became detached from the tree.
  static Rect? remeasure(RenderObject target) {
    if (!target.attached) return null;
    return _globalBoundingRect(target);
  }

  /// Climbs one level up the meaningful-widget hierarchy from [current].
  /// Used to bubble a repeat-tap up to the parent widget when the current
  /// selection isn't the one the user wanted.
  static ({DevInspectorInfo info, RenderObject renderObject})? climbFrom(
    RenderObject current,
  ) {
    if (!kDebugMode) return null;
    if (!current.attached) return null;
    try {
      final creator = current.debugCreator;
      if (creator == null) return null;
      Element? element;
      try {
        // ignore: avoid_dynamic_calls
        element = (creator as dynamic).element as Element?;
      } catch (_) {
        return null;
      }
      if (element == null) return null;

      Element? found;
      element.visitAncestorElements((ancestor) {
        final name = ancestor.widget.runtimeType.toString();
        if (_shouldSkip(name)) return true;
        if (_shouldClimbPast(name)) return true;
        found = ancestor;
        return false;
      });
      if (found == null) return null;
      final RenderObject? ro = found!.findRenderObject();
      if (ro == null || !ro.attached) return null;
      final info = _buildInfoForElement(found!, ro);
      return (info: info, renderObject: ro);
    } catch (_) {
      return null;
    }
  }

  /// Builds info from an element/render-object pair without re-running the
  /// climb logic. Used by [climbFrom] (which already picked the element).
  static DevInspectorInfo _buildInfoForElement(
    Element element,
    RenderObject ro,
  ) {
    final typeName = element.widget.runtimeType.toString();
    final Rect rect = _globalBoundingRect(ro);
    final ancestors = _extractAncestors(element);
    final properties = _extractProperties(element);
    final screenHint = _extractScreenHint(element, ancestors);
    final semanticWidget = _extractSemanticWidget(typeName, ancestors);
    final content = _extractContent(element);
    final contextLabels = _extractContextLabels(element, content.label);
    final widgetPath = _buildWidgetPath(typeName, element);
    return DevInspectorInfo(
      widgetType: typeName,
      boundingBox: rect,
      properties: properties,
      ancestors: ancestors,
      widgetPath: widgetPath,
      screenHint: screenHint,
      semanticWidget: semanticWidget,
      visibleLabel: content.label,
      iconHint: content.icon,
      contextLabels: contextLabels,
    );
  }

  /// Walks the selected widget's own subtree to capture the visible label and,
  /// only as a fallback for icon-only controls, the icon codepoint. Kasy
  /// components wrap themselves in `Semantics(label: …)`, so the label resolves
  /// to the button text (or its `semanticLabel`) even when the glyph/text lives
  /// in a child — which is exactly what tells two look-alike widgets apart.
  static ({String? label, String? icon}) _extractContent(Element element) {
    String? semanticsLabel;
    String? firstText;
    String? iconCode;
    var visited = 0;

    void walk(Element el) {
      // Best label already found, or budget spent: stop descending.
      if (semanticsLabel != null || visited >= 80) return;
      visited++;
      final Widget widget = el.widget;
      if (widget is Semantics) {
        final String? label = widget.properties.label;
        if (label != null && label.trim().isNotEmpty) {
          semanticsLabel = label.trim();
          return;
        }
      } else if (widget is Text || widget is RichText) {
        final String? data = _plainText(widget);
        if (firstText == null && data != null) {
          firstText = data;
        }
      } else if (widget is Icon) {
        final IconData? icon = widget.icon;
        if (iconCode == null && icon != null) {
          iconCode = 'U+${icon.codePoint.toRadixString(16).toUpperCase()}';
        }
      }
      el.visitChildren(walk);
    }

    try {
      walk(element);
    } catch (_) {}

    final String? label = _normalizeVisibleLabel(semanticsLabel ?? firstText);
    // The icon codepoint only helps when there's no readable label to show.
    return (label: label, icon: label == null ? iconCode : null);
  }

  /// Icon fonts (Lucide, Material icons, …) surface as a single Private Use
  /// Area character in semantics — not a human-readable label.
  static bool _isIconFontGlyph(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return true;
    if (trimmed.runes.length != 1) return false;
    final int cp = trimmed.runes.first;
    return cp >= 0xE000 && cp <= 0xF8FF;
  }

  static String? _normalizeVisibleLabel(String? raw) {
    if (raw == null) return null;
    final String trimmed = raw.trim();
    if (trimmed.isEmpty || _isIconFontGlyph(trimmed)) return null;
    return trimmed;
  }

  /// Identifying text from the section/card that CONTAINS the selection — the
  /// decisive signal for telling apart look-alike widgets (two "Desbloquear"
  /// buttons, one per plan card: the card carries "Anual" / "Mensal"). Collects
  /// from the FIRST real container only (skipping button/CTA wrappers): a card
  /// with extra text yields it; a tight single-label wrapper (nav tile, list
  /// row whose only text IS the selection) yields nothing, so the Context line
  /// is omitted — the widget's own label already identifies it, and we avoid
  /// dragging in sibling items.
  static List<String> _extractContextLabels(Element selected, String? ownLabel) {
    final List<String> labels = <String>[];
    final Set<String> seen = <String>{};

    selected.visitAncestorElements((ancestor) {
      final String base = _baseName(ancestor.widget.runtimeType.toString());
      if (_shouldSkip(base) || _shouldClimbPast(base)) return true;
      final bool isContainer = base.startsWith('_') || _sectionRx.hasMatch(base);
      if (!isContainer) return true;

      // Reached the screen itself — no enclosing card; don't dump screen text.
      if (!_isKasyComponent(base) && _pageRx.hasMatch(base)) return false;

      // Button/CTA wrappers only repeat the label we already have — keep
      // climbing to the real card that carries the distinguishing text.
      if (_ctaLikeRx.hasMatch(base)) return true;

      _collectTexts(ancestor, ownLabel, labels, seen);
      return false; // first real container only
    });
    return labels.take(3).toList();
  }

  /// Collects up to 3 short, distinct [Text] strings from [root]'s subtree,
  /// skipping [exclude] (the selected widget's own label).
  static void _collectTexts(
    Element root,
    String? exclude,
    List<String> out,
    Set<String> seen,
  ) {
    var visited = 0;
    void walk(Element el) {
      if (out.length >= 3 || visited >= 150) return;
      visited++;
      final String? data = _plainText(el.widget);
      if (data != null &&
          data.length <= 40 &&
          data != exclude &&
          seen.add(data)) {
        out.add(data);
      }
      el.visitChildren(walk);
    }

    try {
      walk(root);
    } catch (_) {}
  }

  /// Plain string a widget renders, covering both `Text` and `RichText`
  /// (`Text.rich`, styled spans). Returns null for non-text widgets or empty
  /// text. A plain `Text` and the `RichText` it builds yield the same string;
  /// callers dedupe.
  static String? _plainText(Widget widget) {
    String? value;
    if (widget is Text) {
      value = widget.data;
    } else if (widget is RichText) {
      value = widget.text.toPlainText(
        includeSemanticsLabels: false,
        includePlaceholders: false,
      );
    }
    // Drop zero-width / BOM chars that `trim()` leaves behind, so invisible
    // baseline anchors don't become empty `""` context entries.
    final StringBuffer cleaned = StringBuffer();
    for (final int unit in value.runes) {
      if (!_zeroWidthCodeUnits.contains(unit)) cleaned.writeCharCode(unit);
    }
    final String result = cleaned.toString().trim();
    if (result.isEmpty || _isIconFontGlyph(result)) return null;
    return result;
  }
}
