import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/data/local/mappers.dart';
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

/// Waits until the latest value in [values] equals [expected] (deeply, so
/// lists compare by their elements).
Future<void> _until<T>(List<T> values, T expected) async {
  bool reached() =>
      values.isNotEmpty && equals(expected).matches(values.last, {});
  for (var i = 0; i < 200 && !reached(); i++) {
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

  /// Adds an adverb [term] with [tags] to [inPack] (the pack by default).
  Future<Entry> addTagged(
    String term,
    List<String> tags, {
    WordType wordType = WordType.adverb,
    LanguagePack? inPack,
  }) async => _ok(
    await repos.entries.add(
      EntryDraft(
        packId: (inPack ?? pack).id,
        wordType: wordType,
        term: term,
        forms: wordType == WordType.noun ? {'article': 'das'} : const {},
        tags: tags,
      ),
    ),
  );

  Future<List<String>> matching(List<DeckFilter> filters) async => [
    for (final entry in await repos.decks.matchingEntries(pack.id, filters))
      entry.term,
  ];

  Future<int> count(List<DeckFilter> filters) =>
      repos.decks.watchMatchCount(pack.id, filters).first;

  DeckFilter any(Set<String> tags) => DeckFilter.tags(tags, TagMatch.any);
  DeckFilter all(Set<String> tags) => DeckFilter.tags(tags, TagMatch.all);

  group('tag filter', () {
    test('any selects entries with at least one of the tags', () async {
      await addTagged('eins', ['A1', 'food']);
      await addTagged('zwei', ['A1']);
      await addTagged('drei', ['food']);
      await addTagged('vier', ['B2']);
      await addTagged('fünf', []);

      expect(
        await matching([
          any({'A1'}),
        ]),
        ['eins', 'zwei'],
      );
      expect(
        await matching([
          any({'A1', 'food'}),
        ]),
        ['eins', 'zwei', 'drei'],
      );
      expect(
        await count([
          any({'A1', 'food'}),
        ]),
        3,
      );
    });

    test('all selects entries with every one of the tags', () async {
      await addTagged('eins', ['A1', 'food', 'home']);
      await addTagged('zwei', ['A1']);
      await addTagged('drei', ['food', 'A1']);

      expect(
        await matching([
          all({'A1', 'food'}),
        ]),
        ['eins', 'drei'],
      );
      expect(
        await count([
          all({'A1', 'food'}),
        ]),
        2,
      );
      expect(
        await matching([
          all({'A1', 'food', 'home'}),
        ]),
        ['eins'],
      );
    });

    test('an empty tag set matches nothing', () async {
      await addTagged('eins', ['A1']);

      expect(await matching([any({})]), isEmpty);
      expect(await count([all({})]), 0);
    });

    test('ignores case and spacing', () async {
      await addTagged('eins', ['A1']);
      await addTagged('zwei', ['Wohnen  im Haus']);

      expect(
        await matching([
          any({' a1'}),
        ]),
        ['eins'],
      );
      expect(
        await matching([
          any({'WOHNEN im  haus '}),
        ]),
        ['zwei'],
      );
      expect(
        await matching([
          all({'a1 ', 'A1'}),
        ]),
        ['eins'],
      );
    });

    test('keeps umlauts', () async {
      await addTagged('eins', ['Möbel']);
      await addTagged('zwei', ['Mobel']);

      expect(
        await matching([
          any({'möbel'}),
        ]),
        ['eins'],
      );
      expect(
        await matching([
          any({'Mobel'}),
        ]),
        ['zwei'],
      );
      expect(
        await matching([
          any({'MÖBEL'}),
        ]),
        ['eins'],
      );
    });

    test('matches whole tags only', () async {
      await addTagged('eins', ['A1']);
      await addTagged('zwei', ['A1 plus']);

      expect(
        await matching([
          any({'A'}),
        ]),
        isEmpty,
      );
      expect(
        await matching([
          any({'A1'}),
        ]),
        ['eins'],
      );
      expect(
        await matching([
          any({'plus'}),
        ]),
        isEmpty,
      );
    });

    test('LIKE wildcards in tags match literally', () async {
      await addTagged('eins', ['A1']);
      await addTagged('zwei', ['100%']);
      await addTagged('drei', ['a_b']);
      await addTagged('vier', [r'back\slash']);

      expect(
        await matching([
          any({'%'}),
        ]),
        isEmpty,
      );
      expect(
        await matching([
          any({'_'}),
        ]),
        isEmpty,
      );
      expect(
        await matching([
          any({'A_'}),
        ]),
        isEmpty,
      );
      expect(
        await matching([
          any({'100%'}),
        ]),
        ['zwei'],
      );
      expect(
        await matching([
          any({'a_b'}),
        ]),
        ['drei'],
      );
      expect(
        await matching([
          any({'axb'}),
        ]),
        isEmpty,
      );
      expect(
        await matching([
          any({r'back\slash'}),
        ]),
        ['vier'],
      );
    });

    test('ignores deleted entries and other packs', () async {
      final other = await repos.createPack('Other');
      final gone = await addTagged('weg', ['A1']);
      _ok(await repos.entries.delete(gone.id));
      await addTagged('dort', ['A1'], inPack: other);
      await addTagged('hier', ['A1']);

      expect(
        await matching([
          any({'A1'}),
        ]),
        ['hier'],
      );
    });

    test('combines with other filters', () async {
      await addTagged('Haus', ['A1'], wordType: WordType.noun);
      await addTagged('gern', ['A1']);
      await addTagged('Baum', ['B2'], wordType: WordType.noun);

      final filters = [
        const DeckFilter.wordTypes({WordType.noun}),
        any({'A1'}),
      ];
      expect(await matching(filters), ['Haus']);
      expect(await count(filters), 1);
      expect(
        await matching([...filters, const DeckFilter.addedInLastDays(0)]),
        isEmpty,
      );
    });

    test('follows tag edits', () async {
      final entry = await addTagged('eins', ['A1']);
      _ok(await repos.entries.update(entry.copyWith(tags: ['B2'])));

      expect(
        await matching([
          any({'A1'}),
        ]),
        isEmpty,
      );
      expect(
        await matching([
          any({'B2'}),
        ]),
        ['eins'],
      );
    });

    test('stores the tags column as wrapped keys', () async {
      final entry = await addTagged('eins', [' A1 ', 'Wohnen  im Haus']);

      final row = await repos.db.select(repos.db.entries).getSingle();
      expect(row.tagKeys, '\na1\nwohnen im haus\n');
      expect(entry.copyWith(tags: const []).toCompanion().tagKeys.value, '');
    });

    test('watchMatchCount updates live as tags change', () async {
      final counts = <int>[];
      final subscription = repos.decks
          .watchMatchCount(pack.id, [
            all({'A1', 'food'}),
          ])
          .listen(counts.add);
      addTearDown(subscription.cancel);
      await _until(counts, 0);

      final entry = await addTagged('eins', ['A1']);
      await addTagged('zwei', ['food', 'a1']);
      await _until(counts, 1);

      _ok(await repos.entries.update(entry.copyWith(tags: ['Food', 'A1'])));
      await _until(counts, 2);
    });
  });

  group('watchTags', () {
    test('lists distinct tags sorted ignoring case', () async {
      await addTagged('eins', ['food', 'A1']);
      await addTagged('zwei', ['b2', 'A1']);
      await addTagged('drei', ['Möbel', 'Mobel']);

      expect(await repos.decks.watchTags(pack.id).first, [
        'A1',
        'b2',
        'food',
        'Mobel',
        'Möbel',
      ]);
    });

    test(
      'keeps the first spelling of tags differing in case or spacing',
      () async {
        await addTagged('eins', ['Wohnen im Haus', 'a1']);
        await addTagged('zwei', ['wohnen  IM haus', 'A1']);

        expect(await repos.decks.watchTags(pack.id).first, [
          'a1',
          'Wohnen im Haus',
        ]);
      },
    );

    test('ignores deleted entries and other packs', () async {
      final other = await repos.createPack('Other');
      final gone = await addTagged('weg', ['old']);
      _ok(await repos.entries.delete(gone.id));
      await addTagged('dort', ['elsewhere'], inPack: other);
      await addTagged('hier', ['A1']);

      expect(await repos.decks.watchTags(pack.id).first, ['A1']);
    });

    test('updates live as entries change', () async {
      final emissions = <List<String>>[];
      final subscription = repos.decks.watchTags(pack.id).listen(emissions.add);
      addTearDown(subscription.cancel);
      await _until(emissions, <String>[]);

      final entry = await addTagged('eins', ['A1']);
      await _until(emissions, ['A1']);
      await addTagged('zwei', ['food']);
      await _until(emissions, ['A1', 'food']);

      _ok(await repos.entries.update(entry.copyWith(tags: ['B2'])));
      await _until(emissions, ['B2', 'food']);

      _ok(await repos.entries.delete(entry.id));
      await _until(emissions, ['food']);
    });
  });
}
