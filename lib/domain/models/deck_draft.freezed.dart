// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deck_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeckDraft {

 String get packId; String get name; List<DeckFilter> get filters;
/// Create a copy of DeckDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeckDraftCopyWith<DeckDraft> get copyWith => _$DeckDraftCopyWithImpl<DeckDraft>(this as DeckDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeckDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeckDraft&&(identical(other.packId, _this.packId) || other.packId == _this.packId)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.filters, _this.filters));
}


@override
int get hashCode {
  final _this = this as DeckDraft;
  return Object.hash(runtimeType,_this.packId,_this.name,const DeepCollectionEquality().hash(_this.filters));
}

@override
String toString() {
  final _this = this as DeckDraft;
  return 'DeckDraft(packId: ${_this.packId}, name: ${_this.name}, filters: ${_this.filters})';
}


}

/// @nodoc
abstract mixin class $DeckDraftCopyWith<$Res>  {
  factory $DeckDraftCopyWith(DeckDraft value, $Res Function(DeckDraft) _then) = _$DeckDraftCopyWithImpl;
@useResult
$Res call({
 String packId, String name, List<DeckFilter> filters
});




}
/// @nodoc
class _$DeckDraftCopyWithImpl<$Res>
    implements $DeckDraftCopyWith<$Res> {
  _$DeckDraftCopyWithImpl(this._self, this._then);

  final DeckDraft _self;
  final $Res Function(DeckDraft) _then;

/// Create a copy of DeckDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packId = null,Object? name = null,Object? filters = null,}) {
  return _then(DeckDraft(
packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as List<DeckFilter>,
  ));
}

}


/// Adds pattern-matching-related methods to [DeckDraft].
extension DeckDraftPatterns on DeckDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeckDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeckDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeckDraft value)  $default,){
final _that = this;
switch (_that) {
case _DeckDraft():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeckDraft value)?  $default,){
final _that = this;
switch (_that) {
case _DeckDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String packId,  String name,  List<DeckFilter> filters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeckDraft() when $default != null:
return $default(_that.packId,_that.name,_that.filters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String packId,  String name,  List<DeckFilter> filters)  $default,) {final _that = this;
switch (_that) {
case _DeckDraft():
return $default(_that.packId,_that.name,_that.filters);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String packId,  String name,  List<DeckFilter> filters)?  $default,) {final _that = this;
switch (_that) {
case _DeckDraft() when $default != null:
return $default(_that.packId,_that.name,_that.filters);case _:
  return null;

}
}

}

/// @nodoc


class _DeckDraft implements DeckDraft {
  const _DeckDraft({required this.packId, required this.name,  List<DeckFilter> filters = const <DeckFilter>[]}): _filters = filters;
  

@override final  String packId;
@override final  String name;
 final  List<DeckFilter> _filters;
@override@JsonKey() List<DeckFilter> get filters {
  if (_filters is EqualUnmodifiableListView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filters);
}


/// Create a copy of DeckDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeckDraftCopyWith<_DeckDraft> get copyWith => __$DeckDraftCopyWithImpl<_DeckDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeckDraft&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.filters, _filters));
}


@override
int get hashCode {
    return Object.hash(runtimeType,packId,name,const DeepCollectionEquality().hash(_filters));
}

@override
String toString() {
    return 'DeckDraft(packId: $packId, name: $name, filters: $filters)';
}


}

/// @nodoc
abstract mixin class _$DeckDraftCopyWith<$Res> implements $DeckDraftCopyWith<$Res> {
  factory _$DeckDraftCopyWith(_DeckDraft value, $Res Function(_DeckDraft) _then) = __$DeckDraftCopyWithImpl;
@override @useResult
$Res call({
 String packId, String name, List<DeckFilter> filters
});




}
/// @nodoc
class __$DeckDraftCopyWithImpl<$Res>
    implements _$DeckDraftCopyWith<$Res> {
  __$DeckDraftCopyWithImpl(this._self, this._then);

  final _DeckDraft _self;
  final $Res Function(_DeckDraft) _then;

/// Create a copy of DeckDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packId = null,Object? name = null,Object? filters = null,}) {
  return _then(_DeckDraft(
packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as List<DeckFilter>,
  ));
}


}

// dart format on
