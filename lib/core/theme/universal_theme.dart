import 'package:cowboydodartinc/core/navigation/kasy_fade_page_transitions_builder.dart';
import 'package:cowboydodartinc/core/theme/colors.dart';
import 'package:cowboydodartinc/core/theme/radius.dart';
import 'package:cowboydodartinc/core/theme/texts.dart';
import 'package:cowboydodartinc/core/theme/theme_data/theme_data.dart';
import 'package:cowboydodartinc/core/theme/theme_data/theme_data_factory.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// This is a uniform theme
/// But you can use it to create multiple themes for iOS, Android, Web, Desktop...
class UniversalThemeFactory extends KasyThemeDataFactory {
  const UniversalThemeFactory();

  @override
  KasyThemeData build({
    required KasyColors colors,
    required KasyTextTheme defaultTextStyle,
  }) {
    return KasyThemeData(
      colors: colors,
      defaultTextTheme: defaultTextStyle,
      materialTheme: ThemeData(
        // On web: remove all Material hover highlights, splash ripples and press
        // overlays — InkWell, ListTile, etc. should be visually silent on hover.
        splashFactory: kIsWeb ? NoSplash.splashFactory : null,
        hoverColor: kIsWeb ? Colors.transparent : null,
        highlightColor: kIsWeb ? Colors.transparent : null,
        splashColor: kIsWeb ? Colors.transparent : null,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: colors.primary,
              // Infer brightness from background luminance so all derived surface
              // container colors (surfaceContainerLow, etc.) are computed correctly
              // for dark mode. Without this, BottomSheet, dialogs and icon colors
              // stay in light mode even when dark colors are applied.
              brightness: colors.background.computeLuminance() < 0.5
                  ? Brightness.dark
                  : Brightness.light,
            ).copyWith(
              surface: colors.surface,
              onSurface: colors.onSurface,
              primary: colors.primary,
              onPrimary: colors.onPrimary,
              error: colors.error,
              onError: colors.onError,
            ),
        scaffoldBackgroundColor: colors.background,
        canvasColor: colors.background,
        elevatedButtonTheme: elevatedButtonTheme(
          colors: colors,
          textTheme: defaultTextStyle,
        ),
        inputDecorationTheme: inputDecorationTheme(
          colors: colors,
          textTheme: defaultTextStyle,
        ),
        textTheme: textTheme(
          colors: colors,
          defaultTextStyle: defaultTextStyle,
        ),
        navigationRailTheme: navigationRailThemeData(
          colors: colors,
          textTheme: defaultTextStyle,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colors.surface,
          foregroundColor: colors.foreground,
          elevation: colors.background.computeLuminance() < 0.5 ? 0 : 1.4,
          shadowColor: colors.background.computeLuminance() < 0.5
              ? Colors.transparent
              : Colors.black.withValues(alpha: 0.05),
        ),
        // Modal bottom sheets span the full available width on every breakpoint.
        // Material 3 otherwise caps them at 640 logical px, so on web/desktop the
        // sheet floats at tablet width with empty gutters on each side. An empty
        // BoxConstraints() removes that cap; phones are unaffected (already < 640).
        bottomSheetTheme: const BottomSheetThemeData(
          constraints: BoxConstraints(),
        ),
        // Drawers are flat panels (like the sidebar rail), not Material 3's
        // rounded, shadowed sheet: square edge, surface fill, no drop shadow.
        // Set once here so every Drawer in the app is consistent — no per-use
        // shape/elevation overrides needed.
        drawerTheme: DrawerThemeData(
          backgroundColor: colors.surface,
          shape: const RoundedRectangleBorder(),
          elevation: 0,
        ),
      ),
    );
  }

  NavigationRailThemeData navigationRailThemeData({
    required KasyColors colors,
    required KasyTextTheme textTheme,
  }) => NavigationRailThemeData(
    backgroundColor: colors.surface,
    elevation: 0,
    selectedIconTheme: IconThemeData(color: colors.primary),
    unselectedIconTheme: IconThemeData(color: colors.muted),
    selectedLabelTextStyle: textTheme.labelLarge.copyWith(
      color: colors.primary,
    ),
    unselectedLabelTextStyle: textTheme.labelLarge.copyWith(
      color: colors.onSurface,
    ),
  );

  ElevatedButtonThemeData elevatedButtonTheme({
    required KasyColors colors,
    required KasyTextTheme textTheme,
  }) => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(200, 48),
      foregroundColor: colors.onPrimary,
      backgroundColor: colors.primary,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 2, color: colors.primary.withValues(alpha: .8)),
        borderRadius: KasyRadius.smBorderRadius,
      ),
      textStyle: textTheme.labelLarge,
      elevation: 0,
    ),
  );

  InputDecorationTheme inputDecorationTheme({
    required KasyColors colors,
    required KasyTextTheme textTheme,
  }) => InputDecorationTheme(
    fillColor: colors.surface,
    enabledBorder: OutlineInputBorder(
      borderRadius: KasyRadius.smBorderRadius,
      borderSide: BorderSide(color: colors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: KasyRadius.smBorderRadius,
      borderSide: BorderSide(color: colors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: KasyRadius.smBorderRadius,
      borderSide: BorderSide(color: colors.error, width: 2),
    ),
    filled: true,
    // On web prevent Flutter's default semi-transparent hover from making the
    // field look transparent — keep fill color unchanged on mouse hover.
    hoverColor: kIsWeb ? colors.surface : null,
    hintStyle: textTheme.bodyLarge.copyWith(
      color: colors.muted,
      fontWeight: FontWeight.w400,
    ),
    // Figma Sign In field labels ("E-mail", "Senha"): Body sm Medium 14 / 20.
    labelStyle: textTheme.bodyMedium.copyWith(
      color: colors.fieldLabel,
      fontWeight: FontWeight.w500,
    ),
    floatingLabelStyle: textTheme.bodyMedium.copyWith(
      color: colors.onSurface.withValues(alpha: 0.76),
      fontWeight: FontWeight.w500,
    ),
    helperStyle: textTheme.bodySmall.copyWith(
      color: colors.muted,
      fontWeight: FontWeight.w400,
    ),
    errorStyle: textTheme.bodySmall.copyWith(
      color: colors.error,
      fontWeight: FontWeight.w400,
    ),
    border: OutlineInputBorder(
      borderRadius: KasyRadius.smBorderRadius,
      borderSide: BorderSide(color: colors.outline),
    ),
  );

  PageTransitionsTheme get pageTransitionsTheme => kasyPageTransitionsTheme;

  /// Full Material 3 text theme built from KasyTextTheme tokens.
  /// Colors are applied per-style so they adapt to light/dark mode.
  TextTheme textTheme({
    required KasyColors colors,
    required KasyTextTheme defaultTextStyle,
  }) => TextTheme(
    // Display
    displayLarge: defaultTextStyle.displayLarge.copyWith(
      color: colors.onBackground,
    ),
    displayMedium: defaultTextStyle.displayMedium.copyWith(
      color: colors.onBackground,
    ),
    displaySmall: defaultTextStyle.displaySmall.copyWith(
      color: colors.onBackground,
    ),

    // Headline
    headlineLarge: defaultTextStyle.headlineLarge.copyWith(
      color: colors.onBackground,
    ),
    headlineMedium: defaultTextStyle.headlineMedium.copyWith(
      color: colors.onBackground,
    ),
    headlineSmall: defaultTextStyle.headlineSmall.copyWith(
      color: colors.onBackground,
    ),

    // Title
    titleLarge: defaultTextStyle.titleLarge.copyWith(color: colors.onSurface),
    titleMedium: defaultTextStyle.titleMedium.copyWith(color: colors.onSurface),
    titleSmall: defaultTextStyle.titleSmall.copyWith(color: colors.onSurface),

    // Body
    // bodyLarge = Body base (primary ink). bodyMedium = Body sm (secondary /
    // row values) → muted, matching Figma Tokens · Typography. bodySmall =
    // Body xs (caption) → muted.
    bodyLarge: defaultTextStyle.bodyLarge.copyWith(color: colors.onSurface),
    bodyMedium: defaultTextStyle.bodyMedium.copyWith(color: colors.muted),
    bodySmall: defaultTextStyle.bodySmall.copyWith(color: colors.muted),

    // Label
    labelLarge: defaultTextStyle.labelLarge.copyWith(color: colors.onSurface),
    labelMedium: defaultTextStyle.labelMedium.copyWith(color: colors.onSurface),
    labelSmall: defaultTextStyle.labelSmall.copyWith(color: colors.muted),
  );
}
