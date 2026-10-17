import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/entry_draft.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/domain/recap/recap_session.dart';

import '../helpers/test_repositories.dart';

/// Proves that a recap session's card order is uniformly random whatever
/// filters chose its entries: the deck query returns them oldest first, and
/// the session shuffles that list.
void main() {
  late TestRepositories repos;

  setUp(() => repos = TestRepositories());
  tearDown(() => repos.close());

  final filters = <String, List<DeckFilter>>{
    'no filter': const [],
    'word types': const [
      DeckFilter.wordTypes({WordType.noun}),
    ],
    'added between': [
      DeckFilter.addedBetween(
        from: DateTime(2026, 10, 14),
        to: DateTime(2026, 10, 16),
      ),
    ],
    'added in the last days': const [DeckFilter.addedInLastDays(7)],
    'combined': [
      const DeckFilter.wordTypes({WordType.noun}),
      const DeckFilter.addedInLastDays(30),
    ],
  };

  for (final MapEntry(key: name, value: deckFilters) in filters.entries) {
    test('every order is equally likely with $name', () async {
      final pack = await repos.createPack();
      for (final term in ['Haus', 'Baum', 'Tisch']) {
        await repos.addNoun(pack, term);
      }
      if (deckFilters.isEmpty) {
        await repos.entries.add(
          EntryDraft(packId: pack.id, wordType: WordType.verb, term: 'gehen'),
        );
      }
      final entries = await repos.decks.matchingEntries(pack.id, deckFilters);
      final queried = [for (final e in entries) e.term];
      expect(queried.length, deckFilters.isEmpty ? 4 : 3);

      // Many sessions over the same entries, like starting the deck again
      // and again. Seeded, so the test is deterministic.
      final random = Random(2026);
      final permutations = _factorial(entries.length);
      final sessions = permutations * 1000;
      final orders = <String, int>{};
      final firsts = <String, int>{};
      for (var i = 0; i < sessions; i++) {
        final session = RecapSession(
          entries: entries,
          direction: RecapDirection.foreignFirst,
          random: random,
        );
        final order = <String>[];
        while (!session.isFinished) {
          order.add(session.current!.entry.term);
          session.reveal();
          session.answer(knewIt: true);
        }
        expect(order, unorderedEquals(queried));
        orders.update(order.join(','), (n) => n + 1, ifAbsent: () => 1);
        firsts.update(order.first, (n) => n + 1, ifAbsent: () => 1);
      }

      // Every possible order shows up about equally often (within 15 % of
      // the expected count), the query's own order included.
      expect(orders, hasLength(permutations));
      expect(orders, contains(queried.join(',')));
      for (final count in orders.values) {
        expect(count, closeTo(1000, 150));
      }
      // Each entry starts the session about equally often.
      for (final term in queried) {
        expect(
          firsts[term],
          closeTo(sessions / entries.length, 0.1 * sessions / entries.length),
        );
      }
    });
  }
}

int _factorial(int n) => n <= 1 ? 1 : n * _factorial(n - 1);
