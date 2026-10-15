import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/fake_remote_sync_api.dart';
import '../helpers/sync_device.dart';

T _ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final error) => throw TestFailure('Expected Ok, got $error'),
};

Entry _remoteEntry(String id, String packId, String term) {
  final at = DateTime.utc(2026, 10, 15, 12);
  return Entry(
    id: id,
    ownerId: 'user-1',
    packId: packId,
    wordType: WordType.adverb,
    term: term,
    schemaVersion: 1,
    createdAt: at,
    updatedAt: at,
  );
}

void main() {
  late FakeRemoteSyncApi server;
  late SyncDevice a;
  late SyncDevice b;

  setUp(() {
    server = FakeRemoteSyncApi();
    a = SyncDevice('a', server);
    b = SyncDevice('b', server);
  });

  tearDown(() async {
    await a.close();
    await b.close();
  });

  group('two accounts on one device', () {
    test('a sync only uploads the syncing account\'s rows', () async {
      final mine = await a.repos.createPack('Mine', 'user-1');
      final theirs = await a.repos.createPack('Theirs', 'user-2');
      await a.repos.addNoun(mine, 'Haus');
      await a.repos.addNoun(theirs, 'Baum', article: 'der');

      await a.sync('user-1');

      expect(server.packs.keys, [mine.id]);
      expect([for (final r in server.entries.values) r.value.term], ['Haus']);
      expect(await a.store.hasDirty('user-2'), isTrue);

      await a.sync('user-2');
      expect(server.packs.keys, unorderedEquals([mine.id, theirs.id]));
    });

    test('a sync never downloads another account\'s rows', () async {
      final theirs = await b.repos.createPack('Theirs', 'user-2');
      await b.sync('user-2');

      await a.sync('user-1');

      expect(await a.packs('user-2'), isEmpty);
      expect(await a.entries(theirs.id), isEmpty);
    });
  });

  group('interrupted sync', () {
    test('a connection drop after the packs upload resumes cleanly', () async {
      final pack = await a.repos.createPack();
      await a.repos.addNoun(pack, 'Haus');
      server
        ..failure = http.ClientException('Connection reset')
        ..failingOperations.add('upsertEntries');

      await expectLater(a.sync(), throwsA(isA<http.ClientException>()));

      expect(server.packs, hasLength(1));
      expect(server.entries, isEmpty);
      expect(await a.store.dirtyPacks('user-1', limit: 10), isEmpty);
      expect(await a.store.dirtyEntries('user-1', limit: 10), hasLength(1));
      expect(await a.store.state('user-1'), isNull);

      server.failure = null;
      await a.sync();

      expect(server.entries, hasLength(1));
      expect(await a.store.hasDirty('user-1'), isFalse);
      expect((await a.store.state('user-1'))?.lastSyncedAt, isNotNull);
    });

    test('a failed download keeps local changes and the old cursor', () async {
      final pack = await a.repos.createPack();
      await a.repos.addNoun(pack, 'Haus');
      server
        ..failure = http.ClientException('Connection reset')
        ..failingOperations.add('fetchEntries');

      await expectLater(a.sync(), throwsA(isA<http.ClientException>()));

      // The upload went through before the download failed.
      expect(server.entries, hasLength(1));
      expect(await a.store.state('user-1'), isNull);
    });
  });

  group('download order', () {
    test('an entry that arrives before its pack is applied once the pack '
        'arrives', () async {
      final known = await a.repos.createPack('Known');
      await a.sync();
      await b.sync();

      final early = _remoteEntry('e-early', known.id, 'gern');
      final orphan = _remoteEntry('e-orphan', 'late-pack', 'oft');
      server
        ..putEntry(early, DateTime.utc(2030, 1, 2))
        ..putEntry(orphan, DateTime.utc(2030, 1, 3));

      await b.sync();
      expect([for (final e in await b.entries(known.id)) e.id], ['e-early']);
      expect(await b.entries('late-pack'), isEmpty);
      // The cursor stops before the deferred entry instead of skipping it.
      expect(
        (await b.store.state('user-1'))!.entriesPulledUntil,
        DateTime.utc(2030, 1, 2),
      );

      server.putPack(
        LanguagePack(
          id: 'late-pack',
          ownerId: 'user-1',
          name: 'Late',
          languageCode: 'de',
          createdAt: DateTime.utc(2026, 10, 15),
          updatedAt: DateTime.utc(2026, 10, 15),
        ),
        DateTime.utc(2030, 1, 4),
      );
      await b.sync();

      expect(
        [for (final e in await b.entries('late-pack')) e.id],
        ['e-orphan'],
      );
    });

    test('a write that committed late, within the overlap, is still '
        'downloaded', () async {
      final pack = await a.repos.createPack();
      await a.repos.addNoun(pack, 'Haus');
      await a.sync();
      await b.sync();
      final cursor = (await b.store.state('user-1'))!.entriesPulledUntil;
      expect(cursor, isNotNull, reason: 'b must have a download cursor');

      server.putEntry(
        _remoteEntry('e-late', pack.id, 'spät'),
        cursor!.subtract(const Duration(seconds: 30)),
      );
      await b.sync();

      expect([
        for (final e in await b.entries(pack.id)) e.term,
      ], unorderedEquals(['Haus', 'spät']));
    });
  });

  group('conflicting edits', () {
    test('devices agree after one deletes a pack while the other edits an '
        'entry in it', () async {
      final pack = await a.repos.createPack();
      final haus = await a.repos.addNoun(pack, 'Haus');
      await a.sync();
      await b.sync();

      _ok(await a.repos.packs.delete(pack.id));
      b.repos.now = a.repos.now.add(const Duration(minutes: 1));
      _ok(await b.repos.entries.update(haus.copyWith(notes: 'edited')));
      await a.sync();
      await b.sync();
      await a.sync();

      expect(await a.packs(), isEmpty);
      expect(await b.packs(), isEmpty);
      expect(await a.entries(pack.id), await b.entries(pack.id));
    });

    test(
      'a later edit on one device undoes an earlier delete on another',
      () async {
        final pack = await a.repos.createPack();
        final haus = await a.repos.addNoun(pack, 'Haus');
        await a.sync();
        await b.sync();

        _ok(await a.repos.entries.delete(haus.id));
        b.repos.now = a.repos.now.add(const Duration(minutes: 1));
        _ok(await b.repos.entries.update(haus.copyWith(notes: 'still needed')));
        await a.sync();
        await b.sync();
        await a.sync();

        for (final device in [a, b]) {
          final [entry] = await device.entries(pack.id);
          expect(entry.notes, 'still needed');
        }
      },
    );

    test('an earlier edit does not undo a later delete', () async {
      final pack = await a.repos.createPack();
      final haus = await a.repos.addNoun(pack, 'Haus');
      await a.sync();
      await b.sync();

      _ok(await b.repos.entries.update(haus.copyWith(notes: 'old edit')));
      a.repos.now = b.repos.now.add(const Duration(minutes: 1));
      _ok(await a.repos.entries.delete(haus.id));
      await a.sync();
      await b.sync();

      expect(await a.entries(pack.id), isEmpty);
      expect(await b.entries(pack.id), isEmpty);
    });
  });
}
