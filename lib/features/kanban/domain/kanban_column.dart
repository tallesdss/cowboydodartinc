import 'package:cowboydodartinc/features/kanban/api/entities/kanban_column_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kanban_column.freezed.dart';

@freezed
sealed class KanbanColumn with _$KanbanColumn {
  const factory KanbanColumn({
    required String id,
    required String name,
    required int order,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _KanbanColumn;

  const KanbanColumn._();

  factory KanbanColumn.fromEntity(KanbanColumnEntity entity) {
    return KanbanColumn(
      id: entity.id!,
      name: entity.name,
      order: entity.order,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  KanbanColumnEntity toEntity() {
    return KanbanColumnEntity(
      id: id,
      name: name,
      order: order,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
