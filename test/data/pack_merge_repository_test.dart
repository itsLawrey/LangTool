import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/data/local/app_database.dart';
import 'package:langtool/data/repositories/pack_merge_repository.dart';
import 'package:langtool/domain/exceptions.dart';
import 'package:langtool/domain/merge/entry_merge.dart';
import 'package:langtool/domain/models/entry_draft.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/fake_remote_sync_api.dart';
import '../helpers/sync_device.dart';
import '../helpers/test_repositories.dart';

String _describe(FormClash clash) =>
    '${clash.formKey} (${clash.packName}): ${clash.value}';

void main() {
  late TestRepositories repos;
  late LanguagePack a;
  late LanguagePack b;

  setUp(() async {
    repos = TestRepositories();
    a = await repos.createPack('A');
    b = await repos.createPack('B');
  });

  tearDown(() => repos.close());

  Future<Result<LanguagePack>> merge(
    List<LanguagePack> packs, {
    String name = 'Merged',
    bool deleteOriginals = false,
    TestRepositories? on,
  }) => (on ?? repos).merge.merge(
    packIds: [for (final pack in packs) pack.id],
    name: name,
    deleteOriginals: deleteOriginals,
    describeClash: _describe,
  );

  LanguagePack ok(Result<LanguagePack> result) => switch (result) {
    Ok(:final value) => value,
    Err(:final error) => throw StateError('$error'),
  };

  Object err(Result<LanguagePack> result) => switch (result) {
    Ok() => throw StateError('expected an error'),
    Err(:final error) => error,
  };

  test('combines matching entries into a new pack', () async {
    await repos.addNoun(a, 'Haus', translations: ['house']);
    await repos.addNoun(a, 'Baum', article: 'der');
    await repos.addNoun(b, ' haus', translations: ['home', 'House']);
    await repos.entries.add(
      EntryDraft(
        packId: b.id,
        wordType: WordType.verb,
        term: 'haus',
        translations: ['to house'],
      ),
    );

    final merged = ok(await merge([a, b]));

    expect(merged.name, 'Merged');
    expect(merged.languageCode, 'de');
    final entries = await repos.entries.watchEntries(merged.id).first;
    expect(
      {for (final e in entries) (e.term, e.wordType): e.translations},
      {
        ('haus', WordType.noun): ['house', 'home'],
        ('Baum', WordType.noun): <String>[],
        ('haus', WordType.verb): ['to house'],
      },
    );
    expect(await repos.packs.watchPacks('user-1').first, hasLength(3));
  });

  test('keeps the originals unless asked to delete them', () async {
    await repos.addNoun(a, 'Haus');
    await repos.addNoun(b, 'Haus');

    final merged = ok(await merge([a, b]));

    final packs = await repos.packs.watchPacks('user-1').first;
    expect(packs.map((p) => p.id), containsAll([a.id, b.id, merged.id]));
    expect(await repos.entries.watchEntries(a.id).first, hasLength(1));
  });

  test('deleting the originals removes their entries and decks', () async {
    await repos.addNoun(a, 'Haus');
    await repos.createDeck(b, 'All');

    final merged = ok(await merge([a, b], deleteOriginals: true));

    final packs = await repos.packs.watchPacks('user-1').first;
    expect(packs.map((p) => p.id), [merged.id]);
    final db = repos.db;
    final rows = await (db.select(db.entries)).get();
    final old = rows.where((r) => r.packId == a.id).single;
    expect(old.deletedAt, isNotNull);
    expect(old.needsPush, isTrue);
    final deck = (await (db.select(
      db.decks,
    )).get()).firstWhere((d) => d.packId == b.id);
    expect(deck.deletedAt, isNotNull);
    expect(deck.needsPush, isTrue);
  });

  test('copies decks and keeps repeated ones once', () async {
    const nouns = DeckFilter.wordTypes({WordType.noun});
    await repos.createDeck(a, 'Nouns', [nouns]);
    await repos.createDeck(b, 'nouns', [nouns]);
    await repos.createDeck(b, 'Week', [const DeckFilter.addedInLastDays(7)]);

    final merged = ok(await merge([a, b]));

    final decks = await repos.decks.watchDecks(merged.id).first;
    expect(decks.map((d) => d.name), unorderedEquals(['Nouns', 'Week']));
    expect(decks.every((d) => d.packId == merged.id), isTrue);
  });

  test('notes differing forms through describeClash', () async {
    await repos.addNoun(a, 'Teller', article: 'der');
    await repos.addNoun(b, 'Teller', article: 'das');

    final merged = ok(await merge([a, b]));

    final [entry] = await repos.entries.watchEntries(merged.id).first;
    expect(entry.forms['article'], 'das');
    expect(entry.notes, 'article (A): der');
  });

  test('merges three packs, keeping the earliest creation time', () async {
    final c = await repos.createPack('C');
    final first = await repos.addNoun(a, 'Haus', translations: ['house']);
    await repos.addNoun(b, 'Haus', translations: ['home']);
    await repos.addNoun(c, 'Haus', translations: ['ház']);

    final merged = ok(await merge([a, b, c]));

    final [entry] = await repos.entries.watchEntries(merged.id).first;
    expect(entry.translations, ['house', 'home', 'ház']);
    expect(entry.createdAt, first.createdAt);
    expect(entry.ownerId, 'user-1');
  });

  test('merged entries are searchable and keep the duplicate rule', () async {
    await repos.addNoun(a, 'Haus', translations: ['house']);
    await repos.addNoun(b, 'Haus');

    final merged = ok(await merge([a, b]));

    final hits = await repos.entries.search(merged.id, 'haus');
    expect(hits.single.entry.term, 'Haus');
    final again = await repos.entries.add(
      EntryDraft(
        packId: merged.id,
        wordType: WordType.noun,
        term: 'HAUS',
        forms: {'article': 'das'},
      ),
    );
    expect(again, isA<Err<Object>>());
  });

  test(
    'rejects a blank name, one pack, mixed languages and unknown packs',
    () async {
      expect(
        err(await merge([a, b], name: '  ')),
        isA<InvalidPackNameException>(),
      );
      expect(
        err(await merge([a, a])),
        isA<MergePacksException>().having(
          (e) => e.reason,
          'reason',
          MergePacksProblem.tooFewPacks,
        ),
      );
      await repos.packs.delete(b.id);
      expect(
        err(await merge([a, b])),
        isA<NotFoundException>().having((e) => e.id, 'id', b.id),
      );
    },
  );

  test('rejects packs of different languages', () async {
    await (repos.db.update(repos.db.languagePacks)
          ..where((p) => p.id.equals(b.id)))
        .write(const LanguagePacksCompanion(languageCode: Value('hu')));

    expect(
      err(await merge([a, b])),
      isA<MergePacksException>().having(
        (e) => e.reason,
        'reason',
        MergePacksProblem.mixedLanguages,
      ),
    );
  });

  test('a failed merge writes nothing', () async {
    await repos.addNoun(a, 'Haus');
    await repos.addNoun(b, 'Haus');
    await repos.addNoun(a, 'Baum');
    var ids = 0;
    final failing = LocalPackMergeRepository(
      repos.db,
      clock: repos.clock,
      // Both merged entries get the same id, so the second insert fails.
      newId: () => ids++ == 0 ? 'new-pack' : 'clash',
    );

    final result = await failing.merge(
      packIds: [a.id, b.id],
      name: 'Merged',
      deleteOriginals: true,
      describeClash: _describe,
    );

    expect(result, isA<Err<LanguagePack>>());
    final packs = await repos.packs.watchPacks('user-1').first;
    expect(packs.map((p) => p.id), unorderedEquals([a.id, b.id]));
    expect(await repos.entries.watchEntries(a.id).first, hasLength(2));
  });

  test(
    'watchPreview counts packs, entries, merged entries and decks',
    () async {
      await repos.addNoun(a, 'Haus');
      await repos.addNoun(a, 'Baum', article: 'der');
      await repos.addNoun(b, 'haus');
      await repos.createDeck(a, 'All');
      await repos.createDeck(b, 'all');
      await repos.createDeck(b, 'Nouns', [
        const DeckFilter.wordTypes({WordType.noun}),
      ]);

      final preview = repos.merge.watchPreview([a.id, b.id]);

      expect(await preview.first, (
        packs: 2,
        entries: 3,
        mergedEntries: 2,
        decks: 2,
      ));
      await repos.addNoun(b, 'Tisch', article: 'der');
      expect(await repos.merge.watchPreview([a.id, b.id]).first, (
        packs: 2,
        entries: 4,
        mergedEntries: 3,
        decks: 2,
      ));
      expect(await repos.merge.watchPreview(const []).first, (
        packs: 0,
        entries: 0,
        mergedEntries: 0,
        decks: 0,
      ));
    },
  );

  test('the merged pack and the deletions sync', () async {
    final server = FakeRemoteSyncApi();
    final phone = SyncDevice('phone', server);
    final laptop = SyncDevice('laptop', server);
    addTearDown(phone.close);
    addTearDown(laptop.close);
    final x = await phone.repos.createPack('X');
    final y = await phone.repos.createPack('Y');
    await phone.repos.addNoun(x, 'Haus', translations: ['house']);
    await phone.repos.addNoun(y, 'Haus', translations: ['home']);
    await phone.sync();

    final merged = ok(
      await merge([x, y], deleteOriginals: true, on: phone.repos),
    );
    await phone.sync();
    await laptop.sync();

    final packs = await laptop.packs();
    expect(packs.map((p) => p.id), [merged.id]);
    final [entry] = await laptop.entries(merged.id);
    expect(entry.translations, ['house', 'home']);
  });
}
