// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pack_bundle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PackBundle {

 LanguagePack get pack; List<Entry> get entries; List<Deck> get decks;
/// Create a copy of PackBundle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackBundleCopyWith<PackBundle> get copyWith => _$PackBundleCopyWithImpl<PackBundle>(this as PackBundle, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PackBundle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackBundle&&(identical(other.pack, _this.pack) || other.pack == _this.pack)&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&const DeepCollectionEquality().equals(other.decks, _this.decks));
}


@override
int get hashCode {
  final _this = this as PackBundle;
  return Object.hash(runtimeType,_this.pack,const DeepCollectionEquality().hash(_this.entries),const DeepCollectionEquality().hash(_this.decks));
}

@override
String toString() {
  final _this = this as PackBundle;
  return 'PackBundle(pack: ${_this.pack}, entries: ${_this.entries}, decks: ${_this.decks})';
}


}

/// @nodoc
abstract mixin class $PackBundleCopyWith<$Res>  {
  factory $PackBundleCopyWith(PackBundle value, $Res Function(PackBundle) _then) = _$PackBundleCopyWithImpl;
@useResult
$Res call({
 LanguagePack pack, List<Entry> entries, List<Deck> decks
});


$LanguagePackCopyWith<$Res> get pack;

}
/// @nodoc
class _$PackBundleCopyWithImpl<$Res>
    implements $PackBundleCopyWith<$Res> {
  _$PackBundleCopyWithImpl(this._self, this._then);

  final PackBundle _self;
  final $Res Function(PackBundle) _then;

/// Create a copy of PackBundle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pack = null,Object? entries = null,Object? decks = null,}) {
  return _then(PackBundle(
pack: null == pack ? _self.pack : pack // ignore: cast_nullable_to_non_nullable
as LanguagePack,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<Entry>,decks: null == decks ? _self.decks : decks // ignore: cast_nullable_to_non_nullable
as List<Deck>,
  ));
}
/// Create a copy of PackBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LanguagePackCopyWith<$Res> get pack {
  
  return $LanguagePackCopyWith<$Res>(_self.pack, (value) {
    return _then(_self.copyWith(pack: value));
  });
}
}


/// Adds pattern-matching-related methods to [PackBundle].
extension PackBundlePatterns on PackBundle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackBundle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackBundle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackBundle value)  $default,){
final _that = this;
switch (_that) {
case _PackBundle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackBundle value)?  $default,){
final _that = this;
switch (_that) {
case _PackBundle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LanguagePack pack,  List<Entry> entries,  List<Deck> decks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackBundle() when $default != null:
return $default(_that.pack,_that.entries,_that.decks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LanguagePack pack,  List<Entry> entries,  List<Deck> decks)  $default,) {final _that = this;
switch (_that) {
case _PackBundle():
return $default(_that.pack,_that.entries,_that.decks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LanguagePack pack,  List<Entry> entries,  List<Deck> decks)?  $default,) {final _that = this;
switch (_that) {
case _PackBundle() when $default != null:
return $default(_that.pack,_that.entries,_that.decks);case _:
  return null;

}
}

}

/// @nodoc


class _PackBundle implements PackBundle {
  const _PackBundle({required this.pack,  List<Entry> entries = const <Entry>[],  List<Deck> decks = const <Deck>[]}): _entries = entries,_decks = decks;
  

@override final  LanguagePack pack;
 final  List<Entry> _entries;
@override@JsonKey() List<Entry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

 final  List<Deck> _decks;
@override@JsonKey() List<Deck> get decks {
  if (_decks is EqualUnmodifiableListView) return _decks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_decks);
}


/// Create a copy of PackBundle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackBundleCopyWith<_PackBundle> get copyWith => __$PackBundleCopyWithImpl<_PackBundle>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackBundle&&(identical(other.pack, pack) || other.pack == pack)&&const DeepCollectionEquality().equals(other.entries, _entries)&&const DeepCollectionEquality().equals(other.decks, _decks));
}


@override
int get hashCode {
    return Object.hash(runtimeType,pack,const DeepCollectionEquality().hash(_entries),const DeepCollectionEquality().hash(_decks));
}

@override
String toString() {
    return 'PackBundle(pack: $pack, entries: $entries, decks: $decks)';
}


}

/// @nodoc
abstract mixin class _$PackBundleCopyWith<$Res> implements $PackBundleCopyWith<$Res> {
  factory _$PackBundleCopyWith(_PackBundle value, $Res Function(_PackBundle) _then) = __$PackBundleCopyWithImpl;
@override @useResult
$Res call({
 LanguagePack pack, List<Entry> entries, List<Deck> decks
});


@override $LanguagePackCopyWith<$Res> get pack;

}
/// @nodoc
class __$PackBundleCopyWithImpl<$Res>
    implements _$PackBundleCopyWith<$Res> {
  __$PackBundleCopyWithImpl(this._self, this._then);

  final _PackBundle _self;
  final $Res Function(_PackBundle) _then;

/// Create a copy of PackBundle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pack = null,Object? entries = null,Object? decks = null,}) {
  return _then(_PackBundle(
pack: null == pack ? _self.pack : pack // ignore: cast_nullable_to_non_nullable
as LanguagePack,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<Entry>,decks: null == decks ? _self._decks : decks // ignore: cast_nullable_to_non_nullable
as List<Deck>,
  ));
}

/// Create a copy of PackBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LanguagePackCopyWith<$Res> get pack {
  
  return $LanguagePackCopyWith<$Res>(_self.pack, (value) {
    return _then(_self.copyWith(pack: value));
  });
}
}

// dart format on
