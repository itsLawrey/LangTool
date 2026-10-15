import 'package:drift/drift.dart';

import '../../domain/models/entry.dart';
import '../../domain/models/language_pack.dart';
import '../../domain/search/text_normalizer.dart';
import 'app_database.dart';

/// Separator between normalized translations in `search_translations`.
/// Normalization collapses whitespace, so it never occurs inside one.
const translationSeparator = '\n';

extension LanguagePackRowMapping on LanguagePackRow {
  LanguagePack toDomain() => LanguagePack(
    id: id,
    ownerId: ownerId,
    name: name,
    languageCode: languageCode,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}

extension LanguagePackMapping on LanguagePack {
  LanguagePacksCompanion toCompanion() => LanguagePacksCompanion.insert(
    id: id,
    ownerId: ownerId,
    name: name,
    languageCode: languageCode,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: Value(deletedAt),
  );
}

extension EntryRowMapping on EntryRow {
  Entry toDomain() => Entry(
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
  );
}

extension EntryMapping on Entry {
  /// Includes the derived search and duplicate-detection columns.
  EntriesCompanion toCompanion() => EntriesCompanion.insert(
    id: id,
    ownerId: ownerId,
    packId: packId,
    wordType: wordType,
    term: term,
    forms: forms,
    translations: translations,
    examples: examples,
    tags: tags,
    notes: Value(notes),
    schemaVersion: schemaVersion,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: Value(deletedAt),
    searchTerm: normalizeForSearch(term),
    searchTranslations: translations
        .map(normalizeForSearch)
        .join(translationSeparator),
    duplicateKey: duplicateKey(term),
  );
}
