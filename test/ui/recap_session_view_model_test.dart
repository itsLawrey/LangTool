import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/domain/recap/recap_session.dart';
import 'package:langtool/ui/features/recap_session/view_models/recap_session_view_model.dart';

import '../helpers/test_repositories.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;
  late List<Entry> nouns;

  Future<void> settle(bool Function() condition) async {
    for (var i = 0; i < 100 && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(condition(), isTrue, reason: 'condition not reached');
  }

  Future<RecapSessionViewModel> start(
    String deckId, {
    RecapDirection direction = RecapDirection.foreignFirst,
    String? packId,
  }) async {
    final viewModel = RecapSessionViewModel(
      deckRepository: repos.decks,
      packRepository: repos.packs,
      packId: packId ?? pack.id,
      deckId: deckId,
      direction: direction,
      random: Random(1),
    );
    addTearDown(viewModel.dispose);
    expect(viewModel.status, RecapSessionStatus.loading);
    await settle(() => viewModel.status != RecapSessionStatus.loading);
    return viewModel;
  }

  /// Answers every remaining card, alternating knew / didn't know starting
  /// with knew, and returns the entries in the order they were shown.
  List<String> playThrough(RecapSessionViewModel viewModel) {
    final shown = <String>[];
    var knew = true;
    while (viewModel.status == RecapSessionStatus.inProgress) {
      shown.add(viewModel.current!.entry.id);
      viewModel
        ..reveal()
        ..answer(knewIt: knew);
      knew = !knew;
    }
    return shown;
  }

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack();
    nouns = [
      for (final (term, translation) in [
        ('Haus', 'house'),
        ('Baum', 'tree'),
        ('Hund', 'dog'),
        ('Katze', 'cat'),
        ('Tisch', 'table'),
        ('Stuhl', 'chair'),
      ])
        await repos.addNoun(pack, term, translations: [translation]),
    ];
  });

  tearDown(() => repos.close());

  test('loads the deck and starts at the first card', () async {
    final deck = await repos.createDeck(pack, 'All');

    final viewModel = await start(deck.id);

    expect(viewModel.status, RecapSessionStatus.inProgress);
    expect(viewModel.deck, deck);
    expect(viewModel.schema?.code, 'de');
    expect(viewModel.total, nouns.length);
    expect(viewModel.position, 0);
    expect(viewModel.revealed, isFalse);
    expect(nouns, contains(viewModel.current!.entry));
  });

  test('reveal and answer advance through the cards', () async {
    final deck = await repos.createDeck(pack, 'All');
    final viewModel = await start(deck.id);
    var notified = 0;
    viewModel.addListener(() => notified++);
    final first = viewModel.current!.entry;

    viewModel.reveal();
    expect(viewModel.revealed, isTrue);
    expect(viewModel.current!.entry, first);

    viewModel.answer(knewIt: true);
    expect(viewModel.position, 1);
    expect(viewModel.revealed, isFalse);
    expect(viewModel.current!.entry, isNot(first));
    expect(viewModel.knownCount, 1);
    expect(viewModel.unknownCount, 0);

    viewModel
      ..reveal()
      ..answer(knewIt: false);
    expect(viewModel.knownCount, 1);
    expect(viewModel.unknownCount, 1);
    expect(notified, 4);
  });

  test('finishes after the last card with the counts', () async {
    final deck = await repos.createDeck(pack, 'All');
    final viewModel = await start(deck.id);

    final shown = playThrough(viewModel);

    expect(viewModel.status, RecapSessionStatus.finished);
    expect(shown.toSet(), {for (final e in nouns) e.id});
    expect(viewModel.current, isNull);
    expect(viewModel.position, nouns.length);
    expect(viewModel.knownCount, 3);
    expect(viewModel.unknownCount, 3);
  });

  test('restart reshuffles the same entries and resets the counts', () async {
    final deck = await repos.createDeck(pack, 'All');
    final viewModel = await start(deck.id);
    final firstOrder = playThrough(viewModel);

    viewModel.restart();

    expect(viewModel.status, RecapSessionStatus.inProgress);
    expect(viewModel.position, 0);
    expect(viewModel.knownCount, 0);
    expect(viewModel.unknownCount, 0);
    final secondOrder = playThrough(viewModel);
    expect(secondOrder.toSet(), firstOrder.toSet());
    expect(secondOrder, isNot(firstOrder));
  });

  test('keeps its cards when entries change during the session', () async {
    final deck = await repos.createDeck(pack, 'All');
    final viewModel = await start(deck.id);

    await repos.addNoun(pack, 'Buch', translations: ['book']);
    viewModel.restart();

    expect(viewModel.total, nouns.length);
  });

  test('uses only the entries matching the deck filters', () async {
    final verbs = await repos.createDeck(pack, 'Verbs', [
      const DeckFilter.wordTypes({WordType.verb}),
    ]);

    final viewModel = await start(verbs.id);

    expect(viewModel.status, RecapSessionStatus.empty);
    expect(viewModel.total, 0);
  });

  test('reports a missing deck', () async {
    final viewModel = await start('missing');

    expect(viewModel.status, RecapSessionStatus.deckMissing);
    expect(viewModel.deck, isNull);
  });

  test('reports a deleted deck as missing', () async {
    final deck = await repos.createDeck(pack, 'All');
    await repos.decks.delete(deck.id);

    final viewModel = await start(deck.id);

    expect(viewModel.status, RecapSessionStatus.deckMissing);
  });

  test('reports a deck of another pack as missing', () async {
    final other = await repos.createPack('Other');
    final deck = await repos.createDeck(other, 'All');

    final viewModel = await start(deck.id);

    expect(viewModel.status, RecapSessionStatus.deckMissing);
  });

  group('direction', () {
    Future<Set<CardSide>> frontsFor(RecapDirection direction) async {
      final deck = await repos.createDeck(pack, direction.name);
      final viewModel = await start(deck.id, direction: direction);
      final fronts = <CardSide>{};
      while (viewModel.status == RecapSessionStatus.inProgress) {
        fronts.add(viewModel.current!.front);
        viewModel
          ..reveal()
          ..answer(knewIt: true);
      }
      return fronts;
    }

    test('foreign first', () async {
      expect(await frontsFor(RecapDirection.foreignFirst), {CardSide.foreign});
    });

    test('translation first', () async {
      expect(await frontsFor(RecapDirection.translationFirst), {
        CardSide.translation,
      });
    });

    test('mixed', () async {
      expect(await frontsFor(RecapDirection.mixed), {
        CardSide.foreign,
        CardSide.translation,
      });
    });

    test('is kept on restart', () async {
      final deck = await repos.createDeck(pack, 'All');
      final viewModel = await start(
        deck.id,
        direction: RecapDirection.translationFirst,
      );

      viewModel.restart();

      expect(viewModel.direction, RecapDirection.translationFirst);
      expect(viewModel.current!.front, CardSide.translation);
    });
  });
}
