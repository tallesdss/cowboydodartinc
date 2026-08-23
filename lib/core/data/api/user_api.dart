import 'dart:typed_data';

import 'package:cowboydodartinc/core/data/entities/upload_result.dart';
import 'package:cowboydodartinc/core/data/entities/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userApiProvider = Provider<UserApi>(
  (ref) => UserApi(),
);

class UserApi {
  final Map<String, UserEntity> _users = {};

  UserApi() {
    _users['dartdynamicsprogramadores@gmail.co'] = UserEntity(
      id: 'dartdynamicsprogramadores@gmail.co',
      email: 'dartdynamicsprogramadores@gmail.co',
      name: 'Dart Dynamics',
      role: 'admin',
      onboarded: true,
      creationDate: DateTime.now(),
      lastUpdateDate: DateTime.now(),
    );
  }

  Future<UserEntity?> get(String id) async {
    if (!_users.containsKey(id)) {
      _users[id] = UserEntity(
        id: id,
        email: id,
        name: 'Mock User',
        role: id.contains('admin') ? 'admin' : 'cliente',
        onboarded: true,
        creationDate: DateTime.now(),
        lastUpdateDate: DateTime.now(),
      );
    }
    return _users[id];
  }

  Stream<String?> watchRole(String id) async* {
    yield _users[id]?.role ?? 'cliente';
  }

  Future<void> update(UserEntity user) async {
    final existing = _users[user.id] ?? UserEntity(id: user.id);
    _users[user.id!] = existing.copyWith(
      email: user.email ?? existing.email,
      name: user.name ?? existing.name,
      bio: user.bio ?? existing.bio,
      avatarPath: user.avatarPath ?? existing.avatarPath,
      onboarded: user.onboarded ?? existing.onboarded,
      locale: user.locale ?? existing.locale,
      role: user.role ?? existing.role,
    );
  }

  Future<void> delete(String userId) async {
    _users.remove(userId);
  }

  Future<void> deleteMe() async {}

  Future<void> create(UserEntity user) async {
    _users[user.id!] = user;
  }

  Stream<UploadResult> updateAvatar(
    String userId,
    Uint8List data,
  ) async* {
    yield UploadResultCompleted(imagePath: 'mock-path', imagePublicUrl: 'mock-url');
  }

  Future<void> deleteAvatar(String userId) async {
    final user = _users[userId];
    if (user != null) {
      _users[userId] = user.copyWith(avatarPath: null);
    }
  }

  Future<void> updateLocale(String userId, String locale) async {
    final user = _users[userId];
    if (user != null) {
      _users[userId] = user.copyWith(locale: locale);
    }
  }
}
