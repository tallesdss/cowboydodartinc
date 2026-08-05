// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kanban_task_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KanbanTaskEntity _$KanbanTaskEntityFromJson(Map json) => KanbanTaskEntity(
  id: json['id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String?,
  columnId: json['columnId'] as String,
  order: (json['order'] as num).toInt(),
  priority: json['priority'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$KanbanTaskEntityToJson(KanbanTaskEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'columnId': instance.columnId,
      'order': instance.order,
      'priority': instance.priority,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
