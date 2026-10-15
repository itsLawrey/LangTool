import 'package:flutter/foundation.dart';

import '../../../../data/repositories/entry_repository.dart';
import '../../../../data/repositories/language_pack_repository.dart';
import '../../../../domain/languages/language_registry.dart';
import '../../../../domain/languages/language_schema.dart';
import '../../../../domain/models/entry.dart';
import '../../../../domain/models/entry_draft.dart';
import '../../../../domain/models/word_type.dart';
import '../../../../domain/search/text_normalizer.dart';
import '../../../../utils/result.dart';

/// Adds a new entry to a pack, or edits [entryId] if given.
class EntryFormViewModel extends ChangeNotifier {
  EntryFormViewModel({
    required EntryRepository entryRepository,
    required LanguagePackRepository packRepository,
    required this.packId,
    this.entryId,
  }) : _entries = entryRepository,
       _packs = packRepository {
    _load();
  }

  final EntryRepository _entries;
  final LanguagePackRepository _packs;
  final String packId;
  final String? entryId;

  bool _loading = true;
  bool _saving = false;
  LanguageSchema? _schema;
  Entry? _initial;

  bool get isEditing => entryId != null;
  bool get loading => _loading;
  bool get saving => _saving;
  LanguageSchema? get schema => _schema;

  /// The entry being edited, or `null` when adding.
  Entry? get initial => _initial;

  /// Whether the pack (or the edited entry) could not be loaded.
  bool get missing =>
      !_loading && (_schema == null || isEditing && _initial == null);

  /// Existing entries the user may be about to duplicate. Skipped when an
  /// edit keeps the term and word type unchanged.
  Future<List<Entry>> findSimilar(String term, WordType wordType) async {
    final initial = _initial;
    if (initial != null &&
        initial.wordType == wordType &&
        duplicateKey(initial.term) == duplicateKey(term)) {
      return const [];
    }
    return _entries.findSimilar(packId, term, wordType, excludeId: entryId);
  }

  /// Saves [draft]. Its `packId` is ignored in favour of [packId].
  Future<Result<Entry>> save(EntryDraft draft) async {
    _saving = true;
    notifyListeners();

    final initial = _initial;
    final result = initial == null
        ? await _entries.add(draft.copyWith(packId: packId))
        : await _entries.update(
            initial.copyWith(
              wordType: draft.wordType,
              term: draft.term,
              forms: draft.forms,
              translations: draft.translations,
              examples: draft.examples,
              tags: draft.tags,
              notes: draft.notes,
            ),
          );

    _saving = false;
    notifyListeners();
    return result;
  }

  Future<void> _load() async {
    if (await _packs.getPack(packId) case Ok(:final value)) {
      _schema = languageSchemaFor(value.languageCode);
    }
    if (entryId case final id?) {
      if (await _entries.getEntry(id) case Ok(:final value)) _initial = value;
    }
    _loading = false;
    notifyListeners();
  }
}
