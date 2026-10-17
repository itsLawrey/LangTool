/// Key-value storage for options kept on this device only (not synced).
abstract interface class SettingsStore {
  /// The stored value of [key], or `null` if none was stored.
  bool? getBool(String key);

  Future<void> setBool(String key, bool value);
}
