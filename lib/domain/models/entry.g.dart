// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Entry _$EntryFromJson(Map<String, dynamic> json) => _Entry(
  id: json['id'] as String,
  ownerId: json['owner_id'] as String,
  packId: json['pack_id'] as String,
  wordType: $enumDecode(_$WordTypeEnumMap, json['word_type']),
  term: json['term'] as String,
  forms:
      (json['forms'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  examples:
      (json['examples'] as List<dynamic>?)
          ?.map((e) => Example.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Example>[],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  notes: json['notes'] as String?,
  schemaVersion: (json['schema_version'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$EntryToJson(_Entry instance) => <String, dynamic>{
  'id': instance.id,
  'owner_id': instance.ownerId,
  'pack_id': instance.packId,
  'word_type': _$WordTypeEnumMap[instance.wordType]!,
  'term': instance.term,
  'forms': instance.forms,
  'translations': instance.translations,
  'examples': instance.examples.map((e) => e.toJson()).toList(),
  'tags': instance.tags,
  'notes': instance.notes,
  'schema_version': instance.schemaVersion,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

const _$WordTypeEnumMap = {
  WordType.noun: 'noun',
  WordType.verb: 'verb',
  WordType.adjective: 'adjective',
  WordType.adverb: 'adverb',
  WordType.phrase: 'phrase',
  WordType.preposition: 'preposition',
  WordType.conjunction: 'conjunction',
  WordType.pronoun: 'pronoun',
  WordType.other: 'other',
};

_Example _$ExampleFromJson(Map<String, dynamic> json) => _Example(
  text: json['text'] as String,
  translation: json['translation'] as String?,
);

Map<String, dynamic> _$ExampleToJson(_Example instance) => <String, dynamic>{
  'text': instance.text,
  'translation': instance.translation,
};
