// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EntryDraft {

 String get packId; WordType get wordType; String get term; Map<String, String> get forms; List<String> get translations; List<Example> get examples; List<String> get tags; String? get notes;
/// Create a copy of EntryDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryDraftCopyWith<EntryDraft> get copyWith => _$EntryDraftCopyWithImpl<EntryDraft>(this as EntryDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EntryDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntryDraft&&(identical(other.packId, _this.packId) || other.packId == _this.packId)&&(identical(other.wordType, _this.wordType) || other.wordType == _this.wordType)&&(identical(other.term, _this.term) || other.term == _this.term)&&const DeepCollectionEquality().equals(other.forms, _this.forms)&&const DeepCollectionEquality().equals(other.translations, _this.translations)&&const DeepCollectionEquality().equals(other.examples, _this.examples)&&const DeepCollectionEquality().equals(other.tags, _this.tags)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}


@override
int get hashCode {
  final _this = this as EntryDraft;
  return Object.hash(runtimeType,_this.packId,_this.wordType,_this.term,const DeepCollectionEquality().hash(_this.forms),const DeepCollectionEquality().hash(_this.translations),const DeepCollectionEquality().hash(_this.examples),const DeepCollectionEquality().hash(_this.tags),_this.notes);
}

@override
String toString() {
  final _this = this as EntryDraft;
  return 'EntryDraft(packId: ${_this.packId}, wordType: ${_this.wordType}, term: ${_this.term}, forms: ${_this.forms}, translations: ${_this.translations}, examples: ${_this.examples}, tags: ${_this.tags}, notes: ${_this.notes})';
}


}

/// @nodoc
abstract mixin class $EntryDraftCopyWith<$Res>  {
  factory $EntryDraftCopyWith(EntryDraft value, $Res Function(EntryDraft) _then) = _$EntryDraftCopyWithImpl;
@useResult
$Res call({
 String packId, WordType wordType, String term, Map<String, String> forms, List<String> translations, List<Example> examples, List<String> tags, String? notes
});




}
/// @nodoc
class _$EntryDraftCopyWithImpl<$Res>
    implements $EntryDraftCopyWith<$Res> {
  _$EntryDraftCopyWithImpl(this._self, this._then);

  final EntryDraft _self;
  final $Res Function(EntryDraft) _then;

/// Create a copy of EntryDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packId = null,Object? wordType = null,Object? term = null,Object? forms = null,Object? translations = null,Object? examples = null,Object? tags = null,Object? notes = freezed,}) {
  return _then(EntryDraft(
packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,wordType: null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as WordType,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,forms: null == forms ? _self.forms : forms // ignore: cast_nullable_to_non_nullable
as Map<String, String>,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as List<String>,examples: null == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as List<Example>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EntryDraft].
extension EntryDraftPatterns on EntryDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntryDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntryDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntryDraft value)  $default,){
final _that = this;
switch (_that) {
case _EntryDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntryDraft value)?  $default,){
final _that = this;
switch (_that) {
case _EntryDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String packId,  WordType wordType,  String term,  Map<String, String> forms,  List<String> translations,  List<Example> examples,  List<String> tags,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntryDraft() when $default != null:
return $default(_that.packId,_that.wordType,_that.term,_that.forms,_that.translations,_that.examples,_that.tags,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String packId,  WordType wordType,  String term,  Map<String, String> forms,  List<String> translations,  List<Example> examples,  List<String> tags,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _EntryDraft():
return $default(_that.packId,_that.wordType,_that.term,_that.forms,_that.translations,_that.examples,_that.tags,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String packId,  WordType wordType,  String term,  Map<String, String> forms,  List<String> translations,  List<Example> examples,  List<String> tags,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _EntryDraft() when $default != null:
return $default(_that.packId,_that.wordType,_that.term,_that.forms,_that.translations,_that.examples,_that.tags,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _EntryDraft implements EntryDraft {
  const _EntryDraft({required this.packId, required this.wordType, required this.term,  Map<String, String> forms = const <String, String>{},  List<String> translations = const <String>[],  List<Example> examples = const <Example>[],  List<String> tags = const <String>[], this.notes}): _forms = forms,_translations = translations,_examples = examples,_tags = tags;
  

@override final  String packId;
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

/// Create a copy of EntryDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryDraftCopyWith<_EntryDraft> get copyWith => __$EntryDraftCopyWithImpl<_EntryDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntryDraft&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.wordType, wordType) || other.wordType == wordType)&&(identical(other.term, term) || other.term == term)&&const DeepCollectionEquality().equals(other.forms, _forms)&&const DeepCollectionEquality().equals(other.translations, _translations)&&const DeepCollectionEquality().equals(other.examples, _examples)&&const DeepCollectionEquality().equals(other.tags, _tags)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,packId,wordType,term,const DeepCollectionEquality().hash(_forms),const DeepCollectionEquality().hash(_translations),const DeepCollectionEquality().hash(_examples),const DeepCollectionEquality().hash(_tags),notes);
}

@override
String toString() {
    return 'EntryDraft(packId: $packId, wordType: $wordType, term: $term, forms: $forms, translations: $translations, examples: $examples, tags: $tags, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$EntryDraftCopyWith<$Res> implements $EntryDraftCopyWith<$Res> {
  factory _$EntryDraftCopyWith(_EntryDraft value, $Res Function(_EntryDraft) _then) = __$EntryDraftCopyWithImpl;
@override @useResult
$Res call({
 String packId, WordType wordType, String term, Map<String, String> forms, List<String> translations, List<Example> examples, List<String> tags, String? notes
});




}
/// @nodoc
class __$EntryDraftCopyWithImpl<$Res>
    implements _$EntryDraftCopyWith<$Res> {
  __$EntryDraftCopyWithImpl(this._self, this._then);

  final _EntryDraft _self;
  final $Res Function(_EntryDraft) _then;

/// Create a copy of EntryDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packId = null,Object? wordType = null,Object? term = null,Object? forms = null,Object? translations = null,Object? examples = null,Object? tags = null,Object? notes = freezed,}) {
  return _then(_EntryDraft(
packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,wordType: null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as WordType,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,forms: null == forms ? _self._forms : forms // ignore: cast_nullable_to_non_nullable
as Map<String, String>,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as List<String>,examples: null == examples ? _self._examples : examples // ignore: cast_nullable_to_non_nullable
as List<Example>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
