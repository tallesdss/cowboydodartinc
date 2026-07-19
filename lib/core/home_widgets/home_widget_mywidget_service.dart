import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/home_widgets/home_widget_service.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/features/subscriptions/repositories/subscription_repository.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:home_widget/home_widget.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_widget_mywidget_service.g.dart';

@Riverpod(keepAlive: true)
class MyWidgetHomeWidget extends _$MyWidgetHomeWidget
    implements UpdatableHomeWidget {
  static const String _androidWidgetName = 'MyWidgetReceiver';
  static const String _iosWidgetName = 'MyWidgetWidget';

  @override
  void build() {
    // Auto-refresh the widget whenever user state changes in a way that
    // affects what it renders (login/logout, name, email, premium status).
    // The initial render is triggered explicitly by HomeWidgetsManager.init()
    // after setAppGroupId completes — putting it here would race with the
    // app-group setup and the first saveWidgetData could land in the wrong
    // UserDefaults suite.
    ref.listen(userStateNotifierProvider, (previous, next) {
      if (previous == null) return;
      if (_widgetSignature(previous.user) != _widgetSignature(next.user)) {
        update();
      }
    });
  }

  /// Snapshot of the user fields the widget reads. Used to skip the update
  /// when an unrelated field changes (e.g. lastUpdateDate refresh).
  (String?, String?, String?, bool) _widgetSignature(User user) {
    final name = switch (user) {
      AuthenticatedUserData(:final name) => name,
      _ => null,
    };
    final email = switch (user) {
      AuthenticatedUserData(:final email) => email,
      _ => null,
    };
    return (user.idOrNull, name, email, _cachedIsPro(user));
  }

  @override
  Future<void> update() => _renderForLocale(
        LocaleSettings.currentLocale,
        refreshSubscription: true,
      );

  /// Same as [update] but renders against an explicit locale and skips the
  /// RevenueCat refresh. Two reasons:
  ///  1. `LocaleSettings.setLocale` propagates to `currentLocale` over a
  ///     frame boundary, and an [update] call scheduled at the same time
  ///     can race with it — passing the locale removes the race.
  ///  2. The network call inside [_resolveIsPro] adds up to 2s of latency
  ///     before the new strings reach SharedPreferences, which is what made
  ///     the widget look "one step behind" after switching language.
  Future<void> updateForLocale(AppLocale locale) =>
      _renderForLocale(locale, refreshSubscription: false);

  Future<void> _renderForLocale(
    AppLocale locale, {
    required bool refreshSubscription,
  }) async {
    final logger = Logger();
    logger.i('🔄 Updating MyWidget Home Widget (${locale.languageCode})');
    final user = ref.read(userStateNotifierProvider).user;

    // Slang lazy-loads non-base locales: AppLocale.pt.translations falls back
    // silently to the base locale (en) if the bundle isn't in the translation
    // map yet. The async loadLocale() can't be used here as a safety net
    // because it short-circuits ("already loading") when setLocale() is in
    // flight in parallel — leaving us reading translations that aren't loaded
    // yet. loadLocaleSync forces the bundle into the map right now, no race.
    LocaleSettings.instance.loadLocaleSync(locale);
    final t = locale.translations;

    // "Logged out" = no user id at all (post-logout in authRequired mode, or
    // before any anonymous signup completes). In this state we show a
    // come-back message and hide the plan tag — showing a plan would be
    // misleading when there is no account behind it.
    final isLoggedOut = user.idOrNull == null;

    final name = switch (user) {
      AuthenticatedUserData(:final name)
          when name != null && name.isNotEmpty =>
        name.split(' ').first,
      // Fallback when the Firestore profile has no name yet: derive a
      // display name from the email local-part (matches what the
      // settings page shows).
      AuthenticatedUserData(:final email) => email.split('@').first,
      _ => null,
    };

    final isPro = !isLoggedOut &&
        (refreshSubscription ? await _resolveIsPro(user) : _cachedIsPro(user));

    final greeting = _greeting(t);
    final title = isLoggedOut
        ? t.home_widget.title_logged_out
        : name == null
            ? t.home_widget.title_default
            : t.home_widget.title_with_name(name: name);
    // Empty planText is the contract used by the native widget to skip
    // rendering the pill — see MyWidget.swift / MyWidget.kt.
    final planText = isLoggedOut
        ? ''
        : (isPro ? t.home_widget.plan_pro : t.home_widget.plan_free);
    final quote = t.home_widget.quote;
    final quoteAuthor = t.home_widget.quote_author;

    logger.d(
      'Widget payload → greeting: "$greeting", title: "$title", '
      'planText: "$planText", isPro: $isPro, loggedOut: $isLoggedOut',
    );

    return updateWidget({
      'greeting': greeting,
      'title': title,
      'planText': planText,
      'isPro': isPro.toString(),
      'quote': quote,
      'quoteAuthor': quoteAuthor,
    });
  }

  bool _cachedIsPro(User user) => switch (user) {
        AuthenticatedUserData(:final subscription) ||
        AnonymousUserData(:final subscription) =>
          subscription?.isActive ?? false,
        _ => false,
      };

  /// Returns true if the user has an active subscription.
  /// Queries the SubscriptionRepository directly so the widget reflects the
  /// most recent state — including the RevenueCat fallback when the backend
  /// webhook is delayed. Falls back to the in-memory user.subscription if the
  /// fresh fetch fails (no network, RC not initialised, etc.).
  Future<bool> _resolveIsPro(User user) async {
    final cached = _cachedIsPro(user);
    final userId = user.idOrNull;
    if (userId == null) return cached;
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      // 2s timeout — if RevenueCat/network is slow, fall back to the cached
      // value so the widget renders promptly on first install. The next
      // background tick (or any user-state change) will reconcile later.
      return await Future(() async {
        await repo.initUser(userId);
        final fresh = await repo.get(userId);
        return fresh.isActive;
      }).timeout(const Duration(seconds: 2), onTimeout: () => cached);
    } catch (e) {
      Logger().w('Widget could not refresh subscription: $e (using cached)');
      return cached;
    }
  }

  Future<void> updateWidget(Map<String, String> data) async {
    await HomeWidget.saveWidgetData<String>('greeting', data['greeting'] ?? '');
    await HomeWidget.saveWidgetData<String>('title', data['title'] ?? '');
    await HomeWidget.saveWidgetData<String>('planText', data['planText'] ?? '');
    await HomeWidget.saveWidgetData<String>('isPro', data['isPro'] ?? 'false');
    await HomeWidget.saveWidgetData<String>('quote', data['quote'] ?? '');
    await HomeWidget.saveWidgetData<String>(
      'quoteAuthor',
      data['quoteAuthor'] ?? '',
    );

    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      iOSName: _iosWidgetName,
    );
  }

  /// Time-of-day greeting in the app language (matches what the user sees
  /// inside the app, not the device language).
  static String _greeting(Translations t) {
    final hour = DateTime.now().hour;
    if (hour < 12) return t.home_widget.greeting_morning;
    if (hour < 18) return t.home_widget.greeting_afternoon;
    return t.home_widget.greeting_evening;
  }
}
