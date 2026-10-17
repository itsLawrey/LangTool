import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/merge/deck_merge.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';

Deck _deck(String id, String name, List<DeckFilter> filters) => Deck(
  id: id,
  ownerId: 'user-1',
  packId: 'pack',
  name: name,
  filters: filters,
  createdAt: DateTime.utc(2026, 10, 1),
  updatedAt: DateTime.utc(2026, 10, 1),
);

void main() {
  const nouns = DeckFilter.wordTypes({WordType.noun});
  const nounsAndVerbs = DeckFilter.wordTypes({WordType.verb, WordType.noun});
  const lastWeek = DeckFilter.addedInLastDays(7);

  test('keeps the first of decks with the same name and filters', () {
    final decks = [
      _deck('a', 'Nouns', [nouns, lastWeek]),
      _deck('b', ' nouns', [lastWeek, nouns]),
      _deck('c', 'Nouns', [nouns]),
      _deck('d', 'Words', [nouns, lastWeek]),
      _deck('e', 'Mixed', [nounsAndVerbs]),
      _deck('f', 'Mixed', [
        const DeckFilter.wordTypes({WordType.noun, WordType.verb}),
      ]),
    ];

    expect(uniqueDecks(decks).map((d) => d.id), ['a', 'c', 'd', 'e']);
  });

  test('decks without filters repeat by name only', () {
    final decks = [_deck('a', 'All', []), _deck('b', 'All', [])];

    expect(uniqueDecks(decks).map((d) => d.id), ['a']);
  });
}
