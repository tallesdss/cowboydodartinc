import 'dart:async';

import 'package:cowboydodartinc/core/data/entities/user_entity.dart';

import 'package:cowboydodartinc/features/authentication/api/authentication_api_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authenticationApiProvider = Provider<AuthenticationApi>(
  (ref) => MockAuthenticationApi(),
);

class MockAuthenticationApi implements AuthenticationApi {
  Credentials? _current;
  String? _email;
  String? _name;

  @override
  Future<void> init() async {}

  @override
  Future<Credentials?> get() async => _current;

  @override
  Future<Credentials> signup(String email, String password) async {
    _email = email;
    _current = Credentials(id: email, token: 'mock-token-$email');
    return _current!;
  }

  @override
  Future<Credentials> signin(String email, String password) async {
    _email = email;
    _current = Credentials(id: email, token: 'mock-token-$email');
    return _current!;
  }

  @override
  Future<void> signout() async {
    _current = null;
    _email = null;
    _name = null;
  }

  @override
  Future<Credentials> signinAnonymously() async {
    _current = Credentials(id: 'anon-${DateTime.now().millisecondsSinceEpoch}', token: 'mock-anon');
    return _current!;
  }

  @override
  Future<Credentials> signinWithGoogle() => signinAnonymously();

  @override
  Future<Credentials> signinWithGooglePlay() => signinAnonymously();

  @override
  Future<Credentials> signinWithFacebook() => signinAnonymously();

  @override
  Future<Credentials> signinWithApple() => signinAnonymously();

  @override
  Future<void> recoverPassword(String email) async {}

  @override
  Future<Credentials> signupFromAnonymousWithGoogle() async => _current ?? await signinAnonymously();

  @override
  Future<Credentials> signupFromAnonymousWithApple() async => _current ?? await signinAnonymously();

  @override
  Future<Credentials> signupFromAnonymousWithFacebook() async => _current ?? await signinAnonymously();

  @override
  Future<String> signinWithPhone(String phoneNumber) async => 'verification-id';

  @override
  Future<Credentials> verifyPhoneAuth(String verificationId, String otp) => signinAnonymously();

  @override
  Future<String> updateAuthPhone(String phoneNumber) async => phoneNumber;

  @override
  Future<Credentials> confirmLinkPhoneAuth(String verificationId, String otp) async => _current ?? await signinAnonymously();

  @override
  Future<String?> getCurrentUserEmail() async => _email;

  @override
  Future<String?> getCurrentUserDisplayName() async => _name;

  @override
  Future<String?> getCurrentUserPhotoUrl() async => null;

  @override
  Future<List<String>> getLinkedProviders() async => ['email'];

  @override
  Future<void> setPassword(String password) async {}

  @override
  Future<List<String>> linkableSocialProviders() async => ['google', 'apple', 'facebook'];

  @override
  Future<void> linkSocialProvider(String provider) async {}
}
