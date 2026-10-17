import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/exceptions.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/fake_remote_sync_api.dart';
import '../helpers/sync_device.dart';

const _owner = 'user-1';

T _ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final error) => throw TestFailure('Expected Ok, got $error'),
};

final _filters = [
  DeckFilter.addedBetween(from: DateTime(2026, 10, 1)),
  const DeckFilter.wordTypes({WordType.noun}),
  const DeckFilter.unknown({'type': 'tagged', 'tag': 'A1'}),
];

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

  test('a deck created on one device appears on another', () async {
    final pack = await a.repos.createPack();
    final deck = await a.repos.createDeck(pack, 'Nouns', _filters);
    expect(await a.store.hasDirty(_owner), isTrue);

    await a.sync();
    expect(await a.store.hasDirty(_owner), isFalse);
    expect(server.decks.keys, [deck.id]);

    await b.sync();
    expect(await b.decks(pack.id), [deck]);
    expect(await b.store.hasDirty(_owner), isFalse);
    expect(
      (await b.store.state(_owner))!.decksPulledUntil,
      server.decks[deck.id]!.serverUpdatedAt,
    );
  });

  test('deck edits reach other devices, the newer edit winning', () async {
    final pack = await a.repos.createPack();
    final deck = await a.repos.createDeck(pack, 'Nouns');
    await a.sync();
    await b.sync();

    b.repos.now = a.repos.now.add(const Duration(hours: 1));
    _ok(
      await b.repos.decks.update(deck.copyWith(name: 'B', filters: _filters)),
    );
    _ok(await a.repos.decks.update(deck.copyWith(name: 'A')));
    await b.sync();
    await a.sync();
    await b.sync();

    for (final device in [a, b]) {
      final [synced] = await device.decks(pack.id);
      expect(synced.name, 'B');
      expect(synced.filters, _filters);
    }
  });

  test('deck deletions reach other devices', () async {
    final pack = await a.repos.createPack();
    final deck = await a.repos.createDeck(pack, 'Nouns');
    await a.sync();
    await b.sync();

    _ok(await a.repos.decks.delete(deck.id));
    await a.sync();
    await b.sync();

    expect(await b.decks(pack.id), isEmpty);
    expect(
      await b.repos.decks.getDeck(deck.id),
      isA<Err<Deck>>().having(
        (e) => e.error,
        'error',
        isA<NotFoundException>(),
      ),
    );
  });

  test('pack deletion removes its decks on other devices', () async {
    final pack = await a.repos.createPack();
    await a.repos.createDeck(pack, 'Nouns');
    await a.sync();
    await b.sync();

    _ok(await a.repos.packs.delete(pack.id));
    await a.sync();
    await b.sync();

    expect(await b.packs(), isEmpty);
    expect(await b.decks(pack.id), isEmpty);
    expect(server.decks.values.single.value.deletedAt, isNotNull);
  });

  test('later syncs pick up further decks', () async {
    final pack = await a.repos.createPack();
    await a.repos.createDeck(pack, 'First');
    await a.sync();
    await b.sync();

    await a.repos.createDeck(pack, 'Second');
    await a.sync();
    await b.sync();

    expect(
      [for (final d in await b.decks(pack.id)) d.name],
      ['First', 'Second'],
    );
  });

  test('pages through many decks', () async {
    final small = SyncDevice('c', server, pageSize: 2);
    final pack = await a.repos.createPack();
    for (var i = 0; i < 5; i++) {
      await a.repos.createDeck(pack, 'Deck $i');
    }
    await a.sync();

    await small.sync();

    expect(await small.decks(pack.id), hasLength(5));
    await small.close();
  });

  test('keeps decks edited during an upload marked for the next one', () async {
    final pack = await a.repos.createPack();
    final deck = await a.repos.createDeck(pack, 'Nouns');
    final stale = (await a.store.dirtyDecks(_owner, limit: 10)).single;
    _ok(await a.repos.decks.update(deck.copyWith(name: 'Edited')));

    await a.store.markDecksPushed([stale]);

    expect(await a.store.dirtyDecks(_owner, limit: 10), hasLength(1));
  });

  test('a failed deck upload is retried on the next sync', () async {
    final pack = await a.repos.createPack();
    final deck = await a.repos.createDeck(pack, 'Nouns');
    server
      ..failure = Exception('upload failed')
      ..failingOperations.add('upsertDecks');

    await expectLater(a.sync(), throwsException);
    expect(server.packs.keys, [pack.id]);
    expect(server.decks, isEmpty);
    expect(await a.store.hasDirty(_owner), isTrue);

    server.failure = null;
    await a.sync();
    expect(server.decks.keys, [deck.id]);
    expect(await a.store.hasDirty(_owner), isFalse);
  });

  group('a deck whose pack is unknown locally', () {
    final at = DateTime.utc(2026, 10, 15, 12);
    final pack = LanguagePack(
      id: 'remote-pack',
      ownerId: _owner,
      name: 'Deutsch',
      languageCode: 'de',
      createdAt: at,
      updatedAt: at,
    );
    final deck = Deck(
      id: 'remote-deck',
      ownerId: _owner,
      packId: pack.id,
      name: 'Nouns',
      createdAt: at,
      updatedAt: at,
    );

    test('is not applied', () async {
      expect(await b.store.applyRemoteDecks([deck]), 0);
      expect(await b.decks(pack.id), isEmpty);
    });

    test('is applied once its pack has arrived', () async {
      server.putDeck(deck, DateTime.utc(2030));
      await b.sync();
      expect(await b.decks(pack.id), isEmpty);

      server.putPack(pack, DateTime.utc(2030, 1, 2));
      await b.sync();
      expect(await b.decks(pack.id), [deck]);
    });
  });
}
