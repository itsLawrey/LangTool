import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../../data/repositories/deck_repository.dart';
import '../../../../../data/repositories/language_pack_repository.dart';
import '../../../../../domain/models/deck.dart';
import '../../../../../domain/recap/deck_filter.dart';
import '../../../../../utils/result.dart';

/// One deck and its live number of matching entries.
class DeckDetailViewModel extends ChangeNotifier {
  DeckDetailViewModel({
    required DeckRepository deckRepository,
    required LanguagePackRepository packRepository,
    required this.packId,
    required this.deckId,
  }) : _decks = deckRepository,
       _packs = packRepository {
    _loadPack();
    _deckSubscription = _decks.watchDeck(deckId).listen(_onDeck);
  }

  final DeckRepository _decks;
  final LanguagePackRepository _packs;
  final String packId;
  final String deckId;
  late final StreamSubscription<Deck?> _deckSubscription;
  StreamSubscription<int>? _countSubscription;
  List<DeckFilter>? _countedFilters;

  Deck? _deck;
  bool _loading = true;
  String? _languageCode;
  int? _count;

  Deck? get deck => _deck;
  bool get loading => _loading;

  /// The pack's language, or `null` until the pack is loaded.
  String? get languageCode => _languageCode;

  /// Matching entries, or `null` while they are counted.
  int? get count => _count;

  /// Whether a session can be started: the deck has entries and the pack's
  /// language is known.
  bool get canStart => (_count ?? 0) > 0 && _languageCode != null;

  Future<Result<void>> delete() => _decks.delete(deckId);

  Future<void> _loadPack() async {
    if (await _packs.getPack(packId) case Ok(:final value)) {
      _languageCode = value.languageCode;
      notifyListeners();
    }
  }

  void _onDeck(Deck? deck) {
    _deck = deck;
    _loading = false;
    if (deck == null) {
      _stopCounting();
    } else if (_countedFilters == null ||
        !listEquals(_countedFilters, deck.filters)) {
      _stopCounting();
      _countedFilters = deck.filters;
      _countSubscription = _decks.watchMatchCount(packId, deck.filters).listen((
        count,
      ) {
        _count = count;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void _stopCounting() {
    _countSubscription?.cancel();
    _countSubscription = null;
    _countedFilters = null;
    _count = null;
  }

  @override
  void dispose() {
    _deckSubscription.cancel();
    _countSubscription?.cancel();
    super.dispose();
  }
}
