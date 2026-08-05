// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kanban_column_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KanbanColumnEntity _$KanbanColumnEntityFromJson(Map json) => KanbanColumnEntity(
  id: json['id'] as String?,
  name: json['name'] as String,
  order: (json['order'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$KanbanColumnEntityToJson(KanbanColumnEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'order': instance.order,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
