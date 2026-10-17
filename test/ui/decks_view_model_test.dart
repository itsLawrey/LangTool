import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/ui/features/recap/decks/view_models/decks_view_model.dart';

import '../helpers/test_repositories.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;
  late DecksViewModel viewModel;

  DecksViewModel create([String? packId]) => DecksViewModel(
    deckRepository: repos.decks,
    packRepository: repos.packs,
    packId: packId ?? pack.id,
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
  });

  tearDown(() async {
    viewModel.dispose();
    await repos.close();
  });

  test('loads the pack and an empty deck list', () async {
    viewModel = create();

    await settle(() => !viewModel.loading && viewModel.pack != null);

    expect(viewModel.pack!.name, 'Deutsch');
    expect(viewModel.decks, isEmpty);
    expect(viewModel.packMissing, isFalse);
  });

  test('reports a missing pack', () async {
    viewModel = create('nope');

    await settle(() => viewModel.packMissing);
  });

  test('counts each deck and recounts when entries change', () async {
    await repos.addNoun(pack, 'Haus');
    final all = await repos.createDeck(pack, 'All');
    final verbs = await repos.createDeck(pack, 'Verbs', const [
      DeckFilter.wordTypes({WordType.verb}),
    ]);
    viewModel = create();

    await settle(
      () =>
          viewModel.countFor(all.id) == 1 && viewModel.countFor(verbs.id) == 0,
    );
    expect([for (final d in viewModel.decks) d.name], ['All', 'Verbs']);

    await repos.addNoun(pack, 'Baum', article: 'der');

    await settle(() => viewModel.countFor(all.id) == 2);
    expect(viewModel.countFor(verbs.id), 0);
  });

  test(
    'recounts a deck whose filters change and forgets deleted ones',
    () async {
      await repos.addNoun(pack, 'Haus');
      final deck = await repos.createDeck(pack, 'Deck');
      viewModel = create();
      await settle(() => viewModel.countFor(deck.id) == 1);

      await repos.decks.update(
        deck.copyWith(
          filters: const [
            DeckFilter.wordTypes({WordType.verb}),
          ],
        ),
      );
      await settle(() => viewModel.countFor(deck.id) == 0);

      await repos.decks.delete(deck.id);
      await settle(() => viewModel.decks.isEmpty);
      expect(viewModel.countFor(deck.id), isNull);
    },
  );

  test('shows new decks as they are created', () async {
    viewModel = create();
    await settle(() => !viewModel.loading);

    final Deck deck = await repos.createDeck(pack, 'New');

    await settle(() => viewModel.decks.length == 1);
    await settle(() => viewModel.countFor(deck.id) == 0);
  });
}
