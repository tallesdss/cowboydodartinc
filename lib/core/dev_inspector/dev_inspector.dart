import 'dart:async';

import 'package:cowboydodartinc/core/dev_inspector/dev_inspector_info.dart';
import 'package:cowboydodartinc/core/dev_inspector/dev_inspector_service.dart';
import 'package:cowboydodartinc/core/icons/kasy_icons.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:cowboydodartinc/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Same lime used by the Kasy CLI brand color (Tailwind lime-500). Balanced
/// for visibility on both light and dark surfaces.
const Color _highlightColor = Color(0xFF84CC16);
const double _highlightStrokeWidth = 2.0;
const double _highlightCornerRadius = 4.0;

final GlobalKey<ScaffoldMessengerState> devInspectorRootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>(debugLabel: 'devInspectorRoot');

/// Persisted master switch flipped from the admin settings sheet. When `true`
/// the inspector is permanently armed (`devInspectorActiveNotifier` follows it).
/// Esc/pill toggles flip this same flag, which is then persisted to prefs so
/// the next launch matches what the user left.
///
/// Key kept as `dev_inspector_fab_enabled` for backwards compatibility with
/// users who already had the toggle on before the FAB was removed.
const String devInspectorEnabledPrefKey = 'dev_inspector_fab_enabled';

final ValueNotifier<bool> devInspectorEnabledNotifier = ValueNotifier<bool>(
  false,
);

/// Set to true to trigger a copy of the currently selected widget.
/// [DevInspector] handles the copy + feedback and resets this to false.
final ValueNotifier<bool> devInspectorCopyTriggerNotifier = ValueNotifier<bool>(
  false,
);

/// Currently selected widget, or null when nothing is picked. Drives the copy
/// button state in the Web Device Preview toolbar.
final ValueNotifier<DevInspectorInfo?> devInspectorSelectionNotifier =
    ValueNotifier<DevInspectorInfo?>(null);

/// Set to true to clear the current selection WITHOUT deactivating the
/// inspector. The Web Device Preview toggle fires this when entering/leaving
/// the device frame so a stale highlight doesn't linger across the transition.
/// [DevInspector] clears the selection and resets this to false.
final ValueNotifier<bool> devInspectorClearSelectionTriggerNotifier =
    ValueNotifier<bool>(false);

/// Runtime active state of the inspector. Mirrors [devInspectorEnabledNotifier]
/// — the Web Device Preview pill, the admin toggle and the Esc shortcut all
/// flip the persisted notifier, and this one follows.
final ValueNotifier<bool> devInspectorActiveNotifier = ValueNotifier<bool>(
  false,
);

/// Set to true to hide the in-app status pill that the [DevInspector] shows
/// while active (e.g. when the WebDevicePreview chrome is already displaying
/// its own inspector state).
final ValueNotifier<bool> devInspectorSuppressStatusPillNotifier =
    ValueNotifier<bool>(false);

/// Confirmation message the [DevInspector] wants surfaced. When the
/// WebDevicePreview chrome is present it OWNS the toast surface (so the
/// inspector's "copied" pill lands in the exact same spot and size as the
/// chrome's own toasts, e.g. "Image copied"). The chrome listens here, shows
/// the toast, and resets this to null. When no chrome is present the inspector
/// renders its own in-app toast instead.
final ValueNotifier<({String message, bool isError})?>
devInspectorToastNotifier = ValueNotifier<({String message, bool isError})?>(
  null,
);

/// Rect of the currently selected widget expressed in **root view coordinates**
/// (the browser window / native window). External surfaces — e.g. the Web
/// Device Preview chrome which renders OUTSIDE the device frame — listen to
/// this and draw the highlight above the frame so it stays visible even when
/// the selected widget hugs the edges of the simulated device.
final ValueNotifier<Rect?> devInspectorHighlightGlobalRect =
    ValueNotifier<Rect?>(null);

const Color devInspectorHighlightColor = _highlightColor;
const double devInspectorHighlightStrokeWidth = _highlightStrokeWidth;
const double devInspectorHighlightCornerRadius = _highlightCornerRadius;

/// Keyboard shortcut for toggling the inspector, formatted for the current
/// platform. Key names are kept in English regardless of the app locale —
/// "Command", "Ctrl" and "Shift" are universal keyboard conventions.
String devInspectorShortcutLabel() {
  final String mod = defaultTargetPlatform == TargetPlatform.macOS
      ? 'Command'
      : 'Ctrl';
  return '$mod + Shift + P';
}

class DevInspector extends StatefulWidget {
  const DevInspector({super.key, required this.child});

  final Widget child;

  static Widget wrap({required Widget child}) {
    if (!kDebugMode) return child;
    return DevInspector(child: child);
  }

  @override
  State<DevInspector> createState() => _DevInspectorState();
}

class _DevInspectorState extends State<DevInspector>
    with TickerProviderStateMixin {
  static const Duration _copyFeedbackVisible = Duration(milliseconds: 2200);
  static const int _historyCapacity = 20;

  bool _active = false;
  bool _copyBusy = false;

  Timer? _copyFeedbackTimer;
  String? _copyFeedbackText;
  bool _copyFeedbackIsError = false;

  DevInspectorInfo? _selectedInfo;
  RenderObject? _selectedRender;
  Rect? _highlightRect;
  // Live highlight of whatever the cursor is over (hover-to-inspect). Distinct
  // from the locked selection [_highlightRect] — drawn softer, no history/copy.
  Rect? _hoverRect;
  Ticker? _highlightTicker;
  late final AnimationController _transitionCtrl;
  Rect? _transitionFromRect;
  Rect? _transitionToRect;
  Rect? _transitionFromGlobalRect;
  Rect? _transitionToGlobalRect;
  final GlobalKey _overlayKey = GlobalKey(debugLabel: 'devInspectorOverlay');
  final GlobalKey _contentKey = GlobalKey(debugLabel: 'devInspectorContent');

  /// Past selections, oldest → newest. [_historyCursor] points at the current
  /// position; ← and → keys walk this list. Cleared when the inspector is
  /// disabled.
  final List<({DevInspectorInfo info, RenderObject renderObject})> _history =
      [];
  int _historyCursor = -1;
  bool _navigatingHistory = false;

  @override
  void initState() {
    super.initState();
    _transitionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    )..addListener(_handleTransitionTick);
    devInspectorActiveNotifier.addListener(_handleActiveChanged);
    devInspectorEnabledNotifier.addListener(_handleEnabledChanged);
    devInspectorCopyTriggerNotifier.addListener(_onCopyTriggered);
    devInspectorClearSelectionTriggerNotifier.addListener(
      _onClearSelectionTriggered,
    );
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    unawaited(_bootstrapEnabledPreference());
  }

  @override
  void dispose() {
    _copyFeedbackTimer?.cancel();
    _highlightTicker?.dispose();
    _transitionCtrl.dispose();
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    devInspectorEnabledNotifier.removeListener(_handleEnabledChanged);
    devInspectorCopyTriggerNotifier.removeListener(_onCopyTriggered);
    devInspectorClearSelectionTriggerNotifier.removeListener(
      _onClearSelectionTriggered,
    );
    devInspectorActiveNotifier.removeListener(_handleActiveChanged);
    if (devInspectorActiveNotifier.value) {
      devInspectorActiveNotifier.value = false;
    }
    super.dispose();
  }

  void _handleTransitionTick() {
    if (!mounted) return;
    final Rect? from = _transitionFromRect;
    final Rect? to = _transitionToRect;
    if (from == null || to == null) return;
    final double t = Curves.easeOutCubic.transform(_transitionCtrl.value);
    setState(() => _highlightRect = Rect.lerp(from, to, t));

    final Rect? gFrom = _transitionFromGlobalRect;
    final Rect? gTo = _transitionToGlobalRect;
    if (gFrom != null && gTo != null) {
      devInspectorHighlightGlobalRect.value = Rect.lerp(gFrom, gTo, t);
    }
  }

  /// Global keyboard shortcuts. The "wake up" combo works from anywhere,
  /// even when the inspector is off; the rest only fire when it's active.
  ///   • Cmd/Ctrl + Shift + P → toggle inspector on/off (debug only)
  ///   • Esc                  → deactivate (and persist OFF)
  ///   • C                    → copy the selected widget (no modifier; the
  ///                            usual Cmd/Ctrl+C still copies text elsewhere)
  ///   • ← / →                → step backward / forward through history
  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final HardwareKeyboard kb = HardwareKeyboard.instance;

    // Cmd/Ctrl + Shift + P — works regardless of active state.
    if (kDebugMode &&
        event.logicalKey == LogicalKeyboardKey.keyP &&
        (kb.isMetaPressed || kb.isControlPressed) &&
        kb.isShiftPressed &&
        !kb.isAltPressed) {
      _toggleInspectorFromShortcut();
      return true;
    }

    if (!_active) return false;

    final bool hasModifier =
        kb.isMetaPressed ||
        kb.isControlPressed ||
        kb.isAltPressed ||
        kb.isShiftPressed;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      // Esc must turn the inspector off no matter HOW it was activated:
      //   • Admin toggle  → flip Enabled (and let it cascade to Active).
      //   • WebDevicePreview pill → only Active is set; flip it directly.
      // We touch both so ValueNotifier always observes a real change.
      if (devInspectorEnabledNotifier.value) {
        devInspectorEnabledNotifier.value = false;
      }
      if (devInspectorActiveNotifier.value) {
        devInspectorActiveNotifier.value = false;
      }
      HapticFeedback.lightImpact();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyC && !hasModifier) {
      if (_selectedInfo == null) return false;
      unawaited(_copySelection());
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && !hasModifier) {
      return _stepHistory(-1);
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight && !hasModifier) {
      return _stepHistory(1);
    }
    return false;
  }

  /// Flip the inspector on or off via the global shortcut. Mirrors what the
  /// admin toggle does on the ON side, and what Esc does on the OFF side.
  void _toggleInspectorFromShortcut() {
    final bool turningOn = !_active;
    if (turningOn) {
      devInspectorEnabledNotifier.value = true;
    } else {
      if (devInspectorEnabledNotifier.value) {
        devInspectorEnabledNotifier.value = false;
      }
      if (devInspectorActiveNotifier.value) {
        devInspectorActiveNotifier.value = false;
      }
    }
    HapticFeedback.lightImpact();
  }

  bool _stepHistory(int delta) {
    if (_history.isEmpty) return false;
    final int next = _historyCursor + delta;
    if (next < 0 || next >= _history.length) return false;
    _historyCursor = next;
    final entry = _history[next];
    if (!entry.renderObject.attached) return false;

    final Rect? newRect = _rectInOverlaySpace(entry.renderObject);
    final Rect? newGlobalRect = _rectInRootSpace(entry.renderObject);
    final Rect? fromRect = _highlightRect;
    final Rect? fromGlobalRect = devInspectorHighlightGlobalRect.value;

    _navigatingHistory = true;
    setState(() {
      _selectedInfo = entry.info;
      _selectedRender = entry.renderObject;
    });
    devInspectorSelectionNotifier.value = entry.info;
    _animateHighlightTo(
      fromRect: fromRect,
      toRect: newRect,
      fromGlobalRect: fromGlobalRect,
      toGlobalRect: newGlobalRect,
    );
    _navigatingHistory = false;
    HapticFeedback.selectionClick();
    unawaited(_copySelection());
    return true;
  }

  Future<void> _bootstrapEnabledPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final bool enabled = prefs.getBool(devInspectorEnabledPrefKey) ?? false;
    if (devInspectorEnabledNotifier.value != enabled) {
      devInspectorEnabledNotifier.value = enabled;
    } else {
      _applyEnabled(enabled);
    }
  }

  Future<void> _persistEnabled(bool value) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(devInspectorEnabledPrefKey, value);
    } catch (_) {
      // Best-effort persistence — don't crash the inspector if prefs fail.
    }
  }

  void _handleEnabledChanged() {
    _applyEnabled(devInspectorEnabledNotifier.value);
    unawaited(_persistEnabled(devInspectorEnabledNotifier.value));
  }

  void _applyEnabled(bool enabled) {
    if (!mounted) return;
    // Master switch directly drives the runtime active flag — no FAB stage.
    if (devInspectorActiveNotifier.value != enabled) {
      devInspectorActiveNotifier.value = enabled;
    }
    if (!enabled) {
      _copyFeedbackTimer?.cancel();
      setState(() {
        _active = false;
        _copyFeedbackText = null;
        _copyFeedbackIsError = false;
        _clearSelection();
      });
    }
  }

  void _onCopyTriggered() {
    if (!devInspectorCopyTriggerNotifier.value) return;
    devInspectorCopyTriggerNotifier.value = false;
    if (!_active) return;
    unawaited(_copySelection());
  }

  /// Drops the current selection while keeping the inspector active, so a stale
  /// highlight doesn't carry over when the Web Device Preview is toggled.
  void _onClearSelectionTriggered() {
    if (!devInspectorClearSelectionTriggerNotifier.value) return;
    devInspectorClearSelectionTriggerNotifier.value = false;
    if (!mounted) return;
    if (_selectedInfo == null && _selectedRender == null) return;
    setState(_clearSelection);
  }

  void _handleActiveChanged() {
    final bool active = devInspectorActiveNotifier.value;
    if (_active == active) return;
    if (!mounted) return;
    setState(() {
      _active = active;
      if (!active) _clearSelection();
    });
  }

  void _clearSelection() {
    _selectedInfo = null;
    _selectedRender = null;
    _highlightRect = null;
    _hoverRect = null;
    devInspectorSelectionNotifier.value = null;
    _transitionFromRect = null;
    _transitionToRect = null;
    _transitionFromGlobalRect = null;
    _transitionToGlobalRect = null;
    if (_transitionCtrl.isAnimating) _transitionCtrl.stop();
    _stopHighlightTicker();
    devInspectorHighlightGlobalRect.value = null;
    _history.clear();
    _historyCursor = -1;
  }

  void _pushHistory(DevInspectorInfo info, RenderObject renderObject) {
    // Drop anything ahead of the cursor — selecting a new widget after
    // pressing ← invalidates the "forward" history (same as a browser).
    if (_historyCursor < _history.length - 1) {
      _history.removeRange(_historyCursor + 1, _history.length);
    }
    _history.add((info: info, renderObject: renderObject));
    if (_history.length > _historyCapacity) {
      _history.removeAt(0);
    }
    _historyCursor = _history.length - 1;
  }

  /// Live hover preview: highlight whatever widget is under the cursor without
  /// selecting it. Cheap rect-diff guard avoids rebuilding when nothing moved.
  void _onInspectorHover(Offset globalPosition) {
    if (!_active) return;
    final RenderObject? content = _contentKey.currentContext
        ?.findRenderObject();
    if (content is! RenderBox) return;
    final picked = DevInspectorService.pickAtInBox(content, globalPosition);
    final Rect? rect = picked == null
        ? null
        : _rectInOverlaySpace(picked.renderObject);
    if (rect != _hoverRect) setState(() => _hoverRect = rect);
  }

  void _clearHover() {
    if (_hoverRect != null) setState(() => _hoverRect = null);
  }

  void _onInspectorTap(Offset globalPosition) {
    final RenderObject? content = _contentKey.currentContext
        ?.findRenderObject();
    if (content is! RenderBox) {
      HapticFeedback.heavyImpact();
      return;
    }
    var picked = DevInspectorService.pickAtInBox(content, globalPosition);
    if (picked == null) {
      HapticFeedback.heavyImpact();
      return;
    }

    // Repeat-click bubbles the selection up: if the tap landed on the SAME
    // widget that's already selected, climb one level up the meaningful
    // hierarchy instead of re-selecting it.
    if (_selectedRender != null &&
        identical(picked.renderObject, _selectedRender)) {
      final climbed = DevInspectorService.climbFrom(picked.renderObject);
      if (climbed != null) picked = climbed;
    }

    final Rect? newRect = _rectInOverlaySpace(picked.renderObject);
    final Rect? newGlobalRect = _rectInRootSpace(picked.renderObject);
    final Rect? fromRect = _highlightRect;
    final Rect? fromGlobalRect = devInspectorHighlightGlobalRect.value;

    setState(() {
      _selectedInfo = picked!.info;
      _selectedRender = picked.renderObject;
    });
    devInspectorSelectionNotifier.value = picked.info;

    if (!_navigatingHistory) {
      _pushHistory(picked.info, picked.renderObject);
    }

    _animateHighlightTo(
      fromRect: fromRect,
      toRect: newRect,
      fromGlobalRect: fromGlobalRect,
      toGlobalRect: newGlobalRect,
    );
    HapticFeedback.selectionClick();
    unawaited(_copySelection());
  }

  /// Animates the highlight from [fromRect] to [toRect] in ~140 ms, then hands
  /// off to the per-frame ticker (which keeps the highlight glued to the
  /// widget if it animates internally). If there's no previous rect or no
  /// change in geometry, the new rect is applied instantly.
  void _animateHighlightTo({
    required Rect? fromRect,
    required Rect? toRect,
    required Rect? fromGlobalRect,
    required Rect? toGlobalRect,
  }) {
    _stopHighlightTicker();
    if (_transitionCtrl.isAnimating) _transitionCtrl.stop();

    if (fromRect == null || toRect == null || fromRect == toRect) {
      setState(() => _highlightRect = toRect);
      devInspectorHighlightGlobalRect.value = toGlobalRect;
      if (toRect != null && _selectedRender != null) _startHighlightTicker();
      return;
    }

    _transitionFromRect = fromRect;
    _transitionToRect = toRect;
    _transitionFromGlobalRect = fromGlobalRect;
    _transitionToGlobalRect = toGlobalRect;
    _transitionCtrl.forward(from: 0.0).whenComplete(() {
      if (!mounted) return;
      if (_transitionCtrl.status != AnimationStatus.completed) return;
      setState(() => _highlightRect = toRect);
      devInspectorHighlightGlobalRect.value = toGlobalRect;
      _transitionFromRect = null;
      _transitionToRect = null;
      _transitionFromGlobalRect = null;
      _transitionToGlobalRect = null;
      if (_selectedRender != null) _startHighlightTicker();
    });
  }

  /// Computes the bounds of [target] in the overlay's local coordinate space,
  /// walking the paint-transform matrix directly. This works regardless of any
  /// transforms applied above the overlay (e.g. WebDevicePreview's scale).
  Rect? _rectInOverlaySpace(RenderObject target) {
    if (!target.attached) return null;
    final RenderObject? overlay = _overlayKey.currentContext
        ?.findRenderObject();
    if (overlay == null || !overlay.attached) return null;
    try {
      final Matrix4 transform = target.getTransformTo(overlay);
      return MatrixUtils.transformRect(transform, target.paintBounds);
    } catch (_) {
      return null;
    }
  }

  /// Computes the bounds of [target] in **root view coordinates** (the browser
  /// window / native window). Used to drive the external highlight overlay
  /// that sits ABOVE the device frame in WebDevicePreview.
  Rect? _rectInRootSpace(RenderObject target) {
    if (!target.attached) return null;
    try {
      final Matrix4 transform = target.getTransformTo(null);
      return MatrixUtils.transformRect(transform, target.paintBounds);
    } catch (_) {
      return null;
    }
  }

  void _startHighlightTicker() {
    _highlightTicker ??= createTicker(_onHighlightTick);
    if (!_highlightTicker!.isActive) _highlightTicker!.start();
  }

  void _stopHighlightTicker() {
    if (_highlightTicker?.isActive ?? false) _highlightTicker!.stop();
  }

  void _onHighlightTick(Duration _) {
    final RenderObject? target = _selectedRender;
    if (target == null) return;
    if (!target.attached) {
      setState(_clearSelection);
      return;
    }
    final Rect? local = _rectInOverlaySpace(target);
    if (local != null && _highlightRect != local) {
      setState(() => _highlightRect = local);
    }
    final Rect? global = _rectInRootSpace(target);
    if (global != devInspectorHighlightGlobalRect.value) {
      devInspectorHighlightGlobalRect.value = global;
    }
  }

  String? _currentRoutePath() {
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) return null;
    try {
      final String path =
          GoRouter.of(context).routeInformationProvider.value.uri.path;
      return path.isEmpty ? '/' : path;
    } catch (_) {
      return null;
    }
  }

  void _showCopyFeedback(String message, {required bool isError}) {
    // When the WebDevicePreview chrome is up it owns the toast surface — hand
    // the message off so the confirmation appears in the exact same place and
    // size as the chrome's other toasts (e.g. "Image copied"). No local toast
    // in that case, to avoid showing two.
    if (devInspectorSuppressStatusPillNotifier.value) {
      devInspectorToastNotifier.value = (message: message, isError: isError);
      return;
    }
    _copyFeedbackTimer?.cancel();
    setState(() {
      _copyFeedbackText = message;
      _copyFeedbackIsError = isError;
    });
    _copyFeedbackTimer = Timer(_copyFeedbackVisible, () {
      if (!mounted) return;
      setState(() {
        _copyFeedbackText = null;
        _copyFeedbackIsError = false;
      });
      _copyFeedbackTimer = null;
    });
  }

  Future<void> _copySelection() async {
    if (!_active || _copyBusy) return;
    _copyBusy = true;
    try {
      final DevInspectorInfo? info = _selectedInfo;
      if (!mounted) return;
      if (info == null) {
        _showCopyFeedback(t.devInspector.selectWidgetFirst, isError: true);
        HapticFeedback.heavyImpact();
        return;
      }

      final (Size screenSize, _) = _sizeAndPadding(context);
      await Clipboard.setData(
        ClipboardData(
          text: info.toAIClipboard(
            routePath: _currentRoutePath(),
            screenSize: screenSize,
          ),
        ),
      );
      if (!mounted) return;
      _showCopyFeedback(t.devInspector.copied, isError: false);
      HapticFeedback.selectionClick();
    } finally {
      _copyBusy = false;
    }
  }

  (Size, EdgeInsets) _sizeAndPadding(BuildContext context) {
    final MediaQueryData? mq = MediaQuery.maybeOf(context);
    if (mq != null) return (mq.size, mq.padding);
    final view = View.of(context);
    final double dpr = view.devicePixelRatio;
    return (
      Size(view.physicalSize.width / dpr, view.physicalSize.height / dpr),
      EdgeInsets.fromViewPadding(view.padding, dpr),
    );
  }

  static TextDirection _platformTextDirection() {
    final String lang =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    const Set<String> rtl = {'ar', 'fa', 'he', 'ur'};
    return rtl.contains(lang.toLowerCase())
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    final (_, EdgeInsets padding) = _sizeAndPadding(context);

    return Directionality(
      textDirection: _platformTextDirection(),
      child: Builder(
        builder: (BuildContext context) {
          return Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                // While inspecting, the app must not react to clicks — only the
                // inspector selects/highlights. AbsorbPointer swallows pointer
                // events for the app subtree. Picking still works: the inspector
                // calls hitTest directly on the content render box (via
                // _contentKey), which is a CHILD of this AbsorbPointer, so the
                // direct call bypasses the absorption.
                AbsorbPointer(
                  absorbing: _active,
                  child: KeyedSubtree(key: _contentKey, child: widget.child),
                ),
                if (_active)
                  Positioned.fill(
                    child: MouseRegion(
                      opaque: false,
                      cursor: SystemMouseCursors.precise,
                      onHover: (PointerHoverEvent ev) =>
                          _onInspectorHover(ev.position),
                      onExit: (_) => _clearHover(),
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (PointerDownEvent ev) =>
                            _onInspectorTap(ev.position),
                        child: IgnorePointer(
                          child: CustomPaint(
                            key: _overlayKey,
                            painter: _HighlightPainter(
                              rect: _highlightRect,
                              hoverRect: _hoverRect,
                            ),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_active)
                  Positioned(
                    bottom: padding.bottom + 12,
                    right: 12,
                    child: const IgnorePointer(child: _InspectorStatusPill()),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: padding.bottom + 24,
                  child: IgnorePointer(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _copyFeedbackText == null
                            ? const SizedBox.shrink()
                            : _InspectorToast(
                                key: ValueKey<String>(_copyFeedbackText!),
                                message: _copyFeedbackText!,
                                isError: _copyFeedbackIsError,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
    );
  }
}

class _HighlightPainter extends CustomPainter {
  _HighlightPainter({required this.rect, this.hoverRect});

  final Rect? rect;
  final Rect? hoverRect;

  @override
  void paint(Canvas canvas, Size size) {
    // Hover preview first (under the selection): soft translucent fill + thin
    // stroke. Skipped when it coincides with the locked selection.
    final Rect? hover = hoverRect;
    if (hover != null && !hover.isEmpty && hover != rect) {
      final RRect hoverRRect = RRect.fromRectAndRadius(
        hover,
        const Radius.circular(_highlightCornerRadius),
      );
      canvas.drawRRect(
        hoverRRect,
        Paint()
          ..color = _highlightColor.withValues(alpha: 0.12)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        hoverRRect,
        Paint()
          ..color = _highlightColor.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    // Locked selection: solid stroke.
    final Rect? r = rect;
    if (r == null || r.isEmpty) return;
    final Paint paint = Paint()
      ..color = _highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _highlightStrokeWidth;
    final Rect outer = r.inflate(_highlightStrokeWidth / 2);
    final RRect rrect = RRect.fromRectAndRadius(
      outer,
      const Radius.circular(_highlightCornerRadius),
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_HighlightPainter oldDelegate) =>
      oldDelegate.rect != rect || oldDelegate.hoverRect != hoverRect;
}

/// Minimal status pill tucked in the bottom-right corner while the inspector
/// is active. Mirrors the role of the WebDevicePreview chrome (which already
/// shows inspector state); hidden when that chrome is present via
/// [devInspectorSuppressStatusPillNotifier].
class _InspectorStatusPill extends StatelessWidget {
  const _InspectorStatusPill();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: devInspectorSuppressStatusPillNotifier,
      builder: (BuildContext context, bool suppressed, Widget? _) {
        if (suppressed) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xB3111111),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const _PulsingDot(),
              const SizedBox(width: 7),
              Text(
                t.devInspector.statusActive,
                style: const TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Modern confirmation pill shown briefly after a copy. Mirrors the toast used
/// by the WebDevicePreview chrome: dark frosted capsule, leading status icon,
/// Inter text. Success shows a green check; errors show a red alert.
class _InspectorToast extends StatelessWidget {
  const _InspectorToast({
    super.key,
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF02C2C2E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isError ? KasyIcons.error : KasyIcons.checkCircle,
              color: isError ? const Color(0xFFFF453A) : const Color(0xFF34C759),
              size: 15,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (BuildContext context, Widget? _) {
        final double t = Curves.easeInOut.transform(_ctrl.value);
        final double alpha = 0.45 + 0.55 * t;
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: _highlightColor.withValues(alpha: alpha),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
