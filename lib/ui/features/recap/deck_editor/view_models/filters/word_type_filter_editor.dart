import '../../../../../../domain/models/word_type.dart';
import '../../../../../../domain/recap/deck_filter.dart';
import 'filter_editor.dart';

/// Edits the filter on word types. No selected type means all types.
class WordTypeFilterEditor extends FilterEditor {
  /// [available] are the word types of the pack's language.
  WordTypeFilterEditor(Iterable<WordType> available)
    : _available = available.toSet();

  final Set<WordType> _available;
  final _selected = <WordType>{};
  bool _loaded = false;

  /// The selectable types: the language's, plus any selected type it lacks,
  /// so a loaded selection can still be cleared.
  List<WordType> get types => [
    for (final type in WordType.values)
      if (_available.contains(type) || _selected.contains(type)) type,
  ];

  bool isSelected(WordType type) => _selected.contains(type);

  @override
  DeckFilter? get filter =>
      _selected.isEmpty ? null : DeckFilter.wordTypes({..._selected});

  void setSelected(WordType type, bool selected) {
    final changed = selected ? _selected.add(type) : _selected.remove(type);
    if (changed) notifyListeners();
  }

  /// A filter without types matches nothing, so it is left to be kept
  /// unchanged rather than shown as "all types".
  @override
  bool load(DeckFilter filter) {
    if (_loaded) return false;
    if (filter case WordTypesFilter(:final types) when types.isNotEmpty) {
      _selected.addAll(types);
      _loaded = true;
      return true;
    }
    return false;
  }
}
