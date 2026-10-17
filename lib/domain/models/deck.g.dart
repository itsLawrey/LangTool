// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Deck _$DeckFromJson(Map<String, dynamic> json) => _Deck(
  id: json['id'] as String,
  ownerId: json['owner_id'] as String,
  packId: json['pack_id'] as String,
  name: json['name'] as String,
  filters: json['filters'] == null
      ? const <DeckFilter>[]
      : _filtersFromJson(json['filters'] as List?),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$DeckToJson(_Deck instance) => <String, dynamic>{
  'id': instance.id,
  'owner_id': instance.ownerId,
  'pack_id': instance.packId,
  'name': instance.name,
  'filters': _filtersToJson(instance.filters),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
