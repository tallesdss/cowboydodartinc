import 'package:cowboydodartinc/features/kanban/api/entities/kanban_task_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kanban_task.freezed.dart';

enum TaskPriority { low, medium, high, urgent }

@freezed
sealed class KanbanTask with _$KanbanTask {
  const factory KanbanTask({
    required String id,
    required String title,
    String? description,
    required String columnId,
    required int order,
    TaskPriority? priority,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _KanbanTask;

  const KanbanTask._();

  factory KanbanTask.fromEntity(KanbanTaskEntity entity) {
    return KanbanTask(
      id: entity.id!,
      title: entity.title,
      description: entity.description,
      columnId: entity.columnId,
      order: entity.order,
      priority: _parsePriority(entity.priority),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static TaskPriority? _parsePriority(String? value) {
    return switch (value) {
      'low' => TaskPriority.low,
      'medium' => TaskPriority.medium,
      'high' => TaskPriority.high,
      'urgent' => TaskPriority.urgent,
      _ => null,
    };
  }

  KanbanTaskEntity toEntity() {
    return KanbanTaskEntity(
      id: id,
      title: title,
      description: description,
      columnId: columnId,
      order: order,
      priority: priority?.name,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
