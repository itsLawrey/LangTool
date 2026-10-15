import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/entry_repository.dart';
import '../../../../data/repositories/language_pack_repository.dart';
import '../../../../domain/languages/language_registry.dart';
import '../../../../domain/languages/language_schema.dart';
import '../../../../domain/models/entry.dart';
import '../../../../domain/models/language_pack.dart';
import '../../../../domain/search/search_result.dart';
import '../../../../utils/result.dart';
import 'timeline_items.dart';

/// The entries of a pack as a day-grouped timeline, newest first. Loads
/// [pageSize] entries at a time. While a search query is set, the matching
/// entries are shown instead, best match first and without day headers.
class TimelineViewModel extends ChangeNotifier {
  TimelineViewModel({
    required EntryRepository entryRepository,
    required LanguagePackRepository packRepository,
    required this.packId,
    this.pageSize = 50,
    this.searchDebounce = const Duration(milliseconds: 250),
  }) : _entries = entryRepository,
       _packs = packRepository,
       _limit = pageSize {
    _loadPack();
    _watchTimeline();
    _changes = _entries.watchChanges().listen((_) {
      if (_query.isNotEmpty) _runSearch();
    });
  }

  final EntryRepository _entries;
  final LanguagePackRepository _packs;
  final String packId;
  final int pageSize;
  final Duration searchDebounce;

  StreamSubscription<List<Entry>>? _timeline;
  late final StreamSubscription<void> _changes;
  Timer? _debounce;

  LanguagePack? _pack;
  bool _packMissing = false;
  int _limit;
  bool _timelineLoaded = false;
  List<Entry> _timelineEntries = const [];

  String _query = '';
  List<Entry>? _hits;
  bool _hitsAreSimilar = false;

  List<TimelineItem> _items = const [];

  LanguagePack? get pack => _pack;
  LanguageSchema? get schema =>
      _pack == null ? null : languageSchemaFor(_pack!.languageCode);
  bool get packMissing => _packMissing;

  List<TimelineItem> get items => _items;
  String get query => _query;
  bool get isSearching => _query.isNotEmpty;

  /// Whether the search found no direct matches and shows typo-tolerant
  /// matches instead.
  bool get showingSimilar => isSearching && _hitsAreSimilar;

  bool get loading => isSearching ? _hits == null : !_timelineLoaded;

  /// Whether older entries may exist beyond the loaded ones.
  bool get hasMore => !isSearching && _timelineEntries.length >= _limit;

  /// Loads the next page of older entries.
  void loadMore() {
    if (!hasMore) return;
    _limit += pageSize;
    _watchTimeline();
  }

  void search(String text) {
    final query = text.trim();
    if (query == _query) return;
    _query = query;
    _debounce?.cancel();
    _hits = null;
    _hitsAreSimilar = false;
    if (query.isEmpty) {
      _rebuild();
    } else {
      notifyListeners();
      _debounce = Timer(searchDebounce, _runSearch);
    }
  }

  Future<void> _loadPack() async {
    switch (await _packs.getPack(packId)) {
      case Ok(:final value):
        _pack = value;
      case Err():
        _packMissing = true;
    }
    notifyListeners();
  }

  void _watchTimeline() {
    _timeline?.cancel();
    _timeline = _entries.watchTimeline(packId, limit: _limit).listen((entries) {
      _timelineEntries = entries;
      _timelineLoaded = true;
      if (!isSearching) _rebuild();
    });
  }

  Future<void> _runSearch() async {
    final query = _query;
    final results = await _entries.search(packId, query);
    if (query != _query) return;

    _hits = [for (final result in results) result.entry];
    _hitsAreSimilar =
        results.isNotEmpty && results.first.match.kind == MatchKind.fuzzy;
    _rebuild();
  }

  void _rebuild() {
    _items = isSearching
        ? [for (final entry in _hits ?? const <Entry>[]) EntryItem(entry)]
        : buildTimeline(_timelineEntries);
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _timeline?.cancel();
    _changes.cancel();
    super.dispose();
  }
}
