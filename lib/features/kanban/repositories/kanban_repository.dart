import 'package:cowboydodartinc/features/kanban/api/kanban_api.dart';
import 'package:cowboydodartinc/features/kanban/domain/kanban_column.dart';
import 'package:cowboydodartinc/features/kanban/domain/kanban_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final kanbanRepositoryProvider = Provider<KanbanRepository>(
  (ref) => KanbanRepository(kanbanApi: ref.read(kanbanApiProvider)),
);

class KanbanRepository {
  final KanbanApi _kanbanApi;

  KanbanRepository({required KanbanApi kanbanApi}) : _kanbanApi = kanbanApi;

  // ─────────────────────────────────────────────────────────────────────────
  // Columns
  // ─────────────────────────────────────────────────────────────────────────

  Future<KanbanColumn> createColumn(String name, int order) async {
    final entity = await _kanbanApi.createColumn(name, order);
    return KanbanColumn.fromEntity(entity);
  }

  Future<List<KanbanColumn>> getColumns() async {
    final entities = await _kanbanApi.getColumns();
    return entities.map(KanbanColumn.fromEntity).toList();
  }

  Future<void> updateColumn(String id, String name) async {
    await _kanbanApi.updateColumn(id, name);
  }

  Future<void> deleteColumn(String id) async {
    await _kanbanApi.deleteColumn(id);
  }

  Future<void> reorderColumns(List<String> columnIds) async {
    await _kanbanApi.reorderColumns(columnIds);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tasks
  // ─────────────────────────────────────────────────────────────────────────

  Future<KanbanTask> createTask({
    required String title,
    String? description,
    required String columnId,
    required int order,
    String? priority,
  }) async {
    final entity = await _kanbanApi.createTask(
      title: title,
      description: description,
      columnId: columnId,
      order: order,
      priority: priority,
    );
    return KanbanTask.fromEntity(entity);
  }

  Future<List<KanbanTask>> getTasks() async {
    final entities = await _kanbanApi.getTasks();
    return entities.map(KanbanTask.fromEntity).toList();
  }

  Future<void> updateTask({
    required String id,
    String? title,
    String? description,
    String? priority,
    bool updatePriority = false,
  }) async {
    await _kanbanApi.updateTask(
      id: id,
      title: title,
      description: description,
      priority: priority,
      updatePriority: updatePriority,
    );
  }

  Future<void> moveTask({
    required String id,
    required String newColumnId,
    required int newOrder,
  }) async {
    await _kanbanApi.moveTask(
      id: id,
      newColumnId: newColumnId,
      newOrder: newOrder,
    );
  }

  Future<void> deleteTask(String id) async {
    await _kanbanApi.deleteTask(id);
  }

  Future<void> reorderTasks(List<String> taskIds) async {
    await _kanbanApi.reorderTasks(taskIds);
  }
}
