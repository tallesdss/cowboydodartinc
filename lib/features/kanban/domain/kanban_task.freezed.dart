// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kanban_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KanbanTask {

 String get id; String get title; String? get description; String get columnId; int get order; TaskPriority? get priority; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of KanbanTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KanbanTaskCopyWith<KanbanTask> get copyWith => _$KanbanTaskCopyWithImpl<KanbanTask>(this as KanbanTask, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KanbanTask&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.columnId, columnId) || other.columnId == columnId)&&(identical(other.order, order) || other.order == order)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,columnId,order,priority,createdAt,updatedAt);

@override
String toString() {
  return 'KanbanTask(id: $id, title: $title, description: $description, columnId: $columnId, order: $order, priority: $priority, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $KanbanTaskCopyWith<$Res>  {
  factory $KanbanTaskCopyWith(KanbanTask value, $Res Function(KanbanTask) _then) = _$KanbanTaskCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, String columnId, int order, TaskPriority? priority, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$KanbanTaskCopyWithImpl<$Res>
    implements $KanbanTaskCopyWith<$Res> {
  _$KanbanTaskCopyWithImpl(this._self, this._then);

  final KanbanTask _self;
  final $Res Function(KanbanTask) _then;

/// Create a copy of KanbanTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? columnId = null,Object? order = null,Object? priority = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,columnId: null == columnId ? _self.columnId : columnId // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [KanbanTask].
extension KanbanTaskPatterns on KanbanTask {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KanbanTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KanbanTask() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KanbanTask value)  $default,){
final _that = this;
switch (_that) {
case _KanbanTask():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KanbanTask value)?  $default,){
final _that = this;
switch (_that) {
case _KanbanTask() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String columnId,  int order,  TaskPriority? priority,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KanbanTask() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.columnId,_that.order,_that.priority,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String columnId,  int order,  TaskPriority? priority,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _KanbanTask():
return $default(_that.id,_that.title,_that.description,_that.columnId,_that.order,_that.priority,_that.createdAt,_that.updatedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  String columnId,  int order,  TaskPriority? priority,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _KanbanTask() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.columnId,_that.order,_that.priority,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _KanbanTask extends KanbanTask {
  const _KanbanTask({required this.id, required this.title, this.description, required this.columnId, required this.order, this.priority, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  String columnId;
@override final  int order;
@override final  TaskPriority? priority;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of KanbanTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KanbanTaskCopyWith<_KanbanTask> get copyWith => __$KanbanTaskCopyWithImpl<_KanbanTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KanbanTask&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.columnId, columnId) || other.columnId == columnId)&&(identical(other.order, order) || other.order == order)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,columnId,order,priority,createdAt,updatedAt);

@override
String toString() {
  return 'KanbanTask(id: $id, title: $title, description: $description, columnId: $columnId, order: $order, priority: $priority, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$KanbanTaskCopyWith<$Res> implements $KanbanTaskCopyWith<$Res> {
  factory _$KanbanTaskCopyWith(_KanbanTask value, $Res Function(_KanbanTask) _then) = __$KanbanTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, String columnId, int order, TaskPriority? priority, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$KanbanTaskCopyWithImpl<$Res>
    implements _$KanbanTaskCopyWith<$Res> {
  __$KanbanTaskCopyWithImpl(this._self, this._then);

  final _KanbanTask _self;
  final $Res Function(_KanbanTask) _then;

/// Create a copy of KanbanTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? columnId = null,Object? order = null,Object? priority = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_KanbanTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,columnId: null == columnId ? _self.columnId : columnId // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
