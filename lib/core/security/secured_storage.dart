import 'package:cowboydodartinc/core/data/entities/user_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kTokenKey = "token";
const _kUserIdKey = "userId";

final authSecuredStorageProvider = Provider<AuthSecuredStorage>(
  (ref) => AuthSecuredStorage.fromEnv(),
);

abstract class AuthSecuredStorage {
  Future<void> write({required Credentials value});
  Future<Credentials?> read();
  Future<void> clear();

  // Web uses SharedPreferences (LocalStorage) because flutter_secure_storage
  // has no real on-disk persistence in the browser. Mobile keeps the Keychain
  // / EncryptedSharedPreferences backend it had before.
  factory AuthSecuredStorage.fromEnv() {
    if (kIsWeb) return _WebAuthStorage();
    return _NativeAuthStorage(storage: const FlutterSecureStorage());
  }
}

class _NativeAuthStorage implements AuthSecuredStorage {
  final FlutterSecureStorage _storage;

  _NativeAuthStorage({required FlutterSecureStorage storage}) : _storage = storage;

  @override
  Future<void> write({required Credentials value}) async {
    await _storage.write(key: _kUserIdKey, value: value.id);
    await _storage.write(key: _kTokenKey, value: value.token);
  }

  @override
  Future<Credentials?> read() async {
    final userId = await _storage.read(key: _kUserIdKey);
    final token = await _storage.read(key: _kTokenKey);
    if (userId != null && token != null) {
      return Credentials(id: userId, token: token);
    }
    return null;
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _kUserIdKey);
    await _storage.delete(key: _kTokenKey);
  }
}

class _WebAuthStorage implements AuthSecuredStorage {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<void> write({required Credentials value}) async {
    final prefs = await _prefs;
    await prefs.setString(_kUserIdKey, value.id);
    if (value.token != null) {
      await prefs.setString(_kTokenKey, value.token!);
    } else {
      await prefs.remove(_kTokenKey);
    }
  }

  @override
  Future<Credentials?> read() async {
    final prefs = await _prefs;
    final userId = prefs.getString(_kUserIdKey);
    final token = prefs.getString(_kTokenKey);
    if (userId != null && token != null) {
      return Credentials(id: userId, token: token);
    }
    return null;
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_kUserIdKey);
    await prefs.remove(_kTokenKey);
  }
}
