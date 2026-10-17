import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/entry.dart';

/// Watches a live, newest-first entry query page by page. Starts with
/// [pageSize] entries and grows the limit by [pageSize] on [loadMore].
/// Calls [onChanged] whenever new entries arrive.
class PagedEntries {
  PagedEntries(this._watch, {required this.pageSize, required this.onChanged})
    : _limit = pageSize {
    _subscribe();
  }

  /// Watches at most `limit` entries.
  final Stream<List<Entry>> Function(int limit) _watch;
  final int pageSize;
  final VoidCallback onChanged;

  int _limit;
  StreamSubscription<List<Entry>>? _subscription;
  List<Entry>? _entries;

  /// Whether the first page has arrived.
  bool get loaded => _entries != null;

  List<Entry> get entries => _entries ?? const [];

  /// Whether older entries may exist beyond the loaded ones.
  bool get hasMore => entries.length >= _limit;

  /// Loads the next page of older entries.
  void loadMore() {
    if (!hasMore) return;
    _limit += pageSize;
    _subscribe();
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = _watch(_limit).listen((entries) {
      _entries = entries;
      onChanged();
    });
  }

  void dispose() => _subscription?.cancel();
}
