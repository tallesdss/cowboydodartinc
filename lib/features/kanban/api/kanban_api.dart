import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowboydodartinc/core/data/api/base_api_exceptions.dart';
import 'package:cowboydodartinc/features/kanban/api/entities/kanban_column_entity.dart';
import 'package:cowboydodartinc/features/kanban/api/entities/kanban_task_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final kanbanApiProvider = Provider<KanbanApi>(
  (ref) => KanbanApi(firestore: FirebaseFirestore.instance),
);

const _kColumnsCollection = 'kanban_columns';
const _kTasksCollection = 'kanban_tasks';

/// Firebase Firestore backed Kanban board.
class KanbanApi {
  final FirebaseFirestore _firestore;

  KanbanApi({required FirebaseFirestore firestore}) : _firestore = firestore;

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
      final docRef = _firestore.collection(_kColumnsCollection).doc();
      final data = {
        'id': docRef.id,
        'name': name,
        'position': order,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      await docRef.set(data);
      return KanbanColumnEntity.fromJson(_columnJson(data));
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<List<KanbanColumnEntity>> getColumns() async {
    try {
      final res = await _firestore.collection(_kColumnsCollection).orderBy('position').get();
      return res.docs.map((e) => KanbanColumnEntity.fromJson(_columnJson(e.data()))).toList();
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<void> updateColumn(String id, String name) async {
    try {
      await _firestore.collection(_kColumnsCollection).doc(id).update({
        'name': name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<void> deleteColumn(String id) async {
    try {
      final tasksSnapshot = await _firestore
          .collection(_kTasksCollection)
          .where('column_id', isEqualTo: id)
          .get();
      final batch = _firestore.batch();
      for (final doc in tasksSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_firestore.collection(_kColumnsCollection).doc(id));
      await batch.commit();
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<void> reorderColumns(List<String> columnIds) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final batch = _firestore.batch();
      for (var i = 0; i < columnIds.length; i++) {
        batch.update(_firestore.collection(_kColumnsCollection).doc(columnIds[i]), {
          'position': i,
          'updated_at': now,
        });
      }
      await batch.commit();
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
      final docRef = _firestore.collection(_kTasksCollection).doc();
      final data = {
        'id': docRef.id,
        'title': title,
        'description': description,
        'column_id': columnId,
        'position': order,
        'priority': priority,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      await docRef.set(data);
      return KanbanTaskEntity.fromJson(_taskJson(data));
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<List<KanbanTaskEntity>> getTasks() async {
    try {
      final res = await _firestore.collection(_kTasksCollection).orderBy('position').get();
      return res.docs.map((e) => KanbanTaskEntity.fromJson(_taskJson(e.data()))).toList();
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

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

      await _firestore.collection(_kTasksCollection).doc(id).update(updates);
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
      await _firestore.collection(_kTasksCollection).doc(id).update({
        'column_id': newColumnId,
        'position': newOrder,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _firestore.collection(_kTasksCollection).doc(id).delete();
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<void> reorderTasks(List<String> taskIds) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final batch = _firestore.batch();
      for (var i = 0; i < taskIds.length; i++) {
        batch.update(_firestore.collection(_kTasksCollection).doc(taskIds[i]), {
          'position': i,
          'updated_at': now,
        });
      }
      await batch.commit();
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }
}
