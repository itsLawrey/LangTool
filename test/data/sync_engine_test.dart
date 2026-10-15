import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/exceptions.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/fake_remote_sync_api.dart';
import '../helpers/sync_device.dart';

const _owner = 'user-1';

T _ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final error) => throw TestFailure('Expected Ok, got $error'),
};

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

  test('uploads local data and downloads it on another device', () async {
    final pack = await a.repos.createPack();
    await a.repos.addNoun(pack, 'Haus', translations: ['house']);

    await a.sync();
    expect(await a.store.hasDirty(_owner), isFalse);

    await b.sync();
    expect([for (final p in await b.packs()) p.name], ['Deutsch']);
    final [haus] = await b.entries(pack.id);
    expect(haus.term, 'Haus');
    expect(haus.translations, ['house']);
    expect(await b.store.hasDirty(_owner), isFalse);
  });

  test('the newer edit wins on every device', () async {
    final pack = await a.repos.createPack();
    final haus = await a.repos.addNoun(pack, 'Haus');
    await a.sync();
    await b.sync();

    // A edits first (earlier clock), B edits later; A syncs last.
    b.repos.now = a.repos.now.add(const Duration(hours: 1));
    _ok(await b.repos.entries.update(haus.copyWith(translations: ['home'])));
    _ok(await a.repos.entries.update(haus.copyWith(translations: ['house'])));
    await b.sync();
    await a.sync();
    await b.sync();

    expect((await a.entries(pack.id)).single.translations, ['home']);
    expect((await b.entries(pack.id)).single.translations, ['home']);
  });

  test('deletions reach other devices', () async {
    final pack = await a.repos.createPack();
    final haus = await a.repos.addNoun(pack, 'Haus');
    await a.sync();
    await b.sync();

    _ok(await a.repos.entries.delete(haus.id));
    await a.sync();
    await b.sync();

    expect(
      await b.repos.entries.getEntry(haus.id),
      isA<Err<Entry>>().having(
        (e) => e.error,
        'error',
        isA<NotFoundException>(),
      ),
    );
  });

  test('pack deletion hides its entries on other devices', () async {
    final pack = await a.repos.createPack();
    await a.repos.addNoun(pack, 'Haus');
    await a.sync();
    await b.sync();

    _ok(await a.repos.packs.delete(pack.id));
    await a.sync();
    await b.sync();

    expect(await b.packs(), isEmpty);
    expect(await b.entries(pack.id), isEmpty);
  });

  for (final firstToSync in ['older', 'newer']) {
    test('same word added on two devices keeps the older '
        '($firstToSync device syncs first)', () async {
      final pack = await a.repos.createPack();
      await a.sync();
      await b.sync();

      final older = await a.repos.addNoun(pack, 'Haus', translations: ['a']);
      b.repos.now = a.repos.now.add(const Duration(minutes: 5));
      await b.repos.addNoun(pack, 'haus', translations: ['b']);

      final (first, second) = firstToSync == 'older' ? (a, b) : (b, a);
      await first.sync();
      await second.sync();
      await first.sync();
      await second.sync();

      for (final device in [a, b]) {
        final active = await device.entries(pack.id);
        expect([for (final e in active) e.id], [older.id]);
        expect(await device.store.hasDirty(_owner), isFalse);
      }
      final serverActive = server.entries.values.where(
        (r) => r.value.deletedAt == null,
      );
      expect([for (final r in serverActive) r.value.id], [older.id]);
    });
  }

  test('pages through large change sets', () async {
    final small = SyncDevice('c', server, pageSize: 2);
    final pack = await a.repos.createPack();
    for (var i = 0; i < 5; i++) {
      await a.repos.addNoun(pack, 'Wort$i');
    }
    await a.sync();

    await small.sync();

    expect(await small.entries(pack.id), hasLength(5));
    await small.close();
  });

  test('later syncs pick up further changes', () async {
    final pack = await a.repos.createPack();
    await a.repos.addNoun(pack, 'Haus');
    await a.sync();
    await b.sync();

    await a.repos.addNoun(pack, 'Baum', article: 'der');
    await a.sync();
    await b.sync();

    expect(
      [for (final e in await b.entries(pack.id)) e.term],
      ['Baum', 'Haus'],
    );
  });

  test('keeps rows edited during an upload marked for the next one', () async {
    final pack = await a.repos.createPack();
    final haus = await a.repos.addNoun(pack, 'Haus');
    final stale = (await a.store.dirtyEntries(_owner, limit: 10)).single;
    _ok(await a.repos.entries.update(haus.copyWith(notes: 'edited')));

    await a.store.markEntriesPushed([stale]);

    expect(await a.store.dirtyEntries(_owner, limit: 10), hasLength(1));
  });

  test('defers entries whose pack has not been downloaded yet', () async {
    final now = DateTime.utc(2026, 10, 15);
    final orphan = Entry(
      id: 'remote-entry',
      ownerId: _owner,
      packId: 'unknown-pack',
      wordType: WordType.adverb,
      term: 'gern',
      schemaVersion: 1,
      createdAt: now,
      updatedAt: now,
    );

    expect(await b.store.applyRemoteEntries([orphan]), 0);
  });
}
