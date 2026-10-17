import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/ui/features/recap/deck_detail/view_models/deck_detail_view_model.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/test_repositories.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;
  late Deck deck;
  late DeckDetailViewModel viewModel;

  DeckDetailViewModel create([String? deckId]) => DeckDetailViewModel(
    deckRepository: repos.decks,
    packRepository: repos.packs,
    packId: pack.id,
    deckId: deckId ?? deck.id,
  );

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

  test('reports a missing deck', () async {
    viewModel = create('nope');

    await settle(() => !viewModel.loading);
    expect(viewModel.deck, isNull);
  });
}
