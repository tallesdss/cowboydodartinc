import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_users_api.dart';

class AdminUsersMockStorage {
  static final AdminUsersMockStorage instance = AdminUsersMockStorage._internal();

  AdminUsersMockStorage._internal() {
    _users.addAll(_generateMockUsers());
  }

  final List<AdminUser> _users = [];

  List<AdminUser> _generateMockUsers() {
    final now = DateTime.now();
    return [
      AdminUser(
        id: 'user_1',
        email: 'admin@cowboydodart.com',
        name: 'Administrador Principal',
        createdAt: now.subtract(const Duration(days: 60)),
        subscriber: true,
        role: 'admin',
      ),
      AdminUser(
        id: 'user_2',
        email: 'joao.silva@example.com',
        name: 'João Silva',
        createdAt: now.subtract(const Duration(days: 45)),
        subscriber: true,
      ),
      AdminUser(
        id: 'user_3',
        email: 'maria.souza@example.com',
        name: 'Maria Souza',
        createdAt: now.subtract(const Duration(days: 30)),
        subscriber: false,
      ),
      AdminUser(
        id: 'user_4',
        email: 'carlos.pereira@example.com',
        name: 'Carlos Pereira',
        createdAt: now.subtract(const Duration(days: 15)),
        subscriber: true,
        blocked: true,
      ),
      AdminUser(
        id: 'user_5',
        email: 'lucas.fernandes@example.com',
        name: 'Lucas Fernandes',
        createdAt: now.subtract(const Duration(days: 10)),
        subscriber: false,
      ),
      AdminUser(
        id: 'user_6',
        email: 'ana.costa@example.com',
        name: 'Ana Costa',
        createdAt: now.subtract(const Duration(days: 5)),
        subscriber: true,
      ),
      AdminUser(
        id: 'user_7',
        createdAt: now.subtract(const Duration(days: 2)),
        subscriber: false,
      ),
      for (int i = 8; i <= 20; i++)
        AdminUser(
          id: 'user_$i',
          email: 'usuario_$i@example.com',
          name: 'Usuário de Teste $i',
          createdAt: now.subtract(Duration(days: i)),
          subscriber: i % 3 == 0,
          blocked: i % 7 == 0,
        ),
    ];
  }

  Future<AdminUsersPage> fetchPage(AdminUsersQuery query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    var filtered = List<AdminUser>.from(_users);

    if (query.subscribersOnly) {
      filtered = filtered.where((u) => u.subscriber).toList();
    }

    if (query.search.trim().isNotEmpty) {
      final s = query.search.trim().toLowerCase();
      filtered = filtered.where((u) {
        final matchEmail = u.email?.toLowerCase().contains(s) == true;
        final matchName = u.name?.toLowerCase().contains(s) == true;
        return matchEmail || matchName;
      }).toList();
    }

    filtered.sort((a, b) {
      int cmp = 0;
      switch (query.sort) {
        case AdminUsersSort.user:
          final nameA = (a.name ?? a.email ?? '').toLowerCase();
          final nameB = (b.name ?? b.email ?? '').toLowerCase();
          cmp = nameA.compareTo(nameB);
        case AdminUsersSort.status:
          final statusA = a.blocked ? 0 : 1;
          final statusB = b.blocked ? 0 : 1;
          cmp = statusA.compareTo(statusB);
        case AdminUsersSort.plan:
          final planA = a.subscriber ? 1 : 0;
          final planB = b.subscriber ? 1 : 0;
          cmp = planA.compareTo(planB);
        case AdminUsersSort.joined:
          final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          cmp = dateA.compareTo(dateB);
        case AdminUsersSort.defaultOrder:
          final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          cmp = dateB.compareTo(dateA); // newest first
      }
      return query.sortAsc ? cmp : -cmp;
    });

    final total = filtered.length;
    final startIndex = query.page * query.pageSize;
    final endIndex = (startIndex + query.pageSize).clamp(0, total);
    
    final pageUsers = startIndex < total ? filtered.sublist(startIndex, endIndex) : <AdminUser>[];

    return AdminUsersPage(
      users: pageUsers,
      totalUsers: total,
      page: query.page,
      pageSize: query.pageSize,
      pageCount: total == 0 ? 1 : (total / query.pageSize).ceil(),
    );
  }

  Future<AdminUsersOverviewStats> fetchOverview() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    int subscribers = 0;
    int new7d = 0;
    final now = DateTime.now();
    final cutoff7d = now.subtract(const Duration(days: 7));
    
    final daily = List<int>.filled(14, 0);

    for (final u in _users) {
      if (u.subscriber) subscribers++;
      if (u.createdAt != null && u.createdAt!.isAfter(cutoff7d)) {
        new7d++;
      }
      if (u.createdAt != null) {
        final daysAgo = now.difference(u.createdAt!).inDays;
        if (daysAgo >= 0 && daysAgo < 14) {
          daily[13 - daysAgo]++;
        }
      }
    }

    return AdminUsersOverviewStats(
      totalUsers: _users.length,
      subscribers: subscribers,
      new7d: new7d,
      daily: daily,
      firstDay: now.subtract(const Duration(days: 13)),
      lastDay: now,
    );
  }

  Future<void> updateRole(String id, String role) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      final old = _users[idx];
      _users[idx] = AdminUser(
        id: old.id,
        subscriber: old.subscriber,
        email: old.email,
        name: old.name,
        createdAt: old.createdAt,
        avatarPath: old.avatarPath,
        role: role,
        blocked: old.blocked,
      );
    }
  }

  Future<void> toggleBlock(String id, bool blocked) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      final old = _users[idx];
      _users[idx] = AdminUser(
        id: old.id,
        subscriber: old.subscriber,
        email: old.email,
        name: old.name,
        createdAt: old.createdAt,
        avatarPath: old.avatarPath,
        role: old.role,
        blocked: blocked,
      );
    }
  }
}
