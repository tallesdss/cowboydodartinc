import 'package:cowboydodartinc/features/kanban/domain/kanban_column.dart';
import 'package:cowboydodartinc/features/kanban/domain/kanban_task.dart';
import 'package:cowboydodartinc/features/kanban/providers/models/kanban_state.dart';
import 'package:cowboydodartinc/features/kanban/repositories/kanban_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kanban_notifier.g.dart';

@riverpod
class KanbanNotifier extends _$KanbanNotifier {
  @override
  Future<KanbanState> build() {
    return _loadData();
  }

  Future<KanbanState> _loadData() async {
    final repository = ref.read(kanbanRepositoryProvider);
    var columns = await repository.getColumns();

    if (columns.isEmpty) {
      await _seedDefaultColumns(repository);
      columns = await repository.getColumns();
    }

    final tasks = await repository.getTasks();

    return KanbanState(
      columns: columns..sort((a, b) => a.order.compareTo(b.order)),
      tasks: tasks,
      isLoading: false,
    );
  }

  Future<void> _seedDefaultColumns(KanbanRepository repository) async {
    const defaultNames = ['To Do', 'In Progress', 'In Review', 'Done'];
    for (int i = 0; i < defaultNames.length; i++) {
      await repository.createColumn(defaultNames[i], i);
    }
  }

  // Silent background sync — never flashes a loading spinner.
  Future<void> refresh() async {
    final newState = await AsyncValue.guard(_loadData);
    state = newState;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Columns
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> createColumn(String name) async {
    final currentState = state.value;
    if (currentState == null) return;

    final order = currentState.columns.length;
    final repository = ref.read(kanbanRepositoryProvider);
    final created = await repository.createColumn(name, order);

    // Add the created column (with server ID) directly — no loading flash.
    state = AsyncValue.data(
      currentState.copyWith(columns: [...currentState.columns, created]),
    );
  }

  Future<void> updateColumn(String id, String name) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic: update name immediately.
    state = AsyncValue.data(
      currentState.copyWith(
        columns: currentState.columns
            .map((c) => c.id == id ? c.copyWith(name: name) : c)
            .toList(),
      ),
    );

    final repository = ref.read(kanbanRepositoryProvider);
    await repository.updateColumn(id, name);
  }

  Future<void> deleteColumn(String id) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic: remove column and its tasks immediately.
    state = AsyncValue.data(
      currentState.copyWith(
        columns: currentState.columns.where((c) => c.id != id).toList(),
        tasks: currentState.tasks.where((t) => t.columnId != id).toList(),
      ),
    );

    final repository = ref.read(kanbanRepositoryProvider);
    await repository.deleteColumn(id);
  }

  Future<void> reorderColumns(int oldIndex, int newIndex) async {
    final currentState = state.value;
    if (currentState == null) return;

    final columns = List<KanbanColumn>.from(currentState.columns);
    final adjustedNewIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    final column = columns.removeAt(oldIndex);
    columns.insert(adjustedNewIndex, column);

    state = AsyncValue.data(currentState.copyWith(columns: columns));

    final repository = ref.read(kanbanRepositoryProvider);
    await repository.reorderColumns(columns.map((c) => c.id).toList());
  }

  // Set the definitive column order (preview → committed).
  Future<void> commitColumnOrder(List<KanbanColumn> newOrder) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(columns: newOrder));

    final repository = ref.read(kanbanRepositoryProvider);
    await repository.reorderColumns(newOrder.map((c) => c.id).toList());
  }

  Future<void> moveColumnLeft(String columnId) async {
    final currentState = state.value;
    if (currentState == null) return;

    final columns = List<KanbanColumn>.from(currentState.columns);
    final index = columns.indexWhere((c) => c.id == columnId);
    if (index <= 0) return;

    final column = columns.removeAt(index);
    columns.insert(index - 1, column);

    state = AsyncValue.data(currentState.copyWith(columns: columns));

    final repository = ref.read(kanbanRepositoryProvider);
    await repository.reorderColumns(columns.map((c) => c.id).toList());
  }

  Future<void> moveColumnRight(String columnId) async {
    final currentState = state.value;
    if (currentState == null) return;

    final columns = List<KanbanColumn>.from(currentState.columns);
    final index = columns.indexWhere((c) => c.id == columnId);
    if (index < 0 || index >= columns.length - 1) return;

    final column = columns.removeAt(index);
    columns.insert(index + 1, column);

    state = AsyncValue.data(currentState.copyWith(columns: columns));

    final repository = ref.read(kanbanRepositoryProvider);
    await repository.reorderColumns(columns.map((c) => c.id).toList());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tasks
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> createTask({
    required String title,
    String? description,
    required String columnId,
    TaskPriority? priority,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    final order = currentState.getTasksForColumn(columnId).length;
    final repository = ref.read(kanbanRepositoryProvider);
    final created = await repository.createTask(
      title: title,
      description: description,
      columnId: columnId,
      order: order,
      priority: priority?.name,
    );

    // Add created task (with server ID + timestamps) to state.
    state = AsyncValue.data(
      currentState.copyWith(tasks: [...currentState.tasks, created]),
    );
  }

  Future<void> updateTask({
    required String id,
    String? title,
    String? description,
    TaskPriority? priority,
    bool updatePriority = false,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic: update task fields immediately.
    final taskIndex = currentState.tasks.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      final task = currentState.tasks[taskIndex];
      final updated = task.copyWith(
        title: title ?? task.title,
        description: description ?? task.description,
        priority: updatePriority ? priority : task.priority,
      );
      final newTasks = List<KanbanTask>.from(currentState.tasks);
      newTasks[taskIndex] = updated;
      state = AsyncValue.data(currentState.copyWith(tasks: newTasks));
    }

    final repository = ref.read(kanbanRepositoryProvider);
    await repository.updateTask(
      id: id,
      title: title,
      description: description,
      priority: priority?.name,
      updatePriority: updatePriority,
    );
  }

  Future<void> deleteTask(String id) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic: remove immediately.
    state = AsyncValue.data(
      currentState.copyWith(
        tasks: currentState.tasks.where((t) => t.id != id).toList(),
      ),
    );

    final repository = ref.read(kanbanRepositoryProvider);
    await repository.deleteTask(id);
  }

  // Reorder tasks within the same column (drag-and-drop drop zone).
  Future<void> reorderTasksInColumn({
    required String columnId,
    required int oldIndex,
    required int newIndex,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    final tasks = List<KanbanTask>.from(currentState.getTasksForColumn(columnId));
    // Drop zone index semantics match ReorderableListView: adjust before insert.
    final adjustedNew = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final task = tasks.removeAt(oldIndex);
    tasks.insert(adjustedNew, task);

    // Must update the order field or getTasksForColumn re-sorts to old order.
    final withOrder = List.generate(tasks.length, (i) => tasks[i].copyWith(order: i));

    state = AsyncValue.data(
      currentState.copyWith(
        tasks: [
          ...currentState.tasks.where((t) => t.columnId != columnId),
          ...withOrder,
        ],
      ),
    );

    final repository = ref.read(kanbanRepositoryProvider);
    await repository.reorderTasks(withOrder.map((t) => t.id).toList());
  }

  // Move a task to a different column (or same column at a new index).
  Future<void> moveTask({
    required String taskId,
    required String targetColumnId,
    required int targetIndex,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    final task = currentState.tasks.firstWhere((t) => t.id == taskId);
    final sourceColumnId = task.columnId;

    final sourceTasks = currentState
        .getTasksForColumn(sourceColumnId)
        .where((t) => t.id != taskId)
        .toList();

    final targetTasks = sourceColumnId == targetColumnId
        ? List<KanbanTask>.from(sourceTasks)
        : List<KanbanTask>.from(currentState.getTasksForColumn(targetColumnId));

    final clampedIndex = targetIndex.clamp(0, targetTasks.length);
    targetTasks.insert(clampedIndex, task.copyWith(columnId: targetColumnId));

    final sourceWithOrder = List.generate(
      sourceTasks.length,
      (i) => sourceTasks[i].copyWith(order: i),
    );
    final targetWithOrder = List.generate(
      targetTasks.length,
      (i) => targetTasks[i].copyWith(order: i),
    );

    // Optimistic update: show result before backend confirms.
    state = AsyncValue.data(
      currentState.copyWith(
        tasks: [
          ...currentState.tasks.where(
            (t) => t.columnId != sourceColumnId && t.columnId != targetColumnId,
          ),
          if (sourceColumnId != targetColumnId) ...sourceWithOrder,
          ...targetWithOrder,
        ],
      ),
    );

    final repository = ref.read(kanbanRepositoryProvider);
    await repository.moveTask(
      id: taskId,
      newColumnId: targetColumnId,
      newOrder: clampedIndex,
    );
    await repository.reorderTasks(targetWithOrder.map((t) => t.id).toList());
    if (sourceColumnId != targetColumnId) {
      await repository.reorderTasks(sourceWithOrder.map((t) => t.id).toList());
    }
  }
}
