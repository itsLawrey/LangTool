import 'package:shared_preferences/shared_preferences.dart';

import 'settings_store.dart';

/// A [SettingsStore] backed by the platform's shared preferences. Reads come
/// from a cache loaded once by [create].
class SharedPreferencesSettingsStore implements SettingsStore {
  SharedPreferencesSettingsStore._(this._preferences);

  /// Loads the stored values of the keys in [allowList].
  static Future<SharedPreferencesSettingsStore> create({
    required Set<String> allowList,
  }) async => SharedPreferencesSettingsStore._(
    await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(allowList: allowList),
    ),
  );

  final SharedPreferencesWithCache _preferences;

  @override
  bool? getBool(String key) => _preferences.getBool(key);

  @override
  Future<void> setBool(String key, bool value) =>
      _preferences.setBool(key, value);
}
