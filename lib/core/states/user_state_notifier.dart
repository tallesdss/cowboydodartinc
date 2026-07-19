import 'dart:async';

import 'package:cowboydodartinc/core/bottom_menu/active_tab_notifier.dart';
import 'package:cowboydodartinc/core/config/features.dart';
import 'package:cowboydodartinc/core/data/models/entitlement.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/data/repositories/user_repository.dart';
import 'package:cowboydodartinc/core/initializer/onstart_service.dart';
import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:cowboydodartinc/core/states/models/user_state.dart';
import 'package:cowboydodartinc/core/utils/image_bytes_loader.dart';
import 'package:cowboydodartinc/environments.dart';
import 'package:cowboydodartinc/features/authentication/repositories/authentication_repository.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/device.dart';
import 'package:cowboydodartinc/features/notifications/repositories/device_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_state_notifier.g.dart';

/// Use this provider to access the user state (legacy name)
final userStateNotifierProvider = userStateProvider;

/// This enum is used to parameter the list of the authentication mode
///
/// Most of apps try to not force user to create an account to access the app
/// But you may want to force the user to be authenticated to access the app
enum AuthenticationMode {
  /// By default the user will be authenticated anonymously
  /// This means that the user can access your app without login
  /// He will be able to link his account later to an email or social login
  anonymous,

  /// The user requires to be authenticated to access the app
  /// By default the user won't have any identity
  authRequired,
}

/// This class is responsible for managing the state of the user over the app.
/// It will be used to know if the user is connected or not and to get the user
@Riverpod(keepAlive: true)
class UserStateNotifier extends _$UserStateNotifier implements OnStartService {
  Logger get _logger => Logger();

  AuthenticationRepository get _authenticationRepository =>
      ref.read(authRepositoryProvider);

  DeviceRepository get _deviceRepository => ref.read(deviceRepositoryProvider);

  UserRepository get _userRepository => ref.read(userRepositoryProvider);

  /// The authentication mode of the app.
  /// On web (when withWeb is true), always require explicit auth —
  /// anonymous accounts are not used on web.
  /// see [AuthenticationMode]
  AuthenticationMode get mode {
    if (kIsWeb && withWeb) return AuthenticationMode.authRequired;
    return ref.read(environmentProvider).authenticationMode;
  }

  StreamSubscription<String?>? _roleSubscription;

  @override
  UserState build() {
    ref.onDispose(() => _roleSubscription?.cancel());
    return const UserState(user: User.loading());
  }

  @override
  Future<void> init() async {
    try {
      await _loadState();
    } catch (e, stacktrace) {
      _logger.e(e, stackTrace: stacktrace);
      if (kDebugMode) {
        // we automatically logout the user if an error occurs in debug mode
        // customize this behavior to fit your needs
        _authenticationRepository.logout();
      }
      rethrow;
    }
    assert(state.user is! LoadingUserData, 'UserStateNotifier is not ready');
    _syncRoleListener();
    await _initDeviceRegistration();
    _deviceRepository.onTokenUpdate(_onUpdateToken);
  }

  /// This function is called when the user click on the signin button
  /// It will load the user state and register the device to the notification service
  /// It will also load the subscription state
  Future<void> onSignin() async {
    state = const UserState(user: User.loading());
    await _loadState();
    _syncRoleListener();
    await _initDeviceRegistration();
    // A successful sign-in puts the user past first-run onboarding. Remember it
    // so that after a later logout they land on the sign-in screen instead of
    // being sent back through onboarding.
    await ref.read(sharedPreferencesProvider).setOnboardingCompleted(true);
  }

  /// Set the user as onboarded in the database
  /// This function is called when the user has completed the onboarding
  Future<void> onOnboarded() async {
    // Remember locally that onboarding is done, so it's never shown again on
    // this install (survives logout and account deletion).
    await ref.read(sharedPreferencesProvider).setOnboardingCompleted(true);
    if (state.user.idOrNull == null) {
      // Guest with no account: persist onboarding in local state only.
      // No Firestore document exists yet — no write needed.
      state = state.copyWith(user: const User.anonymous(onboarded: true));
      return;
    }
    try {
      final newUser = await _userRepository.setOnboarded(state.user);
      state = state.copyWith(user: newUser);
    } catch (e) {
      // The user document may not exist yet: the backend's onUserRegistration
      // trigger runs asynchronously and can lag a just-created anonymous account
      // (Firestore update() throws on a missing doc). Onboarding is already
      // remembered locally (flag above), so reflect it in state and move on
      // instead of letting this bubble up and trap the onboarding loader.
      _logger.w('setOnboarded failed, keeping local onboarded state: $e');
      state = state.copyWith(
        user: switch (state.user) {
          final AuthenticatedUserData u => u.copyWith(onboarded: true),
          final AnonymousUserData u => u.copyWith(onboarded: true),
          final LoadingUserData _ => state.user,
        },
      );
    }
  }

  /// Finish onboarding (or "continue as guest" from the sign-in screen) by
  /// making sure the user has a backend identity, then marking them onboarded.
  ///
  /// This is the ONLY place an anonymous account is created. It is created
  /// lazily here — never eagerly on app start, never on logout — so users who
  /// never get this far (or who later sign out) don't leave orphan anonymous
  /// accounts behind in the backend.
  Future<void> continueAsGuest() async {
    if (mode == AuthenticationMode.anonymous && state.user.idOrNull == null) {
      await _loadAnonymousState();
    }
    // Register the device in this same session, exactly like a sign-in does via
    // [onSignin]. The backend sends the one-time welcome notification when the
    // first device is registered (Firebase: onFirstDeviceRegistered trigger,
    // Supabase: AFTER INSERT ON devices). Without registering here, a guest who
    // skips onboarding only gets the welcome on the next app start — when [init]
    // finally registers the device — which is the bug this fixes. Idempotent and
    // safe to run again on later starts: the welcome is guarded once-per-account
    // server-side (claimWelcome), so it is never sent twice.
    await _initDeviceRegistration();
    await onOnboarded();
  }

  /// Mark the user as onboarded immediately (optimistic) and write to the
  /// backend in background. Used by the skip-onboarding flow so navigation
  /// to home is instant — no spinner while waiting for a network round-trip.
  void onSkippedOnboarding() {
    // Remember onboarding as done locally (same flag as [onOnboarded]) so it's
    // never shown again, even after a logout.
    unawaited(ref.read(sharedPreferencesProvider).setOnboardingCompleted(true));
    state = state.copyWith(
      user: switch (state.user) {
        final AuthenticatedUserData u => u.copyWith(onboarded: true),
        final AnonymousUserData u => u.copyWith(onboarded: true),
        final LoadingUserData _ => const User.anonymous(onboarded: true),
      },
    );
    final id = state.user.idOrNull;
    if (id != null) {
      unawaited(_userRepository.setOnboarded(state.user));
    }
  }

  /// This function is called when the user click on the logout button
  /// It will unregister the device from the notification service
  /// and logout the user
  Future<void> onLogout() async {
    _stopRoleListener();
    final userId = state.user.idOrThrow;
    _deviceRepository.removeTokenUpdateListener();
    // Best-effort: if the network call fails we still proceed with logout so
    // the user is never stuck on the previous account. A stale device doc on
    // the old user is cleaned up server-side by the cross-user token dedup
    // trigger when the same install registers under a new account.
    try {
      await _deviceRepository.unregister(userId);
    } catch (e) {
      _logger.w('Failed to unregister device during logout: $e');
    }
    await _authenticationRepository.logout();
    // Biometric lock is a per-account preference, not a device-wide one.
    // The next user signing in on this install should start without it set.
    await ref.read(sharedPreferencesProvider).setBiometricEnabled(false);
    await _clearWebGuestPass();
    // Forget the last bottom-bar tab so the next login lands on the default tab
    // (Home) instead of wherever the previous account left off.
    forgetActiveTab();
    state = const UserState(user: User.anonymous());
    // No anonymous re-signup here. The router redirect sends the user to the
    // sign-in screen (onboarding is remembered as done, so it isn't repeated).
    // Recreating an anonymous account on every logout would pile up orphan
    // users in the backend — an anonymous account is only ever created lazily,
    // in [continueAsGuest], when the user finishes onboarding or explicitly
    // chooses to continue as a guest.
  }

  /// Refresh the user
  Future<void> onUpdateAvatar() async {
    await refresh();
  }

  /// Refresh the user
  Future<void> refresh() async {
    final id = state.user.idOrNull;
    if (id == null) return; // Guest: no Firestore document, nothing to refresh
    final user = await _userRepository.get(id);
    // Preserve the id if the Firestore document is not found (e.g. backend not
    // yet deployed), so the user never loses their session identity.
    state = state.copyWith(user: user ?? User.anonymous(id: id));
  }

  /// On first social sign-in, copy the provider's profile photo (e.g. Google)
  /// into our own storage so the user starts with an avatar. Best-effort and
  /// one-shot: only runs when the user has no avatar yet, and it never overwrites
  /// a photo the user set manually. Apple does not expose a photo (no-op there).
  Future<void> _importSocialAvatarIfNeeded() async {
    final user = state.user;
    if (user is! AuthenticatedUserData) return;
    final userId = user.id;
    if (userId == null || userId.isEmpty) return;
    if (user.avatarPath?.isNotEmpty ?? false) return; // keep existing avatar
    try {
      final photoUrl = await _authenticationRepository.getCurrentUserPhotoUrl();
      if (photoUrl == null || photoUrl.isEmpty) return;
      final bytes = await loadImageBytes(_normalizeAvatarUrl(photoUrl));
      if (bytes == null || bytes.isEmpty) return;
      await for (final _ in _userRepository.saveAvatar(
        userId: userId,
        data: Uint8List.fromList(bytes),
      )) {}
      await refresh();
    } catch (e) {
      // Best-effort: keep the fallback avatar if the import fails.
      _logger.w('Social avatar import skipped: $e');
    }
  }

  /// Google serves profile photos with a size suffix (e.g. `=s96-c`, only 96px).
  /// Request a ~400px source so the avatar stays crisp after our 450px
  /// re-compression. URLs from other providers are returned unchanged.
  String _normalizeAvatarUrl(String url) {
    if (!url.contains('googleusercontent.com')) return url;
    final base = url.contains('=') ? url.substring(0, url.indexOf('=')) : url;
    return '$base=s400-c';
  }

  /// This function is called after a user successfuly purchased a subscription
  /// It will refresh the subscription state without waiting for the webhook
  /// (which can take some time and could show a wrong state to the user)
  /// On next app start, the subscription will be refreshed from the webhook result
  Future<void> refreshSubscription({
    SubscriptionProduct? product,
    List<Entitlement>? entitlements,
  }) async {
    if (product != null) {
      final newUser = switch (state.user) {
        final AuthenticatedUserData user => user.copyWith(
          subscription: Subscription.active(
            activeOffer: product,
            entitlements: entitlements,
          ),
        ),
        final AnonymousUserData user => user.copyWith(
          subscription: Subscription.active(
            activeOffer: product,
            entitlements: entitlements,
          ),
        ),
        final LoadingUserData _ => throw 'User is not connected',
      };
      state = state.copyWith(user: newUser);
      return;
    }
    await Future.delayed(const Duration(seconds: 2));
    await _loadState();
  }

  /// Apple store and Google play stores requires you to be able to delete a user account on demand
  /// Here is the function to do it.
  /// It will delete the user account and logout the user
  Future<void> deleteAccount() async {
    _stopRoleListener();
    final userId = state.user.idOrNull;
    // No backend identity (a guest with no account): there is nothing to delete
    // server-side. Just clear the local session so we never throw a generic
    // error that strands the user on Settings — the UI hides the delete button
    // in this case, this is only a safety net.
    if (userId == null) {
      await _authenticationRepository.logout();
      await _clearWebGuestPass();
      forgetActiveTab();
      state = const UserState(user: User.anonymous());
      return;
    }
    _deviceRepository.removeTokenUpdateListener();
    try {
      await _deviceRepository.unregister(userId);
    } catch (e) {
      _logger.w('Failed to unregister device during account deletion: $e');
    }
    await _userRepository.delete();
    await _authenticationRepository.logout();
    await _clearWebGuestPass();
    // Same as onLogout: forget the last bottom-bar tab so the next account that
    // signs in lands on Home, not wherever the deleted account left off (the
    // user deletes from Settings, so without this the next login reopens it).
    forgetActiveTab();
    state = const UserState(user: User.anonymous());
    // Same as [onLogout]: no anonymous re-signup. The user lands on the sign-in
    // screen; a new anonymous account is only created lazily if they choose to
    // continue as a guest.
  }

  /// On WEB the auth redirect treats "onboarding done" as "this guest is allowed
  /// to stay" (`ready = hasIdentity || isOnboarded || onboardingDone`). After a
  /// logout / account deletion the flag is still true, so the redirect would
  /// keep the just-signed-out user on the current screen instead of sending them
  /// to /signin — and whether it happened to work depended on leftover browser
  /// state. Clearing it on web makes the session boundary land on /signin every
  /// time. No-op on native, where this flag only skips the (native-only)
  /// onboarding screen and logout already routes correctly via hasIdentity, so
  /// clearing it would wrongly show onboarding again.
  Future<void> _clearWebGuestPass() async {
    if (!kIsWeb) return;
    await ref.read(sharedPreferencesProvider).setOnboardingCompleted(false);
  }

  // -------------------------------
  // ROLE LISTENER
  // -------------------------------

  void _syncRoleListener() {
    final id = state.user.idOrNull;
    if (id != null && state.user is AuthenticatedUserData) {
      _startRoleListener(id);
    } else {
      _stopRoleListener();
    }
  }

  void _startRoleListener(String userId) {
    _roleSubscription?.cancel();
    _roleSubscription = _userRepository
        .watchRole(userId)
        .skip(1) // skip initial snapshot — state was just loaded
        .listen((newRole) {
          final currentRole = switch (state.user) {
            AuthenticatedUserData(:final role) => role,
            _ => null,
          };
          if (newRole != currentRole) {
            refresh();
          }
        });
  }

  void _stopRoleListener() {
    _roleSubscription?.cancel();
    _roleSubscription = null;
  }

  // -------------------------------
  // PRIVATES
  // -------------------------------

  /// load anonymous state for the user
  Future<void> _loadAnonymousState() async {
    await _authenticationRepository.signupAnonymously();
    await Future.delayed(const Duration(seconds: 1));
    final credentials = await _authenticationRepository.get();
    var user = await _userRepository.get(credentials!.id);
    // We retry to get the user 3 times (sometimes the user creation trigger is not fast enough)
    var retry = 0;
    while (user == null && retry < 3) {
      await Future.delayed(const Duration(seconds: 1));
      user = await _userRepository.get(credentials.id);
      retry++;
    }
    if (user == null) {
      // Backend not deployed yet: the Cloud Function onUserRegistration has not
      // created the Firestore document. Log the issue for the developer and fall
      // back to a local anonymous state so the app still opens.
      _logger.e(
        '⚠️  User profile not found in database.\n'
        '    The backend may not be deployed yet.\n'
        '    Run: kasy deploy\n'
        '    Then restart the app.',
      );
      state = state.copyWith(user: User.anonymous(id: credentials.id));
      return;
    }
    state = state.copyWith(user: user);
  }

  /// Load the state of the user
  Future<void> _loadState() async {
    final credentials = await _authenticationRepository.get();

    if (credentials == null) {
      // No account yet. We deliberately do NOT create an anonymous account here
      // anymore (even in anonymous mode). It's created lazily in
      // [continueAsGuest] when the user finishes onboarding or taps "continue
      // as guest", so simply opening the app — or signing out — never piles up
      // orphan anonymous users. The router redirect decides where to send them:
      // onboarding on the very first run, the sign-in screen after a logout.
      _logger.i('No credentials: user starts as a guest with no account yet');
      state = state.copyWith(user: const User.anonymous());
    } else {
      _logger.i('User is connected with id ${credentials.id}');
      var user = await _userRepository.get(credentials.id);
      // Retry a few times: the Cloud Function onUserRegistration may not have
      // finished creating the Firestore document yet (race condition on first login).
      var retry = 0;
      while (user == null && retry < 3) {
        await Future.delayed(const Duration(seconds: 1));
        user = await _userRepository.get(credentials.id);
        retry++;
      }
      if (user == null) {
        // User document not found after login. Possible causes:
        // - Cloud Functions not deployed yet (run `kasy deploy` to fix)
        // - onUserRegistration Cloud Function failed
        // - Supabase handle_new_user trigger not run yet (race) or failed
        // Fall back to keeping the user authenticated with their auth ID so
        // the app works locally before `kasy deploy` is run.
        _logger.e(
          '⚠️  User profile not found in database after sign-in.\n'
          '    If this is a new project, run: kasy deploy\n'
          '    to deploy the backend and create the user document.',
        );
        state = state.copyWith(user: User.anonymous(id: credentials.id));
        return;
      }
      // If the Firestore document is anonymous (no email) but Firebase Auth
      // already has an email (happens after linkWithProvider — Google, email, etc.),
      // sync the email and name so the user is properly recognised as authenticated.
      if (user is AnonymousUserData) {
        final authEmail = await _authenticationRepository.getCurrentUserEmail();
        if (authEmail != null && authEmail.isNotEmpty) {
          final authName = await _authenticationRepository
              .getCurrentUserDisplayName();
          await _userRepository.updateEmailAndName(
            userId: credentials.id,
            email: authEmail,
            name: authName,
          );
          final syncedUser = await _userRepository.get(credentials.id);
          state = state.copyWith(user: syncedUser ?? user);
          unawaited(_importSocialAvatarIfNeeded());
          return;
        }
      }
      state = state.copyWith(user: user);
      unawaited(_importSocialAvatarIfNeeded());
    }
  }

  /// If user has an ID we will register his device to send notifications from
  /// the server to the device (only if user has accepted them)
  /// Maybe save your device in UserState if you need it in your app
  Future<void> _initDeviceRegistration() async {
    if (kIsWeb) return;
    final userId = state.user.idOrNull;
    if (userId == null) {
      return;
    }
    try {
      final _ = await _deviceRepository.register(userId);
    } catch (err, stacktrace) {
      _logger.e(err, stackTrace: stacktrace);
      _logger.e('''
          ❌ Your device seems not to be registered.
          Check that you correctly setup a device registration API
          see: `lib/features/notifications/api/device_api.dart`
        ''');
    }
  }

  /// This function is called when the device token is updated
  /// It will update the token in the database
  Future<void> _onUpdateToken(Device device) async {
    await _deviceRepository.updateToken(device.token);
  }
}
