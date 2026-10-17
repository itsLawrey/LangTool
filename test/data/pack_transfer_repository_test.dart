import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/data/repositories/pack_transfer_repository.dart';
import 'package:langtool/domain/exceptions.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/entry_draft.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/domain/transfer/pack_file_pack.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/fake_remote_sync_api.dart';
import '../helpers/sync_device.dart';
import '../helpers/test_repositories.dart';

T _ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final error) => throw TestFailure('Expected Ok, got $error'),
};

Exception _err<T>(Result<T> result) => switch (result) {
  Ok(:final value) => throw TestFailure('Expected Err, got $value'),
  Err(:final error) => error,
};

final _filters = [
  DeckFilter.addedBetween(from: DateTime(2026, 10, 1)),
  const DeckFilter.wordTypes({WordType.noun}),
  const DeckFilter.unknown({'type': 'tagged', 'tag': 'A1'}),
];

void main() {
  late TestRepositories repos;

  setUp(() => repos = TestRepositories());
  tearDown(() => repos.close());

  /// The ids of every pack, entry and deck row.
  Future<List<String>> rowIds() async {
    final db = repos.db;
    return [
      for (final row in await db.select(db.languagePacks).get()) row.id,
      for (final row in await db.select(db.entries).get()) row.id,
      for (final row in await db.select(db.decks).get()) row.id,
    ];
  }

  Future<List<PackFilePack>> exportAndDecode(List<String> packIds) async =>
      _ok(repos.transfer.decode(await repos.transfer.export(packIds)));

  /// A pack with a fully filled entry, a plain one and a deck.
  Future<LanguagePack> createFilledPack([String name = 'Deutsch']) async {
    final pack = await repos.createPack(name);
    _ok(
      await repos.entries.add(
        EntryDraft(
          packId: pack.id,
          wordType: WordType.noun,
          term: 'Haus',
          forms: {'article': 'das', 'plural': 'Häuser'},
          translations: ['house'],
          examples: [const Example(text: 'Ein Haus.', translation: 'A house.')],
          tags: ['A1'],
          notes: 'Neuter.',
        ),
      ),
    );
    await repos.addNoun(pack, 'Baum', article: 'der');
    await repos.createDeck(pack, 'Nouns', _filters);
    return pack;
  }

  group('export', () {
    test('holds the active entries and decks, oldest first', () async {
      final pack = await repos.createPack();
      final haus = await repos.addNoun(pack, 'Haus');
      final baum = await repos.addNoun(pack, 'Baum', article: 'der');
      final tisch = await repos.addNoun(pack, 'Tisch', article: 'der');
      _ok(await repos.entries.delete(baum.id));
      final kept = await repos.createDeck(pack, 'Kept', _filters);
      final gone = await repos.createDeck(pack, 'Gone');
      _ok(await repos.decks.delete(gone.id));

      final [exported] = await exportAndDecode([pack.id]);
      expect(exported.name, 'Deutsch');
      expect(exported.languageCode, 'de');
      expect(exported.createdAt, pack.createdAt);
      expect(exported.entries, [
        PackFileEntry.fromEntry(haus),
        PackFileEntry.fromEntry(tisch),
      ]);
      expect(exported.decks, [
        PackFileDeck(
          name: 'Kept',
          filters: _filters,
          createdAt: kept.createdAt,
        ),
      ]);
    });

    test(
      'keeps the given pack order and skips deleted or missing packs',
      () async {
        final a = await repos.createPack('A');
        final b = await repos.createPack('B');
        final deleted = await repos.createPack('Deleted');
        _ok(await repos.packs.delete(deleted.id));

        final packs = await exportAndDecode([
          b.id,
          deleted.id,
          'missing',
          a.id,
        ]);
        expect([for (final p in packs) p.name], ['B', 'A']);
      },
    );
  });

  group('import', () {
    test(
      'creates new packs owned by the user, keeping creation times',
      () async {
        final original = await createFilledPack();
        final file = await exportAndDecode([original.id]);
        final originalEntries = await repos.entries
            .watchEntries(original.id)
            .first;
        final [originalDeck] = await repos.decks.watchDecks(original.id).first;

        final [imported] = _ok(
          await repos.transfer.import(file, ownerId: 'user-2'),
        );
        final importedAt = repos.now;

        expect(imported.id, isNot(original.id));
        expect(imported.ownerId, 'user-2');
        expect(imported.name, 'Deutsch');
        expect(imported.createdAt, original.createdAt);
        expect(imported.updatedAt, importedAt);
        expect(_ok(await repos.packs.getPack(imported.id)), imported);

        final entries = await repos.entries.watchEntries(imported.id).first;
        expect(entries, hasLength(2));
        for (final (i, entry) in entries.indexed) {
          final source = originalEntries[i];
          expect(entry.id, isNot(source.id));
          expect(
            entry,
            source.copyWith(
              id: entry.id,
              ownerId: 'user-2',
              packId: imported.id,
              updatedAt: importedAt,
            ),
          );
        }

        final [deck] = await repos.decks.watchDecks(imported.id).first;
        expect(
          deck,
          originalDeck.copyWith(
            id: deck.id,
            ownerId: 'user-2',
            packId: imported.id,
            updatedAt: importedAt,
          ),
        );
        expect(deck.id, isNot(originalDeck.id));
      },
    );

    test('marks the imported rows for upload', () async {
      final original = await createFilledPack();
      final file = await exportAndDecode([original.id]);
      final db = repos.db;
      // Rows synced earlier are clean; only the imported ones need a push.
      await db.customStatement('UPDATE language_packs SET needs_push = 0');
      await db.customStatement('UPDATE entries SET needs_push = 0');
      await db.customStatement('UPDATE decks SET needs_push = 0');

      final [imported] = _ok(
        await repos.transfer.import(file, ownerId: 'user-1'),
      );

      final pack = await (db.select(
        db.languagePacks,
      )..where((p) => p.needsPush.equals(true))).get();
      final entries = await (db.select(
        db.entries,
      )..where((e) => e.needsPush.equals(true))).get();
      final decks = await (db.select(
        db.decks,
      )..where((d) => d.needsPush.equals(true))).get();
      expect([for (final row in pack) row.id], [imported.id]);
      expect({for (final row in entries) row.packId}, {imported.id});
      expect(entries, hasLength(2));
      expect([for (final row in decks) row.packId], [imported.id]);
    });

    test('imported entries are searchable and count as duplicates', () async {
      final original = await createFilledPack();
      final file = await exportAndDecode([original.id]);
      final [imported] = _ok(
        await repos.transfer.import(file, ownerId: 'user-1'),
      );

      final [hit] = await repos.entries.search(imported.id, 'house');
      expect(hit.entry.term, 'Haus');
      expect(hit.entry.packId, imported.id);

      final result = await repos.entries.add(
        EntryDraft(
          packId: imported.id,
          wordType: WordType.noun,
          term: 'haus',
          forms: {'article': 'das'},
        ),
      );
      expect(_err(result), isA<DuplicateEntryException>());
    });

    test('importing the same file twice gives two packs', () async {
      final original = await createFilledPack();
      final file = await exportAndDecode([original.id]);

      final [first] = _ok(await repos.transfer.import(file, ownerId: 'user-2'));
      final [second] = _ok(
        await repos.transfer.import(file, ownerId: 'user-2'),
      );

      expect(first.id, isNot(second.id));
      final packs = await repos.packs.watchPacks('user-2').first;
      expect([for (final p in packs) p.name], ['Deutsch', 'Deutsch']);
      for (final pack in packs) {
        expect(await repos.entries.watchEntries(pack.id).first, hasLength(2));
      }
    });

    test('imports several packs at once', () async {
      final a = await createFilledPack('A');
      final b = await repos.createPack('B');
      final file = await exportAndDecode([a.id, b.id]);

      final imported = _ok(
        await repos.transfer.import(file, ownerId: 'user-2'),
      );
      expect([for (final p in imported) p.name], ['A', 'B']);
    });

    test('rejects a pack that cannot be imported, writing nothing', () async {
      final createdAt = DateTime.utc(2026, 9, 1);
      PackFileEntry noun(String term) => PackFileEntry(
        wordType: WordType.noun,
        term: term,
        forms: {'article': 'das'},
        createdAt: createdAt,
      );
      final valid = PackFilePack(
        name: 'Valid',
        languageCode: 'de',
        createdAt: createdAt,
        entries: [noun('Haus')],
      );
      final duplicate = valid.copyWith(
        name: 'Duplicate',
        entries: [noun('Haus'), noun(' haus')],
      );

      final error = _err(
        await repos.transfer.import([valid, duplicate], ownerId: 'user-1'),
      );
      expect(error, isA<PackFileException>());
      expect(
        (error as PackFileException).reason,
        PackFileProblem.duplicateEntry,
      );
      expect(error.term, 'haus');

      final unsupported = valid.copyWith(languageCode: 'xx');
      expect(
        (_err(
          await repos.transfer.import([unsupported], ownerId: 'user-1'),
        ) as PackFileException).reason,
        PackFileProblem.unsupportedLanguage,
      );

      expect(await repos.db.select(repos.db.languagePacks).get(), isEmpty);
      expect(await repos.db.select(repos.db.entries).get(), isEmpty);
    });

    test('a failure part way rolls back every pack', () async {
      final original = await createFilledPack();
      final file = await exportAndDecode([original.id]);
      final rowsBefore = await rowIds();

      // The second pack gets an id that is already taken, so its insert
      // fails after the first pack and its entries were written.
      var calls = 0;
      final transfer = LocalPackTransferRepository(
        repos.db,
        clock: repos.clock,
        newId: () => ++calls == 5 ? original.id : 'new-$calls',
      );
      final result = await transfer.import([
        ...file,
        ...file,
      ], ownerId: 'user-1');

      expect(result, isA<Err<List<LanguagePack>>>());
      expect(await rowIds(), rowsBefore);
    });

    test('imported packs sync to other devices', () async {
      final server = FakeRemoteSyncApi();
      final a = SyncDevice('a', server);
      final b = SyncDevice('b', server);
      addTearDown(a.close);
      addTearDown(b.close);

      final original = await a.repos.createPack();
      await a.repos.addNoun(original, 'Haus');
      await a.repos.createDeck(original, 'All', _filters);
      await a.sync();
      final file = _ok(
        a.repos.transfer.decode(await a.repos.transfer.export([original.id])),
      );

      final [imported] = _ok(
        await a.repos.transfer.import(file, ownerId: 'user-1'),
      );
      expect(await a.store.hasDirty('user-1'), isTrue);
      await a.sync();
      expect(await a.store.hasDirty('user-1'), isFalse);
      expect(server.packs.keys, contains(imported.id));

      await b.sync();
      expect(await b.packs(), hasLength(2));
      final [entry] = await b.entries(imported.id);
      expect(entry.term, 'Haus');
      final [deck] = await b.decks(imported.id);
      expect(deck.filters, _filters);
    });
  });
}
