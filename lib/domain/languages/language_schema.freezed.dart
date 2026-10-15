// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'language_schema.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ValidationIssue {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationIssue);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ValidationIssue()';
}


}

/// @nodoc
class $ValidationIssueCopyWith<$Res>  {
$ValidationIssueCopyWith(ValidationIssue _, $Res Function(ValidationIssue) __);
}


/// Adds pattern-matching-related methods to [ValidationIssue].
extension ValidationIssuePatterns on ValidationIssue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( BlankTerm value)?  blankTerm,TResult Function( UnsupportedWordType value)?  unsupportedWordType,TResult Function( MissingRequiredField value)?  missingRequiredField,TResult Function( UnknownField value)?  unknownField,TResult Function( DisallowedValue value)?  disallowedValue,required TResult orElse(),}){
final _that = this;
switch (_that) {
case BlankTerm() when blankTerm != null:
return blankTerm(_that);case UnsupportedWordType() when unsupportedWordType != null:
return unsupportedWordType(_that);case MissingRequiredField() when missingRequiredField != null:
return missingRequiredField(_that);case UnknownField() when unknownField != null:
return unknownField(_that);case DisallowedValue() when disallowedValue != null:
return disallowedValue(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( BlankTerm value)  blankTerm,required TResult Function( UnsupportedWordType value)  unsupportedWordType,required TResult Function( MissingRequiredField value)  missingRequiredField,required TResult Function( UnknownField value)  unknownField,required TResult Function( DisallowedValue value)  disallowedValue,}){
final _that = this;
switch (_that) {
case BlankTerm():
return blankTerm(_that);case UnsupportedWordType():
return unsupportedWordType(_that);case MissingRequiredField():
return missingRequiredField(_that);case UnknownField():
return unknownField(_that);case DisallowedValue():
return disallowedValue(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( BlankTerm value)?  blankTerm,TResult? Function( UnsupportedWordType value)?  unsupportedWordType,TResult? Function( MissingRequiredField value)?  missingRequiredField,TResult? Function( UnknownField value)?  unknownField,TResult? Function( DisallowedValue value)?  disallowedValue,}){
final _that = this;
switch (_that) {
case BlankTerm() when blankTerm != null:
return blankTerm(_that);case UnsupportedWordType() when unsupportedWordType != null:
return unsupportedWordType(_that);case MissingRequiredField() when missingRequiredField != null:
return missingRequiredField(_that);case UnknownField() when unknownField != null:
return unknownField(_that);case DisallowedValue() when disallowedValue != null:
return disallowedValue(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  blankTerm,TResult Function( WordType wordType)?  unsupportedWordType,TResult Function( String key)?  missingRequiredField,TResult Function( String key)?  unknownField,TResult Function( String key,  String value)?  disallowedValue,required TResult orElse(),}) {final _that = this;
switch (_that) {
case BlankTerm() when blankTerm != null:
return blankTerm();case UnsupportedWordType() when unsupportedWordType != null:
return unsupportedWordType(_that.wordType);case MissingRequiredField() when missingRequiredField != null:
return missingRequiredField(_that.key);case UnknownField() when unknownField != null:
return unknownField(_that.key);case DisallowedValue() when disallowedValue != null:
return disallowedValue(_that.key,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  blankTerm,required TResult Function( WordType wordType)  unsupportedWordType,required TResult Function( String key)  missingRequiredField,required TResult Function( String key)  unknownField,required TResult Function( String key,  String value)  disallowedValue,}) {final _that = this;
switch (_that) {
case BlankTerm():
return blankTerm();case UnsupportedWordType():
return unsupportedWordType(_that.wordType);case MissingRequiredField():
return missingRequiredField(_that.key);case UnknownField():
return unknownField(_that.key);case DisallowedValue():
return disallowedValue(_that.key,_that.value);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  blankTerm,TResult? Function( WordType wordType)?  unsupportedWordType,TResult? Function( String key)?  missingRequiredField,TResult? Function( String key)?  unknownField,TResult? Function( String key,  String value)?  disallowedValue,}) {final _that = this;
switch (_that) {
case BlankTerm() when blankTerm != null:
return blankTerm();case UnsupportedWordType() when unsupportedWordType != null:
return unsupportedWordType(_that.wordType);case MissingRequiredField() when missingRequiredField != null:
return missingRequiredField(_that.key);case UnknownField() when unknownField != null:
return unknownField(_that.key);case DisallowedValue() when disallowedValue != null:
return disallowedValue(_that.key,_that.value);case _:
  return null;

}
}

}

/// @nodoc


class BlankTerm implements ValidationIssue {
  const BlankTerm();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BlankTerm);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ValidationIssue.blankTerm()';
}


}




/// @nodoc


class UnsupportedWordType implements ValidationIssue {
  const UnsupportedWordType(this.wordType);
  

 final  WordType wordType;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnsupportedWordTypeCopyWith<UnsupportedWordType> get copyWith => _$UnsupportedWordTypeCopyWithImpl<UnsupportedWordType>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnsupportedWordType&&(identical(other.wordType, wordType) || other.wordType == wordType));
}


@override
int get hashCode {
    return Object.hash(runtimeType,wordType);
}

@override
String toString() {
    return 'ValidationIssue.unsupportedWordType(wordType: $wordType)';
}


}

/// @nodoc
abstract mixin class $UnsupportedWordTypeCopyWith<$Res> implements $ValidationIssueCopyWith<$Res> {
  factory $UnsupportedWordTypeCopyWith(UnsupportedWordType value, $Res Function(UnsupportedWordType) _then) = _$UnsupportedWordTypeCopyWithImpl;
@useResult
$Res call({
 WordType wordType
});




}
/// @nodoc
class _$UnsupportedWordTypeCopyWithImpl<$Res>
    implements $UnsupportedWordTypeCopyWith<$Res> {
  _$UnsupportedWordTypeCopyWithImpl(this._self, this._then);

  final UnsupportedWordType _self;
  final $Res Function(UnsupportedWordType) _then;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? wordType = null,}) {
  return _then(UnsupportedWordType(
null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as WordType,
  ));
}


}

/// @nodoc


class MissingRequiredField implements ValidationIssue {
  const MissingRequiredField(this.key);
  

 final  String key;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissingRequiredFieldCopyWith<MissingRequiredField> get copyWith => _$MissingRequiredFieldCopyWithImpl<MissingRequiredField>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MissingRequiredField&&(identical(other.key, key) || other.key == key));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key);
}

@override
String toString() {
    return 'ValidationIssue.missingRequiredField(key: $key)';
}


}

/// @nodoc
abstract mixin class $MissingRequiredFieldCopyWith<$Res> implements $ValidationIssueCopyWith<$Res> {
  factory $MissingRequiredFieldCopyWith(MissingRequiredField value, $Res Function(MissingRequiredField) _then) = _$MissingRequiredFieldCopyWithImpl;
@useResult
$Res call({
 String key
});




}
/// @nodoc
class _$MissingRequiredFieldCopyWithImpl<$Res>
    implements $MissingRequiredFieldCopyWith<$Res> {
  _$MissingRequiredFieldCopyWithImpl(this._self, this._then);

  final MissingRequiredField _self;
  final $Res Function(MissingRequiredField) _then;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? key = null,}) {
  return _then(MissingRequiredField(
null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UnknownField implements ValidationIssue {
  const UnknownField(this.key);
  

 final  String key;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownFieldCopyWith<UnknownField> get copyWith => _$UnknownFieldCopyWithImpl<UnknownField>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownField&&(identical(other.key, key) || other.key == key));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key);
}

@override
String toString() {
    return 'ValidationIssue.unknownField(key: $key)';
}


}

/// @nodoc
abstract mixin class $UnknownFieldCopyWith<$Res> implements $ValidationIssueCopyWith<$Res> {
  factory $UnknownFieldCopyWith(UnknownField value, $Res Function(UnknownField) _then) = _$UnknownFieldCopyWithImpl;
@useResult
$Res call({
 String key
});




}
/// @nodoc
class _$UnknownFieldCopyWithImpl<$Res>
    implements $UnknownFieldCopyWith<$Res> {
  _$UnknownFieldCopyWithImpl(this._self, this._then);

  final UnknownField _self;
  final $Res Function(UnknownField) _then;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? key = null,}) {
  return _then(UnknownField(
null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DisallowedValue implements ValidationIssue {
  const DisallowedValue(this.key, this.value);
  

 final  String key;
 final  String value;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisallowedValueCopyWith<DisallowedValue> get copyWith => _$DisallowedValueCopyWithImpl<DisallowedValue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DisallowedValue&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,value);
}

@override
String toString() {
    return 'ValidationIssue.disallowedValue(key: $key, value: $value)';
}


}

/// @nodoc
abstract mixin class $DisallowedValueCopyWith<$Res> implements $ValidationIssueCopyWith<$Res> {
  factory $DisallowedValueCopyWith(DisallowedValue value, $Res Function(DisallowedValue) _then) = _$DisallowedValueCopyWithImpl;
@useResult
$Res call({
 String key, String value
});




}
/// @nodoc
class _$DisallowedValueCopyWithImpl<$Res>
    implements $DisallowedValueCopyWith<$Res> {
  _$DisallowedValueCopyWithImpl(this._self, this._then);

  final DisallowedValue _self;
  final $Res Function(DisallowedValue) _then;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? key = null,Object? value = null,}) {
  return _then(DisallowedValue(
null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
