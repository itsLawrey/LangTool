import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../../data/repositories/deck_repository.dart';
import '../../../../../data/repositories/language_pack_repository.dart';
import '../../../../../domain/languages/language_registry.dart';
import '../../../../../domain/languages/language_schema.dart';
import '../../../../../domain/models/deck.dart';
import '../../../../../domain/recap/deck_filter.dart';
import '../../../../../utils/result.dart';
import '../../../../core/paged_entries.dart';
import '../../../../core/timeline_items.dart';

/// One deck, its live number of matching entries and the matching entries
/// as a day-grouped timeline, newest first, [pageSize] at a time.
class DeckDetailViewModel extends ChangeNotifier {
  DeckDetailViewModel({
    required DeckRepository deckRepository,
    required LanguagePackRepository packRepository,
    required this.packId,
    required this.deckId,
    this.pageSize = 50,
  }) : _decks = deckRepository,
       _packs = packRepository {
    _loadPack();
    _deckSubscription = _decks.watchDeck(deckId).listen(_onDeck);
  }

  final DeckRepository _decks;
  final LanguagePackRepository _packs;
  final String packId;
  final String deckId;
  final int pageSize;
  late final StreamSubscription<Deck?> _deckSubscription;
  StreamSubscription<int>? _countSubscription;
  PagedEntries? _entries;
  List<DeckFilter>? _watchedFilters;

  Deck? _deck;
  bool _loading = true;
  String? _languageCode;
  int? _count;
  List<TimelineItem> _items = const [];

  Deck? get deck => _deck;
  bool get loading => _loading;

  /// The pack's language, or `null` until the pack is loaded.
  String? get languageCode => _languageCode;

  LanguageSchema? get schema =>
      _languageCode == null ? null : languageSchemaFor(_languageCode!);

  /// Matching entries, or `null` while they are counted.
  int? get count => _count;

  /// The loaded matching entries with day headers.
  List<TimelineItem> get items => _items;

  /// Whether older matching entries may exist beyond the loaded ones.
  bool get hasMore => _entries?.hasMore ?? false;

  /// Loads the next page of older matching entries.
  void loadMore() => _entries?.loadMore();

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
      _stopWatching();
      _items = const [];
    } else if (_watchedFilters == null ||
        !listEquals(_watchedFilters, deck.filters)) {
      _watch(deck.filters);
    }
    notifyListeners();
  }

  /// Follows the count and entries matching [filters]. The previous
  /// entries stay shown until the new ones arrive.
  void _watch(List<DeckFilter> filters) {
    _stopWatching();
    _watchedFilters = filters;
    _countSubscription = _decks.watchMatchCount(packId, filters).listen((
      count,
    ) {
      _count = count;
      notifyListeners();
    });
    _entries = PagedEntries(
      (limit) => _decks.watchMatchingEntries(packId, filters, limit: limit),
      pageSize: pageSize,
      onChanged: () {
        _items = buildTimeline(_entries!.entries);
        notifyListeners();
      },
    );
  }

  void _stopWatching() {
    _countSubscription?.cancel();
    _countSubscription = null;
    _entries?.dispose();
    _entries = null;
    _watchedFilters = null;
    _count = null;
  }

  @override
  void dispose() {
    _deckSubscription.cancel();
    _stopWatching();
    super.dispose();
  }
}
