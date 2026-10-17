// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pack_file_pack.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PackFilePack {

 String get name; String get languageCode;/// UTC.
 DateTime get createdAt; List<PackFileEntry> get entries; List<PackFileDeck> get decks;
/// Create a copy of PackFilePack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackFilePackCopyWith<PackFilePack> get copyWith => _$PackFilePackCopyWithImpl<PackFilePack>(this as PackFilePack, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PackFilePack;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackFilePack&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.languageCode, _this.languageCode) || other.languageCode == _this.languageCode)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&const DeepCollectionEquality().equals(other.decks, _this.decks));
}


@override
int get hashCode {
  final _this = this as PackFilePack;
  return Object.hash(runtimeType,_this.name,_this.languageCode,_this.createdAt,const DeepCollectionEquality().hash(_this.entries),const DeepCollectionEquality().hash(_this.decks));
}

@override
String toString() {
  final _this = this as PackFilePack;
  return 'PackFilePack(name: ${_this.name}, languageCode: ${_this.languageCode}, createdAt: ${_this.createdAt}, entries: ${_this.entries}, decks: ${_this.decks})';
}


}

/// @nodoc
abstract mixin class $PackFilePackCopyWith<$Res>  {
  factory $PackFilePackCopyWith(PackFilePack value, $Res Function(PackFilePack) _then) = _$PackFilePackCopyWithImpl;
@useResult
$Res call({
 String name, String languageCode, DateTime createdAt, List<PackFileEntry> entries, List<PackFileDeck> decks
});




}
/// @nodoc
class _$PackFilePackCopyWithImpl<$Res>
    implements $PackFilePackCopyWith<$Res> {
  _$PackFilePackCopyWithImpl(this._self, this._then);

  final PackFilePack _self;
  final $Res Function(PackFilePack) _then;

/// Create a copy of PackFilePack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? languageCode = null,Object? createdAt = null,Object? entries = null,Object? decks = null,}) {
  return _then(PackFilePack(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<PackFileEntry>,decks: null == decks ? _self.decks : decks // ignore: cast_nullable_to_non_nullable
as List<PackFileDeck>,
  ));
}

}


/// Adds pattern-matching-related methods to [PackFilePack].
extension PackFilePackPatterns on PackFilePack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackFilePack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackFilePack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackFilePack value)  $default,){
final _that = this;
switch (_that) {
case _PackFilePack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackFilePack value)?  $default,){
final _that = this;
switch (_that) {
case _PackFilePack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String languageCode,  DateTime createdAt,  List<PackFileEntry> entries,  List<PackFileDeck> decks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackFilePack() when $default != null:
return $default(_that.name,_that.languageCode,_that.createdAt,_that.entries,_that.decks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String languageCode,  DateTime createdAt,  List<PackFileEntry> entries,  List<PackFileDeck> decks)  $default,) {final _that = this;
switch (_that) {
case _PackFilePack():
return $default(_that.name,_that.languageCode,_that.createdAt,_that.entries,_that.decks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String languageCode,  DateTime createdAt,  List<PackFileEntry> entries,  List<PackFileDeck> decks)?  $default,) {final _that = this;
switch (_that) {
case _PackFilePack() when $default != null:
return $default(_that.name,_that.languageCode,_that.createdAt,_that.entries,_that.decks);case _:
  return null;

}
}

}

/// @nodoc


class _PackFilePack implements PackFilePack {
  const _PackFilePack({required this.name, required this.languageCode, required this.createdAt,  List<PackFileEntry> entries = const <PackFileEntry>[],  List<PackFileDeck> decks = const <PackFileDeck>[]}): _entries = entries,_decks = decks;
  

@override final  String name;
@override final  String languageCode;
/// UTC.
@override final  DateTime createdAt;
 final  List<PackFileEntry> _entries;
@override@JsonKey() List<PackFileEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

 final  List<PackFileDeck> _decks;
@override@JsonKey() List<PackFileDeck> get decks {
  if (_decks is EqualUnmodifiableListView) return _decks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_decks);
}


/// Create a copy of PackFilePack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackFilePackCopyWith<_PackFilePack> get copyWith => __$PackFilePackCopyWithImpl<_PackFilePack>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackFilePack&&(identical(other.name, name) || other.name == name)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.entries, _entries)&&const DeepCollectionEquality().equals(other.decks, _decks));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,languageCode,createdAt,const DeepCollectionEquality().hash(_entries),const DeepCollectionEquality().hash(_decks));
}

@override
String toString() {
    return 'PackFilePack(name: $name, languageCode: $languageCode, createdAt: $createdAt, entries: $entries, decks: $decks)';
}


}

/// @nodoc
abstract mixin class _$PackFilePackCopyWith<$Res> implements $PackFilePackCopyWith<$Res> {
  factory _$PackFilePackCopyWith(_PackFilePack value, $Res Function(_PackFilePack) _then) = __$PackFilePackCopyWithImpl;
@override @useResult
$Res call({
 String name, String languageCode, DateTime createdAt, List<PackFileEntry> entries, List<PackFileDeck> decks
});




}
/// @nodoc
class __$PackFilePackCopyWithImpl<$Res>
    implements _$PackFilePackCopyWith<$Res> {
  __$PackFilePackCopyWithImpl(this._self, this._then);

  final _PackFilePack _self;
  final $Res Function(_PackFilePack) _then;

/// Create a copy of PackFilePack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? languageCode = null,Object? createdAt = null,Object? entries = null,Object? decks = null,}) {
  return _then(_PackFilePack(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<PackFileEntry>,decks: null == decks ? _self._decks : decks // ignore: cast_nullable_to_non_nullable
as List<PackFileDeck>,
  ));
}


}

/// @nodoc
mixin _$PackFileEntry {

 WordType get wordType; String get term; Map<String, String> get forms; List<String> get translations; List<Example> get examples; List<String> get tags; String? get notes;/// UTC.
 DateTime get createdAt;
/// Create a copy of PackFileEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackFileEntryCopyWith<PackFileEntry> get copyWith => _$PackFileEntryCopyWithImpl<PackFileEntry>(this as PackFileEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PackFileEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackFileEntry&&(identical(other.wordType, _this.wordType) || other.wordType == _this.wordType)&&(identical(other.term, _this.term) || other.term == _this.term)&&const DeepCollectionEquality().equals(other.forms, _this.forms)&&const DeepCollectionEquality().equals(other.translations, _this.translations)&&const DeepCollectionEquality().equals(other.examples, _this.examples)&&const DeepCollectionEquality().equals(other.tags, _this.tags)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as PackFileEntry;
  return Object.hash(runtimeType,_this.wordType,_this.term,const DeepCollectionEquality().hash(_this.forms),const DeepCollectionEquality().hash(_this.translations),const DeepCollectionEquality().hash(_this.examples),const DeepCollectionEquality().hash(_this.tags),_this.notes,_this.createdAt);
}

@override
String toString() {
  final _this = this as PackFileEntry;
  return 'PackFileEntry(wordType: ${_this.wordType}, term: ${_this.term}, forms: ${_this.forms}, translations: ${_this.translations}, examples: ${_this.examples}, tags: ${_this.tags}, notes: ${_this.notes}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $PackFileEntryCopyWith<$Res>  {
  factory $PackFileEntryCopyWith(PackFileEntry value, $Res Function(PackFileEntry) _then) = _$PackFileEntryCopyWithImpl;
@useResult
$Res call({
 WordType wordType, String term, Map<String, String> forms, List<String> translations, List<Example> examples, List<String> tags, String? notes, DateTime createdAt
});




}
/// @nodoc
class _$PackFileEntryCopyWithImpl<$Res>
    implements $PackFileEntryCopyWith<$Res> {
  _$PackFileEntryCopyWithImpl(this._self, this._then);

  final PackFileEntry _self;
  final $Res Function(PackFileEntry) _then;

/// Create a copy of PackFileEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wordType = null,Object? term = null,Object? forms = null,Object? translations = null,Object? examples = null,Object? tags = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(PackFileEntry(
wordType: null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as WordType,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,forms: null == forms ? _self.forms : forms // ignore: cast_nullable_to_non_nullable
as Map<String, String>,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as List<String>,examples: null == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as List<Example>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PackFileEntry].
extension PackFileEntryPatterns on PackFileEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackFileEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackFileEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackFileEntry value)  $default,){
final _that = this;
switch (_that) {
case _PackFileEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackFileEntry value)?  $default,){
final _that = this;
switch (_that) {
case _PackFileEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WordType wordType,  String term,  Map<String, String> forms,  List<String> translations,  List<Example> examples,  List<String> tags,  String? notes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackFileEntry() when $default != null:
return $default(_that.wordType,_that.term,_that.forms,_that.translations,_that.examples,_that.tags,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WordType wordType,  String term,  Map<String, String> forms,  List<String> translations,  List<Example> examples,  List<String> tags,  String? notes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PackFileEntry():
return $default(_that.wordType,_that.term,_that.forms,_that.translations,_that.examples,_that.tags,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WordType wordType,  String term,  Map<String, String> forms,  List<String> translations,  List<Example> examples,  List<String> tags,  String? notes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PackFileEntry() when $default != null:
return $default(_that.wordType,_that.term,_that.forms,_that.translations,_that.examples,_that.tags,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _PackFileEntry extends PackFileEntry {
  const _PackFileEntry({required this.wordType, required this.term,  Map<String, String> forms = const <String, String>{},  List<String> translations = const <String>[],  List<Example> examples = const <Example>[],  List<String> tags = const <String>[], this.notes, required this.createdAt}): _forms = forms,_translations = translations,_examples = examples,_tags = tags,super._();
  

@override final  WordType wordType;
@override final  String term;
 final  Map<String, String> _forms;
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
/// UTC.
@override final  DateTime createdAt;

/// Create a copy of PackFileEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackFileEntryCopyWith<_PackFileEntry> get copyWith => __$PackFileEntryCopyWithImpl<_PackFileEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackFileEntry&&(identical(other.wordType, wordType) || other.wordType == wordType)&&(identical(other.term, term) || other.term == term)&&const DeepCollectionEquality().equals(other.forms, _forms)&&const DeepCollectionEquality().equals(other.translations, _translations)&&const DeepCollectionEquality().equals(other.examples, _examples)&&const DeepCollectionEquality().equals(other.tags, _tags)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,wordType,term,const DeepCollectionEquality().hash(_forms),const DeepCollectionEquality().hash(_translations),const DeepCollectionEquality().hash(_examples),const DeepCollectionEquality().hash(_tags),notes,createdAt);
}

@override
String toString() {
    return 'PackFileEntry(wordType: $wordType, term: $term, forms: $forms, translations: $translations, examples: $examples, tags: $tags, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PackFileEntryCopyWith<$Res> implements $PackFileEntryCopyWith<$Res> {
  factory _$PackFileEntryCopyWith(_PackFileEntry value, $Res Function(_PackFileEntry) _then) = __$PackFileEntryCopyWithImpl;
@override @useResult
$Res call({
 WordType wordType, String term, Map<String, String> forms, List<String> translations, List<Example> examples, List<String> tags, String? notes, DateTime createdAt
});




}
/// @nodoc
class __$PackFileEntryCopyWithImpl<$Res>
    implements _$PackFileEntryCopyWith<$Res> {
  __$PackFileEntryCopyWithImpl(this._self, this._then);

  final _PackFileEntry _self;
  final $Res Function(_PackFileEntry) _then;

/// Create a copy of PackFileEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wordType = null,Object? term = null,Object? forms = null,Object? translations = null,Object? examples = null,Object? tags = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_PackFileEntry(
wordType: null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as WordType,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,forms: null == forms ? _self._forms : forms // ignore: cast_nullable_to_non_nullable
as Map<String, String>,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as List<String>,examples: null == examples ? _self._examples : examples // ignore: cast_nullable_to_non_nullable
as List<Example>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$PackFileDeck {

 String get name; List<DeckFilter> get filters;/// UTC.
 DateTime get createdAt;
/// Create a copy of PackFileDeck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackFileDeckCopyWith<PackFileDeck> get copyWith => _$PackFileDeckCopyWithImpl<PackFileDeck>(this as PackFileDeck, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PackFileDeck;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackFileDeck&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.filters, _this.filters)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as PackFileDeck;
  return Object.hash(runtimeType,_this.name,const DeepCollectionEquality().hash(_this.filters),_this.createdAt);
}

@override
String toString() {
  final _this = this as PackFileDeck;
  return 'PackFileDeck(name: ${_this.name}, filters: ${_this.filters}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $PackFileDeckCopyWith<$Res>  {
  factory $PackFileDeckCopyWith(PackFileDeck value, $Res Function(PackFileDeck) _then) = _$PackFileDeckCopyWithImpl;
@useResult
$Res call({
 String name, List<DeckFilter> filters, DateTime createdAt
});




}
/// @nodoc
class _$PackFileDeckCopyWithImpl<$Res>
    implements $PackFileDeckCopyWith<$Res> {
  _$PackFileDeckCopyWithImpl(this._self, this._then);

  final PackFileDeck _self;
  final $Res Function(PackFileDeck) _then;

/// Create a copy of PackFileDeck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? filters = null,Object? createdAt = null,}) {
  return _then(PackFileDeck(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as List<DeckFilter>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PackFileDeck].
extension PackFileDeckPatterns on PackFileDeck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackFileDeck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackFileDeck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackFileDeck value)  $default,){
final _that = this;
switch (_that) {
case _PackFileDeck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackFileDeck value)?  $default,){
final _that = this;
switch (_that) {
case _PackFileDeck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<DeckFilter> filters,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackFileDeck() when $default != null:
return $default(_that.name,_that.filters,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<DeckFilter> filters,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PackFileDeck():
return $default(_that.name,_that.filters,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<DeckFilter> filters,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PackFileDeck() when $default != null:
return $default(_that.name,_that.filters,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _PackFileDeck extends PackFileDeck {
  const _PackFileDeck({required this.name,  List<DeckFilter> filters = const <DeckFilter>[], required this.createdAt}): _filters = filters,super._();
  

@override final  String name;
 final  List<DeckFilter> _filters;
@override@JsonKey() List<DeckFilter> get filters {
  if (_filters is EqualUnmodifiableListView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filters);
}

/// UTC.
@override final  DateTime createdAt;

/// Create a copy of PackFileDeck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackFileDeckCopyWith<_PackFileDeck> get copyWith => __$PackFileDeckCopyWithImpl<_PackFileDeck>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackFileDeck&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.filters, _filters)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_filters),createdAt);
}

@override
String toString() {
    return 'PackFileDeck(name: $name, filters: $filters, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PackFileDeckCopyWith<$Res> implements $PackFileDeckCopyWith<$Res> {
  factory _$PackFileDeckCopyWith(_PackFileDeck value, $Res Function(_PackFileDeck) _then) = __$PackFileDeckCopyWithImpl;
@override @useResult
$Res call({
 String name, List<DeckFilter> filters, DateTime createdAt
});




}
/// @nodoc
class __$PackFileDeckCopyWithImpl<$Res>
    implements _$PackFileDeckCopyWith<$Res> {
  __$PackFileDeckCopyWithImpl(this._self, this._then);

  final _PackFileDeck _self;
  final $Res Function(_PackFileDeck) _then;

/// Create a copy of PackFileDeck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? filters = null,Object? createdAt = null,}) {
  return _then(_PackFileDeck(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as List<DeckFilter>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
