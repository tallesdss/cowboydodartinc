import 'package:cowboydodartinc/i18n/translations.g.dart';

/// Display metadata for supported [AppLocale] values in settings and pickers.
///
/// Uses endonyms (native language names), matching common practice in iOS,
/// Google, and Netflix — no country flags.
extension AppLocaleDisplay on AppLocale {
  /// Language name written in that language (e.g. `Español`, not `Spanish`).
  String get nativeName => switch (this) {
        AppLocale.en => 'English',
        AppLocale.es => 'Español',
        AppLocale.pt => 'Português',
      };

  /// Two-letter code shown in locale badges (e.g. `EN`, `PT`).
  String get languageCodeLabel => languageCode.toUpperCase();
}
