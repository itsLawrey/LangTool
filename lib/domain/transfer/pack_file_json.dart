import '../../utils/result.dart';
import '../exceptions.dart';
import '../languages/language_registry.dart';
import '../languages/language_schema.dart';
import '../models/deck.dart';
import '../models/entry.dart';
import '../models/word_type.dart';
import '../recap/deck_filter.dart';
import 'pack_bundle.dart';
import 'pack_file_check.dart';
import 'pack_file_format.dart';
import 'pack_file_pack.dart';

/// The JSON of a pack file holding [bundles]:
///
/// ```json
/// {"format": "langtool-packs", "version": 1, "exported_at": "<UTC>",
///  "packs": [{"name": "…", "language_code": "de", "created_at": "<UTC>",
///    "entries": [{"word_type": "noun", "term": "Haus", "forms": {…},
///      "translations": […], "examples": [{"text": "…", "translation": "…"}],
///      "tags": […], "notes": "…", "schema_version": 1, "created_at": "<UTC>"}],
///    "decks": [{"name": "…", "filters": [<DeckFilter JSON>],
///      "created_at": "<UTC>"}]}]}
/// ```
///
/// Ids, owners, pack ids, `updated_at` and `deleted_at` are left out, as
/// are empty maps and lists and `null` values. Soft-deleted entries and
/// decks are skipped.
Map<String, Object?> packFileToJson(
  List<PackBundle> bundles, {
  required DateTime exportedAt,
}) => {
  'format': packFileFormatId,
  'version': packFileVersion,
  'exported_at': _dateToJson(exportedAt),
  'packs': [for (final bundle in bundles) _packToJson(bundle)],
};

/// Reads and validates the JSON of a pack file (see [packFileToJson]).
///
/// Files of an older layout version are upgraded with [migrations] and
/// entries of an older schema version with [LanguageSchema.migrateForms].
/// Entries are cleaned like entries saved in the app. Fails with a
/// [PackFileException] if anything in the file cannot be imported (see
/// [checkPackFilePack]); [schemaFor] looks up the packs' languages.
Result<List<PackFilePack>> packFileFromJson(
  Object? json, {
  Map<int, PackFileMigration> migrations = packFileMigrations,
  LanguageSchema? Function(String code) schemaFor = languageSchemaFor,
}) {
  try {
    final upgraded = _upgrade(json, migrations);
    final packs = [
      for (final pack in _field<List<Object?>>(upgraded, 'packs'))
        _packFromJson(_asMap(pack), schemaFor),
    ];
    return Result.ok(packs);
  } on PackFileException catch (e) {
    return Result.error(e);
  }
}

const _notLangTool = PackFileException(PackFileProblem.notLangTool);
const _newerVersion = PackFileException(PackFileProblem.newerVersion);

Map<String, Object?> _packToJson(PackBundle bundle) {
  final entries = [
    for (final entry in bundle.entries)
      if (entry.deletedAt == null) _entryToJson(entry),
  ];
  final decks = [
    for (final deck in bundle.decks)
      if (deck.deletedAt == null) _deckToJson(deck),
  ];
  return {
    'name': bundle.pack.name,
    'language_code': bundle.pack.languageCode,
    'created_at': _dateToJson(bundle.pack.createdAt),
    if (entries.isNotEmpty) 'entries': entries,
    if (decks.isNotEmpty) 'decks': decks,
  };
}

Map<String, Object?> _entryToJson(Entry entry) => {
  'word_type': entry.wordType.name,
  'term': entry.term,
  if (entry.forms.isNotEmpty) 'forms': entry.forms,
  if (entry.translations.isNotEmpty) 'translations': entry.translations,
  if (entry.examples.isNotEmpty)
    'examples': [
      for (final example in entry.examples)
        {
          'text': example.text,
          if (example.translation != null) 'translation': example.translation,
        },
    ],
  if (entry.tags.isNotEmpty) 'tags': entry.tags,
  if (entry.notes != null) 'notes': entry.notes,
  'schema_version': entry.schemaVersion,
  'created_at': _dateToJson(entry.createdAt),
};

Map<String, Object?> _deckToJson(Deck deck) => {
  'name': deck.name,
  if (deck.filters.isNotEmpty)
    'filters': [for (final filter in deck.filters) filter.toJson()],
  'created_at': _dateToJson(deck.createdAt),
};

/// Checks the format and version of [json] and upgrades it to
/// [packFileVersion].
Map<String, Object?> _upgrade(
  Object? json,
  Map<int, PackFileMigration> migrations,
) {
  var map = _asMap(json);
  if (map['format'] != packFileFormatId) throw _notLangTool;
  final version = _field<int>(map, 'version');
  if (version > packFileVersion) throw _newerVersion;

  for (var from = version; from < packFileVersion; from++) {
    final step = migrations[from];
    if (step == null) throw _notLangTool;
    try {
      map = step(map);
    } catch (_) {
      throw _notLangTool;
    }
  }
  return map;
}

PackFilePack _packFromJson(
  Map<String, Object?> json,
  LanguageSchema? Function(String code) schemaFor,
) {
  final languageCode = _field<String>(json, 'language_code');
  final schema = schemaFor(languageCode);
  if (schema == null) {
    throw PackFileException(
      PackFileProblem.unsupportedLanguage,
      languageCode: languageCode,
    );
  }

  final pack = PackFilePack(
    name: _field<String>(json, 'name').trim(),
    languageCode: languageCode,
    createdAt: _date(json, 'created_at'),
    entries: [
      for (final entry in _list(json, 'entries'))
        _entryFromJson(_asMap(entry), schema),
    ],
    decks: [
      for (final deck in _list(json, 'decks')) _deckFromJson(_asMap(deck)),
    ],
  );
  if (checkPackFilePack(pack, schemaFor: schemaFor) case final problem?) {
    throw problem;
  }
  return pack;
}

PackFileEntry _entryFromJson(Map<String, Object?> json, LanguageSchema schema) {
  final wordType =
      WordType.values.asNameMap()[_field<String>(json, 'word_type')] ??
      (throw _newerVersion);
  final schemaVersion = _field<int>(json, 'schema_version');
  if (schemaVersion > schema.version) throw _newerVersion;

  final forms = {
    for (final MapEntry(:key, :value) in _map(json, 'forms').entries)
      key: _asString(value),
  };
  return PackFileEntry(
    wordType: wordType,
    term: _field<String>(json, 'term'),
    forms: schemaVersion < schema.version
        ? schema.migrateForms(forms, wordType, schemaVersion)
        : forms,
    translations: _strings(json, 'translations'),
    examples: [
      for (final example in _list(json, 'examples'))
        _exampleFromJson(_asMap(example)),
    ],
    tags: _strings(json, 'tags'),
    notes: _field<String?>(json, 'notes'),
    createdAt: _date(json, 'created_at'),
  ).cleaned();
}

Example _exampleFromJson(Map<String, Object?> json) => Example(
  text: _field<String>(json, 'text'),
  translation: _field<String?>(json, 'translation'),
);

PackFileDeck _deckFromJson(Map<String, Object?> json) => PackFileDeck(
  name: _field<String>(json, 'name').trim(),
  filters: [
    for (final filter in _list(json, 'filters')) _filterFromJson(filter),
  ],
  createdAt: _date(json, 'created_at'),
);

/// Unknown filter types are kept as [DeckFilter.unknown], like in sync.
DeckFilter _filterFromJson(Object? json) {
  final map = _asMap(json);
  try {
    return DeckFilter.fromJson(map);
  } catch (_) {
    throw _notLangTool;
  }
}

extension on PackFileEntry {
  PackFileEntry cleaned() => PackFileEntry.fromEntry(
    toEntry(
      id: '',
      ownerId: '',
      packId: '',
      schemaVersion: 0,
      updatedAt: createdAt,
    ),
  );
}

T _field<T>(Map<String, Object?> json, String key) => switch (json[key]) {
  final T value => value,
  _ => throw _notLangTool,
};

Map<String, Object?> _asMap(Object? json) => switch (json) {
  final Map<String, Object?> map => map,
  _ => throw _notLangTool,
};

String _asString(Object? json) => switch (json) {
  final String text => text,
  _ => throw _notLangTool,
};

/// A list that may be left out when empty.
List<Object?> _list(Map<String, Object?> json, String key) =>
    _field<List<Object?>?>(json, key) ?? const [];

/// A map that may be left out when empty.
Map<String, Object?> _map(Map<String, Object?> json, String key) =>
    _field<Map<String, Object?>?>(json, key) ?? const {};

List<String> _strings(Map<String, Object?> json, String key) => [
  for (final item in _list(json, key)) _asString(item),
];

DateTime _date(Map<String, Object?> json, String key) =>
    DateTime.tryParse(_field<String>(json, key))?.toUtc() ??
    (throw _notLangTool);

String _dateToJson(DateTime date) => date.toUtc().toIso8601String();
