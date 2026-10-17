// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deck_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeckFilter {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DeckFilter);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DeckFilter()';
}


}

/// @nodoc
class $DeckFilterCopyWith<$Res>  {
$DeckFilterCopyWith(DeckFilter _, $Res Function(DeckFilter) __);
}


/// Adds pattern-matching-related methods to [DeckFilter].
extension DeckFilterPatterns on DeckFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AddedBetween value)?  addedBetween,TResult Function( AddedInLastDays value)?  addedInLastDays,TResult Function( WordTypesFilter value)?  wordTypes,TResult Function( UnknownFilter value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AddedBetween() when addedBetween != null:
return addedBetween(_that);case AddedInLastDays() when addedInLastDays != null:
return addedInLastDays(_that);case WordTypesFilter() when wordTypes != null:
return wordTypes(_that);case UnknownFilter() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AddedBetween value)  addedBetween,required TResult Function( AddedInLastDays value)  addedInLastDays,required TResult Function( WordTypesFilter value)  wordTypes,required TResult Function( UnknownFilter value)  unknown,}){
final _that = this;
switch (_that) {
case AddedBetween():
return addedBetween(_that);case AddedInLastDays():
return addedInLastDays(_that);case WordTypesFilter():
return wordTypes(_that);case UnknownFilter():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AddedBetween value)?  addedBetween,TResult? Function( AddedInLastDays value)?  addedInLastDays,TResult? Function( WordTypesFilter value)?  wordTypes,TResult? Function( UnknownFilter value)?  unknown,}){
final _that = this;
switch (_that) {
case AddedBetween() when addedBetween != null:
return addedBetween(_that);case AddedInLastDays() when addedInLastDays != null:
return addedInLastDays(_that);case WordTypesFilter() when wordTypes != null:
return wordTypes(_that);case UnknownFilter() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( DateTime? from,  DateTime? to)?  addedBetween,TResult Function( int days)?  addedInLastDays,TResult Function( Set<WordType> types)?  wordTypes,TResult Function( Map<String, Object?> json)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AddedBetween() when addedBetween != null:
return addedBetween(_that.from,_that.to);case AddedInLastDays() when addedInLastDays != null:
return addedInLastDays(_that.days);case WordTypesFilter() when wordTypes != null:
return wordTypes(_that.types);case UnknownFilter() when unknown != null:
return unknown(_that.json);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( DateTime? from,  DateTime? to)  addedBetween,required TResult Function( int days)  addedInLastDays,required TResult Function( Set<WordType> types)  wordTypes,required TResult Function( Map<String, Object?> json)  unknown,}) {final _that = this;
switch (_that) {
case AddedBetween():
return addedBetween(_that.from,_that.to);case AddedInLastDays():
return addedInLastDays(_that.days);case WordTypesFilter():
return wordTypes(_that.types);case UnknownFilter():
return unknown(_that.json);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( DateTime? from,  DateTime? to)?  addedBetween,TResult? Function( int days)?  addedInLastDays,TResult? Function( Set<WordType> types)?  wordTypes,TResult? Function( Map<String, Object?> json)?  unknown,}) {final _that = this;
switch (_that) {
case AddedBetween() when addedBetween != null:
return addedBetween(_that.from,_that.to);case AddedInLastDays() when addedInLastDays != null:
return addedInLastDays(_that.days);case WordTypesFilter() when wordTypes != null:
return wordTypes(_that.types);case UnknownFilter() when unknown != null:
return unknown(_that.json);case _:
  return null;

}
}

}

/// @nodoc


class AddedBetween extends DeckFilter {
  const AddedBetween({this.from, this.to}): super._();
  

 final  DateTime? from;
 final  DateTime? to;

/// Create a copy of DeckFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddedBetweenCopyWith<AddedBetween> get copyWith => _$AddedBetweenCopyWithImpl<AddedBetween>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AddedBetween&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode {
    return Object.hash(runtimeType,from,to);
}

@override
String toString() {
    return 'DeckFilter.addedBetween(from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class $AddedBetweenCopyWith<$Res> implements $DeckFilterCopyWith<$Res> {
  factory $AddedBetweenCopyWith(AddedBetween value, $Res Function(AddedBetween) _then) = _$AddedBetweenCopyWithImpl;
@useResult
$Res call({
 DateTime? from, DateTime? to
});




}
/// @nodoc
class _$AddedBetweenCopyWithImpl<$Res>
    implements $AddedBetweenCopyWith<$Res> {
  _$AddedBetweenCopyWithImpl(this._self, this._then);

  final AddedBetween _self;
  final $Res Function(AddedBetween) _then;

/// Create a copy of DeckFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? from = freezed,Object? to = freezed,}) {
  return _then(AddedBetween(
from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class AddedInLastDays extends DeckFilter {
  const AddedInLastDays(this.days): super._();
  

 final  int days;

/// Create a copy of DeckFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddedInLastDaysCopyWith<AddedInLastDays> get copyWith => _$AddedInLastDaysCopyWithImpl<AddedInLastDays>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AddedInLastDays&&(identical(other.days, days) || other.days == days));
}


@override
int get hashCode {
    return Object.hash(runtimeType,days);
}

@override
String toString() {
    return 'DeckFilter.addedInLastDays(days: $days)';
}


}

/// @nodoc
abstract mixin class $AddedInLastDaysCopyWith<$Res> implements $DeckFilterCopyWith<$Res> {
  factory $AddedInLastDaysCopyWith(AddedInLastDays value, $Res Function(AddedInLastDays) _then) = _$AddedInLastDaysCopyWithImpl;
@useResult
$Res call({
 int days
});




}
/// @nodoc
class _$AddedInLastDaysCopyWithImpl<$Res>
    implements $AddedInLastDaysCopyWith<$Res> {
  _$AddedInLastDaysCopyWithImpl(this._self, this._then);

  final AddedInLastDays _self;
  final $Res Function(AddedInLastDays) _then;

/// Create a copy of DeckFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? days = null,}) {
  return _then(AddedInLastDays(
null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class WordTypesFilter extends DeckFilter {
  const WordTypesFilter( Set<WordType> types): _types = types,super._();
  

 final  Set<WordType> _types;
 Set<WordType> get types {
  if (_types is EqualUnmodifiableSetView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_types);
}


/// Create a copy of DeckFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordTypesFilterCopyWith<WordTypesFilter> get copyWith => _$WordTypesFilterCopyWithImpl<WordTypesFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WordTypesFilter&&const DeepCollectionEquality().equals(other.types, _types));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_types));
}

@override
String toString() {
    return 'DeckFilter.wordTypes(types: $types)';
}


}

/// @nodoc
abstract mixin class $WordTypesFilterCopyWith<$Res> implements $DeckFilterCopyWith<$Res> {
  factory $WordTypesFilterCopyWith(WordTypesFilter value, $Res Function(WordTypesFilter) _then) = _$WordTypesFilterCopyWithImpl;
@useResult
$Res call({
 Set<WordType> types
});




}
/// @nodoc
class _$WordTypesFilterCopyWithImpl<$Res>
    implements $WordTypesFilterCopyWith<$Res> {
  _$WordTypesFilterCopyWithImpl(this._self, this._then);

  final WordTypesFilter _self;
  final $Res Function(WordTypesFilter) _then;

/// Create a copy of DeckFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? types = null,}) {
  return _then(WordTypesFilter(
null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as Set<WordType>,
  ));
}


}

/// @nodoc


class UnknownFilter extends DeckFilter {
  const UnknownFilter( Map<String, Object?> json): _json = json,super._();
  

 final  Map<String, Object?> _json;
 Map<String, Object?> get json {
  if (_json is EqualUnmodifiableMapView) return _json;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_json);
}


/// Create a copy of DeckFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownFilterCopyWith<UnknownFilter> get copyWith => _$UnknownFilterCopyWithImpl<UnknownFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownFilter&&const DeepCollectionEquality().equals(other.json, _json));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_json));
}

@override
String toString() {
    return 'DeckFilter.unknown(json: $json)';
}


}

/// @nodoc
abstract mixin class $UnknownFilterCopyWith<$Res> implements $DeckFilterCopyWith<$Res> {
  factory $UnknownFilterCopyWith(UnknownFilter value, $Res Function(UnknownFilter) _then) = _$UnknownFilterCopyWithImpl;
@useResult
$Res call({
 Map<String, Object?> json
});




}
/// @nodoc
class _$UnknownFilterCopyWithImpl<$Res>
    implements $UnknownFilterCopyWith<$Res> {
  _$UnknownFilterCopyWithImpl(this._self, this._then);

  final UnknownFilter _self;
  final $Res Function(UnknownFilter) _then;

/// Create a copy of DeckFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? json = null,}) {
  return _then(UnknownFilter(
null == json ? _self._json : json // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}

// dart format on
