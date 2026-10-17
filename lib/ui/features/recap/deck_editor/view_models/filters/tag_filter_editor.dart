import 'dart:async';

import '../../../../../../domain/recap/deck_filter.dart';
import '../../../../../../domain/search/text_normalizer.dart';
import 'filter_editor.dart';

/// Edits the filter on tags. No selected tag means any tags (or none).
///
/// Tags are told apart like the filter matches them, by [duplicateKey], so
/// `A1` and `a1` are one tag.
class TagFilterEditor extends FilterEditor {
  /// [available] emits the tags of the pack's entries.
  TagFilterEditor(Stream<List<String>> available) {
    _subscription = available.listen((tags) {
      _available = tags;
      notifyListeners();
    });
  }

  late final StreamSubscription<List<String>> _subscription;
  List<String>? _available;

  /// Selected tags by key, as spelled when selected.
  final _selected = <String, String>{};
  TagMatch _match = TagMatch.any;
  bool _loaded = false;

  /// Whether the pack's tags have been read.
  bool get ready => _available != null;

  /// The selectable tags: the pack's, plus any selected tag it no longer
  /// has, so a loaded selection can still be cleared. Sorted ignoring case.
  List<String> get tags {
    final byKey = {
      for (final tag in _available ?? const <String>[]) duplicateKey(tag): tag,
    };
    _selected.forEach((key, tag) => byKey.putIfAbsent(key, () => tag));
    return byKey.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  bool isSelected(String tag) => _selected.containsKey(duplicateKey(tag));

  /// How many tags are selected.
  int get selectedCount => _selected.length;

  TagMatch get match => _match;

  @override
  DeckFilter? get filter =>
      _selected.isEmpty ? null : DeckFilter.tags({..._selected.values}, _match);

  void setSelected(String tag, bool selected) {
    final key = duplicateKey(tag);
    if (selected == _selected.containsKey(key)) return;
    if (selected) {
      _selected[key] = tag;
    } else {
      _selected.remove(key);
    }
    notifyListeners();
  }

  void setMatch(TagMatch match) {
    if (match == _match) return;
    _match = match;
    notifyListeners();
  }

  /// A filter without tags matches nothing, so it is left to be kept
  /// unchanged rather than shown as "any tags".
  @override
  bool load(DeckFilter filter) {
    if (_loaded) return false;
    if (filter case TagsFilter(:final tags, :final match)
        when tags.isNotEmpty) {
      for (final tag in tags) {
        _selected.putIfAbsent(duplicateKey(tag), () => tag);
      }
      _match = match;
      _loaded = true;
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
