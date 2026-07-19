import 'package:cowboydodartinc/core/data/api/http_client.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/data/repositories/user_repository.dart';
import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/environments.dart';
import 'package:cowboydodartinc/features/authentication/repositories/authentication_repository.dart';
import 'package:cowboydodartinc/features/notifications/repositories/device_repository.dart';
import 'package:cowboydodartinc/features/subscriptions/repositories/subscription_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/authentication/data/api/auth_api_fake.dart';
import '../../features/authentication/data/api/user_api_fake.dart';
import '../../features/notifications/data/device_api_fake.dart';
import '../../features/subscriptions/api/fake_inapp_subscription_api.dart';
import '../../features/subscriptions/api/fake_subscription_api.dart';
import '../data/api/storage_api_fake.dart';
import '../security/secured_storage_fake.dart';

void main() {
  group('authRequired AuthenticationMode', () {
    final authRepository = HttpAuthenticationRepository(
      logger: Logger(),
      authenticationApi: FakeAuthenticationApi(),
      storage: FakeAuthSecuredStorage.empty(),
      userApi: FakeUserApi(storageApi: FakeStorageApi()),
      httpClient: HttpClient(baseUrl: ''),
    );

    final fakeStorageApi = FakeStorageApi();

    Future<ProviderContainer> initTestContainer() async {
      SharedPreferences.setMockInitialValues({});
      final sharedPrefs = await SharedPreferences.getInstance();
      final deviceRepository = DeviceRepository(
        deviceApi: FakeDeviceApi(),
        prefs: sharedPrefs,
      );

      final subscriptionRepository = SubscriptionRepository(
        subscriptionApi: SubscriptionApiFake(),
        inAppSubscriptionApi: InAppSubscriptionApiFake(),
        prefs: sharedPrefs,
      );

      final userRepository = UserRepository(
        userApi: FakeUserApi(storageApi: fakeStorageApi),
        subscriptionRepository: subscriptionRepository,
      );

      const env = Environment.dev(
        name: 'dev',
        backendUrl: 'https://example.com',
        authenticationMode: AuthenticationMode.authRequired,
      );

      final container = ProviderContainer.test(
        overrides: [
          environmentProvider.overrideWithValue(env),
          authRepositoryProvider.overrideWithValue(authRepository),
          userRepositoryProvider.overrideWithValue(userRepository),
          deviceRepositoryProvider.overrideWithValue(deviceRepository),
          subscriptionRepositoryProvider.overrideWithValue(subscriptionRepository),
        ],
      );

      // The notifier touches SharedPreferences (onboarding flag, biometric
      // reset) during logout/onboarding, so the builder must be initialized.
      await container.read(sharedPreferencesProvider).init();
      return container;
    }

    test(
      'Should load user at startup, user is not connected => user should be in unauth state',
      () async {
        final testContainer = await initTestContainer();
        final userStateNotifier = testContainer.read(
          userStateNotifierProvider.notifier,
        );

        expect(
          userStateNotifier.state.user,
          isA<LoadingUserData>(),
          reason: 'user should be in loading state at the beginning',
        );
        await userStateNotifier.init();
        expect(
          userStateNotifier.state.user,
          isA<AnonymousUserData>(),
          reason: 'user should be in unauthenticated state',
        );
      },
    );

    test(
      'Should load user at startup, user signin => state user is connected',
      () async {
        final testContainer = await initTestContainer();
        final userStateNotifier = testContainer.read(
          userStateNotifierProvider.notifier,
        );
        await userStateNotifier.init();

        await authRepository.signup('email', 'password');
        await userStateNotifier.onSignin();
        expect(
          userStateNotifier.state.user,
          isA<AuthenticatedUserData>(),
          reason: 'user should be authenticated',
        );
      },
    );

    test('on logout -> user state is anonymous', () async {
      final testContainer = await initTestContainer();
      final userStateNotifier = testContainer.read(
        userStateNotifierProvider.notifier,
      );
      await userStateNotifier.init();
      await authRepository.signup('email', 'password');
      await userStateNotifier.onSignin();
      await authRepository.logout();
      await userStateNotifier.onLogout();

      expect(
        userStateNotifier.state.user,
        isA<AnonymousUserData>(),
        reason: 'user should be anonymous',
      );
    });
  });

  group('authRequired anonymous', () {
    final authRepository = HttpAuthenticationRepository(
      logger: Logger(),
      authenticationApi: FakeAuthenticationApi(),
      storage: FakeAuthSecuredStorage.empty(),
      userApi: FakeUserApi(storageApi: FakeStorageApi()),
      httpClient: HttpClient(baseUrl: ''),
    );

    final fakeStorageApi = FakeStorageApi();

    Future<ProviderContainer> initTestContainer() async {
      SharedPreferences.setMockInitialValues({});
      final sharedPrefs = await SharedPreferences.getInstance();
      final deviceRepository = DeviceRepository(
        deviceApi: FakeDeviceApi(),
        prefs: sharedPrefs,
      );

      final subscriptionRepository = SubscriptionRepository(
        subscriptionApi: SubscriptionApiFake(),
        inAppSubscriptionApi: InAppSubscriptionApiFake(),
        prefs: sharedPrefs,
      );

      final userRepository = UserRepository(
        userApi: FakeUserApi(storageApi: fakeStorageApi),
        subscriptionRepository: subscriptionRepository,
      );

      const env = Environment.dev(
        name: 'dev',
        backendUrl: 'https://example.com',
        authenticationMode: AuthenticationMode.anonymous,
      );

      final container = ProviderContainer.test(
        overrides: [
          environmentProvider.overrideWithValue(env),
          authRepositoryProvider.overrideWithValue(authRepository),
          subscriptionRepositoryProvider.overrideWithValue(subscriptionRepository),
          userRepositoryProvider.overrideWithValue(userRepository),
          deviceRepositoryProvider.overrideWithValue(deviceRepository),
        ],
      );

      // The notifier touches SharedPreferences (onboarding flag, biometric
      // reset) during logout/onboarding, so the builder must be initialized.
      await container.read(sharedPreferencesProvider).init();
      return container;
    }

    test(
      'Should load user at startup, no account yet => anonymous guest with no id',
      () async {
        final testContainer = await initTestContainer();
        final userStateNotifier = testContainer.read(
          userStateNotifierProvider.notifier,
        );
        expect(
          userStateNotifier.state.user,
          isA<LoadingUserData>(),
          reason: 'user should be in loading state at the beginning',
        );
        await userStateNotifier.init();
        expect(
          userStateNotifier.state.user,
          isA<AnonymousUserData>(),
          reason: 'user should be in unauthenticated state',
        );
        expect(
          userStateNotifier.state.user.idOrNull,
          isNull,
          reason:
              'no anonymous account is created eagerly anymore — it is created '
              'lazily in continueAsGuest (onboarding end / "continue as guest")',
        );
      },
    );

    test(
      'continueAsGuest => creates anonymous account with id and remembers onboarding',
      () async {
        final testContainer = await initTestContainer();
        final userStateNotifier = testContainer.read(
          userStateNotifierProvider.notifier,
        );
        await userStateNotifier.init();
        await userStateNotifier.continueAsGuest();

        expect(
          userStateNotifier.state.user,
          isA<AnonymousUserData>(),
          reason: 'guest is anonymous',
        );
        expect(
          userStateNotifier.state.user.idOrThrow,
          'fake-user-id-anonymous',
          reason: 'the anonymous account is created on demand here',
        );
        expect(
          testContainer.read(sharedPreferencesProvider).getOnboardingCompleted(),
          isTrue,
          reason: 'onboarding is remembered so it is never shown again',
        );
      },
    );

    test(
      'Should load user at startup, user signin => state user is connected',
      () async {
        final testContainer = await initTestContainer();
        final userStateNotifier = testContainer.read(
          userStateNotifierProvider.notifier,
        );
        await userStateNotifier.init();

        await authRepository.signup('email', 'password');
        await userStateNotifier.onSignin();
        expect(
          userStateNotifier.state.user,
          isA<AuthenticatedUserData>(),
          reason: 'user should be authenticated',
        );
      },
    );

    test('on logout -> anonymous guest with no id (no re-signup)', () async {
      final testContainer = await initTestContainer();
      final userStateNotifier = testContainer.read(
        userStateNotifierProvider.notifier,
      );
      await userStateNotifier.init();
      await authRepository.signup('email', 'password');
      await userStateNotifier.onSignin();
      await authRepository.logout();
      await userStateNotifier.onLogout();

      expect(
        userStateNotifier.state.user,
        isA<AnonymousUserData>(),
        reason: 'user should be anonymous',
      );
      expect(
        userStateNotifier.state.user.idOrNull,
        isNull,
        reason:
            'logout must not recreate an anonymous account (would pile up '
            'orphan users); the user is sent to the sign-in screen instead',
      );
    });
  });
}
