import 'package:cowboydodartinc/core/theme/colors.dart';
import 'package:cowboydodartinc/core/theme/texts.dart';
import 'package:cowboydodartinc/core/theme/theme_data/theme_data.dart';

/// This is the factory used to create the theme from the colors and textTheme
/// You can create your own factory to create your own theme
/// see universal_theme.dart for an example
abstract class KasyThemeDataFactory {
  const KasyThemeDataFactory();

  KasyThemeData build({
    required KasyColors colors,
    required KasyTextTheme defaultTextStyle,
  });
}
