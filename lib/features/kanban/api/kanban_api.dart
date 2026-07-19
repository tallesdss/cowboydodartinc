import 'package:cowboydodartinc/core/data/api/base_api_exceptions.dart';
import 'package:cowboydodartinc/features/kanban/api/entities/kanban_column_entity.dart';
import 'package:cowboydodartinc/features/kanban/api/entities/kanban_task_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final kanbanApiProvider = Provider<KanbanApi>(
  (ref) => KanbanApi(client: Supabase.instance.client),
);

const _kColumnsTable = 'kanban_columns';
const _kTasksTable = 'kanban_tasks';

/// Supabase-backed Kanban board. Schema lives in
/// supabase/migrations/20240101000016_kanban.sql. The board is global; RLS lets
/// any signed-in user read it and only admins (public.is_admin()) write it.
///
/// The Postgres columns are snake_case and use `position` for the entity's
/// `order` field; the `_columnJson` / `_taskJson` helpers map a row back to the
/// camelCase shape KanbanColumnEntity/KanbanTaskEntity.fromJson expect.
class KanbanApi {
  final SupabaseClient _client;

  KanbanApi({required SupabaseClient client}) : _client = client;

  Map<String, dynamic> _columnJson(Map<String, dynamic> row) => {
        'id': row['id'],
        'name': row['name'],
        'order': row['position'],
        'createdAt': row['created_at'],
        'updatedAt': row['updated_at'],
      };

  Map<String, dynamic> _taskJson(Map<String, dynamic> row) => {
        'id': row['id'],
        'title': row['title'],
        'description': row['description'],
        'columnId': row['column_id'],
        'order': row['position'],
        'priority': row['priority'],
        'createdAt': row['created_at'],
        'updatedAt': row['updated_at'],
      };

  // ───────────────────────────────────────────────────────────────────────────
  // Columns CRUD
  // ───────────────────────────────────────────────────────────────────────────

  Future<KanbanColumnEntity> createColumn(String name, int order) async {
    try {
      final res = await _client
          .from(_kColumnsTable)
          .insert({'name': name, 'position': order})
          .select()
          .single();
      return KanbanColumnEntity.fromJson(_columnJson(res));
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<List<KanbanColumnEntity>> getColumns() async {
    try {
      final res =
          await _client.from(_kColumnsTable).select().order('position');
      return res.map((e) => KanbanColumnEntity.fromJson(_columnJson(e))).toList();
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<void> updateColumn(String id, String name) async {
    try {
      await _client.from(_kColumnsTable).update({
        'name': name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<void> deleteColumn(String id) async {
    try {
      // Tasks cascade via the column_id ON DELETE CASCADE foreign key.
      await _client.from(_kColumnsTable).delete().eq('id', id);
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<void> reorderColumns(List<String> columnIds) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      for (var i = 0; i < columnIds.length; i++) {
        await _client
            .from(_kColumnsTable)
            .update({'position': i, 'updated_at': now}).eq('id', columnIds[i]);
      }
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Tasks CRUD
  // ───────────────────────────────────────────────────────────────────────────

  Future<KanbanTaskEntity> createTask({
    required String title,
    String? description,
    required String columnId,
    required int order,
    String? priority,
  }) async {
    try {
      final res = await _client
          .from(_kTasksTable)
          .insert({
            'title': title,
            'description': description,
            'column_id': columnId,
            'position': order,
            'priority': priority,
          })
          .select()
          .single();
      return KanbanTaskEntity.fromJson(_taskJson(res));
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<List<KanbanTaskEntity>> getTasks() async {
    try {
      final res = await _client.from(_kTasksTable).select().order('position');
      return res.map((e) => KanbanTaskEntity.fromJson(_taskJson(e))).toList();
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  // [updatePriority] must be true to write the priority field (allows null to clear it).
  Future<void> updateTask({
    required String id,
    String? title,
    String? description,
    String? priority,
    bool updatePriority = false,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (updatePriority) updates['priority'] = priority;

      await _client.from(_kTasksTable).update(updates).eq('id', id);
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<void> moveTask({
    required String id,
    required String newColumnId,
    required int newOrder,
  }) async {
    try {
      await _client.from(_kTasksTable).update({
        'column_id': newColumnId,
        'position': newOrder,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _client.from(_kTasksTable).delete().eq('id', id);
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<void> reorderTasks(List<String> taskIds) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      for (var i = 0; i < taskIds.length; i++) {
        await _client
            .from(_kTasksTable)
            .update({'position': i, 'updated_at': now}).eq('id', taskIds[i]);
      }
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }
}
