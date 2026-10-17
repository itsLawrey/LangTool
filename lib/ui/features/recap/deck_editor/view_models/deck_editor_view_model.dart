import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../../data/repositories/deck_repository.dart';
import '../../../../../data/repositories/language_pack_repository.dart';
import '../../../../../domain/languages/language_registry.dart';
import '../../../../../domain/languages/language_schema.dart';
import '../../../../../domain/models/deck.dart';
import '../../../../../domain/models/deck_draft.dart';
import '../../../../../domain/recap/deck_filter.dart';
import '../../../../../utils/clock.dart';
import '../../../../../utils/result.dart';
import 'filters/added_filter_editor.dart';
import 'filters/filter_editor.dart';
import 'filters/tag_filter_editor.dart';
import 'filters/word_type_filter_editor.dart';

/// Creates a deck in a pack, or edits [deckId] if given. Holds one
/// [FilterEditor] per filter kind and keeps a live count of the entries the
/// current filters match.
class DeckEditorViewModel extends ChangeNotifier {
  /// `now` gives today's date for the date presets.
  DeckEditorViewModel({
    required DeckRepository deckRepository,
    required LanguagePackRepository packRepository,
    required this.packId,
    this.deckId,
    this._now = DateTime.now,
  }) : _decks = deckRepository,
       _packs = packRepository {
    _load();
  }

  final DeckRepository _decks;
  final LanguagePackRepository _packs;
  final String packId;
  final String? deckId;
  final Clock _now;

  bool _disposed = false;
  bool _loading = true;
  bool _saving = false;
  LanguageSchema? _schema;
  Deck? _initial;
  List<FilterEditor> _editors = const [];
  List<DeckFilter> _kept = const [];

  StreamSubscription<int>? _countSubscription;
  List<DeckFilter>? _countedFilters;
  int? _count;

  late final AddedFilterEditor added;
  late final WordTypeFilterEditor wordTypes;
  late final TagFilterEditor tags;

  bool get isEditing => deckId != null;
  bool get loading => _loading;
  bool get saving => _saving;

  /// The deck being edited, or `null` when creating.
  Deck? get initial => _initial;

  /// Whether the pack (or the edited deck) could not be loaded.
  bool get missing =>
      !_loading && (_schema == null || isEditing && _initial == null);

  /// Filters of the edited deck that no editor handles, such as ones from a
  /// newer app version. They are saved unchanged.
  List<DeckFilter> get keptFilters => _kept;

  /// The deck's filters for the current input.
  List<DeckFilter> get filters => [
    for (final editor in _editors) ?editor.filter,
    ..._kept,
  ];

  bool get filtersValid => _editors.every((editor) => editor.isValid);

  /// Entries matching [filters], or `null` while counting or while the input
  /// is invalid.
  int? get count => _count;

  bool get canSave => !_loading && !_saving && filtersValid;

  /// Saves the deck with [name] and the current filters.
  Future<Result<Deck>> save(String name) async {
    _saving = true;
    notifyListeners();

    final initial = _initial;
    final result = initial == null
        ? await _decks.create(
            DeckDraft(packId: packId, name: name, filters: filters),
          )
        : await _decks.update(initial.copyWith(name: name, filters: filters));

    _saving = false;
    if (!_disposed) notifyListeners();
    return result;
  }

  Future<void> _load() async {
    if (await _packs.getPack(packId) case Ok(:final value)) {
      _schema = languageSchemaFor(value.languageCode);
    }
    if (deckId case final id?) {
      if (await _decks.getDeck(id) case Ok(:final value)) _initial = value;
    }
    if (_disposed) return;

    added = AddedFilterEditor(now: _now);
    wordTypes = WordTypeFilterEditor(_schema?.wordTypes.keys ?? const []);
    tags = TagFilterEditor(_decks.watchTags(packId));
    _editors = [added, wordTypes, tags];
    _kept = [
      for (final filter in _initial?.filters ?? const <DeckFilter>[])
        if (!_editors.any((editor) => editor.load(filter))) filter,
    ];
    for (final editor in _editors) {
      editor.addListener(_onFiltersChanged);
    }

    _loading = false;
    _recount();
    notifyListeners();
  }

  void _onFiltersChanged() {
    _recount();
    notifyListeners();
  }

  /// Counts the matches of the current filters, unless they are unchanged.
  void _recount() {
    if (!filtersValid) {
      _stopCounting();
      return;
    }
    final filters = this.filters;
    if (_countedFilters != null && listEquals(_countedFilters, filters)) return;
    _stopCounting();
    _countedFilters = filters;
    _countSubscription = _decks.watchMatchCount(packId, filters).listen((
      count,
    ) {
      _count = count;
      notifyListeners();
    });
  }

  void _stopCounting() {
    _countSubscription?.cancel();
    _countSubscription = null;
    _countedFilters = null;
    _count = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _countSubscription?.cancel();
    for (final editor in _editors) {
      editor.dispose();
    }
    super.dispose();
  }
}
