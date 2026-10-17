import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/deck_repository.dart';
import '../../../../data/repositories/language_pack_repository.dart';
import '../../../../domain/languages/language_registry.dart';
import '../../../../domain/languages/language_schema.dart';
import '../../../../domain/models/deck.dart';
import '../../../../domain/models/entry.dart';
import '../../../../domain/recap/recap_session.dart';
import '../../../../utils/result.dart';

enum RecapSessionStatus { loading, deckMissing, empty, inProgress, finished }

/// A recap session over a deck. The deck's matching entries are loaded once
/// when the session starts and stay fixed for its duration.
class RecapSessionViewModel extends ChangeNotifier {
  RecapSessionViewModel({
    required DeckRepository deckRepository,
    required LanguagePackRepository packRepository,
    required this.packId,
    required this.deckId,
    required this.direction,
    Random? random,
  }) : _decks = deckRepository,
       _packs = packRepository,
       _random = random ?? Random() {
    _load();
  }

  final DeckRepository _decks;
  final LanguagePackRepository _packs;
  final Random _random;
  final String packId;
  final String deckId;
  final RecapDirection direction;

  var _loading = true;
  var _disposed = false;
  Deck? _deck;
  LanguageSchema? _schema;
  var _entries = const <Entry>[];
  RecapSession? _session;

  RecapSessionStatus get status => switch (_session) {
    _ when _loading => RecapSessionStatus.loading,
    _ when _deck == null => RecapSessionStatus.deckMissing,
    _ when _entries.isEmpty => RecapSessionStatus.empty,
    RecapSession(isFinished: true) => RecapSessionStatus.finished,
    _ => RecapSessionStatus.inProgress,
  };

  Deck? get deck => _deck;

  /// Schema of the pack's language, for form labels; `null` if unsupported.
  LanguageSchema? get schema => _schema;

  RecapCard? get current => _session?.current;
  bool get revealed => _session?.revealed ?? false;

  /// Zero-based index of the current card; [total] once finished.
  int get position => _session?.position ?? 0;
  int get total => _session?.total ?? 0;
  int get knownCount => _session?.knownCount ?? 0;
  int get unknownCount => _session?.unknownCount ?? 0;

  void reveal() {
    _session?.reveal();
    notifyListeners();
  }

  /// Records the answer for the current card and moves to the next one.
  void answer({required bool knewIt}) {
    _session?.answer(knewIt: knewIt);
    notifyListeners();
  }

  /// Starts a new, reshuffled session over the same entries and direction.
  void restart() {
    if (_deck == null || _entries.isEmpty) return;
    _session = _newSession();
    notifyListeners();
  }

  RecapSession _newSession() =>
      RecapSession(entries: _entries, direction: direction, random: _random);

  Future<void> _load() async {
    if (await _packs.getPack(packId) case Ok(:final value)) {
      _schema = languageSchemaFor(value.languageCode);
    }
    if (await _decks.getDeck(deckId) case Ok(:final value)
        when value.packId == packId) {
      _deck = value;
      _entries = await _decks.matchingEntries(packId, value.filters);
      _session = _newSession();
    }
    _loading = false;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
