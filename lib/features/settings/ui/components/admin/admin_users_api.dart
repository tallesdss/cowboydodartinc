import 'package:cloud_functions/cloud_functions.dart';
import 'package:cowboydodartinc/core/data/api/base_api_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One row of the admin Users table, as returned by the `admin-list-users` Edge
/// Function. The function verifies the caller is `role == "admin"` and only then
/// reads across all users with the service role.
///
/// Shared admin data-layer contract — public surface matches Firebase/API so the
/// Users tab UI stays the same; only [AdminUsersApi] bodies differ.
class AdminUser {
  final String id;
  final String? email;
  final String? name;
  final DateTime? createdAt;
  final String? avatarPath;
  final bool subscriber;
  final String? role;
  final bool blocked;

  const AdminUser({
    required this.id,
    required this.subscriber,
    this.email,
    this.name,
    this.createdAt,
    this.avatarPath,
    this.role = 'user',
    this.blocked = false,
  });

  factory AdminUser.fromMap(Map<String, dynamic> m) {
    final createdMillis = m['createdAt'];
    return AdminUser(
      id: (m['id'] as String?) ?? '',
      email: m['email'] as String?,
      name: m['name'] as String?,
      createdAt: createdMillis is num
          ? DateTime.fromMillisecondsSinceEpoch(createdMillis.toInt())
          : null,
      avatarPath: m['avatarPath'] as String?,
      subscriber: m['subscriber'] == true,
      role: m['role'] as String? ?? 'user',
      blocked: m['blocked'] == true,
    );
  }
}

enum AdminUsersSort {
  defaultOrder,
  user,
  status,
  plan,
  joined;

  String get wireName => switch (this) {
        AdminUsersSort.defaultOrder => 'default',
        AdminUsersSort.user => 'user',
        AdminUsersSort.status => 'status',
        AdminUsersSort.plan => 'plan',
        AdminUsersSort.joined => 'joined',
      };
}

@immutable
class AdminUsersQuery {
  final int page;
  final int pageSize;
  final String search;
  final bool subscribersOnly;
  final AdminUsersSort sort;
  final bool sortAsc;

  const AdminUsersQuery({
    this.page = 0,
    this.pageSize = 10,
    this.search = '',
    this.subscribersOnly = false,
    this.sort = AdminUsersSort.defaultOrder,
    this.sortAsc = true,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (subscribersOnly) 'subscribersOnly': true,
        'sort': sort.wireName,
        'sortAsc': sortAsc,
      };

  @override
  bool operator ==(Object other) =>
      other is AdminUsersQuery &&
      other.page == page &&
      other.pageSize == pageSize &&
      other.search == search &&
      other.subscribersOnly == subscribersOnly &&
      other.sort == sort &&
      other.sortAsc == sortAsc;

  @override
  int get hashCode => Object.hash(
        page,
        pageSize,
        search,
        subscribersOnly,
        sort,
        sortAsc,
      );
}

class AdminUsersPage {
  final List<AdminUser> users;
  final int totalUsers;
  final int page;
  final int pageSize;
  final int pageCount;
  final bool searchCapped;

  const AdminUsersPage({
    required this.users,
    required this.totalUsers,
    required this.page,
    required this.pageSize,
    required this.pageCount,
    this.searchCapped = false,
  });

  factory AdminUsersPage.fromMap(Map<String, dynamic> data) {
    final rawUsers = (data['users'] as List?) ?? const [];
    final int pageSize = (data['pageSize'] as num?)?.toInt() ?? 10;
    final int totalUsers = (data['totalUsers'] as num?)?.toInt() ?? 0;
    final int pageCount = (data['pageCount'] as num?)?.toInt() ??
        (totalUsers == 0 ? 1 : (totalUsers / pageSize).ceil());
    return AdminUsersPage(
      users: rawUsers
          .map((e) => AdminUser.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      totalUsers: totalUsers,
      page: (data['page'] as num?)?.toInt() ?? 0,
      pageSize: pageSize,
      pageCount: pageCount,
      searchCapped: data['searchCapped'] == true,
    );
  }

  int get rangeFrom => totalUsers == 0 ? 0 : page * pageSize + 1;
  int get rangeTo =>
      totalUsers == 0 ? 0 : (page * pageSize + users.length).clamp(0, totalUsers);
}

class AdminUsersOverviewStats {
  final int totalUsers;
  final int subscribers;
  final int new7d;
  final List<int> daily;
  final DateTime firstDay;
  final DateTime lastDay;

  const AdminUsersOverviewStats({
    required this.totalUsers,
    required this.subscribers,
    required this.new7d,
    required this.daily,
    required this.firstDay,
    required this.lastDay,
  });

  factory AdminUsersOverviewStats.fromMap(Map<String, dynamic> data) {
    final List<int> daily = ((data['daily'] as List?) ?? const [])
        .map((e) => (e as num).toInt())
        .toList();
    final int firstMs = (data['firstDayMs'] as num?)?.toInt() ?? 0;
    final int lastMs = (data['lastDayMs'] as num?)?.toInt() ?? 0;
    return AdminUsersOverviewStats(
      totalUsers: (data['totalUsers'] as num?)?.toInt() ?? 0,
      subscribers: (data['subscribers'] as num?)?.toInt() ?? 0,
      new7d: (data['new7d'] as num?)?.toInt() ?? 0,
      daily: daily.length == 14 ? daily : List<int>.filled(14, 0),
      firstDay: DateTime.fromMillisecondsSinceEpoch(firstMs),
      lastDay: DateTime.fromMillisecondsSinceEpoch(lastMs),
    );
  }

  int get free => (totalUsers - subscribers).clamp(0, totalUsers);
  int get signups14 => daily.fold(0, (a, b) => a + b);
  int get conversionPercent =>
      totalUsers == 0 ? 0 : (subscribers / totalUsers * 100).round();
}


final adminUsersApiProvider = Provider<AdminUsersApi>(
  (ref) => AdminUsersApi(functions: FirebaseFunctions.instance),
);

class AdminUsersApi {
  final FirebaseFunctions _functions;

  AdminUsersApi({required FirebaseFunctions functions}) : _functions = functions;

  Future<AdminUsersPage> fetchPage(AdminUsersQuery query) async {
    try {
      final callable = _functions.httpsCallable('adminFunctions-listUsers');
      final result = await callable.call<Map<String, dynamic>>(query.toJson());
      return AdminUsersPage.fromMap(result.data);
    } catch (e, stacktrace) {
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<AdminUsersOverviewStats> fetchOverview() async {
    try {
      final callable = _functions.httpsCallable('adminFunctions-listUsers');
      final result = await callable.call<Map<String, dynamic>>({'overview': true});
      return AdminUsersOverviewStats.fromMap(result.data);
    } catch (e, stacktrace) {
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<void> updateRole(String id, String role) async {
    try {
      final callable = _functions.httpsCallable('adminFunctions-updateUserRole');
      await callable.call<Map<String, dynamic>>({'userId': id, 'role': role});
    } catch (e, stacktrace) {
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<void> toggleBlock(String id, bool blocked) async {
    try {
      final callable = _functions.httpsCallable('adminFunctions-toggleUserBlock');
      await callable.call<Map<String, dynamic>>({'userId': id, 'blocked': blocked});
    } catch (e, stacktrace) {
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }
}
