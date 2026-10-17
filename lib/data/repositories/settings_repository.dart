import 'package:flutter/foundation.dart';

import '../services/settings_store.dart';

/// Options stored on this device only. They are not synced.
class SettingsRepository extends ChangeNotifier {
  SettingsRepository(this._store)
    : _commaTranslations = _store.getBool(commaTranslationsKey) ?? false,
      _quickAddMode = _store.getBool(quickAddModeKey) ?? false;

  static const commaTranslationsKey = 'comma_translations';
  static const quickAddModeKey = 'quick_add_mode';

  /// The keys of all options, e.g. to limit what a store loads.
  static const keys = {commaTranslationsKey, quickAddModeKey};

  final SettingsStore _store;
  bool _commaTranslations;
  bool _quickAddMode;

  /// Whether the entry form takes all translations in one comma-separated
  /// field.
  bool get commaTranslations => _commaTranslations;

  /// Whether Ctrl+Enter in the entry form saves (and, for a new entry,
  /// starts the next one).
  bool get quickAddMode => _quickAddMode;

  Future<void> setCommaTranslations(bool value) async {
    _commaTranslations = value;
    notifyListeners();
    await _store.setBool(commaTranslationsKey, value);
  }

  Future<void> setQuickAddMode(bool value) async {
    _quickAddMode = value;
    notifyListeners();
    await _store.setBool(quickAddModeKey, value);
  }
}
