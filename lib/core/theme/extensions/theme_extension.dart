import 'package:cowboydodartinc/core/theme/colors.dart';
import 'package:cowboydodartinc/core/theme/providers/theme_provider.dart';
import 'package:cowboydodartinc/core/theme/texts.dart';
import 'package:cowboydodartinc/core/theme/theme_data/theme_data.dart';
import 'package:flutter/material.dart';

/// Convenience extension to access the entire design system from BuildContext.
///
/// Usage:
///   context.colors.primary          → brand color
///   context.colors.success           → semantic success color
///   context.colors.muted             → secondary text color
///   context.colors.fieldLabel        → form field label (text field / text area)
///   context.textTheme.bodyMedium     → body text style
///   context.textTheme.titleLarge     → card title style
///   KasySpacing.md               → 16.0 (spacing token)
///   KasyRadius.lgBorderRadius    → BorderRadius.circular(16)
extension KasyThemeExt on BuildContext {
  /// Access all Kasy color tokens (primary, surface, success, muted, etc.)
  KasyColors get colors =>
      Theme.of(this).extension<KasyColors>()!;

  /// Access the full Material 3 text theme (bodyMedium, titleLarge, etc.)
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Access all Kasy typography tokens as KasyTextTheme
  KasyTextTheme get kasyTextTheme =>
      Theme.of(this).extension<KasyTextTheme>()!;

  /// Raw Flutter ThemeData
  ThemeData get theme => Theme.of(this);

  /// Current brightness (light / dark)
  Brightness get brightness => Theme.of(this).brightness;

  /// Whether current theme is dark mode
  bool get isDark => brightness == Brightness.dark;

  /// Full Kasy theme data
  KasyThemeData get kitTheme => ThemeProvider.of(this).current.data;
}

// Note: KasySpacing and KasyRadius are used directly as static classes.
// No need to access through context since they are not theme-dependent.
//
// Examples:
//   padding: EdgeInsets.all(KasySpacing.md)
//   borderRadius: KasyRadius.smBorderRadius
