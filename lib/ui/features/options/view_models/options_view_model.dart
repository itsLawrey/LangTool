import 'package:flutter/foundation.dart';

import '../../../../data/repositories/settings_repository.dart';

/// Shows and changes this device's options.
class OptionsViewModel extends ChangeNotifier {
  OptionsViewModel({required SettingsRepository settingsRepository})
    : _settings = settingsRepository {
    _settings.addListener(notifyListeners);
  }

  final SettingsRepository _settings;

  bool get commaTranslations => _settings.commaTranslations;
  bool get quickAddMode => _settings.quickAddMode;

  Future<void> setCommaTranslations(bool value) =>
      _settings.setCommaTranslations(value);

  Future<void> setQuickAddMode(bool value) => _settings.setQuickAddMode(value);

  @override
  void dispose() {
    _settings.removeListener(notifyListeners);
    super.dispose();
  }
}
