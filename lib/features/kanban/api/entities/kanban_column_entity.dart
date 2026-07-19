import 'package:json_annotation/json_annotation.dart';

part 'kanban_column_entity.g.dart';

@JsonSerializable()
class KanbanColumnEntity {
  final String? id;
  final String name;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KanbanColumnEntity({
    this.id,
    required this.name,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KanbanColumnEntity.fromJson(Map<String, dynamic> json) =>
      _$KanbanColumnEntityFromJson(json);

  Map<String, dynamic> toJson() => _$KanbanColumnEntityToJson(this);

  KanbanColumnEntity copyWith({
    String? id,
    String? name,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KanbanColumnEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
