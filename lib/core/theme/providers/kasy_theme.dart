import 'package:cowboydodartinc/core/theme/colors.dart';
import 'package:cowboydodartinc/core/theme/texts.dart';
import 'package:cowboydodartinc/core/theme/theme_data/theme_data.dart';
import 'package:universal_io/io.dart';

/// This is the the base theme for the app
/// It is used to generate the light and dark themes
sealed class KasyTheme {
  const KasyTheme();

  KasyColors get colors;

  KasyTextTheme get textTheme;

  KasyThemeData get data;
}

class KasyThemeUniform extends KasyTheme {
  const KasyThemeUniform(this.data);

  @override
  final KasyThemeData data;

  @override
  KasyColors get colors => data.colors;

  @override
  KasyTextTheme get textTheme => data.defaultTextTheme;
}

/// If you want to have different
/// themes for different platforms
class KasyThemeAdaptive extends KasyTheme {
  final KasyThemeData? ios;
  final KasyThemeData? android;
  final KasyThemeData? web;

  const KasyThemeAdaptive({
    this.ios,
    this.android,
    this.web,
  });

  @override
  KasyColors get colors {
    if (Platform.isIOS) {
      return ios!.colors;
    } else if (Platform.isAndroid) {
      return android!.colors;
    } else {
      return web!.colors;
    }
  }

  @override
  KasyTextTheme get textTheme {
    if (Platform.isIOS) {
      return ios!.defaultTextTheme;
    } else if (Platform.isAndroid) {
      return android!.defaultTextTheme;
    } else {
      return web!.defaultTextTheme;
    }
  }

  @override
  KasyThemeData get data {
    if (Platform.isIOS) {
      return ios!;
    } else if (Platform.isAndroid) {
      return android!;
    } else {
      return web!;
    }
  }
}
