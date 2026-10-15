// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_pack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LanguagePack _$LanguagePackFromJson(Map<String, dynamic> json) =>
    _LanguagePack(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      languageCode: json['language_code'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$LanguagePackToJson(_LanguagePack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'name': instance.name,
      'language_code': instance.languageCode,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
