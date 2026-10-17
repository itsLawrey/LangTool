import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/entry_repository.dart';
import '../../../../data/repositories/language_pack_repository.dart';
import '../../../../domain/languages/language_registry.dart';
import '../../../../domain/languages/language_schema.dart';
import '../../../../domain/models/entry.dart';
import '../../../../utils/result.dart';

/// One entry, kept up to date when it is edited.
class EntryDetailViewModel extends ChangeNotifier {
  EntryDetailViewModel({
    required EntryRepository entryRepository,
    required LanguagePackRepository packRepository,
    required this.packId,
    required this.entryId,
  }) : _entries = entryRepository,
       _packs = packRepository {
    _load();
    _changes = _entries.watchChanges().listen((_) => _load());
  }

  final EntryRepository _entries;
  final LanguagePackRepository _packs;
  final String packId;
  final String entryId;
  late final StreamSubscription<void> _changes;

  Entry? _entry;
  LanguageSchema? _schema;
  bool _loading = true;

  Entry? get entry => _entry;
  LanguageSchema? get schema => _schema;
  bool get loading => _loading;

  Future<void> _load() async {
    if (_schema == null) {
      if (await _packs.getPack(packId) case Ok(:final value)) {
        _schema = languageSchemaFor(value.languageCode);
      }
    }
    _entry = switch (await _entries.getEntry(entryId)) {
      Ok(:final value) => value,
      Err() => null,
    };
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _changes.cancel();
    super.dispose();
  }
}
