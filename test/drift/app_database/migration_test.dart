// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:langtool/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

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
}
