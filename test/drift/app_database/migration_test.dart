// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:langtool/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('migration from v1 to v2 keeps data and marks it for upload', () async {
    const pack = v1.LanguagePacksData(
      id: 'pack-1',
      ownerId: 'user-1',
      name: 'Deutsch',
      languageCode: 'de',
      createdAt: '2026-10-15T12:00:00.000Z',
      updatedAt: '2026-10-15T12:00:00.000Z',
    );
    const entry = v1.EntriesData(
      id: 'entry-1',
      ownerId: 'user-1',
      packId: 'pack-1',
      wordType: 'noun',
      term: 'Haus',
      forms: '{"article":"das"}',
      translations: '["house"]',
      examples: '[]',
      tags: '[]',
      schemaVersion: 1,
      createdAt: '2026-10-15T12:00:00.000Z',
      updatedAt: '2026-10-15T12:00:00.000Z',
      searchTerm: 'haus',
      searchTranslations: 'house',
      duplicateKey: 'haus',
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(oldDb.languagePacks, pack);
        batch.insert(oldDb.entries, entry);
      },
      validateItems: (newDb) async {
        final [newPack] = await newDb.select(newDb.languagePacks).get();
        expect(newPack.name, 'Deutsch');
        expect(newPack.needsPush, 1); // SQLite boolean

        final [newEntry] = await newDb.select(newDb.entries).get();
        expect(newEntry.term, 'Haus');
        expect(newEntry.forms, '{"article":"das"}');
        expect(newEntry.needsPush, 1);

        expect(await newDb.select(newDb.syncStates).get(), isEmpty);
      },
    );
  });

  test('migration from v2 to v3 keeps data and adds empty decks', () async {
    const pack = v2.LanguagePacksData(
      id: 'pack-1',
      ownerId: 'user-1',
      name: 'Deutsch',
      languageCode: 'de',
      createdAt: '2026-10-15T12:00:00.000Z',
      updatedAt: '2026-10-15T12:00:00.000Z',
      needsPush: 0,
    );
    const entry = v2.EntriesData(
      id: 'entry-1',
      ownerId: 'user-1',
      packId: 'pack-1',
      wordType: 'noun',
      term: 'Haus',
      forms: '{"article":"das"}',
      translations: '["house"]',
      examples: '[]',
      tags: '[]',
      schemaVersion: 1,
      createdAt: '2026-10-15T12:00:00.000Z',
      updatedAt: '2026-10-15T12:00:00.000Z',
      searchTerm: 'haus',
      searchTranslations: 'house',
      duplicateKey: 'haus',
      needsPush: 1,
    );
    const state = v2.SyncStatesData(
      ownerId: 'user-1',
      packsPulledUntil: '2030-01-01T00:00:00.000Z',
      entriesPulledUntil: '2030-01-01T00:00:01.000Z',
      lastSyncedAt: '2026-10-15T12:00:00.000Z',
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(oldDb.languagePacks, pack);
        batch.insert(oldDb.entries, entry);
        batch.insert(oldDb.syncStates, state);
      },
      validateItems: (newDb) async {
        final [newPack] = await newDb.select(newDb.languagePacks).get();
        expect(newPack.name, 'Deutsch');
        expect(newPack.needsPush, 0); // SQLite boolean

        final [newEntry] = await newDb.select(newDb.entries).get();
        expect(newEntry.term, 'Haus');
        expect(newEntry.needsPush, 1);

        final [newState] = await newDb.select(newDb.syncStates).get();
        expect(newState.packsPulledUntil, state.packsPulledUntil);
        expect(newState.entriesPulledUntil, state.entriesPulledUntil);
        expect(newState.decksPulledUntil, null);

        // The new table is empty and accepts decks of existing packs.
        expect(await newDb.select(newDb.decks).get(), isEmpty);
        await newDb
            .into(newDb.decks)
            .insert(
              const v3.DecksData(
                id: 'deck-1',
                ownerId: 'user-1',
                packId: 'pack-1',
                name: 'Nouns',
                filters: '[]',
                createdAt: '2026-10-15T12:00:00.000Z',
                updatedAt: '2026-10-15T12:00:00.000Z',
                needsPush: 1,
              ),
            );
        expect(await newDb.select(newDb.decks).get(), hasLength(1));
      },
    );
  });

  test('migration from v3 to v4 recomputes the search columns', () async {
    const pack = v3.LanguagePacksData(
      id: 'pack-1',
      ownerId: 'user-1',
      name: 'Deutsch',
      languageCode: 'de',
      createdAt: '2026-10-15T12:00:00.000Z',
      updatedAt: '2026-10-15T12:00:00.000Z',
      needsPush: 0,
    );
    // Search columns as v3 wrote them, with the separators kept.
    const entry = v3.EntriesData(
      id: 'entry-1',
      ownerId: 'user-1',
      packId: 'pack-1',
      wordType: 'verb',
      term: 'sich gut an|hören',
      forms: '{}',
      translations: '["to sound good","well-known"]',
      examples: '[]',
      tags: '[]',
      schemaVersion: 1,
      createdAt: '2026-10-15T12:00:00.000Z',
      updatedAt: '2026-10-15T12:00:00.000Z',
      searchTerm: 'sich gut an|horen',
      searchTranslations: 'to sound good\nwell-known',
      duplicateKey: 'sich gut an|hören',
      needsPush: 0,
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(oldDb.languagePacks, pack);
        batch.insert(oldDb.entries, entry);
      },
      validateItems: (newDb) async {
        final [newEntry] = await newDb.select(newDb.entries).get();
        expect(newEntry.term, 'sich gut an|hören');
        expect(newEntry.searchTerm, 'sich gut anhoren');
        expect(newEntry.searchTranslations, 'to sound good\nwellknown');
        // The duplicate rule and the sync state don't change.
        expect(newEntry.duplicateKey, 'sich gut an|hören');
        expect(newEntry.needsPush, 0);
      },
    );
  });
}
