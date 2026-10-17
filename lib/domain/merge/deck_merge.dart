import '../models/deck.dart';
import '../search/text_normalizer.dart';

/// [decks] without repeats: decks with the same name (compared with
/// [duplicateKey]) and the same filters, in any order, are kept once, as the
/// first of them.
List<Deck> uniqueDecks(List<Deck> decks) {
  final kept = <Deck>[];
  for (final deck in decks) {
    final filters = deck.filters.toSet();
    final repeat = kept.any(
      (other) =>
          duplicateKey(other.name) == duplicateKey(deck.name) &&
          other.filters.length == deck.filters.length &&
          filters.containsAll(other.filters) &&
          other.filters.toSet().containsAll(filters),
    );
    if (!repeat) kept.add(deck);
  }
  return kept;
}
