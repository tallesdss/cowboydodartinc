// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kanban_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KanbanState {

 List<KanbanColumn> get columns; List<KanbanTask> get tasks; bool get isLoading; String? get error;
/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KanbanStateCopyWith<KanbanState> get copyWith => _$KanbanStateCopyWithImpl<KanbanState>(this as KanbanState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KanbanState&&const DeepCollectionEquality().equals(other.columns, columns)&&const DeepCollectionEquality().equals(other.tasks, tasks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(columns),const DeepCollectionEquality().hash(tasks),isLoading,error);

@override
String toString() {
  return 'KanbanState(columns: $columns, tasks: $tasks, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class $KanbanStateCopyWith<$Res>  {
  factory $KanbanStateCopyWith(KanbanState value, $Res Function(KanbanState) _then) = _$KanbanStateCopyWithImpl;
@useResult
$Res call({
 List<KanbanColumn> columns, List<KanbanTask> tasks, bool isLoading, String? error
});




}
/// @nodoc
class _$KanbanStateCopyWithImpl<$Res>
    implements $KanbanStateCopyWith<$Res> {
  _$KanbanStateCopyWithImpl(this._self, this._then);

  final KanbanState _self;
  final $Res Function(KanbanState) _then;

/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? columns = null,Object? tasks = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as List<KanbanColumn>,tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<KanbanTask>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [KanbanState].
extension KanbanStatePatterns on KanbanState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KanbanState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KanbanState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KanbanState value)  $default,){
final _that = this;
switch (_that) {
case _KanbanState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KanbanState value)?  $default,){
final _that = this;
switch (_that) {
case _KanbanState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<KanbanColumn> columns,  List<KanbanTask> tasks,  bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KanbanState() when $default != null:
return $default(_that.columns,_that.tasks,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<KanbanColumn> columns,  List<KanbanTask> tasks,  bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _KanbanState():
return $default(_that.columns,_that.tasks,_that.isLoading,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<KanbanColumn> columns,  List<KanbanTask> tasks,  bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _KanbanState() when $default != null:
return $default(_that.columns,_that.tasks,_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _KanbanState extends KanbanState {
  const _KanbanState({required final  List<KanbanColumn> columns, required final  List<KanbanTask> tasks, required this.isLoading, this.error}): _columns = columns,_tasks = tasks,super._();
  

 final  List<KanbanColumn> _columns;
@override List<KanbanColumn> get columns {
  if (_columns is EqualUnmodifiableListView) return _columns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_columns);
}

 final  List<KanbanTask> _tasks;
@override List<KanbanTask> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}

@override final  bool isLoading;
@override final  String? error;

/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KanbanStateCopyWith<_KanbanState> get copyWith => __$KanbanStateCopyWithImpl<_KanbanState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KanbanState&&const DeepCollectionEquality().equals(other._columns, _columns)&&const DeepCollectionEquality().equals(other._tasks, _tasks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_columns),const DeepCollectionEquality().hash(_tasks),isLoading,error);

@override
String toString() {
  return 'KanbanState(columns: $columns, tasks: $tasks, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$KanbanStateCopyWith<$Res> implements $KanbanStateCopyWith<$Res> {
  factory _$KanbanStateCopyWith(_KanbanState value, $Res Function(_KanbanState) _then) = __$KanbanStateCopyWithImpl;
@override @useResult
$Res call({
 List<KanbanColumn> columns, List<KanbanTask> tasks, bool isLoading, String? error
});




}
/// @nodoc
class __$KanbanStateCopyWithImpl<$Res>
    implements _$KanbanStateCopyWith<$Res> {
  __$KanbanStateCopyWithImpl(this._self, this._then);

  final _KanbanState _self;
  final $Res Function(_KanbanState) _then;

/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? columns = null,Object? tasks = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_KanbanState(
columns: null == columns ? _self._columns : columns // ignore: cast_nullable_to_non_nullable
as List<KanbanColumn>,tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<KanbanTask>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
