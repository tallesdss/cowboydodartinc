import 'package:cowboydodartinc/features/kanban/domain/kanban_column.dart';
import 'package:cowboydodartinc/features/kanban/domain/kanban_task.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kanban_state.freezed.dart';

@freezed
sealed class KanbanState with _$KanbanState {
  const factory KanbanState({
    required List<KanbanColumn> columns,
    required List<KanbanTask> tasks,
    required bool isLoading,
    String? error,
  }) = _KanbanState;

  const KanbanState._();

  factory KanbanState.initial() => const KanbanState(
        columns: [],
        tasks: [],
        isLoading: false,
      );

  List<KanbanTask> getTasksForColumn(String columnId) {
    return tasks
        .where((task) => task.columnId == columnId)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
}
