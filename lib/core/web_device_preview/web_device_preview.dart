import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cowboydodartinc/core/dev_inspector/dev_inspector.dart';
import 'package:cowboydodartinc/core/icons/kasy_icons.dart';
import 'package:cowboydodartinc/core/theme/colors.dart';
import 'package:cowboydodartinc/core/theme/providers/theme_provider.dart';
import 'package:cowboydodartinc/core/theme/web_background_sync.dart'
    if (dart.library.js_interop)
        'package:cowboydodartinc/core/theme/web_background_sync_web.dart';
import 'package:cowboydodartinc/core/web_device_preview/boot_prefs.dart';
import 'package:cowboydodartinc/core/web_device_preview/dev_reload_bridge.dart';
import 'package:cowboydodartinc/core/web_device_preview/kasy_preview_devices.dart';
import 'package:cowboydodartinc/core/web_device_preview/png_clipboard.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Suffixed `_v2` because the default flipped from OFF to ON. Values saved under
// the old key were written while the default was OFF, so we ignore them and
// start fresh — every install now gets the new ON default until it's toggled.
const String webDevicePreviewEnabledPrefKey = 'web_device_preview_enabled_v2';
const String _platformPrefKey = 'web_device_preview_platform';
const String _iosIndexPrefKey = 'web_device_preview_ios_index';
const String _androidIndexPrefKey = 'web_device_preview_android_index';
const String _iPadIndexPrefKey = 'web_device_preview_ipad_index';
const String _desktopIndexPrefKey = 'web_device_preview_desktop_index';
const String _bgDarkPrefKey = 'web_device_preview_bg_dark';
const String _landscapePrefKey = 'web_device_preview_landscape';
const String _textScalePrefKey = 'web_device_preview_text_scale';

final ValueNotifier<bool> webDevicePreviewEnabledNotifier = ValueNotifier<bool>(
  false,
);

/// True only once the device frame is actually ON SCREEN (not the instant the
/// toggle flips — the frame takes a moment to build). The web viewport scale
/// reads THIS, not [webDevicePreviewEnabledNotifier], so the scale drops to
/// native 1.0 only when the frame is up — otherwise the toggle would flash a
/// big, unframed, unscaled app while the frame builds.
final ValueNotifier<bool> webDevicePreviewActiveNotifier = ValueNotifier<bool>(
  false,
);

// Kit primary. The chrome lives above the MaterialApp, so it can't read
// context.colors — mirror KasyColors.primary here. Used to highlight active
// toggles so it's obvious at a glance what's turned on.
Color _chromeAccent(bool dark) =>
    dark ? KasyColors.dark().primary : KasyColors.light().primary;

// ROADMAP: secondary controls (locale, landscape orientation, text-scale) are
// hidden for now — they'll move to a dedicated vertical toolbar later, while the
// main horizontal pill stays for quick access. Return true to bring them back
// inline. (A function, not a const, so the guarded widgets aren't dead code.)
bool _showSecondaryTools() => false;

// Poppins — the kit's typeface. Centralizes the chrome's text styling so every
// label shares the design-system font.
TextStyle _chromeText({
  required double size,
  required FontWeight weight,
  required Color color,
  double spacing = 0,
}) => GoogleFonts.poppins(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
);

/// Keyboard shortcut for toggling the web device preview chrome, formatted
/// for the current platform. Key names stay in English regardless of the
/// app locale — universal keyboard conventions.
String webDevicePreviewShortcutLabel() {
  final String mod = defaultTargetPlatform == TargetPlatform.macOS
      ? 'Command'
      : 'Ctrl';
  return '$mod + Shift + D';
}

// Platform order: 0 = iOS, 1 = Android, 2 = iPad, 3 = Desktop
const int _lastPlatformIndex = 3;

/// Frame painter placeholder for desktop viewports (never shown — desktop has no bezel).
class _DesktopNoOpFramePainter extends CustomPainter {
  const _DesktopNoOpFramePainter();
  @override
  void paint(Canvas canvas, Size size) {}
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Plain desktop viewport — no device bezel, just the breakpoint size.
DeviceInfo _kasyDesktopViewport({
  required String id,
  required String name,
  required double viewportWidth,
  required double viewportHeight,
}) {
  const double cornerRadius = 12;
  final Path screenPath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, viewportWidth, viewportHeight),
        const Radius.circular(cornerRadius),
      ),
    );
  return DeviceInfo(
    identifier: DeviceIdentifier(
      TargetPlatform.macOS,
      DeviceType.desktop,
      id,
    ),
    name: name,
    safeAreas: EdgeInsets.zero,
    screenPath: screenPath,
    pixelRatio: 1.0,
    framePainter: const _DesktopNoOpFramePainter(),
    frameSize: Size(viewportWidth, viewportHeight),
    screenSize: Size(viewportWidth, viewportHeight),
  );
}

// iOS: compact → standard → pro
final List<DeviceInfo> _iosDevices = [
  Devices.ios.iPhoneSE,
  Devices.ios.iPhone16,
  Devices.ios.iPhone16Pro,
];

// Android: compact → standard → pro
final List<DeviceInfo> _androidDevices = [
  Devices.android.samsungGalaxyA50,
  Devices.android.googlePixel9,
  Devices.android.samsungGalaxyS25,
];

// iPad: standard → pro 11" → pro 13"
final List<DeviceInfo> _iPadDevices = [
  Devices.ios.iPad,
  Devices.ios.iPadPro11Inches,
  Devices.ios.iPadPro13InchesM4,
];

// Desktop: large (1024) → design target (1280) → wide (1440, default) → full HD (1920)
final List<DeviceInfo> _desktopDevices = [
  _kasyDesktopViewport(
    id: '1024',
    name: '1024',
    viewportWidth: 1024,
    viewportHeight: 768,
  ),
  _kasyDesktopViewport(
    id: '1280',
    name: '1280',
    viewportWidth: 1280,
    viewportHeight: 800,
  ),
  _kasyDesktopViewport(
    id: '1440',
    name: '1440',
    viewportWidth: 1440,
    viewportHeight: 900,
  ),
  _kasyDesktopViewport(
    id: '1920',
    name: '1920',
    viewportWidth: 1920,
    viewportHeight: 1080,
  ),
];

class WebDevicePreview extends StatefulWidget {
  const WebDevicePreview({super.key, required this.child});

  final Widget child;

  static Widget wrap({required Widget child}) {
    if (!kIsWeb || !kDebugMode) return child;
    return WebDevicePreview(child: child);
  }

  @override
  State<WebDevicePreview> createState() => _WebDevicePreviewState();
}

class _WebDevicePreviewState extends State<WebDevicePreview>
    with WidgetsBindingObserver {
  int _platform = 0; // 0 = iOS, 1 = Android, 2 = iPad, 3 = Desktop
  int _iosIndex = 1; // default: iPhone 16
  int _androidIndex = 1; // default: Google Pixel 9
  int _iPadIndex = 0;
  int _desktopIndex = 2; // default: 1440 (wide desktop)
  bool _controlsVisible = false;
  Timer? _controlsTimer;
  String? _toast;
  bool _toastIsError = false;
  Timer? _toastTimer;
  bool _devBridgeAvailable = false;
  int _hotReloadSeq = 0;
  int _hotRestartSeq = 0;
  DevBridgeStatus? _devBridgeStatus;
  Timer? _devStatusTimer;
  // Latest app (ThemeMode) brightness, captured in build. Used to restore the
  // page/chrome background to the app theme when the preview turns OFF, without
  // an InheritedWidget lookup from a callback.
  bool _lastAppDark = false;

  final ValueNotifier<DeviceInfo> _deviceNotifier = ValueNotifier<DeviceInfo>(
    _iosDevices[1],
  ); // iPhone 16
  final ValueNotifier<bool> _frameVisibleNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _bgDarkNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _landscapeNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> _textScaleNotifier = ValueNotifier<double>(1.0);
  late final ValueNotifier<AppLocale> _localeNotifier;
  BuildContext? _screenshotContext;
  RenderRepaintBoundary? _cachedScreenshotBoundary;

  /// Extra multiplier on top of the device [DeviceInfo.pixelRatio] for exports.
  /// Native device pixel ratio (1×) is enough for crisp marketing exports.
  static const double _screenshotQualityBoost = 1.0;

  /// Chrome / Safari truncate canvases above this on one side; higher ratios
  /// produce the "tiny corner on black" glitch when the device frame is visible.
  static const double _maxScreenshotSidePx = 8192;

  static const _textScaleSteps = [1.0, 1.3, 1.5];

  List<DeviceInfo> get _devices => switch (_platform) {
    1 => _androidDevices,
    2 => _iPadDevices,
    3 => _desktopDevices,
    _ => _iosDevices,
  };

  int get _currentIndex => switch (_platform) {
    1 => _androidIndex,
    2 => _iPadIndex,
    3 => _desktopIndex,
    _ => _iosIndex,
  };

  DeviceInfo get _currentDevice => _devices[_currentIndex];

  bool get _isDesktopPlatform => _platform == 3;

  List<DeviceInfo> get _catalogDevices => <DeviceInfo>[
    ..._iosDevices,
    ..._androidDevices,
    ..._iPadDevices,
    ..._desktopDevices,
  ];

  /// Picks the framed mockup or a rectangular screen clip when the bezel is off.
  DeviceInfo _resolvePreviewDevice(DeviceInfo base) {
    if (_isDesktopPlatform || _frameVisibleNotifier.value) {
      return base;
    }
    return kasyScreenOnlyVariant(base);
  }

  void _applyPreviewDevice() {
    _deviceNotifier.value = _resolvePreviewDevice(_currentDevice);
    _scheduleScreenshotBoundaryRefresh();
  }

  void _scheduleScreenshotBoundaryRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final BuildContext? ctx = _screenshotContext;
      if (ctx == null || !ctx.mounted) {
        _cachedScreenshotBoundary = null;
        return;
      }
      _cachedScreenshotBoundary = _findDeviceFrameRepaintBoundary(ctx);
    });
  }

  /// Desktop is always frameless; mobile/tablet restore the bezel when leaving it.
  void _applyDesktopFramePolicy({int? previousPlatform}) {
    if (_isDesktopPlatform) {
      _frameVisibleNotifier.value = false;
    } else if (previousPlatform == 3) {
      _frameVisibleNotifier.value = true;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _localeNotifier = ValueNotifier<AppLocale>(
      LocaleSettings.instance.currentLocale,
    );
    // Prime the first frame from a SYNCHRONOUS prefs read BEFORE wiring the
    // listeners — otherwise the hot-restart gap (enabled resets to false, the
    // async load hasn't run yet) flashes the full app in its own theme behind
    // the device. This must run before addListener so setting the enabled
    // notifier here doesn't fire _onEnabledChanged mid-initState.
    _primeFromBootPrefs();
    webDevicePreviewEnabledNotifier.addListener(_onEnabledChanged);
    _bgDarkNotifier.addListener(_onBgChanged);
    _frameVisibleNotifier.addListener(_onFrameVisibilityChanged);
    devInspectorToastNotifier.addListener(_onInspectorToast);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    unawaited(_bootstrap());
  }

  /// Synchronously seed state from localStorage so the very first frame after a
  /// hot restart already shows the device frame in the right theme/device (web
  /// only — the stub returns null elsewhere, so everything keeps its defaults).
  /// The async [_bootstrap] still runs afterwards for the values not read here
  /// (orientation, text scale, locale) and to persist first-boot defaults.
  void _primeFromBootPrefs() {
    final platform = bootPrefInt(_platformPrefKey);
    final iosIdx = bootPrefInt(_iosIndexPrefKey);
    final androidIdx = bootPrefInt(_androidIndexPrefKey);
    final iPadIdx = bootPrefInt(_iPadIndexPrefKey);
    final desktopIdx = bootPrefInt(_desktopIndexPrefKey);
    // The resolved chrome decision we wrote on the previous run, in our own
    // stable format. Absent => fresh debug session => preview ON, light canvas.
    final chrome = readPreviewChrome();
    final enabled = chrome != 'off'; // 'dark' | 'light' | absent => on
    final bgDark = chrome == 'dark';

    if (platform != null) _platform = platform.clamp(0, _lastPlatformIndex);
    if (iosIdx != null) _iosIndex = iosIdx.clamp(0, _iosDevices.length - 1);
    if (androidIdx != null) {
      _androidIndex = androidIdx.clamp(0, _androidDevices.length - 1);
    }
    if (iPadIdx != null) _iPadIndex = iPadIdx.clamp(0, _iPadDevices.length - 1);
    if (desktopIdx != null) {
      _desktopIndex = desktopIdx.clamp(0, _desktopDevices.length - 1);
    }
    _applyDesktopFramePolicy();
    _applyPreviewDevice();
    if (enabled) _bgDarkNotifier.value = bgDark;

    if (enabled) {
      webDevicePreviewEnabledNotifier.value = true;
      // _onEnabledChanged isn't wired yet (see initState ordering), so replicate
      // the bits it would have done for an "on" start: take over the web chrome
      // background, suppress the in-app inspector pill and fade the toolbar in
      // after the frame settles.
      _syncWebChromeForPreview();
      devInspectorSuppressStatusPillNotifier.value = true;
      _controlsTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _controlsVisible = true);
      });
    }
  }

  /// While the preview is ON, the page / browser-chrome background (the colour
  /// that shows behind the device frame AND during the hot-restart flash) tracks
  /// the preview's OWN light/dark toggle, not the app's ThemeMode — so a reload
  /// obeys the device theme. When OFF, control goes back to the app theme. No-op
  /// off the web: the sync functions are stubs there.
  void _syncWebChromeForPreview() {
    if (webDevicePreviewEnabledNotifier.value) {
      final bool dark = _bgDarkNotifier.value;
      final b = dark ? Brightness.dark : Brightness.light;
      setWebBackgroundOverride(b);
      syncWebBackgroundColor(b);
      // Persist the resolved decision so the next reload (the pre-Flutter boot
      // script in index.html AND _primeFromBootPrefs) paints this same colour.
      writePreviewChrome(dark ? 'dark' : 'light');
    } else {
      setWebBackgroundOverride(null);
      syncWebBackgroundColor(_lastAppDark ? Brightness.dark : Brightness.light);
      // 'off' tells the boot readers to step aside and let the app theme drive.
      writePreviewChrome('off');
    }
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // The simulated MediaQuery below forwards the host browser's brightness;
    // rebuild so the app inside the device frame follows OS dark/light when
    // the user's theme is set to "system".
    if (mounted) setState(() {});
  }

  /// Global toggle for the device preview chrome.
  ///
  /// `Cmd/Ctrl + Shift + D` — works from anywhere (debug only). Mirrors what
  /// the close button does, persisting the choice to prefs so subsequent
  /// launches respect it.
  bool _handleKeyEvent(KeyEvent event) {
    if (!kDebugMode) return false;
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.keyD) return false;
    final HardwareKeyboard kb = HardwareKeyboard.instance;
    if (!kb.isShiftPressed) return false;
    if (!(kb.isMetaPressed || kb.isControlPressed)) return false;
    if (kb.isAltPressed) return false;
    final bool turningOn = !webDevicePreviewEnabledNotifier.value;
    webDevicePreviewEnabledNotifier.value = turningOn;
    unawaited(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(webDevicePreviewEnabledPrefKey, turningOn);
    }());
    HapticFeedback.lightImpact();
    return true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    webDevicePreviewEnabledNotifier.removeListener(_onEnabledChanged);
    _bgDarkNotifier.removeListener(_onBgChanged);
    devInspectorToastNotifier.removeListener(_onInspectorToast);
    _deviceNotifier.dispose();
    _frameVisibleNotifier.removeListener(_onFrameVisibilityChanged);
    _frameVisibleNotifier.dispose();
    _bgDarkNotifier.dispose();
    _landscapeNotifier.dispose();
    _textScaleNotifier.dispose();
    _localeNotifier.dispose();
    _controlsTimer?.cancel();
    _toastTimer?.cancel();
    _devStatusTimer?.cancel();
    super.dispose();
  }

  /// Transient confirmation pill shown in the chrome (e.g. "Image copied").
  void _showToast(String message, {bool isError = false}) {
    _toastTimer?.cancel();
    setState(() {
      _toast = message;
      _toastIsError = isError;
    });
    _toastTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  /// The DevInspector hands its "copied" message here so it renders in the same
  /// spot and size as the chrome's own toasts (instead of inside the device).
  void _onInspectorToast() {
    final msg = devInspectorToastNotifier.value;
    if (msg == null) return;
    devInspectorToastNotifier.value = null;
    if (mounted) _showToast(msg.message, isError: msg.isError);
  }

  void _onEnabledChanged() {
    // Hand the web chrome background to the preview (on) or back to the app
    // theme (off) the moment the preview is toggled.
    _syncWebChromeForPreview();
    // Our chrome already surfaces inspector state via the pill, so suppress
    // the DevInspector's in-app status pill while the preview is on.
    devInspectorSuppressStatusPillNotifier.value =
        webDevicePreviewEnabledNotifier.value;
    // Entering or leaving the device frame: drop any lingering inspector
    // selection so an old highlight doesn't carry across the transition.
    devInspectorClearSelectionTriggerNotifier.value = true;
    if (webDevicePreviewEnabledNotifier.value) {
      _controlsTimer?.cancel();
      _controlsTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _controlsVisible = true);
      });
      setState(() {}); // rebuild DevicePreview with enabled: true
      // [webDevicePreviewActiveNotifier] flips to true only once the frame is
      // actually built — see [_buildFramedContent] — so the web scale stays put
      // until then (no big-unframed-app flash during the build).
    } else {
      _controlsTimer?.cancel();
      // Leaving the frame: restore the web scale immediately.
      webDevicePreviewActiveNotifier.value = false;
      setState(() => _controlsVisible = false);
    }
  }

  void _onBgChanged() {
    // The preview's own light/dark toggle changed — repaint the web chrome to
    // match so the hot-restart flash follows it.
    _syncWebChromeForPreview();
    setState(() {});
  }

  /// Builds the app content placed INSIDE the device frame. DevicePreview calls
  /// this as it brings the framed environment up, so it doubles as the "frame is
  /// on screen now" signal: after this paints we flip
  /// [webDevicePreviewActiveNotifier], which is what lets the web viewport scale
  /// drop to native 1.0 — and only then, so the toggle never shows a flash of
  /// big, unframed, unscaled app while the frame is still building.
  Widget _buildFramedContent(BuildContext context) {
    _screenshotContext = context;
    _scheduleScreenshotBoundaryRefresh();
    if (webDevicePreviewEnabledNotifier.value &&
        !webDevicePreviewActiveNotifier.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && webDevicePreviewEnabledNotifier.value) {
          webDevicePreviewActiveNotifier.value = true;
        }
      });
    }
    return ListenableBuilder(
      listenable: _textScaleNotifier,
      builder: (ctx, _) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(
          textScaler: TextScaler.linear(_textScaleNotifier.value),
          // DevicePreview hard-codes platformBrightness to light inside the
          // simulated frame, which breaks MaterialApp's ThemeMode.system.
          // Forward the real host brightness so "system" tracks the OS.
          platformBrightness:
              WidgetsBinding.instance.platformDispatcher.platformBrightness,
        ),
        child: _DeviceSwitchBridge(
          deviceNotifier: _deviceNotifier,
          frameVisibleNotifier: _frameVisibleNotifier,
          landscapeNotifier: _landscapeNotifier,
          child: widget.child,
        ),
      ),
    );
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();

    // Default ON: previewing the mobile app inside a device frame is the
    // expected first view for this mobile-first template. Devs who prefer the
    // real desktop proportions toggle it off (shortcut), and that choice
    // persists for subsequent launches.
    final savedEnabled = prefs.getBool(webDevicePreviewEnabledPrefKey) ?? true;
    final savedPlatform = prefs.getInt(_platformPrefKey);
    final savedIosIndex = prefs.getInt(_iosIndexPrefKey);
    final savedAndroidIndex = prefs.getInt(_androidIndexPrefKey);
    final savedIPadIndex = prefs.getInt(_iPadIndexPrefKey);
    final savedDesktopIndex = prefs.getInt(_desktopIndexPrefKey);
    final savedBgDark = prefs.getBool(_bgDarkPrefKey);
    final savedLandscape = prefs.getBool(_landscapePrefKey);
    final savedTextScale = prefs.getDouble(_textScalePrefKey);

    if (!mounted) return;
    setState(() {
      if (savedPlatform != null) {
        _platform = savedPlatform.clamp(0, _lastPlatformIndex);
      }
      if (savedIosIndex != null) {
        _iosIndex = savedIosIndex.clamp(0, _iosDevices.length - 1);
      }
      if (savedAndroidIndex != null) {
        _androidIndex = savedAndroidIndex.clamp(0, _androidDevices.length - 1);
      }
      if (savedIPadIndex != null) {
        _iPadIndex = savedIPadIndex.clamp(0, _iPadDevices.length - 1);
      }
      if (savedDesktopIndex != null) {
        _desktopIndex = savedDesktopIndex.clamp(0, _desktopDevices.length - 1);
      }
    });
    _applyDesktopFramePolicy();
    _applyPreviewDevice();
    if (savedBgDark != null) _bgDarkNotifier.value = savedBgDark;
    if (savedLandscape != null) _landscapeNotifier.value = savedLandscape;
    if (savedTextScale != null && _textScaleSteps.contains(savedTextScale)) {
      _textScaleNotifier.value = savedTextScale;
    }
    if (savedEnabled) webDevicePreviewEnabledNotifier.value = true;

    // Reconcile the self-owned chrome boot hint with the canonical (async) prefs
    // now that they're loaded — covers a first-ever boot (no hint written yet)
    // and keeps the hint in step with the real enabled/background state.
    _syncWebChromeForPreview();
    if (kDebugMode && kIsWeb) {
      unawaited(_probeDevBridge());
      _startDevStatusPolling();
    }
  }

  void _startDevStatusPolling() {
    _devStatusTimer?.cancel();
    _devStatusTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) => unawaited(_pollDevBridgeStatus()),
    );
  }

  Future<void> _pollDevBridgeStatus() async {
    final DevBridgeStatus status = await fetchDevBridgeStatus(_devBridgePort);
    if (!mounted) return;
    setState(() {
      _devBridgeAvailable = status.available;
      _devBridgeStatus = status.available ? status : null;
    });
  }

  int get _devBridgePort {
    final int appPort = Uri.base.port == 0 ? 5555 : Uri.base.port;
    return devBridgePortForAppPort(appPort);
  }

  Future<void> _probeDevBridge() async {
    final DevBridgeStatus status = await fetchDevBridgeStatus(_devBridgePort);
    if (mounted) {
      setState(() {
        _devBridgeAvailable = status.available;
        _devBridgeStatus = status.available ? status : null;
      });
    }
  }

  Future<void> _hotReload() async {
    final previewT = Translations.of(context).webDevicePreview;
    if (!_devBridgeAvailable) {
      await _probeDevBridge();
      if (!mounted) return;
      if (!_devBridgeAvailable) {
        _showToast(previewT.devBridgeUnavailable, isError: true);
        return;
      }
    }
    final int seq = ++_hotReloadSeq;
    _showToast(previewT.hotReloading);
    final DevReloadResult result = await requestDevReload(_devBridgePort);
    if (!mounted || seq != _hotReloadSeq) return;
    if (!result.available) {
      setState(() => _devBridgeAvailable = false);
      _showToast(previewT.devBridgeUnavailable, isError: true);
      return;
    }
    if (result.ok) {
      setState(() {
        _devBridgeStatus = const DevBridgeStatus(
          available: true,
          ready: true,
          hasError: false,
        );
      });
      _showToast(
        result.message.isNotEmpty ? result.message : previewT.hotReloadDone,
      );
    } else {
      if (result.compileError || result.needsRestart) {
        setState(() {
          _devBridgeStatus = const DevBridgeStatus(
            available: true,
            ready: true,
            hasError: true,
          );
        });
      }
      _showToast(
        result.needsRestart
            ? previewT.hotReloadNeedsRestart
            : result.compileError
            ? previewT.hotReloadCompileError
            : result.message.isNotEmpty
            ? result.message
            : previewT.hotReloadFailed,
        isError: true,
      );
    }
  }

  Future<void> _hotRestart() async {
    final previewT = Translations.of(context).webDevicePreview;
    if (!_devBridgeAvailable) {
      await _probeDevBridge();
      if (!mounted) return;
      if (!_devBridgeAvailable) {
        _showToast(previewT.devBridgeUnavailable, isError: true);
        return;
      }
    }
    final int seq = ++_hotRestartSeq;
    _showToast(previewT.hotRestarting);
    final DevReloadResult result = await requestDevRestart(_devBridgePort);
    if (!mounted || seq != _hotRestartSeq) return;
    if (!result.available) {
      setState(() => _devBridgeAvailable = false);
      _showToast(previewT.devBridgeUnavailable, isError: true);
      return;
    }
    if (result.ok) {
      setState(() {
        _devBridgeStatus = const DevBridgeStatus(
          available: true,
          ready: true,
          hasError: false,
        );
      });
      _showToast(
        result.message.isNotEmpty ? result.message : previewT.hotRestartDone,
      );
    } else {
      if (result.compileError) {
        setState(() {
          _devBridgeStatus = const DevBridgeStatus(
            available: true,
            ready: true,
            hasError: true,
          );
        });
      }
      _showToast(
        result.compileError
            ? previewT.hotRestartCompileError
            : result.message.isNotEmpty
            ? result.message
            : previewT.hotRestartFailed,
        isError: true,
      );
    }
  }

  Future<void> _close() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(webDevicePreviewEnabledPrefKey, false);
    webDevicePreviewEnabledNotifier.value = false;
  }

  Future<void> _savePlatform() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_platformPrefKey, _platform);
  }

  Future<void> _saveDeviceIndices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_iosIndexPrefKey, _iosIndex);
    await prefs.setInt(_androidIndexPrefKey, _androidIndex);
    await prefs.setInt(_iPadIndexPrefKey, _iPadIndex);
    await prefs.setInt(_desktopIndexPrefKey, _desktopIndex);
  }

  Future<void> _saveBgDark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bgDarkPrefKey, _bgDarkNotifier.value);
  }

  Future<void> _saveLandscape() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_landscapePrefKey, _landscapeNotifier.value);
  }

  Future<void> _saveTextScale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScalePrefKey, _textScaleNotifier.value);
  }

  Future<void> _saveLocale(AppLocale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale.languageCode);
  }

  void _setPlatform(int p) {
    final int previousPlatform = _platform;
    setState(() {
      _platform = p;
      // Choosing a platform always lands on its default device:
      // iPad → plain iPad, Android → Samsung Galaxy A50, Desktop → 1440.
      if (p == 1) _androidIndex = 0;
      if (p == 2) _iPadIndex = 0;
      if (p == 3) _desktopIndex = 2;
    });
    _applyDesktopFramePolicy(previousPlatform: previousPlatform);
    _applyPreviewDevice();
    unawaited(_savePlatform());
    if (p == 1 || p == 2 || p == 3) unawaited(_saveDeviceIndices());
  }

  void _toggleFrame() {
    if (_isDesktopPlatform) return;
    _frameVisibleNotifier.value = !_frameVisibleNotifier.value;
    _applyPreviewDevice();
  }

  void _onFrameVisibilityChanged() {
    _applyPreviewDevice();
  }

  void _toggleBg() {
    _bgDarkNotifier.value = !_bgDarkNotifier.value;
    unawaited(_saveBgDark());
  }

  void _toggleInspector() {
    devInspectorActiveNotifier.value = !devInspectorActiveNotifier.value;
  }

  void _toggleLandscape() {
    _landscapeNotifier.value = !_landscapeNotifier.value;
    unawaited(_saveLandscape());
  }

  void _cycleTextScale() {
    final idx = _textScaleSteps.indexWhere(
      (s) => (s - _textScaleNotifier.value).abs() < 0.01,
    );
    _textScaleNotifier.value =
        _textScaleSteps[(idx + 1) % _textScaleSteps.length];
    unawaited(_saveTextScale());
  }

  void _cycleLocale() {
    const locales = AppLocale.values;
    final idx = locales.indexOf(_localeNotifier.value);
    final next = locales[(idx + 1) % locales.length];
    LocaleSettings.setLocale(next);
    unawaited(Jiffy.setLocale(next.languageCode));
    _localeNotifier.value = next;
    unawaited(_saveLocale(next));
  }

  Future<void> _takeScreenshot() async {
    final BuildContext? ctx = _screenshotContext;
    if (ctx == null || !ctx.mounted) return;
    final RenderRepaintBoundary? boundary =
        _cachedScreenshotBoundary ?? _findDeviceFrameRepaintBoundary(ctx);
    if (boundary == null) return;
    final DevicePreviewStore store = Provider.of<DevicePreviewStore>(
      ctx,
      listen: false,
    );
    final double exportRatio = _cappedExportPixelRatio(
      device: store.deviceInfo,
      boundary: boundary,
    );
    final ui.Image image = await boundary.toImage(pixelRatio: exportRatio);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    if (byteData == null || !mounted) return;
    final Uint8List bytes = byteData.buffer.asUint8List();
    final PngExportResult result = await copyOrDownloadPng(bytes);
    if (!mounted) return;
    switch (result) {
      case PngExportResult.copied:
        _showToast(t.webDevicePreview.imageCopied);
      case PngExportResult.downloaded:
        _showToast(t.webDevicePreview.imageDownloaded);
      case PngExportResult.unavailable:
        break;
    }
  }

  /// The [RepaintBoundary] that wraps [DeviceFrame] inside [DevicePreview].
  /// Capturing it yields only the device (or screen-only when the frame is off),
  /// without canvas padding or the toolbar.
  RenderRepaintBoundary? _findDeviceFrameRepaintBoundary(BuildContext context) {
    Element? deviceFrameHost;
    context.visitAncestorElements((Element element) {
      if (element.widget is DeviceFrame) {
        deviceFrameHost = element;
        return false;
      }
      return true;
    });
    if (deviceFrameHost == null) return null;
    RenderRepaintBoundary? boundary;
    deviceFrameHost!.visitAncestorElements((Element element) {
      if (element.widget is RepaintBoundary) {
        final RenderObject? renderObject = element.renderObject;
        if (renderObject is RenderRepaintBoundary) {
          boundary = renderObject;
          return false;
        }
      }
      return true;
    });
    return boundary;
  }

  double _cappedExportPixelRatio({
    required DeviceInfo device,
    required RenderRepaintBoundary boundary,
  }) {
    final double desired = device.pixelRatio * _screenshotQualityBoost;
    final Size logicalSize = boundary.size;
    final double maxSide = math.max(
      logicalSize.width * desired,
      logicalSize.height * desired,
    );
    if (maxSide <= _maxScreenshotSidePx) {
      return desired;
    }
    return desired * (_maxScreenshotSidePx / maxSide);
  }

  void _next() {
    setState(() {
      switch (_platform) {
        case 1:
          _androidIndex = (_androidIndex + 1) % _androidDevices.length;
        case 2:
          _iPadIndex = (_iPadIndex + 1) % _iPadDevices.length;
        case 3:
          _desktopIndex = (_desktopIndex + 1) % _desktopDevices.length;
        default:
          _iosIndex = (_iosIndex + 1) % _iosDevices.length;
      }
    });
    _applyPreviewDevice();
    unawaited(_saveDeviceIndices());
  }

  @override
  Widget build(BuildContext context) {
    final enabled = webDevicePreviewEnabledNotifier.value;

    // App theme (light/dark) lives in ThemeProvider, which sits ABOVE this
    // widget — reading it here rebuilds the toolbar when the theme flips.
    final AppTheme appTheme = ThemeProvider.of(context);
    final bool appDark = appTheme.effectiveMode == ThemeMode.dark;
    // Remember it so _syncWebChromeForPreview can restore the app-theme chrome
    // when the preview is turned off (no InheritedWidget lookup from a callback).
    _lastAppDark = appDark;

    // ThemeData.light() in Flutter 3.x M3 uses a lavender-tinted surface.
    // Passing backgroundColor directly avoids that and gives us an exact color.
    final canvasColor = _bgDarkNotifier.value
        ? const Color(0xFF1C1C1E)
        : Colors.white;

    final preview = DevicePreview(
      enabled: enabled,
      isToolbarVisible: false,
      backgroundColor: canvasColor,
      // Reserve room at the top so the floating toolbar never sits on the device.
      // DevicePreview fills the whole viewport, so this is the single source of
      // background — there is no second surface that could create a seam.
      padding: enabled
          ? const EdgeInsets.only(top: 56, left: 20, right: 20, bottom: 20)
          : null,
      storage: DevicePreviewStorage.none(),
      defaultDevice: _resolvePreviewDevice(_currentDevice),
      devices: kasyAllPreviewDevices(_catalogDevices),
      builder: _buildFramedContent,
    );

    if (!enabled) return preview;

    return TapRegionSurface(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            // DevicePreview paints the entire viewport (single background, no
            // seam). The device frame is pushed below the toolbar by the top
            // padding above, so the toolbar never overlaps it.
            preview,
            // Inspector highlight drawn ABOVE the device frame so widgets that
            // hug the viewport edges (AppBar, bottom nav, …) keep a full border.
            const Positioned.fill(
              child: IgnorePointer(child: _DevInspectorExternalHighlight()),
            ),
            // Floating toolbar — overlaid at the top, centered. Opening its
            // dropdowns never pushes or resizes the device (they overlay).
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _controlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: IgnorePointer(
                  ignoring: !_controlsVisible,
                  child: Center(
                    child: ListenableBuilder(
                      listenable: Listenable.merge([
                        _frameVisibleNotifier,
                        _bgDarkNotifier,
                        _landscapeNotifier,
                        _textScaleNotifier,
                        _localeNotifier,
                        devInspectorActiveNotifier,
                      ]),
                      builder: (context, child) => _PreviewControls(
                        platform: _platform,
                        deviceName: _currentDevice.name,
                        dark: _bgDarkNotifier.value,
                        appDark: appDark,
                        onToggleAppTheme: appTheme.toggle,
                        frameVisible: _frameVisibleNotifier.value,
                        isLandscape: _landscapeNotifier.value,
                        textScale: _textScaleNotifier.value,
                        currentLocale: _localeNotifier.value,
                        inspectorEnabled: devInspectorActiveNotifier.value,
                        onPlatformChanged: _setPlatform,
                        onNext: _next,
                        onToggleFrame: _toggleFrame,
                        onToggleLandscape: _toggleLandscape,
                        onCycleTextScale: _cycleTextScale,
                        onCycleLocale: _cycleLocale,
                        onToggleInspector: _toggleInspector,
                        onScreenshot: () => unawaited(_takeScreenshot()),
                        onHotReload: () => unawaited(_hotReload()),
                        onHotRestart: () => unawaited(_hotRestart()),
                        onClose: () => unawaited(_close()),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Theme toggle — standalone sun/moon button pinned to the
            // bottom-right corner, independent of the toolbar.
            Positioned(
              bottom: 10,
              right: 10,
              child: AnimatedOpacity(
                opacity: _controlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: IgnorePointer(
                  ignoring: !_controlsVisible,
                  child: ListenableBuilder(
                    listenable: _bgDarkNotifier,
                    builder: (context, child) => _ThemeCornerButton(
                      dark: _bgDarkNotifier.value,
                      onTap: _toggleBg,
                    ),
                  ),
                ),
              ),
            ),
            // Terminal status — bare pulsing dot bottom-left (green / red).
            Positioned(
              bottom: 14,
              left: 14,
              child: AnimatedOpacity(
                opacity: _controlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: IgnorePointer(
                  child: ListenableBuilder(
                    listenable: _bgDarkNotifier,
                    builder: (context, child) {
                      final previewT = Translations.of(context).webDevicePreview;
                      final DevBridgeStatus? status = _devBridgeStatus;
                      final String tooltip = status == null || !status.available
                          ? previewT.terminalStatusOffline
                          : status.hasError
                          ? previewT.terminalStatusError
                          : previewT.terminalStatusOk;
                      return _TerminalStatusDot(
                        dark: _bgDarkNotifier.value,
                        status: _devBridgeStatus,
                        tooltip: tooltip,
                      );
                    },
                  ),
                ),
              ),
            ),
            // Transient confirmation toast (e.g. screenshot copied).
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _toast == null
                        ? const SizedBox.shrink()
                        : _Toast(
                            key: ValueKey(_toast),
                            message: _toast!,
                            isError: _toastIsError,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bridge — inside DevicePreview.builder, has DevicePreviewStore in context.
// ---------------------------------------------------------------------------

class _DeviceSwitchBridge extends StatefulWidget {
  const _DeviceSwitchBridge({
    required this.deviceNotifier,
    required this.frameVisibleNotifier,
    required this.landscapeNotifier,
    required this.child,
  });

  final ValueNotifier<DeviceInfo> deviceNotifier;
  final ValueNotifier<bool> frameVisibleNotifier;
  final ValueNotifier<bool> landscapeNotifier;
  final Widget child;

  @override
  State<_DeviceSwitchBridge> createState() => _DeviceSwitchBridgeState();
}

class _DeviceSwitchBridgeState extends State<_DeviceSwitchBridge> {
  // _syncOrientation retries on the next frame while the DevicePreview store is
  // still mounting/initializing; cap the retries so it can never spin forever.
  int _syncRetries = 0;
  static const int _maxSyncRetries = 120;

  @override
  void initState() {
    super.initState();
    widget.deviceNotifier.addListener(_onDeviceChanged);
    widget.frameVisibleNotifier.addListener(_onFrameVisibleChanged);
    widget.landscapeNotifier.addListener(_onOrientationChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncOrientation());
  }

  @override
  void dispose() {
    widget.deviceNotifier.removeListener(_onDeviceChanged);
    widget.frameVisibleNotifier.removeListener(_onFrameVisibleChanged);
    widget.landscapeNotifier.removeListener(_onOrientationChanged);
    super.dispose();
  }

  void _onDeviceChanged() {
    if (!mounted) return;
    DevicePreview.selectDevice(context, widget.deviceNotifier.value.identifier);
  }

  void _onFrameVisibleChanged() {
    final store = _store();
    if (store == null) return;
    final data = _readData(store);
    if (data == null) return;
    if (data.isFrameVisible != widget.frameVisibleNotifier.value) {
      store.toggleFrame();
    }
  }

  void _onOrientationChanged() => _syncOrientation();

  void _syncOrientation() {
    final store = _store();
    final data = store == null ? null : _readData(store);
    if (store == null || data == null) {
      // DevicePreview mounts its store asynchronously: on the first web frames the
      // provider may not be in the tree yet (ProviderNotFound) or the store may be
      // uninitialized (reading .data throws "Not initialized"). Retry on the next
      // frame instead of surfacing a scary (and harmless) exception. Capped so it
      // can never spin forever.
      if (mounted && _syncRetries < _maxSyncRetries) {
        _syncRetries++;
        WidgetsBinding.instance.addPostFrameCallback((_) => _syncOrientation());
      }
      return;
    }
    _syncRetries = 0;
    final target = widget.landscapeNotifier.value
        ? Orientation.landscape
        : Orientation.portrait;
    if (data.orientation != target) {
      store.data = data.copyWith(orientation: target);
    }
  }

  /// The DevicePreview store, or null if it isn't in the tree yet — `Provider.of`
  /// throws ProviderNotFound on the first web frames before DevicePreview mounts it.
  DevicePreviewStore? _store() {
    if (!mounted) return null;
    try {
      return Provider.of<DevicePreviewStore>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  /// [DevicePreviewStore.data] throws "Not initialized" while the store finishes its
  /// async init. Returns null instead so callers can skip or retry cleanly.
  DevicePreviewData? _readData(DevicePreviewStore store) {
    try {
      return store.data;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ---------------------------------------------------------------------------
// Controls pill — StatefulWidget so the platform dropdown can self-manage.
// ---------------------------------------------------------------------------

class _PreviewControls extends StatefulWidget {
  const _PreviewControls({
    required this.platform,
    required this.deviceName,
    required this.dark,
    required this.appDark,
    required this.onToggleAppTheme,
    required this.frameVisible,
    required this.isLandscape,
    required this.textScale,
    required this.currentLocale,
    required this.inspectorEnabled,
    required this.onPlatformChanged,
    required this.onNext,
    required this.onToggleFrame,
    required this.onToggleLandscape,
    required this.onCycleTextScale,
    required this.onCycleLocale,
    required this.onToggleInspector,
    required this.onScreenshot,
    required this.onHotReload,
    required this.onHotRestart,
    required this.onClose,
  });

  final int platform;
  final String deviceName;
  final bool dark;

  /// App theme (light/dark) state + toggle — flips the real app ThemeMode.
  final bool appDark;
  final VoidCallback onToggleAppTheme;

  final bool frameVisible;
  final bool isLandscape;
  final double textScale;
  final AppLocale currentLocale;
  final bool inspectorEnabled;
  final ValueChanged<int> onPlatformChanged;
  final VoidCallback onNext;
  final VoidCallback onToggleFrame;
  final VoidCallback onToggleLandscape;
  final VoidCallback onCycleTextScale;
  final VoidCallback onCycleLocale;
  final VoidCallback onToggleInspector;
  final VoidCallback onScreenshot;
  final VoidCallback onHotReload;
  final VoidCallback onHotRestart;
  final VoidCallback onClose;

  @override
  State<_PreviewControls> createState() => _PreviewControlsState();
}

class _PreviewControlsState extends State<_PreviewControls> {
  bool _menuOpen = false;
  bool _platformBtnHovered = false;
  bool _deviceBtnHovered = false;

  static const _platformLabels = ['iOS', 'Android', 'iPad', 'Desktop'];

  // Color scheme adapts to the preview theme: dark pill (white content) in dark
  // mode, white pill (dark content) in light mode.
  Color get _pillColor => widget.dark ? const Color(0xFF2C2C2E) : Colors.white;
  Color get _menuColor => widget.dark ? const Color(0xFF3A3A3C) : Colors.white;
  // Foreground (text/icons) base — alphas are derived from this.
  Color get _fg => widget.dark ? Colors.white : const Color(0xFF1C1C1E);
  // Selected-tool fill — Kasy primary for the current chrome theme.
  Color get _accent => _chromeAccent(widget.dark);

  BoxDecoration get _pillDecoration => BoxDecoration(
    color: _pillColor,
    borderRadius: const BorderRadius.all(Radius.circular(24)),
  );

  // Tight, low-spread shadow: enough to lift the pill off the canvas without
  // casting a wide smudge below it that reads as a horizontal "division" line.
  static const _pillShadow = [
    BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static String _textScaleLabel(double scale) => switch (scale) {
    1.0 => '1×',
    1.3 => '1.3×',
    _ => '1.5×',
  };

  void _toggleMenu() => setState(() => _menuOpen = !_menuOpen);

  void _selectPlatform(int i) {
    widget.onPlatformChanged(i);
    setState(() => _menuOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) {
        if (_menuOpen) setState(() => _menuOpen = false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              boxShadow: _pillShadow,
            ),
            child: _buildPill(),
          ),
          if (_menuOpen) _buildMenu(),
        ],
      ),
    );
  }

  Widget _buildPill() {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: _pillDecoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Platform selector button
          MouseRegion(
            onEnter: (_) => setState(() => _platformBtnHovered = true),
            onExit: (_) => setState(() => _platformBtnHovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _toggleMenu,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  // No resting fill — it just alternates platforms. Subtle fill
                  // only while open or hovered.
                  color: _fg.withValues(
                    alpha: _menuOpen
                        ? 0.16
                        : (_platformBtnHovered ? 0.12 : 0.0),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _platformLabels[widget.platform],
                      style: _chromeText(
                        size: 12,
                        weight: FontWeight.w600,
                        color: _fg,
                      ),
                    ),
                    const SizedBox(width: 2),
                    AnimatedRotation(
                      turns: _menuOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 160),
                      child: Icon(KasyIcons.chevronDown, color: _fg, size: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _VerticalDivider(base: _fg),
          // Tapping the name cycles to the next device — no side chevrons, saves
          // space (same pattern as the locale cycler).
          MouseRegion(
            onEnter: (_) => setState(() => _deviceBtnHovered = true),
            onExit: (_) => setState(() => _deviceBtnHovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onNext,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: _fg.withValues(alpha: _deviceBtnHovered ? 0.12 : 0.0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.deviceName,
                  style: _chromeText(
                    size: 12,
                    weight: FontWeight.w500,
                    color: _fg,
                    spacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
          // Locale chip — hidden for now (see ROADMAP: moves to vertical bar).
          if (_showSecondaryTools()) ...[
            _VerticalDivider(base: _fg),
            _PillChip(
              label: widget.currentLocale.languageCode.toUpperCase(),
              onTap: widget.onCycleLocale,
              base: _fg,
              accent: _accent,
            ),
          ],
          // Tools, all inline (no dropdown).
          _VerticalDivider(base: _fg),
          // Frame toggle — mobile/tablet only; desktop is always frameless.
          if (widget.platform != 3) ...[
            _IconBtn(
              icon: widget.frameVisible
                  ? KasyIcons.deviceFrame
                  : KasyIcons.deviceFrameOff,
              onTap: widget.onToggleFrame,
              base: _fg,
              color: _fg,
              accent: _accent,
            ),
          ],
          // App theme switch (light/dark of the app inside the device). Mode
          // switch like frame — the sun/moon icon flips, so no accent fill.
          _IconBtn(
            icon: widget.appDark ? KasyIcons.darkMode : KasyIcons.lightMode,
            onTap: widget.onToggleAppTheme,
            base: _fg,
            color: _fg,
            accent: _accent,
          ),
          // Orientation + text-scale hidden for now (see ROADMAP flag).
          if (_showSecondaryTools()) ...[
            _IconBtn(
              icon: widget.isLandscape
                  ? KasyIcons.landscape
                  : KasyIcons.portrait,
              onTap: widget.onToggleLandscape,
              base: _fg,
              active: widget.isLandscape,
              color: _fg,
              accent: _accent,
            ),
            _PillChip(
              label: _textScaleLabel(widget.textScale),
              onTap: widget.onCycleTextScale,
              base: _fg,
              active: widget.textScale != 1.0,
              accent: _accent,
            ),
          ],
          _IconBtn(
            icon: KasyIcons.cameraAlt,
            onTap: widget.onScreenshot,
            base: _fg,
            color: _fg,
            accent: _accent,
          ),
          // Inspector
          _VerticalDivider(base: _fg),
          _IconBtn(
            icon: KasyIcons.inspector,
            onTap: widget.onToggleInspector,
            base: _fg,
            active: widget.inspectorEnabled,
            color: _fg,
            accent: _accent,
          ),
          // Hot reload / restart — own group, separate from inspector.
          _VerticalDivider(base: _fg),
          _LetterBtn(
            label: 'r',
            onTap: widget.onHotReload,
            base: _fg,
          ),
          _LetterBtn(
            label: 'R',
            onTap: widget.onHotRestart,
            base: _fg,
          ),
          // Close
          _VerticalDivider(base: _fg),
          _IconBtn(
            icon: KasyIcons.close,
            onTap: widget.onClose,
            base: _fg,
            color: _fg,
            accent: _accent,
          ),
          const SizedBox(width: 2),
        ],
      ),
    );
  }

  Widget _buildMenu() {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: _menuColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.dark ? 0.4 : 0.18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_platformLabels.length, (i) {
            final selected = widget.platform == i;
            return _DropdownItem(
              label: _platformLabels[i],
              selected: selected,
              base: _fg,
              onTap: () => _selectPlatform(i),
            );
          }),
        ),
      ),
    );
  }
}

class _DropdownItem extends StatefulWidget {
  const _DropdownItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.base = Colors.white,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color base;

  @override
  State<_DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<_DropdownItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: _hovered
              ? widget.base.withValues(alpha: 0.10)
              : Colors.transparent,
          child: Text(
            widget.label,
            style: _chromeText(
              size: 13,
              weight: widget.selected ? FontWeight.w600 : FontWeight.w400,
              color: widget.selected
                  ? widget.base
                  : widget.base.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillChip extends StatefulWidget {
  const _PillChip({
    required this.label,
    required this.onTap,
    this.base = Colors.white,
    this.active = false,
    required this.accent,
  });

  final String label;
  final VoidCallback onTap;
  final Color base;

  /// When true the chip reads as "non-default" (accent tint + accent text).
  final bool active;

  /// Selected fill — Kasy primary for the current chrome theme.
  final Color accent;

  @override
  State<_PillChip> createState() => _PillChipState();
}

class _PillChipState extends State<_PillChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool on = widget.active;
    final Color textColor = on ? Colors.white : widget.base;
    // No resting fill — it just cycles a value. Solid accent when active,
    // subtle fill only on hover otherwise.
    final Color bg = on
        ? (_hovered ? widget.accent.withValues(alpha: 0.85) : widget.accent)
        : (_hovered ? widget.base.withValues(alpha: 0.14) : Colors.transparent);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.label,
            style: _chromeText(
              size: 11,
              weight: FontWeight.w600,
              color: textColor,
              spacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small confirmation pill shown briefly in the chrome (e.g. after a screenshot
/// is copied). Dark, frosted, centered near the bottom.
class _Toast extends StatelessWidget {
  const _Toast({super.key, required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF02C2C2E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? KasyIcons.error : KasyIcons.checkCircle,
              color: isError
                  ? const Color(0xFFFF453A)
                  : const Color(0xFF34C759),
              size: 15,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: _chromeText(
                size: 12,
                weight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone sun/moon theme toggle pinned to the top-right corner. Switches
/// the preview canvas between light (sun) and dark (moon).
class _ChromeHoverHint extends StatefulWidget {
  const _ChromeHoverHint({
    required this.message,
    required this.child,
    this.placement = _ChromeHoverHintPlacement.below,
  });

  final String message;
  final Widget child;
  final _ChromeHoverHintPlacement placement;

  @override
  State<_ChromeHoverHint> createState() => _ChromeHoverHintState();
}

enum _ChromeHoverHintPlacement { below, above }

class _ChromeHoverHintState extends State<_ChromeHoverHint> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          if (_hovered)
            Positioned(
              top: widget.placement == _ChromeHoverHintPlacement.below ? 34 : null,
              bottom: widget.placement == _ChromeHoverHintPlacement.above ? 34 : null,
              left: 0,
              right: 0,
              child: Align(
                child: _ChromeHoverHintBubble(message: widget.message),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChromeHoverHintBubble extends StatelessWidget {
  const _ChromeHoverHintBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF02C2C2E),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          message,
          style: _chromeText(size: 11, weight: FontWeight.w500, color: Colors.white),
        ),
      ),
    );
  }
}

class _TerminalStatusDot extends StatefulWidget {
  const _TerminalStatusDot({
    required this.dark,
    required this.status,
    required this.tooltip,
  });

  final bool dark;
  final DevBridgeStatus? status;
  final String tooltip;

  @override
  State<_TerminalStatusDot> createState() => _TerminalStatusDotState();
}

class _TerminalStatusDotState extends State<_TerminalStatusDot>
    with SingleTickerProviderStateMixin {
  // Dark canvas: neon green + light vivid red. Light canvas: slightly deeper tones.
  static const Color _okDark = Color(0xFF3DFF7A);
  static const Color _errorDark = Color(0xFFFF6B63);
  static const Color _okLight = Color(0xFF28A745);
  static const Color _errorLight = Color(0xFFE02828);

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Color? get _dotColor {
    final DevBridgeStatus? status = widget.status;
    if (status == null || !status.available) return null;
    if (status.hasError) {
      return widget.dark ? _errorDark : _errorLight;
    }
    return widget.dark ? _okDark : _okLight;
  }

  @override
  Widget build(BuildContext context) {
    final Color? color = _dotColor;
    if (color == null) return const SizedBox.shrink();

    return _ChromeHoverHint(
      message: widget.tooltip,
      placement: _ChromeHoverHintPlacement.above,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (BuildContext context, Widget? child) {
          final double pulse = 0.5 + (_pulse.value * 0.5);
          final double glow = widget.dark ? 0.55 : 0.4;
          return Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: pulse),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: glow * pulse),
                  blurRadius: widget.dark ? 8 : 6,
                  spreadRadius: widget.dark ? 1.5 : 1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ThemeCornerButton extends StatefulWidget {
  const _ThemeCornerButton({required this.dark, required this.onTap});

  final bool dark;
  final VoidCallback onTap;

  @override
  State<_ThemeCornerButton> createState() => _ThemeCornerButtonState();
}

class _ThemeCornerButtonState extends State<_ThemeCornerButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // Light mode (sun): white fill, dark icon. Dark mode (moon): dark fill,
    // white icon. Both keep a subtle drop shadow to lift the button.
    final Color fill = widget.dark ? const Color(0xFF2C2C2E) : Colors.white;
    final Color iconColor = widget.dark
        ? Colors.white
        : const Color(0xFF1C1C1E);
    final Color hoverOverlay = widget.dark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _hovered ? hoverOverlay : Colors.transparent,
            ),
            child: Icon(
              widget.dark ? KasyIcons.darkMode : KasyIcons.lightMode,
              color: iconColor,
              size: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({this.base = Colors.white});

  final Color base;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 18,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: base.withValues(alpha: 0.12),
    );
  }
}

class _LetterBtn extends StatefulWidget {
  const _LetterBtn({
    required this.label,
    required this.onTap,
    this.base = Colors.white,
  });

  final String label;
  final VoidCallback onTap;
  final Color base;

  @override
  State<_LetterBtn> createState() => _LetterBtnState();
}

class _LetterBtnState extends State<_LetterBtn> {
  static const double _iconSize = 15;
  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 5, vertical: 5);

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.base;
    final Color bg = _hovered
        ? widget.base.withValues(alpha: 0.12)
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: _padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: Align(
              child: SizedBox(
                width: _iconSize,
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: _chromeText(
                    size: 12,
                    weight: FontWeight.w600,
                    color: textColor,
                  ).copyWith(height: 1),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatefulWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.color = Colors.white60,
    this.base = Colors.white,
    this.active = false,
    required this.accent,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color base;

  /// When true the button reads as "on": accent-tinted fill + accent icon.
  final bool active;

  /// Selected fill — Kasy primary for the current chrome theme.
  final Color accent;

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  static const double _iconSize = 15;
  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 5, vertical: 5);

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool on = widget.active;
    // Active: solid accent fill + white icon (filled-button contrast). Inactive:
    // solid foreground icon (no muted grays), background only on hover.
    final Color iconColor = on ? Colors.white : widget.color;
    final Color bg = on
        ? (_hovered ? widget.accent.withValues(alpha: 0.85) : widget.accent)
        : (_hovered ? widget.base.withValues(alpha: 0.12) : Colors.transparent);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: _padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon, color: iconColor, size: _iconSize),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// External inspector highlight — draws the DevInspector selection rect ABOVE
// the simulated device frame so widgets that hug the viewport edges keep a
// complete, uncropped border. Listens to the global rect notifier published
// by DevInspector.
// ---------------------------------------------------------------------------

class _DevInspectorExternalHighlight extends StatelessWidget {
  const _DevInspectorExternalHighlight();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Rect?>(
      valueListenable: devInspectorHighlightGlobalRect,
      builder: (BuildContext context, Rect? rect, Widget? _) {
        if (rect == null || rect.isEmpty) return const SizedBox.shrink();
        return CustomPaint(
          painter: _ExternalHighlightPainter(rect: rect),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ExternalHighlightPainter extends CustomPainter {
  _ExternalHighlightPainter({required this.rect});

  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    if (rect.isEmpty) return;
    final Paint paint = Paint()
      ..color = devInspectorHighlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = devInspectorHighlightStrokeWidth;
    final Rect outer = rect.inflate(devInspectorHighlightStrokeWidth / 2);
    final RRect rrect = RRect.fromRectAndRadius(
      outer,
      const Radius.circular(devInspectorHighlightCornerRadius),
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_ExternalHighlightPainter old) => old.rect != rect;
}
