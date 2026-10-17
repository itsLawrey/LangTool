import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/data/local/app_database.dart';
import 'package:langtool/data/local/mappers.dart';
import 'package:langtool/domain/exceptions.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/deck_draft.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/entry_draft.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/test_repositories.dart';

T _ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final error) => throw TestFailure('Expected Ok, got $error'),
};

Exception _err<T>(Result<T> result) => switch (result) {
  Ok(:final value) => throw TestFailure('Expected Err, got $value'),
  Err(:final error) => error,
};

/// Waits until the latest value in [values] is [expected].
Future<void> _until<T>(List<T> values, T expected) async {
  for (var i = 0; i < 200 && (values.isEmpty || values.last != expected); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(values, isNotEmpty);
  expect(values.last, expected);
}

void main() {
  late TestRepositories repos;
  late LanguagePack pack;

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack();
  });

  tearDown(() => repos.close());

  /// Adds an entry created at [createdAt].
  Future<Entry> addAt(
    DateTime createdAt,
    String term, {
    WordType wordType = WordType.adverb,
  }) async {
    repos.now = createdAt.toUtc().subtract(const Duration(seconds: 1));
    return _ok(
      await repos.entries.add(
        EntryDraft(
          packId: pack.id,
          wordType: wordType,
          term: term,
          forms: wordType == WordType.noun ? {'article': 'das'} : const {},
        ),
      ),
    );
  }

  Future<List<String>> matching(List<DeckFilter> filters) async => [
    for (final entry in await repos.decks.matchingEntries(pack.id, filters))
      entry.term,
  ];

  Future<int> count(List<DeckFilter> filters) =>
      repos.decks.watchMatchCount(pack.id, filters).first;

  group('CRUD', () {
    test('creates a deck in the pack, trimming the name', () async {
      final filters = [
        const DeckFilter.wordTypes({WordType.noun}),
      ];
      final deck = _ok(
        await repos.decks.create(
          DeckDraft(packId: pack.id, name: '  Nouns  ', filters: filters),
        ),
      );

      expect(deck.name, 'Nouns');
      expect(deck.packId, pack.id);
      expect(deck.ownerId, pack.ownerId);
      expect(deck.filters, filters);
      expect(deck.createdAt, deck.updatedAt);
      expect(deck.deletedAt, isNull);
      expect(_ok(await repos.decks.getDeck(deck.id)), deck);
    });

    test('stores every filter type, including unknown ones', () async {
      final filters = [
        DeckFilter.addedBetween(from: DateTime(2026, 10), to: null),
        const DeckFilter.addedInLastDays(7),
        const DeckFilter.wordTypes({WordType.verb, WordType.noun}),
        const DeckFilter.unknown({'type': 'tagged', 'tag': 'A1'}),
      ];
      final deck = await repos.createDeck(pack, 'All', filters);

      expect(_ok(await repos.decks.getDeck(deck.id)).filters, filters);
    });

    test('rejects blank names', () async {
      expect(
        _err(await repos.decks.create(DeckDraft(packId: pack.id, name: ' '))),
        isA<InvalidDeckNameException>(),
      );
      final deck = await repos.createDeck(pack, 'Nouns');
      expect(
        _err(await repos.decks.update(deck.copyWith(name: ''))),
        isA<InvalidDeckNameException>(),
      );
    });

    test('rejects unknown and deleted packs', () async {
      expect(
        _err(
          await repos.decks.create(
            const DeckDraft(packId: 'missing', name: 'Nouns'),
          ),
        ),
        isA<NotFoundException>().having((e) => e.id, 'id', 'missing'),
      );

      _ok(await repos.packs.delete(pack.id));
      expect(
        _err(await repos.decks.create(DeckDraft(packId: pack.id, name: 'N'))),
        isA<NotFoundException>().having((e) => e.id, 'id', pack.id),
      );
    });

    test(
      'updates name and filters, keeping pack, owner and creation',
      () async {
        final other = await repos.createPack('Other', 'user-2');
        final deck = await repos.createDeck(pack, 'Nouns');

        final updated = _ok(
          await repos.decks.update(
            deck.copyWith(
              name: ' Verbs ',
              filters: [
                const DeckFilter.wordTypes({WordType.verb}),
              ],
              packId: other.id,
              ownerId: 'user-2',
              createdAt: DateTime.utc(2000),
            ),
          ),
        );

        expect(updated.name, 'Verbs');
        expect(updated.filters, [
          const DeckFilter.wordTypes({WordType.verb}),
        ]);
        expect(updated.packId, pack.id);
        expect(updated.ownerId, 'user-1');
        expect(updated.createdAt, deck.createdAt);
        expect(updated.updatedAt.isAfter(deck.updatedAt), isTrue);
        expect(_ok(await repos.decks.getDeck(deck.id)), updated);
      },
    );

    test('updating a deleted deck fails', () async {
      final deck = await repos.createDeck(pack, 'Nouns');
      _ok(await repos.decks.delete(deck.id));

      expect(
        _err(await repos.decks.update(deck.copyWith(name: 'Verbs'))),
        isA<NotFoundException>().having((e) => e.id, 'id', deck.id),
      );
    });

    test('deletes softly and marks the deletion for upload', () async {
      final deck = await repos.createDeck(pack, 'Nouns');
      await repos.db
          .update(repos.db.decks)
          .write(const DecksCompanion(needsPush: Value(false)));

      _ok(await repos.decks.delete(deck.id));

      expect(
        _err(await repos.decks.getDeck(deck.id)),
        isA<NotFoundException>(),
      );
      expect(_err(await repos.decks.delete(deck.id)), isA<NotFoundException>());
      final row = await repos.db.select(repos.db.decks).getSingle();
      expect(row.deletedAt, isNotNull);
      expect(row.updatedAt, row.deletedAt);
      expect(row.needsPush, isTrue);
    });

    test('deleting a pack deletes its decks', () async {
      final other = await repos.createPack('Other');
      await repos.createDeck(pack, 'Nouns');
      final kept = await repos.createDeck(other, 'Kept');

      _ok(await repos.packs.delete(pack.id));

      expect(await repos.decks.watchDecks(pack.id).first, isEmpty);
      expect(await repos.decks.watchDecks(other.id).first, [kept]);
      final rows = await (repos.db.select(
        repos.db.decks,
      )..where((d) => d.packId.equals(pack.id))).get();
      expect(rows.single.deletedAt, isNotNull);
      expect(rows.single.needsPush, isTrue);
    });

    test('lists active decks of a pack by name, ignoring case', () async {
      final other = await repos.createPack('Other');
      await repos.createDeck(pack, 'verbs');
      await repos.createDeck(pack, 'Adjectives');
      final gone = await repos.createDeck(pack, 'Gone');
      await repos.createDeck(pack, 'Nouns');
      await repos.createDeck(other, 'Elsewhere');
      _ok(await repos.decks.delete(gone.id));

      final decks = await repos.decks.watchDecks(pack.id).first;

      expect([for (final d in decks) d.name], ['Adjectives', 'Nouns', 'verbs']);
    });

    test('watchDeck follows edits and emits null once deleted', () async {
      final deck = await repos.createDeck(pack, 'Nouns');
      final seen = <Deck?>[];
      final subscription = repos.decks.watchDeck(deck.id).listen(seen.add);
      addTearDown(subscription.cancel);
      await _until(seen, deck);

      final renamed = _ok(
        await repos.decks.update(deck.copyWith(name: 'Renamed')),
      );
      await _until(seen, renamed);

      _ok(await repos.decks.delete(deck.id));
      await _until(seen, null);
      expect(await repos.decks.watchDeck('missing').first, isNull);
    });
  });

  group('filters', () {
    test('no filters select the whole pack, oldest first', () async {
      final other = await repos.createPack('Other');
      await addAt(DateTime.utc(2026, 10, 2), 'zwei');
      await addAt(DateTime.utc(2026, 10, 1), 'eins');
      final gone = await addAt(DateTime.utc(2026, 10, 3), 'drei');
      _ok(await repos.entries.delete(gone.id));
      await repos.addNoun(other, 'Haus');

      expect(await matching(const []), ['eins', 'zwei']);
      expect(await count(const []), 2);
    });

    test('wordTypes selects entries of the given types', () async {
      await addAt(
        DateTime.utc(2026, 10, 1, 1),
        'Haus',
        wordType: WordType.noun,
      );
      await addAt(DateTime.utc(2026, 10, 1, 2), 'gern');
      await addAt(
        DateTime.utc(2026, 10, 1, 3),
        'gehen',
        wordType: WordType.verb,
      );

      expect(
        await matching([
          const DeckFilter.wordTypes({WordType.noun, WordType.verb}),
        ]),
        ['Haus', 'gehen'],
      );
      expect(
        await matching([
          const DeckFilter.wordTypes({WordType.adverb}),
        ]),
        ['gern'],
      );
      expect(await matching([const DeckFilter.wordTypes({})]), isEmpty);
    });

    group('addedBetween', () {
      setUp(() async {
        await addAt(DateTime(2026, 10, 9, 23, 59, 59), 'before');
        await addAt(DateTime(2026, 10, 10), 'first');
        await addAt(DateTime(2026, 10, 11, 12), 'middle');
        await addAt(DateTime(2026, 10, 12, 23, 59), 'last');
        await addAt(DateTime(2026, 10, 13), 'after');
      });

      test('includes both days, whole days in local time', () async {
        expect(
          await matching([
            DeckFilter.addedBetween(
              from: DateTime(2026, 10, 10),
              to: DateTime(2026, 10, 12),
            ),
          ]),
          ['first', 'middle', 'last'],
        );
      });

      test('ignores the time of day of the bounds', () async {
        expect(
          await matching([
            DeckFilter.addedBetween(
              from: DateTime(2026, 10, 10, 18),
              to: DateTime(2026, 10, 12, 6),
            ),
          ]),
          ['first', 'middle', 'last'],
        );
      });

      test('a single day', () async {
        expect(
          await matching([
            DeckFilter.addedBetween(
              from: DateTime(2026, 10, 12),
              to: DateTime(2026, 10, 12),
            ),
          ]),
          ['last'],
        );
      });

      test('either side may be open', () async {
        expect(
          await matching([
            DeckFilter.addedBetween(from: DateTime(2026, 10, 12)),
          ]),
          ['last', 'after'],
        );
        expect(
          await matching([DeckFilter.addedBetween(to: DateTime(2026, 10, 10))]),
          ['before', 'first'],
        );
        expect(await matching([const DeckFilter.addedBetween()]), hasLength(5));
      });

      test('a range ending before it starts selects nothing', () async {
        expect(
          await matching([
            DeckFilter.addedBetween(
              from: DateTime(2026, 10, 12),
              to: DateTime(2026, 10, 10),
            ),
          ]),
          isEmpty,
        );
      });
    });

    // Daylight saving time ends in Europe on 25 October 2026 and in North
    // America on 1 November 2026.
    for (final (from, to) in [
      (DateTime(2026, 10, 10), DateTime(2026, 10, 12)),
      (DateTime(2026, 10, 25), DateTime(2026, 10, 25)),
      (DateTime(2026, 11, 1), DateTime(2026, 11, 1)),
    ]) {
      test('addedBetween matches each instant by its local calendar day '
          '(${from.month}/${from.day} to ${to.month}/${to.day})', () async {
        // Hourly UTC instants around the range: whether the UTC date or the
        // local date counts differs for some of them in every time zone
        // except UTC.
        final expected = <String>[];
        final first = DateTime.utc(from.year, from.month, from.day - 1);
        final last = DateTime.utc(to.year, to.month, to.day + 2);
        for (
          var instant = first;
          instant.isBefore(last);
          instant = instant.add(const Duration(hours: 1))
        ) {
          final term = 'h${instant.millisecondsSinceEpoch}';
          await addAt(instant, term);
          final local = instant.toLocal();
          final day = DateTime(local.year, local.month, local.day);
          if (!day.isBefore(from) && !day.isAfter(to)) expected.add(term);
        }

        final filter = DeckFilter.addedBetween(from: from, to: to);
        expect(await matching([filter]), expected);
        expect(await count([filter]), expected.length);
      });
    }

    test('compares instants, whatever offset they were stored with', () async {
      final utc = await addAt(DateTime.utc(2026, 10, 8, 12), 'utc');
      // A row stored with an explicit offset rather than in UTC.
      final local = (await addAt(
        DateTime.utc(2026, 10, 1),
        'local',
      )).copyWith(createdAt: DateTime(2026, 10, 11, 8, 30));
      await repos.db.update(repos.db.entries).replace(local.toCompanion());

      expect(
        await matching([
          DeckFilter.addedBetween(
            from: DateTime(2026, 10, 11),
            to: DateTime(2026, 10, 11),
          ),
        ]),
        ['local'],
      );
      expect(
        await matching([DeckFilter.addedBetween(from: DateTime(2026, 10, 5))]),
        [utc.term, 'local'],
      );
    });

    group('addedInLastDays', () {
      setUp(() async {
        await addAt(DateTime(2026, 10, 12, 23, 59), 'four days ago');
        await addAt(DateTime(2026, 10, 13), 'three days ago');
        await addAt(DateTime(2026, 10, 14, 23, 59), 'yesterday');
        await addAt(DateTime(2026, 10, 15), 'today');
        // "Now" is 10:00 local time on 15 October.
        repos.now = DateTime(2026, 10, 15, 10).toUtc();
      });

      test('1 day means today', () async {
        expect(await matching([const DeckFilter.addedInLastDays(1)]), [
          'today',
        ]);
      });

      test('counts whole local days back from today', () async {
        expect(await matching([const DeckFilter.addedInLastDays(3)]), [
          'three days ago',
          'yesterday',
          'today',
        ]);
      });

      test('moves forward with the clock', () async {
        repos.now = DateTime(2026, 10, 16, 0, 0, 30).toUtc();
        expect(await matching([const DeckFilter.addedInLastDays(2)]), [
          'today',
        ]);
      });

      test('zero days selects nothing', () async {
        expect(await matching([const DeckFilter.addedInLastDays(0)]), isEmpty);
      });
    });

    test('unknown filters match nothing', () async {
      await repos.addNoun(pack, 'Haus');

      expect(
        await matching([
          const DeckFilter.unknown({'type': 'tagged'}),
        ]),
        isEmpty,
      );
      expect(
        await count([
          const DeckFilter.unknown({'type': 'tagged'}),
        ]),
        0,
      );
    });

    test('combines filters with AND', () async {
      await addAt(DateTime(2026, 10, 1, 9), 'Haus', wordType: WordType.noun);
      await addAt(DateTime(2026, 10, 1, 10), 'gern');
      await addAt(DateTime(2026, 10, 5, 9), 'Baum', wordType: WordType.noun);

      final filters = [
        DeckFilter.addedBetween(to: DateTime(2026, 10, 2)),
        const DeckFilter.wordTypes({WordType.noun}),
      ];
      expect(await matching(filters), ['Haus']);
      expect(await count(filters), 1);
      expect(
        await matching([
          ...filters,
          const DeckFilter.unknown({'type': 'tagged'}),
        ]),
        isEmpty,
      );
    });

    test('watchMatchCount updates live as entries change', () async {
      final counts = <int>[];
      final subscription = repos.decks
          .watchMatchCount(pack.id, [
            const DeckFilter.wordTypes({WordType.noun}),
          ])
          .listen(counts.add);
      addTearDown(subscription.cancel);
      await _until(counts, 0);

      final haus = await repos.addNoun(pack, 'Haus');
      await _until(counts, 1);
      await addAt(DateTime.utc(2026, 10, 1), 'gern');
      await repos.addNoun(pack, 'Baum', article: 'der');
      await _until(counts, 2);

      _ok(await repos.entries.delete(haus.id));
      await _until(counts, 1);
    });
  });
}
