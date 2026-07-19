import 'dart:async';
import 'dart:convert';

import 'package:cowboydodartinc/core/data/api/base_api_exceptions.dart';
import 'package:cowboydodartinc/core/data/entities/user_entity.dart';
import 'package:cowboydodartinc/environments.dart';
import 'package:cowboydodartinc/features/authentication/api/auth_web_support.dart'
    if (dart.library.js_interop) 'package:cowboydodartinc/features/authentication/api/auth_web_support_web.dart';
import 'package:cowboydodartinc/features/authentication/api/authentication_api_interface.dart';
import 'package:cowboydodartinc/features/authentication/api/popup_dismiss_watcher.dart'
    if (dart.library.js_interop) 'package:cowboydodartinc/features/authentication/api/popup_dismiss_watcher_web.dart';
import 'package:cowboydodartinc/features/authentication/repositories/exceptions/authentication_exceptions.dart';
import 'package:cowboydodartinc/google_auth_options.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authenticationApiProvider = Provider<AuthenticationApi>(
  (ref) => SupabaseAuthenticationApi(
    client: Supabase.instance.client,
    environment: ref.watch(environmentProvider),
  ),
);

class SupabaseAuthenticationApi implements AuthenticationApi {
  final SupabaseClient client;
  final Environment environment;
  final Logger _logger = Logger();

  SupabaseAuthenticationApi({
    required this.client,
    required this.environment,
  });

  @override
  Future<void> init() async {
    if (!kIsWeb) return;
    // Complete a pending mobile-web Google redirect sign-in. Firebase handled the
    // full-page redirect (we reuse its web OAuth client to mint the Google ID
    // token — see [signinWithGoogle]), so on return we exchange that token for a
    // Supabase session. No-op when no redirect is pending or a session already
    // exists.
    try {
      final result = await fb_auth.FirebaseAuth.instance.getRedirectResult();
      final idToken = (result.credential as fb_auth.OAuthCredential?)?.idToken;
      if (idToken != null && client.auth.currentUser == null) {
        await client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
        );
      }
    } catch (e) {
      _logger.w('Google redirect sign-in completion failed: $e');
    }
  }

  /// Mobile-web Google sign-in: start a full-page Firebase redirect instead of a
  /// popup. Mobile browsers handle popups unreliably (the result is often lost
  /// when the browser reclaims the backgrounded opener tab), leaving the app
  /// stuck "signing in". The Supabase session is established at startup by [init]
  /// via getRedirectResult. The page is navigating away as soon as
  /// [signInWithRedirect] resolves, so this future intentionally never completes
  /// — the caller stays in its loading state until the browser leaves.
  /// See [isMobileWebBrowser].
  Future<Credentials> _googleSignInWithRedirectWeb() async {
    // Flag the login so startup lands on Home, not the stale tab URL the
    // redirect returns to (linking is a no-op on Supabase, so only login here).
    markWebRedirectLogin();
    await fb_auth.FirebaseAuth.instance.signInWithRedirect(
      fb_auth.GoogleAuthProvider(),
    );
    return Completer<Credentials>().future;
  }

  @override
  Future<void> recoverPassword(String email) {
    return client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<Credentials?> get() async {
    final user = client.auth.currentUser;
    if (user == null) {
      return null;
    }
    return Credentials(id: user.id, token: '');
  }

  @override
  Future<Credentials> signup(String email, String password) async {
    if (client.auth.currentUser?.isAnonymous == true) {
      // Convert anonymous → email user.
      // Must set email first (Supabase rejects password update on anonymous user
      // without email/phone), then set password in a second call.
      try {
        await client.auth.updateUser(UserAttributes(email: email));
      } on AuthException catch (e) {
        if (e.code != 'email_confirmation_required') {
          // Email already in use — delete orphaned anonymous user then sign in.
          await _deleteCurrentAnonymousUser();
          final res = await client.auth.signInWithPassword(email: email, password: password);
          return Credentials(id: res.user!.id, token: res.session?.accessToken ?? '');
        }
        rethrow;
      }
      // If email confirmation is enabled in Supabase, updateUser(email) triggers
      // a confirmation email but does not apply the email immediately. The user
      // stays anonymous until they click the link. Detect this and inform the user.
      if (client.auth.currentUser?.email == null) {
        throw const AuthException(
          'A confirmation email was sent. Please check your inbox to complete signup.',
          code: 'email_confirmation_required',
        );
      }
      await client.auth.updateUser(UserAttributes(password: password));
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw 'Error while updating user';
      }
      return Credentials(
        id: userId,
        token: client.auth.currentSession?.accessToken ?? '',
      );
    }
    return client.auth
        .signUp(
          email: email,
          password: password,
        )
        .then(
          (value) => Credentials(
            id: value.user!.id,
            token: value.session?.accessToken ?? '',
          ),
          onError: (error) {
            Logger().e("Error while signup: $error");
            Logger().e('''
==============================================================
💡 Please check you enabled email authentication in Supabase
  (Supabase dashboard > Authentication > Providers > Email (enable it))
  -> disable Confirm email as you are on mobile. You don't want a user to leave the app to confirm email.
Note: wait a minute after enabling before trying again. It takes a bit of time to propagate.
Second note: Ensure you installed database schema and policies : https://kasy.dev/docs/conceitos/backends
==============================================================
                ''');
            return error;
          },
        );
  }

  @override
  Future<Credentials> signin(String email, String password) {
    return client.auth
        .signInWithPassword(
          email: email,
          password: password,
        )
        .then(
          (value) => Credentials(
            id: value.user!.id,
            token: value.session?.accessToken ?? '',
          ),
        );
  }

  @override
  Future<Credentials> signinAnonymously() async {
    try {
      final value = await client.auth.signInAnonymously();
      return Credentials(
        id: value.user!.id,
        token: value.session?.accessToken ?? '',
      );
    } catch (error) {
      Logger().e("Error while signing in anonymously: $error");
      Logger().e('''
==============================================================
💡 Please check you enabled anonymous sign-in in Supabase
  (Supabase dashboard > project settings > Authentication > Allow anonymous sign-in (don't enable captcha)
Note: wait a minute after enabling anonymous sign-in before trying again. It takes a bit of time to propagate.
==============================================================
      ''');
      rethrow;
    }
  }

  @override
  Future<Credentials> signinWithApple() async {
    // Apple on web needs a paid Apple Service ID + secret (not configured here);
    // getAppleIDCredential force-unwraps webAuthenticationOptions and crashes on
    // web. The UI hides the Apple button on web; guard here too so a programmatic
    // call fails with a clear error instead of a null-check crash.
    if (kIsWeb) {
      throw ApiError(code: 501, message: 'Apple sign-in on web is not supported.');
    }
    final rawNonce = client.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    late final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          // AppleIDAuthorizationScopes.fullName, // Enable if you want to get the user name
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) throw const UserCancelledSignInException();
      rethrow;
    }

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException(
          'Could not find ID Token from generated credential.',
      );
    }

    final res = await client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
    return Credentials(id: res.user!.id, token: res.session?.accessToken ?? '');

  }

  @override
  Future<Credentials> signinWithFacebook() async {
    // Facebook on web for Supabase is not wired yet (roadmap); the button is hidden
    // on web, so this is a defensive guard.
    if (kIsWeb) {
      throw ApiError(code: 501, message: 'Facebook sign-in on web is not supported on Supabase.');
    }
    final loginResult = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    if (loginResult.status == LoginStatus.cancelled) throw const UserCancelledSignInException();
    if (loginResult.status != LoginStatus.success) {
      throw ApiError(
        code: 401,
        message: loginResult.message ?? 'Facebook login failed',
      );
    }

    final accessToken = loginResult.accessToken?.tokenString;
    if (accessToken == null) {
      throw ApiError(code: 401, message: 'No Facebook access token');
    }

    final res = await client.auth.signInWithIdToken(
      provider: OAuthProvider.facebook,
      idToken: accessToken,
    );

    return Credentials(id: res.user!.id, token: res.session?.accessToken ?? '');
  }

  @override
  Future<Credentials> signinWithGoogle() async {
    if (kIsWeb) {
      if (isMobileWebBrowser()) return _googleSignInWithRedirectWeb();
      // google_sign_in v7 can't do imperative auth on web. Get the Google ID token
      // via Firebase's popup (zero manual config — reuses the Firebase web OAuth
      // client + authorized domains, which the kit already sets up) and sign into
      // Supabase with it. Supabase remains the auth backend.
      final idToken = await _googleIdTokenFromWebPopup();
      // Popup unavailable (blocked / lost under COOP): fall back to a redirect.
      if (idToken == null) return _googleSignInWithRedirectWeb();
      final res = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      return Credentials(id: res.user!.id, token: res.session?.accessToken ?? '');
    }
    final googleSignIn = GoogleSignIn.instance;
    // Web: clientId = Web Client ID (no serverClientId needed)
    // Native iOS: clientId = iOS Client ID, serverClientId = Web Client ID
    // Native Android: serverClientId = Web Client ID (clientId is ignored)
    if (kIsWeb) {
      await googleSignIn.initialize(
        clientId: kGoogleWebClientId.isEmpty ? null : kGoogleWebClientId,
      );
    } else {
      await googleSignIn.initialize(
        clientId: kGoogleIosClientId.isEmpty ? null : kGoogleIosClientId,
        serverClientId: kGoogleWebClientId.isEmpty ? null : kGoogleWebClientId,
      );
    }
    late final GoogleSignInAccount googleUser;
    try {
      googleUser = await googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) throw const UserCancelledSignInException();
      rethrow;
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled' || e.code == 'sign_in_cancelled') {
        throw const UserCancelledSignInException();
      }
      rethrow;
    }
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw 'No ID Token found.';
    }

    final res = await client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
    return Credentials(id: res.user!.id, token: res.session?.accessToken ?? '');
    
  }

  /// Web only: obtains a Google ID token via Firebase's popup. google_sign_in v7
  /// can't do imperative auth on the web, but the kit already initializes Firebase
  /// (for FCM), so we reuse Firebase's working web OAuth client to get the token,
  /// then sign into Supabase with it — no Supabase callback / Google console step
  /// needed. The token's audience is the Firebase web client ID, which is the same
  /// one configured as Supabase's Google provider, so signInWithIdToken accepts it.
  ///
  /// Returns null when the popup is unavailable — blocked, or opened as a tab and
  /// lost its opener (COOP) so it never resolves — so the caller can fall back to
  /// a full-page redirect ([_googleSignInWithRedirectWeb]). A window-refocus
  /// watcher detects that lost popup (otherwise the future hangs forever).
  Future<String?> _googleIdTokenFromWebPopup() async {
    final watch = watchAuthPopupDismiss();
    try {
      final cred = await Future.any<fb_auth.UserCredential?>([
        fb_auth.FirebaseAuth.instance.signInWithPopup(
          fb_auth.GoogleAuthProvider(),
        ),
        watch.dismissed.then<fb_auth.UserCredential?>((_) => null),
      ]);
      // Window refocused before the popup resolved: the popup likely opened as a
      // tab and lost its opener (COOP). Signal the caller to use a redirect.
      if (cred == null) return null;
      final idToken = (cred.credential as fb_auth.OAuthCredential?)?.idToken;
      if (idToken == null) {
        throw ApiError(code: 401, message: 'No Google ID token from Firebase popup.');
      }
      return idToken;
    } on fb_auth.FirebaseAuthException catch (e) {
      // Popup blocked / unsupported in this environment → redirect fallback.
      if (e.code == 'popup-blocked' ||
          e.code == 'operation-not-supported-in-this-environment' ||
          e.code == 'web-storage-unsupported') {
        return null;
      }
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request' ||
          e.code == 'web-context-cancelled' ||
          e.code == 'user-cancelled') {
        throw const UserCancelledSignInException();
      }
      rethrow;
    } finally {
      watch.cancel();
    }
  }

  @override
  Future<Credentials> signinWithGooglePlay() {
    // Google Play Games sign-in is not supported for Supabase backend.
    // For Google account sign-in, use signinWithGoogle() instead.
    throw UnsupportedError(
      'Google Play Games sign-in is not available for Supabase. Use signinWithGoogle() instead.',
    );
  }

  @override
  Future<void> signout() {
    return client.auth.signOut();
  }

  
  @override
  Future<Credentials> signupFromAnonymousWithApple() async {
    // See signinWithApple: Apple on web is unsupported here; the UI hides the button
    // on web, and this guard prevents a null-check crash on a programmatic call.
    if (kIsWeb) {
      throw ApiError(code: 501, message: 'Apple sign-in on web is not supported.');
    }
    final rawNonce = client.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    late final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) throw const UserCancelledSignInException();
      rethrow;
    }
    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException('Could not find ID Token from generated credential.');
    }

    try {
      final response = await client.auth.linkIdentityWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      return Credentials(id: response.user!.id, token: response.session?.accessToken ?? '');
    } on AuthException catch (e) {
      if (e.code == 'identity_already_exists') {
        await _deleteCurrentAnonymousUser();
        final res = await client.auth.signInWithIdToken(
          provider: OAuthProvider.apple,
          idToken: idToken,
          nonce: rawNonce,
        );
        return Credentials(id: res.user!.id, token: res.session?.accessToken ?? '');
      }
      rethrow;
    }
  }

  @override
  Future<Credentials> signupFromAnonymousWithGoogle() async {
    if (kIsWeb) {
      if (isMobileWebBrowser()) return _googleSignInWithRedirectWeb();
      // Web: get the Google ID token via Firebase's popup (see signinWithGoogle).
      final idToken = await _googleIdTokenFromWebPopup();
      // Popup unavailable (blocked / lost under COOP): fall back to a redirect.
      if (idToken == null) return _googleSignInWithRedirectWeb();
      // On web the app runs in authRequired mode, so there is usually no anonymous
      // Supabase session to link to (the user state is just a local placeholder).
      // Linking without a session sends the anon key, which has no `sub`, and Supabase
      // rejects it with "missing sub claim". When there's no session, sign in normally
      // — it creates the account from the Google id_token. Mirrors the Firebase backend.
      if (client.auth.currentUser == null) {
        final res = await client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
        );
        return Credentials(id: res.user!.id, token: res.session?.accessToken ?? '');
      }
      try {
        final response = await client.auth.linkIdentityWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
        );
        return Credentials(id: response.user!.id, token: response.session?.accessToken ?? '');
      } on AuthException catch (e) {
        if (e.code == 'identity_already_exists') {
          await _deleteCurrentAnonymousUser();
          final res = await client.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
          );
          return Credentials(id: res.user!.id, token: res.session?.accessToken ?? '');
        }
        rethrow;
      }
    }
    final scopes = ['email'];
    final googleSignIn = GoogleSignIn.instance;

    if (kIsWeb) {
      await googleSignIn.initialize(
        clientId: kGoogleWebClientId.isEmpty ? null : kGoogleWebClientId,
      );
    } else {
      await googleSignIn.initialize(
        clientId: kGoogleIosClientId.isEmpty ? null : kGoogleIosClientId,
        serverClientId: kGoogleWebClientId.isEmpty ? null : kGoogleWebClientId,
      );
    }
    late final GoogleSignInAccount googleUser;
    try {
      googleUser = await googleSignIn.authenticate(scopeHint: scopes);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) throw const UserCancelledSignInException();
      rethrow;
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled' || e.code == 'sign_in_cancelled') {
        throw const UserCancelledSignInException();
      }
      rethrow;
    }
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    try {
      final response = await client.auth.linkIdentityWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      return Credentials(id: response.user!.id, token: response.session?.accessToken ?? '');
    } on AuthException catch (e) {
      if (e.code == 'identity_already_exists') {
        // Google account already exists — delete orphaned anonymous user via Edge
        // Function (uses service role key, cascades to public.users + devices),
        // then sign in with the existing account.
        await _deleteCurrentAnonymousUser();
        final res = await client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
        );
        return Credentials(id: res.user!.id, token: res.session?.accessToken ?? '');
      }
      rethrow;
    }
  }

  @override
  Future<Credentials> signupFromAnonymousWithFacebook() async {
    // Facebook on web for Supabase is not wired yet (roadmap); the button is hidden
    // on web, so this is a defensive guard.
    if (kIsWeb) {
      throw ApiError(code: 501, message: 'Facebook sign-in on web is not supported on Supabase.');
    }
    final loginResult = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );
    if (loginResult.status == LoginStatus.cancelled) throw const UserCancelledSignInException();
    if (loginResult.status != LoginStatus.success) {
      throw ApiError(code: 401, message: loginResult.message ?? 'Facebook login failed');
    }
    final accessToken = loginResult.accessToken?.tokenString;
    if (accessToken == null) {
      throw ApiError(code: 401, message: 'No Facebook access token');
    }
    try {
      final response = await client.auth.linkIdentityWithIdToken(
        provider: OAuthProvider.facebook,
        idToken: accessToken,
      );
      return Credentials(id: response.user!.id, token: response.session?.accessToken ?? '');
    } on AuthException catch (e) {
      if (e.code == 'identity_already_exists') {
        await _deleteCurrentAnonymousUser();
        final res = await client.auth.signInWithIdToken(
          provider: OAuthProvider.facebook,
          idToken: accessToken,
        );
        return Credentials(id: res.user!.id, token: res.session?.accessToken ?? '');
      }
      rethrow;
    }
  }

  @override
  Future<String> signinWithPhone(String phoneNumber) async {
    try {
      _logger.d('Requesting OTP for phone number: $phoneNumber');
      final normalizedPhone = _normalizePhoneNumber(phoneNumber);

      await client.auth.signInWithOtp(
        phone: normalizedPhone,
      );

      return normalizedPhone;
    } catch (e) {
      _logger.e('Error requesting phone authentication: $e');
      throw ApiError(
        code: 0,
        message: 'Failed to send verification code: $e',
      );
    }
  }

  @override
  Future<String> updateAuthPhone(String phoneNumber) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw ApiError(
        code: 401,
        message: 'User not found',
      );
    }
    try {
      final normalizedPhone = _normalizePhoneNumber(phoneNumber);
      await client.auth.updateUser(UserAttributes(phone: normalizedPhone));
      return normalizedPhone;
    } on AuthException catch (e) {
      final code = e.code;
      _logger.e('Error updating phone number: $code');
      if (code == 'phone_exists') {
        throw PhoneAlreadyLinkedException();
      }
      throw ApiError(
        code: 401,
        message: 'Failed to update phone number: $e',
      );
    } catch (e) {
      _logger.e('Error updating phone number: $e');
      throw ApiError(
        code: 0,
        message: 'Failed to update phone number: $e',
      );
    }
  }

  @override
  Future<Credentials> confirmLinkPhoneAuth(
    String verificationId,
    String otp,
  ) async {
    try {
      _logger.d('confirmLinkPhoneAuth OTP for phone: $verificationId');
      final phoneNumber = verificationId;

      final res = await client.auth.verifyOTP(
        phone: phoneNumber,
        token: otp,
        type: OtpType.phoneChange,
      );

      if (res.user == null) {
        throw ApiError(
          code: 401,
          message: 'Verification failed. Invalid OTP code.',
        );
      }

      return Credentials(
        id: res.user!.id,
        token: res.session?.accessToken ?? '',
      );
    } catch (e) {
      _logger.e('Error verifying phone OTP: $e');
      throw ApiError(
        code: 401,
        message: 'Failed to verify OTP: $e',
      );
    }
  }

  @override
  Future<Credentials> verifyPhoneAuth(String verificationId, String otp) async {
    try {
      _logger.d('Verifying OTP for phone: $verificationId');
      final phoneNumber = verificationId;

      final res = await client.auth.verifyOTP(
        phone: phoneNumber,
        token: otp,
        type: OtpType.sms,
      );

      if (res.user == null) {
        throw ApiError(
          code: 401,
          message: 'Verification failed. Invalid OTP code.',
        );
      }

      return Credentials(
        id: res.user!.id,
        token: res.session?.accessToken ?? '',
      );
    } catch (e) {
      _logger.e('Error verifying phone OTP: $e');
      throw ApiError(
        code: 401,
        message: 'Failed to verify OTP: $e',
      );
    }
  }

  @override
  Future<String?> getCurrentUserEmail() async => client.auth.currentUser?.email;

  @override
  Future<String?> getCurrentUserDisplayName() async =>
      client.auth.currentUser?.userMetadata?['full_name'] as String?;

  @override
  Future<String?> getCurrentUserPhotoUrl() async {
    final meta = client.auth.currentUser?.userMetadata;
    return (meta?['avatar_url'] ?? meta?['picture']) as String?;
  }

  @override
  Future<List<String>> getLinkedProviders() async {
    // Supabase exposes the linked identities in app_metadata['providers'].
    final raw = client.auth.currentUser?.appMetadata['providers'];
    if (raw is! List) return const [];
    return raw.map((p) => p.toString()).toList();
  }

  @override
  Future<void> setPassword(String password) async {
    // Supabase keeps the same user; sets/updates the password so a social-only
    // account can also sign in with email + password.
    await client.auth.updateUser(UserAttributes(password: password));
  }

  // Supabase auto-links identities with the same (confirmed) email on sign-in,
  // so there is no manual-link step: nothing to offer and nothing to do.
  @override
  Future<List<String>> linkableSocialProviders() async => const [];

  @override
  Future<void> linkSocialProvider(String provider) => Future.value();

  String _normalizePhoneNumber(String phoneNumber) {
    String normalized = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (!normalized.startsWith('+')) {
      normalized = '+$normalized';
    }
    return normalized;
  }

  /// Deletes the current anonymous user via the `delete-user-account` Edge
  /// Function, which runs with the service role key and cascades to
  /// public.users, devices, etc. Called before falling back to sign-in when
  /// `identity_already_exists` — prevents orphaned anonymous accounts.
  Future<void> _deleteCurrentAnonymousUser() async {
    if (client.auth.currentUser?.isAnonymous != true) return;
    try {
      await client.functions.invoke('delete-user-account');
    } catch (_) {
      // Deletion failed (e.g. function not deployed yet) — proceed anyway.
      // Orphaned accounts can be cleaned via Supabase Dashboard →
      // Auth → Configuration → "Clean up anonymous users".
    }
  }
}
