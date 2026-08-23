import 'dart:async';

import 'package:cowboydodartinc/core/data/api/base_api_exceptions.dart';
import 'package:cowboydodartinc/core/data/entities/user_entity.dart';
import 'package:cowboydodartinc/environments.dart';

import 'package:cowboydodartinc/features/authentication/api/authentication_api_interface.dart';
import 'package:cowboydodartinc/features/authentication/repositories/exceptions/authentication_exceptions.dart';
import 'package:cowboydodartinc/google_auth_options.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final authenticationApiProvider = Provider<AuthenticationApi>(
  (ref) => FirebaseAuthenticationApi(
    auth: fb_auth.FirebaseAuth.instance,
    environment: ref.watch(environmentProvider),
  ),
);

class FirebaseAuthenticationApi implements AuthenticationApi {
  final fb_auth.FirebaseAuth auth;
  final Environment environment;
  final Logger _logger = Logger();

  FirebaseAuthenticationApi({
    required this.auth,
    required this.environment,
  });

  @override
  Future<void> init() async {
    // Firebase auth handles redirect persistence automatically on Web.
  }

  @override
  Future<void> recoverPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw ApiError(code: 0, message: e.toString());
    }
  }

  @override
  Future<Credentials?> get() async {
    final user = auth.currentUser;
    if (user == null) {
      return null;
    }
    final token = await user.getIdToken() ?? '';
    return Credentials(id: user.uid, token: token);
  }

  @override
  Future<Credentials> signup(String email, String password) async {
    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final token = await cred.user?.getIdToken() ?? '';
      return Credentials(id: cred.user!.uid, token: token);
    } on fb_auth.FirebaseAuthException catch (e) {
      _logger.e("Error while signup: $e");
      throw ApiError(code: 400, message: e.message ?? 'Signup failed');
    } catch (e) {
      _logger.e("Error while signup: $e");
      throw ApiError(code: 0, message: e.toString());
    }
  }

  @override
  Future<Credentials> signin(String email, String password) async {
    try {
      final cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final token = await cred.user?.getIdToken() ?? '';
      return Credentials(id: cred.user!.uid, token: token);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw ApiError(code: 400, message: e.message ?? 'Signin failed');
    } catch (e) {
      throw ApiError(code: 0, message: e.toString());
    }
  }

  @override
  Future<Credentials> signinAnonymously() async {
    try {
      final cred = await auth.signInAnonymously();
      final token = await cred.user?.getIdToken() ?? '';
      return Credentials(id: cred.user!.uid, token: token);
    } on fb_auth.FirebaseAuthException catch (e) {
      _logger.e("Error while signing in anonymously: $e");
      throw ApiError(code: 400, message: e.message ?? 'Anonymous login failed');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Credentials> signinWithApple() async {
    if (kIsWeb) {
      final provider = fb_auth.AppleAuthProvider();
      final cred = await auth.signInWithPopup(provider);
      final token = await cred.user?.getIdToken() ?? '';
      return Credentials(id: cred.user!.uid, token: token);
    }
    
    late final AuthorizationCredentialAppleID appleCredential;
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
        ],
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) throw const UserCancelledSignInException();
      rethrow;
    }

    final idToken = appleCredential.identityToken;
    if (idToken == null) {
      throw ApiError(
        code: 400,
        message: 'Could not find ID Token from generated credential.',
      );
    }

    final credential = fb_auth.OAuthProvider('apple.com').credential(
      idToken: idToken,
      rawNonce: '',
    );
    final cred = await auth.signInWithCredential(credential);
    final token = await cred.user?.getIdToken() ?? '';
    return Credentials(id: cred.user!.uid, token: token);
  }

  @override
  Future<Credentials> signinWithFacebook() async {
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

    final credential = fb_auth.FacebookAuthProvider.credential(accessToken);
    final cred = await auth.signInWithCredential(credential);
    final token = await cred.user?.getIdToken() ?? '';
    return Credentials(id: cred.user!.uid, token: token);
  }

  @override
  Future<Credentials> signinWithGoogle() async {
    if (kIsWeb) {
      final provider = fb_auth.GoogleAuthProvider();
      final cred = await auth.signInWithPopup(provider);
      final token = await cred.user?.getIdToken() ?? '';
      return Credentials(id: cred.user!.uid, token: token);
    }

    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      clientId: kGoogleIosClientId.isEmpty ? null : kGoogleIosClientId,
      serverClientId: kGoogleWebClientId.isEmpty ? null : kGoogleWebClientId,
    );

    late final GoogleSignInAccount googleUser;
    try {
      googleUser = await googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) throw const UserCancelledSignInException();
      rethrow;
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled') {
        throw const UserCancelledSignInException();
      }
      rethrow;
    }

    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw 'No ID Token found.';
    }

    final credential = fb_auth.GoogleAuthProvider.credential(
      idToken: idToken,
    );
    final cred = await auth.signInWithCredential(credential);
    final token = await cred.user?.getIdToken() ?? '';
    return Credentials(id: cred.user!.uid, token: token);
  }

  @override
  Future<Credentials> signinWithGooglePlay() {
    throw UnsupportedError(
      'Google Play Games sign-in is not implemented.',
    );
  }

  @override
  Future<void> signout() async {
    await auth.signOut();
  }

  @override
  Future<Credentials> signupFromAnonymousWithApple() async {
    final user = auth.currentUser;
    if (user == null) throw 'No user is currently signed in.';
    
    late final AuthorizationCredentialAppleID appleCredential;
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) throw const UserCancelledSignInException();
      rethrow;
    }
    final idToken = appleCredential.identityToken;
    if (idToken == null) {
      throw ApiError(code: 400, message: 'Could not find ID Token from generated credential.');
    }

    final credential = fb_auth.OAuthProvider('apple.com').credential(
      idToken: idToken,
      rawNonce: '',
    );
    final cred = await user.linkWithCredential(credential);
    final token = await cred.user?.getIdToken() ?? '';
    return Credentials(id: cred.user!.uid, token: token);
  }

  @override
  Future<Credentials> signupFromAnonymousWithGoogle() async {
    final user = auth.currentUser;
    if (user == null) {
      return signinWithGoogle();
    }
    
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      clientId: kGoogleIosClientId.isEmpty ? null : kGoogleIosClientId,
      serverClientId: kGoogleWebClientId.isEmpty ? null : kGoogleWebClientId,
    );

    late final GoogleSignInAccount googleUser;
    try {
      googleUser = await googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) throw const UserCancelledSignInException();
      rethrow;
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled') {
        throw const UserCancelledSignInException();
      }
      rethrow;
    }

    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw 'No ID Token found.';
    }

    final credential = fb_auth.GoogleAuthProvider.credential(
      idToken: idToken,
    );
    final cred = await user.linkWithCredential(credential);
    final token = await cred.user?.getIdToken() ?? '';
    return Credentials(id: cred.user!.uid, token: token);
  }

  @override
  Future<Credentials> signupFromAnonymousWithFacebook() async {
    final user = auth.currentUser;
    if (user == null) return signinWithFacebook();

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

    final credential = fb_auth.FacebookAuthProvider.credential(accessToken);
    final cred = await user.linkWithCredential(credential);
    final token = await cred.user?.getIdToken() ?? '';
    return Credentials(id: cred.user!.uid, token: token);
  }

  @override
  Future<String> signinWithPhone(String phoneNumber) async {
    return phoneNumber;
  }

  @override
  Future<String> updateAuthPhone(String phoneNumber) async {
    final user = auth.currentUser;
    if (user == null) {
      throw ApiError(code: 401, message: 'User not found');
    }
    return phoneNumber;
  }

  @override
  Future<Credentials> confirmLinkPhoneAuth(
    String verificationId,
    String otp,
  ) async {
    final user = auth.currentUser;
    if (user == null) throw 'No user is connected';
    final credential = fb_auth.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    final cred = await user.linkWithCredential(credential);
    final token = await cred.user?.getIdToken() ?? '';
    return Credentials(id: cred.user!.uid, token: token);
  }

  @override
  Future<Credentials> verifyPhoneAuth(String verificationId, String otp) async {
    final credential = fb_auth.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    final cred = await auth.signInWithCredential(credential);
    final token = await cred.user?.getIdToken() ?? '';
    return Credentials(id: cred.user!.uid, token: token);
  }

  @override
  Future<String?> getCurrentUserEmail() async => auth.currentUser?.email;

  @override
  Future<String?> getCurrentUserDisplayName() async =>
      auth.currentUser?.displayName;

  @override
  Future<String?> getCurrentUserPhotoUrl() async => auth.currentUser?.photoURL;

  @override
  Future<List<String>> getLinkedProviders() async {
    final user = auth.currentUser;
    if (user == null) return const [];
    return user.providerData.map((info) => info.providerId).toList();
  }

  @override
  Future<void> setPassword(String password) async {
    await auth.currentUser?.updatePassword(password);
  }

  @override
  Future<List<String>> linkableSocialProviders() async {
    final linked = await getLinkedProviders();
    final all = ['google', 'apple', 'facebook'];
    return all.where((p) => !linked.contains(p)).toList();
  }

  @override
  Future<void> linkSocialProvider(String provider) async {
    if (provider == 'google') {
      await signupFromAnonymousWithGoogle();
    } else if (provider == 'apple') {
      await signupFromAnonymousWithApple();
    } else if (provider == 'facebook') {
      await signupFromAnonymousWithFacebook();
    }
  }
}
