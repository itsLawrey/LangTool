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
import '../../../core/paged_entries.dart';
import '../../../core/timeline_items.dart';

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
       _packs = packRepository {
    _loadPack();
    _timeline = PagedEntries(
      (limit) => _entries.watchTimeline(packId, limit: limit),
      pageSize: pageSize,
      onChanged: () {
        if (!isSearching) _rebuild();
      },
    );
    _changes = _entries.watchChanges().listen((_) {
      if (_query.isNotEmpty) _runSearch();
    });
  }

  final EntryRepository _entries;
  final LanguagePackRepository _packs;
  final String packId;
  final int pageSize;
  final Duration searchDebounce;

  late final PagedEntries _timeline;
  late final StreamSubscription<void> _changes;
  Timer? _debounce;

  LanguagePack? _pack;
  bool _packMissing = false;

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

  bool get loading => isSearching ? _hits == null : !_timeline.loaded;

  /// Whether older entries may exist beyond the loaded ones.
  bool get hasMore => !isSearching && _timeline.hasMore;

  /// Loads the next page of older entries.
  void loadMore() {
    if (!isSearching) _timeline.loadMore();
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
        : buildTimeline(_timeline.entries);
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _timeline.dispose();
    _changes.cancel();
    super.dispose();
  }
}
