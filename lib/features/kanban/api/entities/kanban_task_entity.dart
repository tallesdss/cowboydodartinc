import 'package:json_annotation/json_annotation.dart';

part 'kanban_task_entity.g.dart';

@JsonSerializable()
class KanbanTaskEntity {
  final String? id;
  final String title;
  final String? description;
  final String columnId;
  final int order;
  final String? priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KanbanTaskEntity({
    this.id,
    required this.title,
    this.description,
    required this.columnId,
    required this.order,
    this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KanbanTaskEntity.fromJson(Map<String, dynamic> json) =>
      _$KanbanTaskEntityFromJson(json);

  Map<String, dynamic> toJson() => _$KanbanTaskEntityToJson(this);

  KanbanTaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? columnId,
    int? order,
    String? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KanbanTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      columnId: columnId ?? this.columnId,
      order: order ?? this.order,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
