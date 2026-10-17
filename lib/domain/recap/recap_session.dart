import 'dart:math';

import '../models/entry.dart';

/// Which side of each card is shown first.
enum RecapDirection {
  /// The foreign word (e.g. German) first; recall the translation.
  foreignFirst,

  /// A translation first; recall the foreign word.
  translationFirst,

  /// Randomly chosen per card.
  mixed,
}

/// The side of a card shown before it is revealed.
enum CardSide { foreign, translation }

/// One card of a session: an entry and the side shown first.
final class RecapCard {
  const RecapCard(this.entry, this.front);

  final Entry entry;
  final CardSide front;
}

/// A recap session over a fixed set of entries, in random order. For each
/// card the user recalls the hidden side, reveals it, then answers whether
/// they knew it. Nothing is persisted.
class RecapSession {
  /// Entries without translations are always shown foreign side first,
  /// since there is nothing to show on the translation side.
  RecapSession({
    required List<Entry> entries,
    required this.direction,
    Random? random,
  }) : _cards = _deal(entries, direction, random ?? Random());

  final RecapDirection direction;
  final List<RecapCard> _cards;
  final _knew = <Entry>[];
  final _missed = <Entry>[];
  var _index = 0;
  var _revealed = false;

  int get total => _cards.length;

  /// Zero-based index of the current card; [total] once finished.
  int get position => _index;

  bool get isFinished => _index >= _cards.length;

  /// The card being practised, or `null` once finished.
  RecapCard? get current => isFinished ? null : _cards[_index];

  /// Whether the hidden side of [current] is shown.
  bool get revealed => _revealed;

  int get knownCount => _knew.length;
  int get unknownCount => _missed.length;

  /// Entries answered with "didn't know", in session order.
  List<Entry> get missed => List.unmodifiable(_missed);

  void reveal() {
    if (!isFinished) _revealed = true;
  }

  /// Records the answer for [current] and moves to the next card. Only
  /// allowed after [reveal].
  void answer({required bool knewIt}) {
    final card = current;
    if (card == null) throw StateError('The session is finished.');
    if (!_revealed) throw StateError('Reveal the card before answering.');
    (knewIt ? _knew : _missed).add(card.entry);
    _index++;
    _revealed = false;
  }
}

List<RecapCard> _deal(
  List<Entry> entries,
  RecapDirection direction,
  Random random,
) {
  final shuffled = [...entries]..shuffle(random);
  return [
    for (final entry in shuffled)
      RecapCard(entry, switch (direction) {
        _ when entry.translations.isEmpty => CardSide.foreign,
        RecapDirection.foreignFirst => CardSide.foreign,
        RecapDirection.translationFirst => CardSide.translation,
        RecapDirection.mixed =>
          random.nextBool() ? CardSide.foreign : CardSide.translation,
      }),
  ];
}
