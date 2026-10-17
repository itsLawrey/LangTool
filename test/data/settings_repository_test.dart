import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/data/repositories/settings_repository.dart';
import 'package:langtool/data/services/in_memory_settings_store.dart';

void main() {
  test('options are off by default', () {
    final settings = SettingsRepository(InMemorySettingsStore());

    expect(settings.commaTranslations, isFalse);
    expect(settings.quickAddMode, isFalse);
  });

  test('reads stored options', () {
    final settings = SettingsRepository(
      InMemorySettingsStore({
        SettingsRepository.commaTranslationsKey: true,
        SettingsRepository.quickAddModeKey: true,
      }),
    );

    expect(settings.commaTranslations, isTrue);
    expect(settings.quickAddMode, isTrue);
  });

  test('changes are stored and notified', () async {
    final store = InMemorySettingsStore();
    final settings = SettingsRepository(store);
    var notified = 0;
    settings.addListener(() => notified++);

    await settings.setCommaTranslations(true);
    await settings.setQuickAddMode(true);

    expect(settings.commaTranslations, isTrue);
    expect(settings.quickAddMode, isTrue);
    expect(notified, 2);
    expect(store.getBool(SettingsRepository.commaTranslationsKey), isTrue);
    expect(store.getBool(SettingsRepository.quickAddModeKey), isTrue);

    // Another repository over the same store, e.g. after a restart.
    final reopened = SettingsRepository(store);
    expect(reopened.commaTranslations, isTrue);
    expect(reopened.quickAddMode, isTrue);

    await settings.setQuickAddMode(false);
    expect(SettingsRepository(store).quickAddMode, isFalse);
  });
}
