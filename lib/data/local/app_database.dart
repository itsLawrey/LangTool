import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/models/deck.dart';
import '../../domain/models/entry.dart';
import '../../domain/models/word_type.dart';
import '../../domain/recap/deck_filter.dart';
import 'app_database.steps.dart';
import 'converters.dart';
import 'search_columns.dart';

part 'app_database.g.dart';

@DataClassName('LanguagePackRow')
@TableIndex(name: 'language_packs_owner_id', columns: {#ownerId})
class LanguagePacks extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text()();
  TextColumn get languageCode => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Whether this row has local changes not yet uploaded. Rows written by
  /// the app are dirty; rows applied from the server are clean.
  BoolColumn get needsPush => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Besides the [Entry] fields, rows carry derived columns kept in sync on
/// every write: [searchTerm] and [searchTranslations] (normalized for search)
/// and [duplicateKey], which a partial unique index uses to forbid two active
/// entries with the same term and word type in a pack.
///
/// `entries_pack_created` serves the timeline and lookups by pack alone.
@DataClassName('EntryRow')
@TableIndex(name: 'entries_pack_created', columns: {#packId, #createdAt})
@TableIndex.sql(
  'CREATE UNIQUE INDEX entries_unique_term '
  'ON entries (pack_id, word_type, duplicate_key) '
  'WHERE deleted_at IS NULL',
)
class Entries extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get packId => text().references(LanguagePacks, #id)();
  TextColumn get wordType => textEnum<WordType>()();
  TextColumn get term => text()();
  TextColumn get forms => text().map(const StringMapConverter())();
  TextColumn get translations => text().map(const StringListConverter())();
  TextColumn get examples => text().map(const ExampleListConverter())();
  TextColumn get tags => text().map(const StringListConverter())();
  TextColumn get notes => text().nullable()();
  IntColumn get schemaVersion => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  TextColumn get searchTerm => text()();

  /// Normalized translations joined by `\n`.
  TextColumn get searchTranslations => text()();
  TextColumn get duplicateKey => text()();

  /// Whether this row has local changes not yet uploaded. Rows written by
  /// the app are dirty; rows applied from the server are clean.
  BoolColumn get needsPush => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Rows mirror [Deck]. [filters] is the JSON array of [DeckFilter]s; the
/// entries a deck selects are resolved from it at query time.
@DataClassName('DeckRow')
@TableIndex(name: 'decks_pack_id', columns: {#packId})
@TableIndex(name: 'decks_owner_id', columns: {#ownerId})
class Decks extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get packId => text().references(LanguagePacks, #id)();
  TextColumn get name => text()();
  TextColumn get filters => text().map(const DeckFilterListConverter())();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Whether this row has local changes not yet uploaded. Rows written by
  /// the app are dirty; rows applied from the server are clean.
  BoolColumn get needsPush => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Per-account sync progress.
@DataClassName('SyncStateRow')
class SyncStates extends Table {
  TextColumn get ownerId => text()();

  /// Server time up to which pack changes have been pulled.
  DateTimeColumn get packsPulledUntil => dateTime().nullable()();

  /// Server time up to which entry changes have been pulled.
  DateTimeColumn get entriesPulledUntil => dateTime().nullable()();

  /// Server time up to which deck changes have been pulled.
  DateTimeColumn get decksPulledUntil => dateTime().nullable()();

  /// When the last sync finished successfully.
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId};
}

@DriftDatabase(tables: [LanguagePacks, Entries, Decks, SyncStates])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: stepByStep(
      // Sync: existing rows were never uploaded, so they start dirty
      // (the column default).
      from1To2: (m, schema) async {
        await m.addColumn(schema.languagePacks, schema.languagePacks.needsPush);
        await m.addColumn(schema.entries, schema.entries.needsPush);
        await m.createTable(schema.syncStates);
      },
      // Recap decks. Their pull cursor starts empty, so the next sync
      // downloads every deck.
      from2To3: (m, schema) async {
        await m.createTable(schema.decks);
        await m.createIndex(schema.decksPackId);
        await m.createIndex(schema.decksOwnerId);
        await m.addColumn(
          schema.syncStates,
          schema.syncStates.decksPulledUntil,
        );
      },
      // Search ignores separators such as `|` since v4: recompute the
      // derived search columns. They exist only locally, so nothing is
      // marked for upload.
      from3To4: (m, schema) async {
        final rows = await customSelect(
          'SELECT id, term, translations FROM entries',
        ).get();
        for (final row in rows) {
          final translations = (jsonDecode(
            row.read<String>('translations'),
          ) as List<Object?>).cast<String>();
          await customStatement(
            'UPDATE entries SET search_term = ?, search_translations = ? '
            'WHERE id = ?',
            [
              searchTermColumn(row.read<String>('term')),
              searchTranslationsColumn(translations),
              row.read<String>('id'),
            ],
          );
        }
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
