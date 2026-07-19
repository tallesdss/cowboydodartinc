import 'package:cowboydodartinc/core/theme/colors.dart';
import 'package:cowboydodartinc/core/theme/providers/kasy_theme.dart';
import 'package:cowboydodartinc/core/theme/texts.dart';
import 'package:cowboydodartinc/core/theme/theme_data/theme_data_factory.dart';
import 'package:cowboydodartinc/core/theme/web_background_sync.dart'
    if (dart.library.js_interop) 'package:cowboydodartinc/core/theme/web_background_sync_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// We use this to access the theme from the BuildContext in all our widgets
/// We don't use riverpod here so we can get the theme from the context and regular widgets
class ThemeProvider extends InheritedNotifier<AppTheme> {
  const ThemeProvider({
    super.key,
    super.notifier,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant InheritedNotifier<AppTheme> oldWidget) {
    return oldWidget.notifier != notifier ||
        oldWidget.notifier?.mode != notifier?.mode;
  }

  static AppTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!.notifier!;
}

/// This is the main theme provider
/// There is two main ways to use it
/// uniform: you define a single theme for all platforms
/// adaptive: you define different themes for different platforms
///
/// Defining a theme for light and dark should only change the colors
/// not redefining everything. (see ./docs/theme.md)
class AppTheme with ChangeNotifier, WidgetsBindingObserver {
  final KasyTheme? lightTheme;
  final KasyTheme? darkTheme;
  final SharedPreferences sharedPreferences;
  ThemeMode mode;

  AppTheme({
    required this.sharedPreferences,
    required this.mode,
    this.lightTheme,
    this.darkTheme,
  }) {
    mode = _loadFromPrefs();
    WidgetsBinding.instance.addObserver(this);
    setSystemBarColor();
  }

  /// Allows you to define a single theme for all platforms
  /// for both light and dark mode or just one of them
  factory AppTheme.uniform({
    KasyColors? lightColors,
    KasyColors? darkColors,
    required KasyTextTheme textTheme,
    required KasyThemeDataFactory themeFactory,
    required ThemeMode defaultMode,
    required SharedPreferences sharedPreferences,
  }) {
    return AppTheme(
      mode: defaultMode,
      sharedPreferences: sharedPreferences,
      lightTheme: lightColors != null
          ? KasyThemeUniform(
              themeFactory.build(
                colors: lightColors,
                defaultTextStyle: textTheme,
              ),
            )
          : null,
      darkTheme: darkColors != null
          ? KasyThemeUniform(
              themeFactory.build(
                colors: darkColors,
                defaultTextStyle: textTheme,
              ),
            )
          : null,
    );
  }

  /// Allows you to define different themes for different platforms
  factory AppTheme.adaptive({
    required SharedPreferences sharedPreferences,
    // maybe you want to use different text themes for different platforms
    required KasyTextTheme defaultTextTheme,
    required ThemeMode mode,
    KasyColors? lightColors,
    KasyColors? darkColors,
    KasyThemeDataFactory? ios,
    KasyThemeDataFactory? android,
    KasyThemeDataFactory? web,
  }) {
    return AppTheme(
      mode: mode,
      sharedPreferences: sharedPreferences,
      lightTheme: lightColors != null
          ? KasyThemeAdaptive(
              ios: ios?.build(
                colors: lightColors,
                defaultTextStyle: defaultTextTheme,
              ),
              android: android?.build(
                colors: lightColors,
                defaultTextStyle: defaultTextTheme,
              ),
              web: web?.build(
                colors: lightColors,
                defaultTextStyle: defaultTextTheme,
              ),
            )
          : null,
      darkTheme: darkColors != null
          ? KasyThemeAdaptive(
              ios: ios?.build(
                colors: darkColors,
                defaultTextStyle: defaultTextTheme,
              ),
              android: android?.build(
                colors: darkColors,
                defaultTextStyle: defaultTextTheme,
              ),
              web: web?.build(
                colors: darkColors,
                defaultTextStyle: defaultTextTheme,
              ),
            )
          : null,
    );
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (mode == ThemeMode.system) {
      setSystemBarColor();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Resolves [mode] to either light or dark by reading the system brightness
  /// when [mode] is [ThemeMode.system].
  ThemeMode get effectiveMode {
    if (mode != ThemeMode.system) return mode;
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Set the theme mode and persist the preference.
  void setMode(ThemeMode newMode) {
    if (mode == newMode) return;
    mode = newMode;
    _saveInPrefs(mode);
    setSystemBarColor();
    notifyListeners();
  }

  /// Toggle between light and dark based on the effective (visible) mode.
  /// If the user is in system mode, this picks the opposite of the
  /// currently displayed brightness and switches out of system mode.
  void toggle() {
    final next =
        effectiveMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setMode(next);
  }

  void setSystemBarColor() {
    final isLight = effectiveMode == ThemeMode.light;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
        statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      ),
    );
    syncWebBackgroundColor(isLight ? Brightness.light : Brightness.dark);
  }

  ThemeData get dark {
    if (darkTheme == null) {
      throw Exception('Dark theme is not defined');
    }
    return darkThemeData.copyWith(
      brightness: Brightness.dark,
      extensions: [
        darkTheme!.colors,
        darkTheme!.textTheme,
      ],
    );
  }

  ThemeData get light {
    if (lightTheme == null) {
      throw Exception('Light theme is not defined');
    }
    return lightThemeData.copyWith(
      brightness: Brightness.light,
      extensions: [
        lightTheme!.colors,
        lightTheme!.textTheme,
      ],
    );
  }

  ThemeData get lightThemeData => lightTheme!.data.materialTheme;

  ThemeData get darkThemeData => darkTheme!.data.materialTheme;

  KasyTheme get current {
    return effectiveMode == ThemeMode.dark ? darkTheme! : lightTheme!;
  }

  ThemeMode _loadFromPrefs() {
    final themeMode = sharedPreferences.getString('themeMode');
    if (themeMode == ThemeMode.dark.name) {
      return ThemeMode.dark;
    } else if (themeMode == ThemeMode.light.name) {
      return ThemeMode.light;
    } else if (themeMode == ThemeMode.system.name) {
      return ThemeMode.system;
    }
    return mode;
  }

  void _saveInPrefs(ThemeMode themeMode) {
    sharedPreferences.setString('themeMode', themeMode.name);
  }
}
