import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/entry_draft.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/ui/core/timeline_items.dart';
import 'package:langtool/ui/features/recap/deck_detail/view_models/deck_detail_view_model.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/test_repositories.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;
  late Deck deck;
  late DeckDetailViewModel viewModel;

  DeckDetailViewModel create([String? deckId, int pageSize = 50]) =>
      DeckDetailViewModel(
        deckRepository: repos.decks,
        packRepository: repos.packs,
        packId: pack.id,
        deckId: deckId ?? deck.id,
        pageSize: pageSize,
      );

  List<String> terms() => [
    for (final item in viewModel.items)
      if (item case EntryItem(:final entry)) entry.term,
  ];

  Future<void> addAdverb(String term) async {
    final result = await repos.entries.add(
      EntryDraft(packId: pack.id, wordType: WordType.adverb, term: term),
    );
    expect(result, isA<Ok<Object>>());
  }

  /// Waits until [condition] holds after the view model notifies.
  Future<void> settle(bool Function() condition) async {
    for (var i = 0; i < 100 && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(condition(), isTrue, reason: 'condition not reached');
  }

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack();
    deck = await repos.createDeck(pack, 'Nouns', const [
      DeckFilter.wordTypes({WordType.noun}),
    ]);
  });

  tearDown(() async {
    viewModel.dispose();
    await repos.close();
  });

  test('cannot start without matching entries', () async {
    viewModel = create();

    await settle(() => viewModel.count == 0 && viewModel.languageCode != null);

    expect(viewModel.deck!.name, 'Nouns');
    expect(viewModel.languageCode, 'de');
    expect(viewModel.canStart, isFalse);
  });

  test('counts live and can start once entries match', () async {
    viewModel = create();
    await settle(() => viewModel.count == 0);

    await repos.addNoun(pack, 'Haus');

    await settle(() => viewModel.count == 1);
    expect(viewModel.canStart, isTrue);
  });

  test('recounts after the filters are edited', () async {
    await repos.addNoun(pack, 'Haus');
    viewModel = create();
    await settle(() => viewModel.count == 1);

    await repos.decks.update(
      deck.copyWith(
        filters: const [
          DeckFilter.wordTypes({WordType.verb}),
        ],
      ),
    );

    await settle(() => viewModel.count == 0);
    expect(viewModel.deck!.filters, const [
      DeckFilter.wordTypes({WordType.verb}),
    ]);
  });

  test('deletes the deck', () async {
    viewModel = create();
    await settle(() => !viewModel.loading);

    expect(await viewModel.delete(), isA<Ok<void>>());

    await settle(() => viewModel.deck == null);
    expect(viewModel.count, isNull);
  });

  group('entries', () {
    test('lists matching entries newest first, grouped by day', () async {
      repos.now = DateTime.utc(2026, 10, 1, 12);
      await repos.addNoun(pack, 'Haus');
      await addAdverb('gern');
      repos.now = DateTime.utc(2026, 10, 3, 12);
      await repos.addNoun(pack, 'Baum', article: 'der');
      await repos.addNoun(pack, 'Auto');
      viewModel = create();

      await settle(() => terms().length == 3 && viewModel.schema != null);

      expect(terms(), ['Auto', 'Baum', 'Haus']);
      expect(viewModel.items.whereType<DayHeaderItem>(), [
        DayHeaderItem(DateTime(2026, 10, 3)),
        DayHeaderItem(DateTime(2026, 10, 1)),
      ]);
      expect(viewModel.items.first, isA<DayHeaderItem>());
      expect(viewModel.hasMore, isFalse);
      expect(viewModel.schema!.code, 'de');
    });

    test('loads older entries page by page', () async {
      for (var i = 0; i < 5; i++) {
        await repos.addNoun(pack, 'Wort$i');
      }
      viewModel = create(null, 2);
      await settle(() => terms().isNotEmpty);
      expect(terms(), ['Wort4', 'Wort3']);
      expect(viewModel.hasMore, isTrue);

      viewModel.loadMore();
      await settle(() => terms().length == 4);
      viewModel.loadMore();
      await settle(() => terms().length == 5);

      expect(viewModel.hasMore, isFalse);
      expect(viewModel.count, 5);
    });

    test('follows added and deleted entries', () async {
      final haus = await repos.addNoun(pack, 'Haus');
      viewModel = create();
      await settle(() => terms().length == 1);

      await repos.addNoun(pack, 'Baum', article: 'der');
      await addAdverb('gern');
      await settle(() => terms().length == 2);
      expect(terms(), ['Baum', 'Haus']);

      await repos.entries.delete(haus.id);
      await settle(() => terms().length == 1);
      expect(terms(), ['Baum']);
    });

    test('re-queries after the filters are edited', () async {
      await repos.addNoun(pack, 'Haus');
      await addAdverb('gern');
      viewModel = create();
      await settle(() => terms().length == 1);
      expect(terms(), ['Haus']);

      await repos.decks.update(
        deck.copyWith(
          filters: const [
            DeckFilter.wordTypes({WordType.adverb}),
          ],
        ),
      );

      await settle(() => terms().length == 1 && terms().first == 'gern');
    });

    test('an empty deck lists nothing', () async {
      viewModel = create();

      await settle(() => viewModel.count == 0);

      expect(viewModel.items, isEmpty);
      expect(viewModel.hasMore, isFalse);
    });

    test('a deleted deck lists nothing', () async {
      await repos.addNoun(pack, 'Haus');
      viewModel = create();
      await settle(() => terms().length == 1);

      await viewModel.delete();

      await settle(() => viewModel.deck == null);
      expect(viewModel.items, isEmpty);
      expect(viewModel.hasMore, isFalse);
    });
  });

  test('reports a missing deck', () async {
    viewModel = create('nope');

    await settle(() => !viewModel.loading);
    expect(viewModel.deck, isNull);
  });
}
