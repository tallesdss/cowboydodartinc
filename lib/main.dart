import 'dart:async';

import 'package:cowboydodartinc/components/kasy_spinner.dart';
import 'package:cowboydodartinc/core/ads/ads_runtime.dart';
import 'package:cowboydodartinc/core/config/app_env.dart';
import 'package:cowboydodartinc/core/config/features.dart';
import 'package:cowboydodartinc/core/data/api/analytics_api.dart';
import 'package:cowboydodartinc/core/data/api/remote_config_api.dart';
import 'package:cowboydodartinc/core/data/api/tracking_api.dart';
import 'package:cowboydodartinc/core/dev_inspector/dev_inspector.dart';
import 'package:cowboydodartinc/core/home_widgets/home_widget_service.dart';
import 'package:cowboydodartinc/core/initializer/onstart_widget.dart';
import 'package:cowboydodartinc/core/keyboard_fix/keyboard_flicker_fix.dart';
import 'package:cowboydodartinc/core/navigation/dev_route_memory.dart';
import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/responsive_text_theme.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/web_device_preview/web_device_preview.dart';
import 'package:cowboydodartinc/core/web_viewport_scale.dart';
import 'package:cowboydodartinc/core/widgets/focus_visibility.dart';
import 'package:cowboydodartinc/environments.dart';
import 'package:cowboydodartinc/features/authentication/api/auth_web_support.dart'
    if (dart.library.js_interop) 'package:cowboydodartinc/features/authentication/api/auth_web_support_web.dart';
import 'package:cowboydodartinc/features/authentication/api/authentication_api.dart';
import 'package:cowboydodartinc/features/notifications/api/local_notifier.dart';
import 'package:cowboydodartinc/features/notifications/repositories/background_notification_handler.dart';
import 'package:cowboydodartinc/features/notifications/repositories/notifications_repository.dart';
import 'package:cowboydodartinc/features/subscriptions/repositories/subscription_repository.dart';
import 'package:cowboydodartinc/firebase_options_dev.dart' as firebase_dev;
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:cowboydodartinc/router.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:jiffy/jiffy.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final widgetsBinding = KasyBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Web: use clean path URLs (/admin/kanban) instead of the legacy hash
  // (/#/admin/kanban). The bottom bar (Bart) already writes path URLs via
  // history, so this unifies both routers on one format and drops the
  // mirrored hash. No-op on native.
  usePathUrlStrategy();
  await AppEnv.load();
  final env = Environment.fromEnv();
  final logger = Logger();
  logger.i('Starting app in ${env.name} mode');
  // I like to force portrait mode on mobile devices
  // What is the last time you used an app in landscape mode?
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // initialize shared preferences for theme and locale
  final sharedPrefs = await SharedPreferences.getInstance();

  // Debug-only: let a hot restart resume on the screen you were working on
  // instead of bouncing back to home. No-op in release builds.
  DevRouteMemory.attach(sharedPrefs);

  // Restore saved locale; fall back to device locale if none saved.
  // Supported locales: en, pt, es. If the device locale is not one of these,
  // the base locale (en) is used as fallback (configured in slang.yaml).
  // To change the default locale, update `base_locale` in slang.yaml.
  final savedLocale = sharedPrefs.getString('app_locale');
  if (savedLocale != null) {
    final appLocale = AppLocale.values.firstWhere(
      (l) => l.languageCode == savedLocale,
      orElse: () => AppLocale.en,
    );
    LocaleSettings.setLocale(appLocale);
  } else {
    LocaleSettings.useDeviceLocale();
  }

  // initialize firebase app for notifications
  await switch (env) {
    DevEnvironment() => Firebase.initializeApp(
      options: firebase_dev.DefaultFirebaseOptions.currentPlatform,
    ),
    ProdEnvironment() => Firebase.initializeApp(
      // SETUP REQUIRED: For production, create a separate Firebase project and run:
      //   flutterfire configure --project=<your-prod-project> --out=lib/firebase_options_prod.dart
      // Then replace this import with firebase_options_prod.dart for this case.
      // Using the dev project in production is only safe for early-stage development.
      options: firebase_dev.DefaultFirebaseOptions.currentPlatform,
    ),
  };

  // Initialize the AdMob SDK (mobile only; no-op on web). Fire-and-forget so
  // it never delays app startup.
  if (withAds) unawaited(initializeAdsRuntime());

  // Jiffy locale must be set AFTER Firebase init because Firebase resets
  // Intl.defaultLocale internally, which would override our setting.
  await Jiffy.setLocale(LocaleSettings.instance.currentLocale.languageCode);

  // MUST be registered at the top-level BEFORE runApp().
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

  // Web: if we just returned from a social-login redirect, reset the address bar
  // to '/' BEFORE the router reads the initial URL, so the app boots on Home
  // instead of the stale tab URL (e.g. /settings) the redirect returned to.
  resetUrlAfterRedirectLogin();

  // initialize sentry for error reporting in production only
  if (env is DevEnvironment) {
    run(sharedPrefs);
  } else if (env is ProdEnvironment) {
    SentryFlutter.init((options) {
      options.dsn = env.sentryDsn;
      // 20% of traces will be sent to Sentry server. You should start with 1 and decrease it once you have more users.
      options.tracesSampleRate = 0.2;
      options.environment = env.name;
    }, appRunner: () => run(sharedPrefs));
  }
}

void run(SharedPreferences prefs) => runApp(
  TranslationProvider(
    child: ProviderScope(child: MyApp(sharedPreferences: prefs)),
  ),
);

// use this if you want to define different themes for different platforms
// notifier: AppTheme.adaptive(
//   defaultTextTheme: KasyTextTheme.build(),
//   ios: const IosThemeFactory(),
//   android: const AndroidThemeFactory(),
//   web: const WebThemeFactory(),
//   lightColors: KasyColors.light(),
//   darkColors: KasyColors.dark(),
//   mode: ThemeMode.dark,
// ),
// See ./docs/theme.md for more details
class MyApp extends ConsumerStatefulWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({super.key, required this.sharedPreferences});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final AppTheme _appTheme;

  @override
  void initState() {
    super.initState();
    _appTheme = AppTheme.uniform(
      sharedPreferences: widget.sharedPreferences,
      themeFactory: const UniversalThemeFactory(),
      lightColors: KasyColors.light(),
      darkColors: KasyColors.dark(),
      textTheme: KasyTextTheme.build(),
      defaultMode: ThemeMode.system,
    );
  }

  @override
  void dispose() {
    _appTheme.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return AppErrorWidget(error: details);
    };
    final goRouter = ref.watch(goRouterProvider);

    return ThemeProvider(
      notifier: _appTheme,
      child: Builder(
        builder: (context) {
          return WebDevicePreview.wrap(
            child: DevInspector.wrap(
              child: ValueListenableBuilder<bool>(
                valueListenable: webDevicePreviewActiveNotifier,
                builder: (context, devicePreviewActive, _) {
                  return MaterialApp.router(
                    debugShowCheckedModeBanner:
                        kDebugMode && !devicePreviewActive,
                    title: 'Kasy',
                    scaffoldMessengerKey: devInspectorRootScaffoldMessengerKey,
                    theme: ThemeProvider.of(context).light,
                    darkTheme: ThemeProvider.of(context).dark,
                    themeMode: ThemeProvider.of(context).mode,
                    themeAnimationDuration: Duration.zero,
                    routerConfig: goRouter,
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    locale: TranslationProvider.of(context).flutterLocale,
                    supportedLocales: AppLocaleUtils.supportedLocales,
                    builder: (context, child) => Initializer(
                      services: [
                        authenticationApiProvider,
                        sharedPreferencesProvider,
                        remoteConfigApiProvider,
                        notificationsSettingsProvider,
                        notificationRepositoryProvider,
                        subscriptionRepositoryProvider,
                        userStateNotifierProvider.notifier,
                        homeWidgetsManagerProvider,
                        analyticsApiProvider,
                        facebookEventApiProvider,
                      ],
                    onReady: FocusVisibility(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: webDevicePreviewActiveNotifier,
                        builder: (context, devicePreviewActive, _) {
                          final Widget app = DevicePreview.appBuilder(
                            context,
                            ResponsiveTextTheme(
                              child: child ?? const SizedBox.shrink(),
                            ),
                          );
                          return devicePreviewActive
                              ? app
                              : WebViewportScale.wrap(app);
                        },
                      ),
                    ),
                    onError: (_, error) =>
                        InitializationErrorPage(error: error),
                    onLoading: const Scaffold(
                      body: Center(child: KasySpinner()),
                    ),
                  ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// This is an example of a more user friendly error widget
/// By default Flutter will show a red screen with the error in debug mode
/// and a grey screen in release mode
class AppErrorWidget extends StatelessWidget {
  final FlutterErrorDetails? error;

  const AppErrorWidget({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.orangeAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Oups!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sorry, Something went wrong',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '${error?.exception}\n',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class InitializationErrorPage extends StatelessWidget {
  final String error;

  const InitializationErrorPage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text('Cannot start app', style: context.textTheme.titleLarge),
            Text(
              'Check your internet connection and start again',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.muted,
              ),
            ),
            if (kDebugMode)
              Text(
                "developper mode error: $error",
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.error,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
