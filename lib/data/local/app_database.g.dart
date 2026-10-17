// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LanguagePacksTable extends LanguagePacks
    with TableInfo<$LanguagePacksTable, LanguagePackRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LanguagePacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsPushMeta = const VerificationMeta(
    'needsPush',
  );
  @override
  late final GeneratedColumn<bool> needsPush = GeneratedColumn<bool>(
    'needs_push',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_push" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    name,
    languageCode,
    createdAt,
    updatedAt,
    deletedAt,
    needsPush,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'language_packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LanguagePackRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_languageCodeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('needs_push')) {
      context.handle(
        _needsPushMeta,
        needsPush.isAcceptableOrUnknown(data['needs_push']!, _needsPushMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LanguagePackRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LanguagePackRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_code'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      needsPush: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_push'],
      )!,
    );
  }

  @override
  $LanguagePacksTable createAlias(String alias) {
    return $LanguagePacksTable(attachedDatabase, alias);
  }
}

class LanguagePackRow extends DataClass implements Insertable<LanguagePackRow> {
  final String id;
  final String ownerId;
  final String name;
  final String languageCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Whether this row has local changes not yet uploaded. Rows written by
  /// the app are dirty; rows applied from the server are clean.
  final bool needsPush;
  const LanguagePackRow({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.languageCode,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.needsPush,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    map['language_code'] = Variable<String>(languageCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['needs_push'] = Variable<bool>(needsPush);
    return map;
  }

  LanguagePacksCompanion toCompanion(bool nullToAbsent) {
    return LanguagePacksCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(name),
      languageCode: Value(languageCode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      needsPush: Value(needsPush),
    );
  }

  factory LanguagePackRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LanguagePackRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      needsPush: serializer.fromJson<bool>(json['needsPush']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'languageCode': serializer.toJson<String>(languageCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'needsPush': serializer.toJson<bool>(needsPush),
    };
  }

  LanguagePackRow copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? languageCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? needsPush,
  }) => LanguagePackRow(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    languageCode: languageCode ?? this.languageCode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    needsPush: needsPush ?? this.needsPush,
  );
  LanguagePackRow copyWithCompanion(LanguagePacksCompanion data) {
    return LanguagePackRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      needsPush: data.needsPush.present ? data.needsPush.value : this.needsPush,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LanguagePackRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('languageCode: $languageCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('needsPush: $needsPush')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    name,
    languageCode,
    createdAt,
    updatedAt,
    deletedAt,
    needsPush,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LanguagePackRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.languageCode == this.languageCode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.needsPush == this.needsPush);
}

class LanguagePacksCompanion extends UpdateCompanion<LanguagePackRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<String> languageCode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> needsPush;
  final Value<int> rowid;
  const LanguagePacksCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.needsPush = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LanguagePacksCompanion.insert({
    required String id,
    required String ownerId,
    required String name,
    required String languageCode,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.needsPush = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       name = Value(name),
       languageCode = Value(languageCode),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LanguagePackRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? languageCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? needsPush,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (languageCode != null) 'language_code': languageCode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (needsPush != null) 'needs_push': needsPush,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LanguagePacksCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? name,
    Value<String>? languageCode,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? needsPush,
    Value<int>? rowid,
  }) {
    return LanguagePacksCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      languageCode: languageCode ?? this.languageCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      needsPush: needsPush ?? this.needsPush,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (needsPush.present) {
      map['needs_push'] = Variable<bool>(needsPush.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LanguagePacksCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('languageCode: $languageCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('needsPush: $needsPush, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, EntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES language_packs (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<WordType, String> wordType =
      GeneratedColumn<String>(
        'word_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WordType>($EntriesTable.$converterwordType);
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
  forms = GeneratedColumn<String>(
    'forms',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, String>>($EntriesTable.$converterforms);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  translations = GeneratedColumn<String>(
    'translations',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($EntriesTable.$convertertranslations);
  @override
  late final GeneratedColumnWithTypeConverter<List<Example>, String> examples =
      GeneratedColumn<String>(
        'examples',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<Example>>($EntriesTable.$converterexamples);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>(
        'tags',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($EntriesTable.$convertertags);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _searchTermMeta = const VerificationMeta(
    'searchTerm',
  );
  @override
  late final GeneratedColumn<String> searchTerm = GeneratedColumn<String>(
    'search_term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchTranslationsMeta =
      const VerificationMeta('searchTranslations');
  @override
  late final GeneratedColumn<String> searchTranslations =
      GeneratedColumn<String>(
        'search_translations',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _duplicateKeyMeta = const VerificationMeta(
    'duplicateKey',
  );
  @override
  late final GeneratedColumn<String> duplicateKey = GeneratedColumn<String>(
    'duplicate_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagKeysMeta = const VerificationMeta(
    'tagKeys',
  );
  @override
  late final GeneratedColumn<String> tagKeys = GeneratedColumn<String>(
    'tag_keys',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _needsPushMeta = const VerificationMeta(
    'needsPush',
  );
  @override
  late final GeneratedColumn<bool> needsPush = GeneratedColumn<bool>(
    'needs_push',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_push" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    packId,
    wordType,
    term,
    forms,
    translations,
    examples,
    tags,
    notes,
    schemaVersion,
    createdAt,
    updatedAt,
    deletedAt,
    searchTerm,
    searchTranslations,
    duplicateKey,
    tagKeys,
    needsPush,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('search_term')) {
      context.handle(
        _searchTermMeta,
        searchTerm.isAcceptableOrUnknown(data['search_term']!, _searchTermMeta),
      );
    } else if (isInserting) {
      context.missing(_searchTermMeta);
    }
    if (data.containsKey('search_translations')) {
      context.handle(
        _searchTranslationsMeta,
        searchTranslations.isAcceptableOrUnknown(
          data['search_translations']!,
          _searchTranslationsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_searchTranslationsMeta);
    }
    if (data.containsKey('duplicate_key')) {
      context.handle(
        _duplicateKeyMeta,
        duplicateKey.isAcceptableOrUnknown(
          data['duplicate_key']!,
          _duplicateKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_duplicateKeyMeta);
    }
    if (data.containsKey('tag_keys')) {
      context.handle(
        _tagKeysMeta,
        tagKeys.isAcceptableOrUnknown(data['tag_keys']!, _tagKeysMeta),
      );
    }
    if (data.containsKey('needs_push')) {
      context.handle(
        _needsPushMeta,
        needsPush.isAcceptableOrUnknown(data['needs_push']!, _needsPushMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
      wordType: $EntriesTable.$converterwordType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}word_type'],
        )!,
      ),
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      forms: $EntriesTable.$converterforms.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}forms'],
        )!,
      ),
      translations: $EntriesTable.$convertertranslations.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}translations'],
        )!,
      ),
      examples: $EntriesTable.$converterexamples.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}examples'],
        )!,
      ),
      tags: $EntriesTable.$convertertags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      searchTerm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_term'],
      )!,
      searchTranslations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_translations'],
      )!,
      duplicateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duplicate_key'],
      )!,
      tagKeys: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_keys'],
      )!,
      needsPush: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_push'],
      )!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WordType, String, String> $converterwordType =
      const EnumNameConverter<WordType>(WordType.values);
  static TypeConverter<Map<String, String>, String> $converterforms =
      const StringMapConverter();
  static TypeConverter<List<String>, String> $convertertranslations =
      const StringListConverter();
  static TypeConverter<List<Example>, String> $converterexamples =
      const ExampleListConverter();
  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class EntryRow extends DataClass implements Insertable<EntryRow> {
  final String id;
  final String ownerId;
  final String packId;
  final WordType wordType;
  final String term;
  final Map<String, String> forms;
  final List<String> translations;
  final List<Example> examples;
  final List<String> tags;
  final String? notes;
  final int schemaVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String searchTerm;

  /// Normalized translations joined by `\n`.
  final String searchTranslations;
  final String duplicateKey;

  /// The tags' duplicate keys, each wrapped in `\n` (see [tagKeysColumn]),
  /// for the deck tag filter. Only stored locally.
  final String tagKeys;

  /// Whether this row has local changes not yet uploaded. Rows written by
  /// the app are dirty; rows applied from the server are clean.
  final bool needsPush;
  const EntryRow({
    required this.id,
    required this.ownerId,
    required this.packId,
    required this.wordType,
    required this.term,
    required this.forms,
    required this.translations,
    required this.examples,
    required this.tags,
    this.notes,
    required this.schemaVersion,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.searchTerm,
    required this.searchTranslations,
    required this.duplicateKey,
    required this.tagKeys,
    required this.needsPush,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['pack_id'] = Variable<String>(packId);
    {
      map['word_type'] = Variable<String>(
        $EntriesTable.$converterwordType.toSql(wordType),
      );
    }
    map['term'] = Variable<String>(term);
    {
      map['forms'] = Variable<String>(
        $EntriesTable.$converterforms.toSql(forms),
      );
    }
    {
      map['translations'] = Variable<String>(
        $EntriesTable.$convertertranslations.toSql(translations),
      );
    }
    {
      map['examples'] = Variable<String>(
        $EntriesTable.$converterexamples.toSql(examples),
      );
    }
    {
      map['tags'] = Variable<String>($EntriesTable.$convertertags.toSql(tags));
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['schema_version'] = Variable<int>(schemaVersion);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['search_term'] = Variable<String>(searchTerm);
    map['search_translations'] = Variable<String>(searchTranslations);
    map['duplicate_key'] = Variable<String>(duplicateKey);
    map['tag_keys'] = Variable<String>(tagKeys);
    map['needs_push'] = Variable<bool>(needsPush);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      packId: Value(packId),
      wordType: Value(wordType),
      term: Value(term),
      forms: Value(forms),
      translations: Value(translations),
      examples: Value(examples),
      tags: Value(tags),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      schemaVersion: Value(schemaVersion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      searchTerm: Value(searchTerm),
      searchTranslations: Value(searchTranslations),
      duplicateKey: Value(duplicateKey),
      tagKeys: Value(tagKeys),
      needsPush: Value(needsPush),
    );
  }

  factory EntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      packId: serializer.fromJson<String>(json['packId']),
      wordType: $EntriesTable.$converterwordType.fromJson(
        serializer.fromJson<String>(json['wordType']),
      ),
      term: serializer.fromJson<String>(json['term']),
      forms: serializer.fromJson<Map<String, String>>(json['forms']),
      translations: serializer.fromJson<List<String>>(json['translations']),
      examples: serializer.fromJson<List<Example>>(json['examples']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      notes: serializer.fromJson<String?>(json['notes']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      searchTerm: serializer.fromJson<String>(json['searchTerm']),
      searchTranslations: serializer.fromJson<String>(
        json['searchTranslations'],
      ),
      duplicateKey: serializer.fromJson<String>(json['duplicateKey']),
      tagKeys: serializer.fromJson<String>(json['tagKeys']),
      needsPush: serializer.fromJson<bool>(json['needsPush']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'packId': serializer.toJson<String>(packId),
      'wordType': serializer.toJson<String>(
        $EntriesTable.$converterwordType.toJson(wordType),
      ),
      'term': serializer.toJson<String>(term),
      'forms': serializer.toJson<Map<String, String>>(forms),
      'translations': serializer.toJson<List<String>>(translations),
      'examples': serializer.toJson<List<Example>>(examples),
      'tags': serializer.toJson<List<String>>(tags),
      'notes': serializer.toJson<String?>(notes),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'searchTerm': serializer.toJson<String>(searchTerm),
      'searchTranslations': serializer.toJson<String>(searchTranslations),
      'duplicateKey': serializer.toJson<String>(duplicateKey),
      'tagKeys': serializer.toJson<String>(tagKeys),
      'needsPush': serializer.toJson<bool>(needsPush),
    };
  }

  EntryRow copyWith({
    String? id,
    String? ownerId,
    String? packId,
    WordType? wordType,
    String? term,
    Map<String, String>? forms,
    List<String>? translations,
    List<Example>? examples,
    List<String>? tags,
    Value<String?> notes = const Value.absent(),
    int? schemaVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? searchTerm,
    String? searchTranslations,
    String? duplicateKey,
    String? tagKeys,
    bool? needsPush,
  }) => EntryRow(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    packId: packId ?? this.packId,
    wordType: wordType ?? this.wordType,
    term: term ?? this.term,
    forms: forms ?? this.forms,
    translations: translations ?? this.translations,
    examples: examples ?? this.examples,
    tags: tags ?? this.tags,
    notes: notes.present ? notes.value : this.notes,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    searchTerm: searchTerm ?? this.searchTerm,
    searchTranslations: searchTranslations ?? this.searchTranslations,
    duplicateKey: duplicateKey ?? this.duplicateKey,
    tagKeys: tagKeys ?? this.tagKeys,
    needsPush: needsPush ?? this.needsPush,
  );
  EntryRow copyWithCompanion(EntriesCompanion data) {
    return EntryRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      packId: data.packId.present ? data.packId.value : this.packId,
      wordType: data.wordType.present ? data.wordType.value : this.wordType,
      term: data.term.present ? data.term.value : this.term,
      forms: data.forms.present ? data.forms.value : this.forms,
      translations: data.translations.present
          ? data.translations.value
          : this.translations,
      examples: data.examples.present ? data.examples.value : this.examples,
      tags: data.tags.present ? data.tags.value : this.tags,
      notes: data.notes.present ? data.notes.value : this.notes,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      searchTerm: data.searchTerm.present
          ? data.searchTerm.value
          : this.searchTerm,
      searchTranslations: data.searchTranslations.present
          ? data.searchTranslations.value
          : this.searchTranslations,
      duplicateKey: data.duplicateKey.present
          ? data.duplicateKey.value
          : this.duplicateKey,
      tagKeys: data.tagKeys.present ? data.tagKeys.value : this.tagKeys,
      needsPush: data.needsPush.present ? data.needsPush.value : this.needsPush,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('packId: $packId, ')
          ..write('wordType: $wordType, ')
          ..write('term: $term, ')
          ..write('forms: $forms, ')
          ..write('translations: $translations, ')
          ..write('examples: $examples, ')
          ..write('tags: $tags, ')
          ..write('notes: $notes, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('searchTerm: $searchTerm, ')
          ..write('searchTranslations: $searchTranslations, ')
          ..write('duplicateKey: $duplicateKey, ')
          ..write('tagKeys: $tagKeys, ')
          ..write('needsPush: $needsPush')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    packId,
    wordType,
    term,
    forms,
    translations,
    examples,
    tags,
    notes,
    schemaVersion,
    createdAt,
    updatedAt,
    deletedAt,
    searchTerm,
    searchTranslations,
    duplicateKey,
    tagKeys,
    needsPush,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.packId == this.packId &&
          other.wordType == this.wordType &&
          other.term == this.term &&
          other.forms == this.forms &&
          other.translations == this.translations &&
          other.examples == this.examples &&
          other.tags == this.tags &&
          other.notes == this.notes &&
          other.schemaVersion == this.schemaVersion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.searchTerm == this.searchTerm &&
          other.searchTranslations == this.searchTranslations &&
          other.duplicateKey == this.duplicateKey &&
          other.tagKeys == this.tagKeys &&
          other.needsPush == this.needsPush);
}

class EntriesCompanion extends UpdateCompanion<EntryRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> packId;
  final Value<WordType> wordType;
  final Value<String> term;
  final Value<Map<String, String>> forms;
  final Value<List<String>> translations;
  final Value<List<Example>> examples;
  final Value<List<String>> tags;
  final Value<String?> notes;
  final Value<int> schemaVersion;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> searchTerm;
  final Value<String> searchTranslations;
  final Value<String> duplicateKey;
  final Value<String> tagKeys;
  final Value<bool> needsPush;
  final Value<int> rowid;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.packId = const Value.absent(),
    this.wordType = const Value.absent(),
    this.term = const Value.absent(),
    this.forms = const Value.absent(),
    this.translations = const Value.absent(),
    this.examples = const Value.absent(),
    this.tags = const Value.absent(),
    this.notes = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.searchTerm = const Value.absent(),
    this.searchTranslations = const Value.absent(),
    this.duplicateKey = const Value.absent(),
    this.tagKeys = const Value.absent(),
    this.needsPush = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required String id,
    required String ownerId,
    required String packId,
    required WordType wordType,
    required String term,
    required Map<String, String> forms,
    required List<String> translations,
    required List<Example> examples,
    required List<String> tags,
    this.notes = const Value.absent(),
    required int schemaVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String searchTerm,
    required String searchTranslations,
    required String duplicateKey,
    this.tagKeys = const Value.absent(),
    this.needsPush = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       packId = Value(packId),
       wordType = Value(wordType),
       term = Value(term),
       forms = Value(forms),
       translations = Value(translations),
       examples = Value(examples),
       tags = Value(tags),
       schemaVersion = Value(schemaVersion),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       searchTerm = Value(searchTerm),
       searchTranslations = Value(searchTranslations),
       duplicateKey = Value(duplicateKey);
  static Insertable<EntryRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? packId,
    Expression<String>? wordType,
    Expression<String>? term,
    Expression<String>? forms,
    Expression<String>? translations,
    Expression<String>? examples,
    Expression<String>? tags,
    Expression<String>? notes,
    Expression<int>? schemaVersion,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? searchTerm,
    Expression<String>? searchTranslations,
    Expression<String>? duplicateKey,
    Expression<String>? tagKeys,
    Expression<bool>? needsPush,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (packId != null) 'pack_id': packId,
      if (wordType != null) 'word_type': wordType,
      if (term != null) 'term': term,
      if (forms != null) 'forms': forms,
      if (translations != null) 'translations': translations,
      if (examples != null) 'examples': examples,
      if (tags != null) 'tags': tags,
      if (notes != null) 'notes': notes,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (searchTerm != null) 'search_term': searchTerm,
      if (searchTranslations != null) 'search_translations': searchTranslations,
      if (duplicateKey != null) 'duplicate_key': duplicateKey,
      if (tagKeys != null) 'tag_keys': tagKeys,
      if (needsPush != null) 'needs_push': needsPush,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? packId,
    Value<WordType>? wordType,
    Value<String>? term,
    Value<Map<String, String>>? forms,
    Value<List<String>>? translations,
    Value<List<Example>>? examples,
    Value<List<String>>? tags,
    Value<String?>? notes,
    Value<int>? schemaVersion,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? searchTerm,
    Value<String>? searchTranslations,
    Value<String>? duplicateKey,
    Value<String>? tagKeys,
    Value<bool>? needsPush,
    Value<int>? rowid,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      packId: packId ?? this.packId,
      wordType: wordType ?? this.wordType,
      term: term ?? this.term,
      forms: forms ?? this.forms,
      translations: translations ?? this.translations,
      examples: examples ?? this.examples,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      searchTerm: searchTerm ?? this.searchTerm,
      searchTranslations: searchTranslations ?? this.searchTranslations,
      duplicateKey: duplicateKey ?? this.duplicateKey,
      tagKeys: tagKeys ?? this.tagKeys,
      needsPush: needsPush ?? this.needsPush,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (wordType.present) {
      map['word_type'] = Variable<String>(
        $EntriesTable.$converterwordType.toSql(wordType.value),
      );
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (forms.present) {
      map['forms'] = Variable<String>(
        $EntriesTable.$converterforms.toSql(forms.value),
      );
    }
    if (translations.present) {
      map['translations'] = Variable<String>(
        $EntriesTable.$convertertranslations.toSql(translations.value),
      );
    }
    if (examples.present) {
      map['examples'] = Variable<String>(
        $EntriesTable.$converterexamples.toSql(examples.value),
      );
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
        $EntriesTable.$convertertags.toSql(tags.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (searchTerm.present) {
      map['search_term'] = Variable<String>(searchTerm.value);
    }
    if (searchTranslations.present) {
      map['search_translations'] = Variable<String>(searchTranslations.value);
    }
    if (duplicateKey.present) {
      map['duplicate_key'] = Variable<String>(duplicateKey.value);
    }
    if (tagKeys.present) {
      map['tag_keys'] = Variable<String>(tagKeys.value);
    }
    if (needsPush.present) {
      map['needs_push'] = Variable<bool>(needsPush.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('packId: $packId, ')
          ..write('wordType: $wordType, ')
          ..write('term: $term, ')
          ..write('forms: $forms, ')
          ..write('translations: $translations, ')
          ..write('examples: $examples, ')
          ..write('tags: $tags, ')
          ..write('notes: $notes, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('searchTerm: $searchTerm, ')
          ..write('searchTranslations: $searchTranslations, ')
          ..write('duplicateKey: $duplicateKey, ')
          ..write('tagKeys: $tagKeys, ')
          ..write('needsPush: $needsPush, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecksTable extends Decks with TableInfo<$DecksTable, DeckRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES language_packs (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<DeckFilter>, String>
  filters = GeneratedColumn<String>(
    'filters',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<DeckFilter>>($DecksTable.$converterfilters);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsPushMeta = const VerificationMeta(
    'needsPush',
  );
  @override
  late final GeneratedColumn<bool> needsPush = GeneratedColumn<bool>(
    'needs_push',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_push" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    packId,
    name,
    filters,
    createdAt,
    updatedAt,
    deletedAt,
    needsPush,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('needs_push')) {
      context.handle(
        _needsPushMeta,
        needsPush.isAcceptableOrUnknown(data['needs_push']!, _needsPushMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeckRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      filters: $DecksTable.$converterfilters.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}filters'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      needsPush: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_push'],
      )!,
    );
  }

  @override
  $DecksTable createAlias(String alias) {
    return $DecksTable(attachedDatabase, alias);
  }

  static TypeConverter<List<DeckFilter>, String> $converterfilters =
      const DeckFilterListConverter();
}

class DeckRow extends DataClass implements Insertable<DeckRow> {
  final String id;
  final String ownerId;
  final String packId;
  final String name;
  final List<DeckFilter> filters;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Whether this row has local changes not yet uploaded. Rows written by
  /// the app are dirty; rows applied from the server are clean.
  final bool needsPush;
  const DeckRow({
    required this.id,
    required this.ownerId,
    required this.packId,
    required this.name,
    required this.filters,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.needsPush,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['pack_id'] = Variable<String>(packId);
    map['name'] = Variable<String>(name);
    {
      map['filters'] = Variable<String>(
        $DecksTable.$converterfilters.toSql(filters),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['needs_push'] = Variable<bool>(needsPush);
    return map;
  }

  DecksCompanion toCompanion(bool nullToAbsent) {
    return DecksCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      packId: Value(packId),
      name: Value(name),
      filters: Value(filters),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      needsPush: Value(needsPush),
    );
  }

  factory DeckRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      packId: serializer.fromJson<String>(json['packId']),
      name: serializer.fromJson<String>(json['name']),
      filters: serializer.fromJson<List<DeckFilter>>(json['filters']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      needsPush: serializer.fromJson<bool>(json['needsPush']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'packId': serializer.toJson<String>(packId),
      'name': serializer.toJson<String>(name),
      'filters': serializer.toJson<List<DeckFilter>>(filters),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'needsPush': serializer.toJson<bool>(needsPush),
    };
  }

  DeckRow copyWith({
    String? id,
    String? ownerId,
    String? packId,
    String? name,
    List<DeckFilter>? filters,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? needsPush,
  }) => DeckRow(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    packId: packId ?? this.packId,
    name: name ?? this.name,
    filters: filters ?? this.filters,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    needsPush: needsPush ?? this.needsPush,
  );
  DeckRow copyWithCompanion(DecksCompanion data) {
    return DeckRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      packId: data.packId.present ? data.packId.value : this.packId,
      name: data.name.present ? data.name.value : this.name,
      filters: data.filters.present ? data.filters.value : this.filters,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      needsPush: data.needsPush.present ? data.needsPush.value : this.needsPush,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('packId: $packId, ')
          ..write('name: $name, ')
          ..write('filters: $filters, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('needsPush: $needsPush')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    packId,
    name,
    filters,
    createdAt,
    updatedAt,
    deletedAt,
    needsPush,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.packId == this.packId &&
          other.name == this.name &&
          other.filters == this.filters &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.needsPush == this.needsPush);
}

class DecksCompanion extends UpdateCompanion<DeckRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> packId;
  final Value<String> name;
  final Value<List<DeckFilter>> filters;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> needsPush;
  final Value<int> rowid;
  const DecksCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.packId = const Value.absent(),
    this.name = const Value.absent(),
    this.filters = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.needsPush = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecksCompanion.insert({
    required String id,
    required String ownerId,
    required String packId,
    required String name,
    required List<DeckFilter> filters,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.needsPush = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       packId = Value(packId),
       name = Value(name),
       filters = Value(filters),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DeckRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? packId,
    Expression<String>? name,
    Expression<String>? filters,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? needsPush,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (packId != null) 'pack_id': packId,
      if (name != null) 'name': name,
      if (filters != null) 'filters': filters,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (needsPush != null) 'needs_push': needsPush,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecksCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? packId,
    Value<String>? name,
    Value<List<DeckFilter>>? filters,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? needsPush,
    Value<int>? rowid,
  }) {
    return DecksCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      packId: packId ?? this.packId,
      name: name ?? this.name,
      filters: filters ?? this.filters,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      needsPush: needsPush ?? this.needsPush,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (filters.present) {
      map['filters'] = Variable<String>(
        $DecksTable.$converterfilters.toSql(filters.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (needsPush.present) {
      map['needs_push'] = Variable<bool>(needsPush.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('packId: $packId, ')
          ..write('name: $name, ')
          ..write('filters: $filters, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('needsPush: $needsPush, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packsPulledUntilMeta = const VerificationMeta(
    'packsPulledUntil',
  );
  @override
  late final GeneratedColumn<DateTime> packsPulledUntil =
      GeneratedColumn<DateTime>(
        'packs_pulled_until',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _entriesPulledUntilMeta =
      const VerificationMeta('entriesPulledUntil');
  @override
  late final GeneratedColumn<DateTime> entriesPulledUntil =
      GeneratedColumn<DateTime>(
        'entries_pulled_until',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _decksPulledUntilMeta = const VerificationMeta(
    'decksPulledUntil',
  );
  @override
  late final GeneratedColumn<DateTime> decksPulledUntil =
      GeneratedColumn<DateTime>(
        'decks_pulled_until',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    packsPulledUntil,
    entriesPulledUntil,
    decksPulledUntil,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('packs_pulled_until')) {
      context.handle(
        _packsPulledUntilMeta,
        packsPulledUntil.isAcceptableOrUnknown(
          data['packs_pulled_until']!,
          _packsPulledUntilMeta,
        ),
      );
    }
    if (data.containsKey('entries_pulled_until')) {
      context.handle(
        _entriesPulledUntilMeta,
        entriesPulledUntil.isAcceptableOrUnknown(
          data['entries_pulled_until']!,
          _entriesPulledUntilMeta,
        ),
      );
    }
    if (data.containsKey('decks_pulled_until')) {
      context.handle(
        _decksPulledUntilMeta,
        decksPulledUntil.isAcceptableOrUnknown(
          data['decks_pulled_until']!,
          _decksPulledUntilMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      packsPulledUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}packs_pulled_until'],
      ),
      entriesPulledUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entries_pulled_until'],
      ),
      decksPulledUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}decks_pulled_until'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final String ownerId;

  /// Server time up to which pack changes have been pulled.
  final DateTime? packsPulledUntil;

  /// Server time up to which entry changes have been pulled.
  final DateTime? entriesPulledUntil;

  /// Server time up to which deck changes have been pulled.
  final DateTime? decksPulledUntil;

  /// When the last sync finished successfully.
  final DateTime? lastSyncedAt;
  const SyncStateRow({
    required this.ownerId,
    this.packsPulledUntil,
    this.entriesPulledUntil,
    this.decksPulledUntil,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    if (!nullToAbsent || packsPulledUntil != null) {
      map['packs_pulled_until'] = Variable<DateTime>(packsPulledUntil);
    }
    if (!nullToAbsent || entriesPulledUntil != null) {
      map['entries_pulled_until'] = Variable<DateTime>(entriesPulledUntil);
    }
    if (!nullToAbsent || decksPulledUntil != null) {
      map['decks_pulled_until'] = Variable<DateTime>(decksPulledUntil);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      ownerId: Value(ownerId),
      packsPulledUntil: packsPulledUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(packsPulledUntil),
      entriesPulledUntil: entriesPulledUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(entriesPulledUntil),
      decksPulledUntil: decksPulledUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(decksPulledUntil),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory SyncStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      packsPulledUntil: serializer.fromJson<DateTime?>(
        json['packsPulledUntil'],
      ),
      entriesPulledUntil: serializer.fromJson<DateTime?>(
        json['entriesPulledUntil'],
      ),
      decksPulledUntil: serializer.fromJson<DateTime?>(
        json['decksPulledUntil'],
      ),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'packsPulledUntil': serializer.toJson<DateTime?>(packsPulledUntil),
      'entriesPulledUntil': serializer.toJson<DateTime?>(entriesPulledUntil),
      'decksPulledUntil': serializer.toJson<DateTime?>(decksPulledUntil),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  SyncStateRow copyWith({
    String? ownerId,
    Value<DateTime?> packsPulledUntil = const Value.absent(),
    Value<DateTime?> entriesPulledUntil = const Value.absent(),
    Value<DateTime?> decksPulledUntil = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => SyncStateRow(
    ownerId: ownerId ?? this.ownerId,
    packsPulledUntil: packsPulledUntil.present
        ? packsPulledUntil.value
        : this.packsPulledUntil,
    entriesPulledUntil: entriesPulledUntil.present
        ? entriesPulledUntil.value
        : this.entriesPulledUntil,
    decksPulledUntil: decksPulledUntil.present
        ? decksPulledUntil.value
        : this.decksPulledUntil,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  SyncStateRow copyWithCompanion(SyncStatesCompanion data) {
    return SyncStateRow(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      packsPulledUntil: data.packsPulledUntil.present
          ? data.packsPulledUntil.value
          : this.packsPulledUntil,
      entriesPulledUntil: data.entriesPulledUntil.present
          ? data.entriesPulledUntil.value
          : this.entriesPulledUntil,
      decksPulledUntil: data.decksPulledUntil.present
          ? data.decksPulledUntil.value
          : this.decksPulledUntil,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('ownerId: $ownerId, ')
          ..write('packsPulledUntil: $packsPulledUntil, ')
          ..write('entriesPulledUntil: $entriesPulledUntil, ')
          ..write('decksPulledUntil: $decksPulledUntil, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    packsPulledUntil,
    entriesPulledUntil,
    decksPulledUntil,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.ownerId == this.ownerId &&
          other.packsPulledUntil == this.packsPulledUntil &&
          other.entriesPulledUntil == this.entriesPulledUntil &&
          other.decksPulledUntil == this.decksPulledUntil &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncStatesCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> ownerId;
  final Value<DateTime?> packsPulledUntil;
  final Value<DateTime?> entriesPulledUntil;
  final Value<DateTime?> decksPulledUntil;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const SyncStatesCompanion({
    this.ownerId = const Value.absent(),
    this.packsPulledUntil = const Value.absent(),
    this.entriesPulledUntil = const Value.absent(),
    this.decksPulledUntil = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    required String ownerId,
    this.packsPulledUntil = const Value.absent(),
    this.entriesPulledUntil = const Value.absent(),
    this.decksPulledUntil = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId);
  static Insertable<SyncStateRow> custom({
    Expression<String>? ownerId,
    Expression<DateTime>? packsPulledUntil,
    Expression<DateTime>? entriesPulledUntil,
    Expression<DateTime>? decksPulledUntil,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (packsPulledUntil != null) 'packs_pulled_until': packsPulledUntil,
      if (entriesPulledUntil != null)
        'entries_pulled_until': entriesPulledUntil,
      if (decksPulledUntil != null) 'decks_pulled_until': decksPulledUntil,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatesCompanion copyWith({
    Value<String>? ownerId,
    Value<DateTime?>? packsPulledUntil,
    Value<DateTime?>? entriesPulledUntil,
    Value<DateTime?>? decksPulledUntil,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return SyncStatesCompanion(
      ownerId: ownerId ?? this.ownerId,
      packsPulledUntil: packsPulledUntil ?? this.packsPulledUntil,
      entriesPulledUntil: entriesPulledUntil ?? this.entriesPulledUntil,
      decksPulledUntil: decksPulledUntil ?? this.decksPulledUntil,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (packsPulledUntil.present) {
      map['packs_pulled_until'] = Variable<DateTime>(packsPulledUntil.value);
    }
    if (entriesPulledUntil.present) {
      map['entries_pulled_until'] = Variable<DateTime>(
        entriesPulledUntil.value,
      );
    }
    if (decksPulledUntil.present) {
      map['decks_pulled_until'] = Variable<DateTime>(decksPulledUntil.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('packsPulledUntil: $packsPulledUntil, ')
          ..write('entriesPulledUntil: $entriesPulledUntil, ')
          ..write('decksPulledUntil: $decksPulledUntil, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LanguagePacksTable languagePacks = $LanguagePacksTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $DecksTable decks = $DecksTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  late final Index languagePacksOwnerId = Index(
    'language_packs_owner_id',
    'CREATE INDEX language_packs_owner_id ON language_packs (owner_id)',
  );
  late final Index entriesPackCreated = Index(
    'entries_pack_created',
    'CREATE INDEX entries_pack_created ON entries (pack_id, created_at)',
  );
  late final Index entriesUniqueTerm = Index(
    'entries_unique_term',
    'CREATE UNIQUE INDEX entries_unique_term ON entries (pack_id, word_type, duplicate_key) WHERE deleted_at IS NULL',
  );
  late final Index decksPackId = Index(
    'decks_pack_id',
    'CREATE INDEX decks_pack_id ON decks (pack_id)',
  );
  late final Index decksOwnerId = Index(
    'decks_owner_id',
    'CREATE INDEX decks_owner_id ON decks (owner_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    languagePacks,
    entries,
    decks,
    syncStates,
    languagePacksOwnerId,
    entriesPackCreated,
    entriesUniqueTerm,
    decksPackId,
    decksOwnerId,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$LanguagePacksTableCreateCompanionBuilder =
    LanguagePacksCompanion Function({
      required String id,
      required String ownerId,
      required String name,
      required String languageCode,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> needsPush,
      Value<int> rowid,
    });
typedef $$LanguagePacksTableUpdateCompanionBuilder =
    LanguagePacksCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> name,
      Value<String> languageCode,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> needsPush,
      Value<int> rowid,
    });

final class $$LanguagePacksTableReferences
    extends
        BaseReferences<_$AppDatabase, $LanguagePacksTable, LanguagePackRow> {
  $$LanguagePacksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$EntriesTable, List<EntryRow>> _entriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: 'language_packs__id__entries__pack_id',
  );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DecksTable, List<DeckRow>> _decksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.decks,
    aliasName: 'language_packs__id__decks__pack_id',
  );

  $$DecksTableProcessedTableManager get decksRefs {
    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_decksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LanguagePacksTableFilterComposer
    extends Composer<_$AppDatabase, $LanguagePacksTable> {
  $$LanguagePacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsPush => $composableBuilder(
    column: $table.needsPush,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> entriesRefs(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> decksRefs(
    Expression<bool> Function($$DecksTableFilterComposer f) f,
  ) {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LanguagePacksTableOrderingComposer
    extends Composer<_$AppDatabase, $LanguagePacksTable> {
  $$LanguagePacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsPush => $composableBuilder(
    column: $table.needsPush,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LanguagePacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LanguagePacksTable> {
  $$LanguagePacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsPush =>
      $composableBuilder(column: $table.needsPush, builder: (column) => column);

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> decksRefs<T extends Object>(
    Expression<T> Function($$DecksTableAnnotationComposer a) f,
  ) {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LanguagePacksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LanguagePacksTable,
          LanguagePackRow,
          $$LanguagePacksTableFilterComposer,
          $$LanguagePacksTableOrderingComposer,
          $$LanguagePacksTableAnnotationComposer,
          $$LanguagePacksTableCreateCompanionBuilder,
          $$LanguagePacksTableUpdateCompanionBuilder,
          (LanguagePackRow, $$LanguagePacksTableReferences),
          LanguagePackRow,
          PrefetchHooks Function({bool entriesRefs, bool decksRefs})
        > {
  $$LanguagePacksTableTableManager(_$AppDatabase db, $LanguagePacksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LanguagePacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LanguagePacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LanguagePacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> needsPush = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LanguagePacksCompanion(
                id: id,
                ownerId: ownerId,
                name: name,
                languageCode: languageCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                needsPush: needsPush,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String name,
                required String languageCode,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> needsPush = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LanguagePacksCompanion.insert(
                id: id,
                ownerId: ownerId,
                name: name,
                languageCode: languageCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                needsPush: needsPush,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LanguagePacksTable, LanguagePackRow>(table),
                  $$LanguagePacksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entriesRefs = false, decksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (entriesRefs) db.entries,
                if (decksRefs) db.decks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (entriesRefs)
                    await $_getPrefetchedData<
                      LanguagePackRow,
                      $LanguagePacksTable,
                      EntryRow
                    >(
                      currentTable: table,
                      referencedTable: $$LanguagePacksTableReferences
                          ._entriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LanguagePacksTableReferences(
                            db,
                            table,
                            p0,
                          ).entriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.packId == item.id),
                      typedResults: items,
                    ),
                  if (decksRefs)
                    await $_getPrefetchedData<
                      LanguagePackRow,
                      $LanguagePacksTable,
                      DeckRow
                    >(
                      currentTable: table,
                      referencedTable: $$LanguagePacksTableReferences
                          ._decksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LanguagePacksTableReferences(
                            db,
                            table,
                            p0,
                          ).decksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.packId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LanguagePacksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LanguagePacksTable,
      LanguagePackRow,
      $$LanguagePacksTableFilterComposer,
      $$LanguagePacksTableOrderingComposer,
      $$LanguagePacksTableAnnotationComposer,
      $$LanguagePacksTableCreateCompanionBuilder,
      $$LanguagePacksTableUpdateCompanionBuilder,
      (LanguagePackRow, $$LanguagePacksTableReferences),
      LanguagePackRow,
      PrefetchHooks Function({bool entriesRefs, bool decksRefs})
    >;
typedef $$EntriesTableCreateCompanionBuilder = EntriesCompanion Function({
  required String id,
  required String ownerId,
  required String packId,
  required WordType wordType,
  required String term,
  required Map<String, String> forms,
  required List<String> translations,
  required List<Example> examples,
  required List<String> tags,
  Value<String?> notes,
  required int schemaVersion,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String searchTerm,
  required String searchTranslations,
  required String duplicateKey,
  Value<String> tagKeys,
  Value<bool> needsPush,
  Value<int> rowid,
});
typedef $$EntriesTableUpdateCompanionBuilder = EntriesCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<String> packId,
  Value<WordType> wordType,
  Value<String> term,
  Value<Map<String, String>> forms,
  Value<List<String>> translations,
  Value<List<Example>> examples,
  Value<List<String>> tags,
  Value<String?> notes,
  Value<int> schemaVersion,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> searchTerm,
  Value<String> searchTranslations,
  Value<String> duplicateKey,
  Value<String> tagKeys,
  Value<bool> needsPush,
  Value<int> rowid,
});

final class $$EntriesTableReferences
    extends BaseReferences<_$AppDatabase, $EntriesTable, EntryRow> {
  $$EntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LanguagePacksTable _packIdTable(_$AppDatabase db) =>
      db.languagePacks.createAlias('entries__pack_id__language_packs__id');

  $$LanguagePacksTableProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $$LanguagePacksTableTableManager(
      $_db,
      $_db.languagePacks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WordType, WordType, String> get wordType =>
      $composableBuilder(
        column: $table.wordType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, String>,
    Map<String, String>,
    String
  >
  get forms => $composableBuilder(
    column: $table.forms,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get translations => $composableBuilder(
    column: $table.translations,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<Example>, List<Example>, String>
  get examples => $composableBuilder(
    column: $table.examples,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
        column: $table.tags,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchTerm => $composableBuilder(
    column: $table.searchTerm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchTranslations => $composableBuilder(
    column: $table.searchTranslations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get duplicateKey => $composableBuilder(
    column: $table.duplicateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagKeys => $composableBuilder(
    column: $table.tagKeys,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsPush => $composableBuilder(
    column: $table.needsPush,
    builder: (column) => ColumnFilters(column),
  );

  $$LanguagePacksTableFilterComposer get packId {
    final $$LanguagePacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.languagePacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LanguagePacksTableFilterComposer(
            $db: $db,
            $table: $db.languagePacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wordType => $composableBuilder(
    column: $table.wordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forms => $composableBuilder(
    column: $table.forms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translations => $composableBuilder(
    column: $table.translations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examples => $composableBuilder(
    column: $table.examples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchTerm => $composableBuilder(
    column: $table.searchTerm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchTranslations => $composableBuilder(
    column: $table.searchTranslations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get duplicateKey => $composableBuilder(
    column: $table.duplicateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagKeys => $composableBuilder(
    column: $table.tagKeys,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsPush => $composableBuilder(
    column: $table.needsPush,
    builder: (column) => ColumnOrderings(column),
  );

  $$LanguagePacksTableOrderingComposer get packId {
    final $$LanguagePacksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.languagePacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LanguagePacksTableOrderingComposer(
            $db: $db,
            $table: $db.languagePacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WordType, String> get wordType =>
      $composableBuilder(column: $table.wordType, builder: (column) => column);

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get forms =>
      $composableBuilder(column: $table.forms, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get translations =>
      $composableBuilder(
        column: $table.translations,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<Example>, String> get examples =>
      $composableBuilder(column: $table.examples, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get searchTerm => $composableBuilder(
    column: $table.searchTerm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchTranslations => $composableBuilder(
    column: $table.searchTranslations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get duplicateKey => $composableBuilder(
    column: $table.duplicateKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tagKeys =>
      $composableBuilder(column: $table.tagKeys, builder: (column) => column);

  GeneratedColumn<bool> get needsPush =>
      $composableBuilder(column: $table.needsPush, builder: (column) => column);

  $$LanguagePacksTableAnnotationComposer get packId {
    final $$LanguagePacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.languagePacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LanguagePacksTableAnnotationComposer(
            $db: $db,
            $table: $db.languagePacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntriesTable,
          EntryRow,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (EntryRow, $$EntriesTableReferences),
          EntryRow,
          PrefetchHooks Function({bool packId})
        > {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<WordType> wordType = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<Map<String, String>> forms = const Value.absent(),
                Value<List<String>> translations = const Value.absent(),
                Value<List<Example>> examples = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> searchTerm = const Value.absent(),
                Value<String> searchTranslations = const Value.absent(),
                Value<String> duplicateKey = const Value.absent(),
                Value<String> tagKeys = const Value.absent(),
                Value<bool> needsPush = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                ownerId: ownerId,
                packId: packId,
                wordType: wordType,
                term: term,
                forms: forms,
                translations: translations,
                examples: examples,
                tags: tags,
                notes: notes,
                schemaVersion: schemaVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                searchTerm: searchTerm,
                searchTranslations: searchTranslations,
                duplicateKey: duplicateKey,
                tagKeys: tagKeys,
                needsPush: needsPush,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String packId,
                required WordType wordType,
                required String term,
                required Map<String, String> forms,
                required List<String> translations,
                required List<Example> examples,
                required List<String> tags,
                Value<String?> notes = const Value.absent(),
                required int schemaVersion,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String searchTerm,
                required String searchTranslations,
                required String duplicateKey,
                Value<String> tagKeys = const Value.absent(),
                Value<bool> needsPush = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                ownerId: ownerId,
                packId: packId,
                wordType: wordType,
                term: term,
                forms: forms,
                translations: translations,
                examples: examples,
                tags: tags,
                notes: notes,
                schemaVersion: schemaVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                searchTerm: searchTerm,
                searchTranslations: searchTranslations,
                duplicateKey: duplicateKey,
                tagKeys: tagKeys,
                needsPush: needsPush,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntriesTable, EntryRow>(table),
                  $$EntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (packId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packId,
                        referencedTable: $$EntriesTableReferences._packIdTable(
                          db,
                        ),
                        referencedColumn: $$EntriesTableReferences
                            ._packIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntriesTable,
      EntryRow,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (EntryRow, $$EntriesTableReferences),
      EntryRow,
      PrefetchHooks Function({bool packId})
    >;
typedef $$DecksTableCreateCompanionBuilder = DecksCompanion Function({
  required String id,
  required String ownerId,
  required String packId,
  required String name,
  required List<DeckFilter> filters,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> needsPush,
  Value<int> rowid,
});
typedef $$DecksTableUpdateCompanionBuilder = DecksCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<String> packId,
  Value<String> name,
  Value<List<DeckFilter>> filters,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> needsPush,
  Value<int> rowid,
});

final class $$DecksTableReferences
    extends BaseReferences<_$AppDatabase, $DecksTable, DeckRow> {
  $$DecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LanguagePacksTable _packIdTable(_$AppDatabase db) =>
      db.languagePacks.createAlias('decks__pack_id__language_packs__id');

  $$LanguagePacksTableProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $$LanguagePacksTableTableManager(
      $_db,
      $_db.languagePacks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DecksTableFilterComposer extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<DeckFilter>, List<DeckFilter>, String>
  get filters => $composableBuilder(
    column: $table.filters,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsPush => $composableBuilder(
    column: $table.needsPush,
    builder: (column) => ColumnFilters(column),
  );

  $$LanguagePacksTableFilterComposer get packId {
    final $$LanguagePacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.languagePacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LanguagePacksTableFilterComposer(
            $db: $db,
            $table: $db.languagePacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecksTableOrderingComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filters => $composableBuilder(
    column: $table.filters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsPush => $composableBuilder(
    column: $table.needsPush,
    builder: (column) => ColumnOrderings(column),
  );

  $$LanguagePacksTableOrderingComposer get packId {
    final $$LanguagePacksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.languagePacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LanguagePacksTableOrderingComposer(
            $db: $db,
            $table: $db.languagePacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<DeckFilter>, String> get filters =>
      $composableBuilder(column: $table.filters, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsPush =>
      $composableBuilder(column: $table.needsPush, builder: (column) => column);

  $$LanguagePacksTableAnnotationComposer get packId {
    final $$LanguagePacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.languagePacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LanguagePacksTableAnnotationComposer(
            $db: $db,
            $table: $db.languagePacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DecksTable,
          DeckRow,
          $$DecksTableFilterComposer,
          $$DecksTableOrderingComposer,
          $$DecksTableAnnotationComposer,
          $$DecksTableCreateCompanionBuilder,
          $$DecksTableUpdateCompanionBuilder,
          (DeckRow, $$DecksTableReferences),
          DeckRow,
          PrefetchHooks Function({bool packId})
        > {
  $$DecksTableTableManager(_$AppDatabase db, $DecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<List<DeckFilter>> filters = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> needsPush = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion(
                id: id,
                ownerId: ownerId,
                packId: packId,
                name: name,
                filters: filters,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                needsPush: needsPush,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String packId,
                required String name,
                required List<DeckFilter> filters,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> needsPush = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion.insert(
                id: id,
                ownerId: ownerId,
                packId: packId,
                name: name,
                filters: filters,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                needsPush: needsPush,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DecksTable, DeckRow>(table),
                  $$DecksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (packId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packId,
                        referencedTable: $$DecksTableReferences._packIdTable(
                          db,
                        ),
                        referencedColumn: $$DecksTableReferences
                            ._packIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DecksTable,
      DeckRow,
      $$DecksTableFilterComposer,
      $$DecksTableOrderingComposer,
      $$DecksTableAnnotationComposer,
      $$DecksTableCreateCompanionBuilder,
      $$DecksTableUpdateCompanionBuilder,
      (DeckRow, $$DecksTableReferences),
      DeckRow,
      PrefetchHooks Function({bool packId})
    >;
typedef $$SyncStatesTableCreateCompanionBuilder = SyncStatesCompanion Function({
  required String ownerId,
  Value<DateTime?> packsPulledUntil,
  Value<DateTime?> entriesPulledUntil,
  Value<DateTime?> decksPulledUntil,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$SyncStatesTableUpdateCompanionBuilder = SyncStatesCompanion Function({
  Value<String> ownerId,
  Value<DateTime?> packsPulledUntil,
  Value<DateTime?> entriesPulledUntil,
  Value<DateTime?> decksPulledUntil,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$SyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get packsPulledUntil => $composableBuilder(
    column: $table.packsPulledUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entriesPulledUntil => $composableBuilder(
    column: $table.entriesPulledUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get decksPulledUntil => $composableBuilder(
    column: $table.decksPulledUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get packsPulledUntil => $composableBuilder(
    column: $table.packsPulledUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entriesPulledUntil => $composableBuilder(
    column: $table.entriesPulledUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get decksPulledUntil => $composableBuilder(
    column: $table.decksPulledUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<DateTime> get packsPulledUntil => $composableBuilder(
    column: $table.packsPulledUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get entriesPulledUntil => $composableBuilder(
    column: $table.entriesPulledUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get decksPulledUntil => $composableBuilder(
    column: $table.decksPulledUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$SyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStatesTable,
          SyncStateRow,
          $$SyncStatesTableFilterComposer,
          $$SyncStatesTableOrderingComposer,
          $$SyncStatesTableAnnotationComposer,
          $$SyncStatesTableCreateCompanionBuilder,
          $$SyncStatesTableUpdateCompanionBuilder,
          (
            SyncStateRow,
            BaseReferences<_$AppDatabase, $SyncStatesTable, SyncStateRow>,
          ),
          SyncStateRow,
          PrefetchHooks Function()
        > {
  $$SyncStatesTableTableManager(_$AppDatabase db, $SyncStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<DateTime?> packsPulledUntil = const Value.absent(),
                Value<DateTime?> entriesPulledUntil = const Value.absent(),
                Value<DateTime?> decksPulledUntil = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion(
                ownerId: ownerId,
                packsPulledUntil: packsPulledUntil,
                entriesPulledUntil: entriesPulledUntil,
                decksPulledUntil: decksPulledUntil,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                Value<DateTime?> packsPulledUntil = const Value.absent(),
                Value<DateTime?> entriesPulledUntil = const Value.absent(),
                Value<DateTime?> decksPulledUntil = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion.insert(
                ownerId: ownerId,
                packsPulledUntil: packsPulledUntil,
                entriesPulledUntil: entriesPulledUntil,
                decksPulledUntil: decksPulledUntil,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStatesTable, SyncStateRow>(table),
                  BaseReferences<_$AppDatabase, $SyncStatesTable, SyncStateRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStatesTable,
      SyncStateRow,
      $$SyncStatesTableFilterComposer,
      $$SyncStatesTableOrderingComposer,
      $$SyncStatesTableAnnotationComposer,
      $$SyncStatesTableCreateCompanionBuilder,
      $$SyncStatesTableUpdateCompanionBuilder,
      (
        SyncStateRow,
        BaseReferences<_$AppDatabase, $SyncStatesTable, SyncStateRow>,
      ),
      SyncStateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LanguagePacksTableTableManager get languagePacks =>
      $$LanguagePacksTableTableManager(_db, _db.languagePacks);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db, _db.decks);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
}
