import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../../data/repositories/deck_repository.dart';
import '../../../../../data/repositories/language_pack_repository.dart';
import '../../../../../domain/models/deck.dart';
import '../../../../../domain/models/language_pack.dart';
import '../../../../../domain/recap/deck_filter.dart';
import '../../../../../utils/result.dart';

/// The decks of a pack, each with its live number of matching entries.
class DecksViewModel extends ChangeNotifier {
  DecksViewModel({
    required DeckRepository deckRepository,
    required LanguagePackRepository packRepository,
    required this.packId,
  }) : _decks = deckRepository,
       _packs = packRepository {
    _loadPack();
    _decksSubscription = _decks.watchDecks(packId).listen(_onDecks);
  }

  final DeckRepository _decks;
  final LanguagePackRepository _packs;
  final String packId;
  late final StreamSubscription<List<Deck>> _decksSubscription;

  /// One match count subscription per deck, with the filters it counts.
  final _countSubscriptions =
      <String, (List<DeckFilter>, StreamSubscription<int>)>{};
  final _counts = <String, int>{};

  LanguagePack? _pack;
  bool _packMissing = false;
  List<Deck> _items = const [];
  bool _loading = true;

  LanguagePack? get pack => _pack;
  bool get packMissing => _packMissing;
  List<Deck> get decks => _items;
  bool get loading => _loading;

  /// The number of entries matching [deckId], or `null` while it is counted.
  int? countFor(String deckId) => _counts[deckId];

  Future<void> _loadPack() async {
    switch (await _packs.getPack(packId)) {
      case Ok(:final value):
        _pack = value;
      case Err():
        _packMissing = true;
    }
    notifyListeners();
  }

  void _onDecks(List<Deck> decks) {
    _items = decks;
    _loading = false;
    _syncCountSubscriptions(decks);
    notifyListeners();
  }

  /// Counts new decks, recounts decks whose filters changed and stops
  /// counting removed decks.
  void _syncCountSubscriptions(List<Deck> decks) {
    final ids = {for (final deck in decks) deck.id};
    for (final id in [..._countSubscriptions.keys]) {
      if (!ids.contains(id)) _stopCounting(id);
    }
    for (final deck in decks) {
      final current = _countSubscriptions[deck.id];
      if (current != null && listEquals(current.$1, deck.filters)) continue;
      _stopCounting(deck.id);
      final subscription = _decks.watchMatchCount(packId, deck.filters).listen((
        count,
      ) {
        _counts[deck.id] = count;
        notifyListeners();
      });
      _countSubscriptions[deck.id] = (deck.filters, subscription);
    }
  }

  void _stopCounting(String deckId) {
    _countSubscriptions.remove(deckId)?.$2.cancel();
    _counts.remove(deckId);
  }

  @override
  void dispose() {
    _decksSubscription.cancel();
    for (final (_, subscription) in _countSubscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }
}
