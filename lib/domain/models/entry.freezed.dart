// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Entry {

/// Client-generated UUID.
 String get id;/// Id of the owning [Profile].
 String get ownerId; String get packId; WordType get wordType;/// The headword, e.g. the singular of a noun or the infinitive of a verb.
 String get term;/// Type-specific fields keyed by field key (e.g. `article`, `plural`).
/// Valid keys and values are defined by the pack language's schema.
 Map<String, String> get forms; List<String> get translations; List<Example> get examples; List<String> get tags; String? get notes;/// Version of the language schema the [forms] were written against.
 int get schemaVersion;/// UTC.
 DateTime get createdAt;/// UTC.
 DateTime get updatedAt;/// UTC. Set when soft-deleted, so the deletion can be synced.
 DateTime? get deletedAt;
/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryCopyWith<Entry> get copyWith => _$EntryCopyWithImpl<Entry>(this as Entry, _$identity);

  /// Serializes this Entry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Entry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Entry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.ownerId, _this.ownerId) || other.ownerId == _this.ownerId)&&(identical(other.packId, _this.packId) || other.packId == _this.packId)&&(identical(other.wordType, _this.wordType) || other.wordType == _this.wordType)&&(identical(other.term, _this.term) || other.term == _this.term)&&const DeepCollectionEquality().equals(other.forms, _this.forms)&&const DeepCollectionEquality().equals(other.translations, _this.translations)&&const DeepCollectionEquality().equals(other.examples, _this.examples)&&const DeepCollectionEquality().equals(other.tags, _this.tags)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Entry;
  return Object.hash(runtimeType,_this.id,_this.ownerId,_this.packId,_this.wordType,_this.term,const DeepCollectionEquality().hash(_this.forms),const DeepCollectionEquality().hash(_this.translations),const DeepCollectionEquality().hash(_this.examples),const DeepCollectionEquality().hash(_this.tags),_this.notes,_this.schemaVersion,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as Entry;
  return 'Entry(id: ${_this.id}, ownerId: ${_this.ownerId}, packId: ${_this.packId}, wordType: ${_this.wordType}, term: ${_this.term}, forms: ${_this.forms}, translations: ${_this.translations}, examples: ${_this.examples}, tags: ${_this.tags}, notes: ${_this.notes}, schemaVersion: ${_this.schemaVersion}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $EntryCopyWith<$Res>  {
  factory $EntryCopyWith(Entry value, $Res Function(Entry) _then) = _$EntryCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String packId, WordType wordType, String term, Map<String, String> forms, List<String> translations, List<Example> examples, List<String> tags, String? notes, int schemaVersion, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$EntryCopyWithImpl<$Res>
    implements $EntryCopyWith<$Res> {
  _$EntryCopyWithImpl(this._self, this._then);

  final Entry _self;
  final $Res Function(Entry) _then;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? packId = null,Object? wordType = null,Object? term = null,Object? forms = null,Object? translations = null,Object? examples = null,Object? tags = null,Object? notes = freezed,Object? schemaVersion = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(Entry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,wordType: null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as WordType,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,forms: null == forms ? _self.forms : forms // ignore: cast_nullable_to_non_nullable
as Map<String, String>,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as List<String>,examples: null == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as List<Example>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Entry].
extension EntryPatterns on Entry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Entry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Entry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Entry value)  $default,){
final _that = this;
switch (_that) {
case _Entry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Entry value)?  $default,){
final _that = this;
switch (_that) {
case _Entry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String packId,  WordType wordType,  String term,  Map<String, String> forms,  List<String> translations,  List<Example> examples,  List<String> tags,  String? notes,  int schemaVersion,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Entry() when $default != null:
return $default(_that.id,_that.ownerId,_that.packId,_that.wordType,_that.term,_that.forms,_that.translations,_that.examples,_that.tags,_that.notes,_that.schemaVersion,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String packId,  WordType wordType,  String term,  Map<String, String> forms,  List<String> translations,  List<Example> examples,  List<String> tags,  String? notes,  int schemaVersion,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Entry():
return $default(_that.id,_that.ownerId,_that.packId,_that.wordType,_that.term,_that.forms,_that.translations,_that.examples,_that.tags,_that.notes,_that.schemaVersion,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String packId,  WordType wordType,  String term,  Map<String, String> forms,  List<String> translations,  List<Example> examples,  List<String> tags,  String? notes,  int schemaVersion,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Entry() when $default != null:
return $default(_that.id,_that.ownerId,_that.packId,_that.wordType,_that.term,_that.forms,_that.translations,_that.examples,_that.tags,_that.notes,_that.schemaVersion,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Entry implements Entry {
  const _Entry({required this.id, required this.ownerId, required this.packId, required this.wordType, required this.term,  Map<String, String> forms = const <String, String>{},  List<String> translations = const <String>[],  List<Example> examples = const <Example>[],  List<String> tags = const <String>[], this.notes, required this.schemaVersion, required this.createdAt, required this.updatedAt, this.deletedAt}): _forms = forms,_translations = translations,_examples = examples,_tags = tags;
  factory _Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

/// Client-generated UUID.
@override final  String id;
/// Id of the owning [Profile].
@override final  String ownerId;
@override final  String packId;
@override final  WordType wordType;
/// The headword, e.g. the singular of a noun or the infinitive of a verb.
@override final  String term;
/// Type-specific fields keyed by field key (e.g. `article`, `plural`).
/// Valid keys and values are defined by the pack language's schema.
 final  Map<String, String> _forms;
/// Type-specific fields keyed by field key (e.g. `article`, `plural`).
/// Valid keys and values are defined by the pack language's schema.
@override@JsonKey() Map<String, String> get forms {
  if (_forms is EqualUnmodifiableMapView) return _forms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_forms);
}

 final  List<String> _translations;
@override@JsonKey() List<String> get translations {
  if (_translations is EqualUnmodifiableListView) return _translations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_translations);
}

 final  List<Example> _examples;
@override@JsonKey() List<Example> get examples {
  if (_examples is EqualUnmodifiableListView) return _examples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_examples);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String? notes;
/// Version of the language schema the [forms] were written against.
@override final  int schemaVersion;
/// UTC.
@override final  DateTime createdAt;
/// UTC.
@override final  DateTime updatedAt;
/// UTC. Set when soft-deleted, so the deletion can be synced.
@override final  DateTime? deletedAt;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryCopyWith<_Entry> get copyWith => __$EntryCopyWithImpl<_Entry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Entry&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.wordType, wordType) || other.wordType == wordType)&&(identical(other.term, term) || other.term == term)&&const DeepCollectionEquality().equals(other.forms, _forms)&&const DeepCollectionEquality().equals(other.translations, _translations)&&const DeepCollectionEquality().equals(other.examples, _examples)&&const DeepCollectionEquality().equals(other.tags, _tags)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,ownerId,packId,wordType,term,const DeepCollectionEquality().hash(_forms),const DeepCollectionEquality().hash(_translations),const DeepCollectionEquality().hash(_examples),const DeepCollectionEquality().hash(_tags),notes,schemaVersion,createdAt,updatedAt,deletedAt);
}

@override
String toString() {
    return 'Entry(id: $id, ownerId: $ownerId, packId: $packId, wordType: $wordType, term: $term, forms: $forms, translations: $translations, examples: $examples, tags: $tags, notes: $notes, schemaVersion: $schemaVersion, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$EntryCopyWith<$Res> implements $EntryCopyWith<$Res> {
  factory _$EntryCopyWith(_Entry value, $Res Function(_Entry) _then) = __$EntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String packId, WordType wordType, String term, Map<String, String> forms, List<String> translations, List<Example> examples, List<String> tags, String? notes, int schemaVersion, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$EntryCopyWithImpl<$Res>
    implements _$EntryCopyWith<$Res> {
  __$EntryCopyWithImpl(this._self, this._then);

  final _Entry _self;
  final $Res Function(_Entry) _then;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? packId = null,Object? wordType = null,Object? term = null,Object? forms = null,Object? translations = null,Object? examples = null,Object? tags = null,Object? notes = freezed,Object? schemaVersion = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_Entry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,wordType: null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as WordType,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,forms: null == forms ? _self._forms : forms // ignore: cast_nullable_to_non_nullable
as Map<String, String>,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as List<String>,examples: null == examples ? _self._examples : examples // ignore: cast_nullable_to_non_nullable
as List<Example>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Example {

 String get text; String? get translation;
/// Create a copy of Example
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExampleCopyWith<Example> get copyWith => _$ExampleCopyWithImpl<Example>(this as Example, _$identity);

  /// Serializes this Example to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Example;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Example&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.translation, _this.translation) || other.translation == _this.translation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Example;
  return Object.hash(runtimeType,_this.text,_this.translation);
}

@override
String toString() {
  final _this = this as Example;
  return 'Example(text: ${_this.text}, translation: ${_this.translation})';
}


}

/// @nodoc
abstract mixin class $ExampleCopyWith<$Res>  {
  factory $ExampleCopyWith(Example value, $Res Function(Example) _then) = _$ExampleCopyWithImpl;
@useResult
$Res call({
 String text, String? translation
});




}
/// @nodoc
class _$ExampleCopyWithImpl<$Res>
    implements $ExampleCopyWith<$Res> {
  _$ExampleCopyWithImpl(this._self, this._then);

  final Example _self;
  final $Res Function(Example) _then;

/// Create a copy of Example
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? translation = freezed,}) {
  return _then(Example(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,translation: freezed == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Example].
extension ExamplePatterns on Example {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Example value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Example() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Example value)  $default,){
final _that = this;
switch (_that) {
case _Example():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Example value)?  $default,){
final _that = this;
switch (_that) {
case _Example() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  String? translation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Example() when $default != null:
return $default(_that.text,_that.translation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  String? translation)  $default,) {final _that = this;
switch (_that) {
case _Example():
return $default(_that.text,_that.translation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  String? translation)?  $default,) {final _that = this;
switch (_that) {
case _Example() when $default != null:
return $default(_that.text,_that.translation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Example implements Example {
  const _Example({required this.text, this.translation});
  factory _Example.fromJson(Map<String, dynamic> json) => _$ExampleFromJson(json);

@override final  String text;
@override final  String? translation;

/// Create a copy of Example
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExampleCopyWith<_Example> get copyWith => __$ExampleCopyWithImpl<_Example>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExampleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Example&&(identical(other.text, text) || other.text == text)&&(identical(other.translation, translation) || other.translation == translation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,translation);
}

@override
String toString() {
    return 'Example(text: $text, translation: $translation)';
}


}

/// @nodoc
abstract mixin class _$ExampleCopyWith<$Res> implements $ExampleCopyWith<$Res> {
  factory _$ExampleCopyWith(_Example value, $Res Function(_Example) _then) = __$ExampleCopyWithImpl;
@override @useResult
$Res call({
 String text, String? translation
});




}
/// @nodoc
class __$ExampleCopyWithImpl<$Res>
    implements _$ExampleCopyWith<$Res> {
  __$ExampleCopyWithImpl(this._self, this._then);

  final _Example _self;
  final $Res Function(_Example) _then;

/// Create a copy of Example
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? translation = freezed,}) {
  return _then(_Example(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,translation: freezed == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
