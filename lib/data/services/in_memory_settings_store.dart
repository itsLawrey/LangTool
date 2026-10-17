import 'settings_store.dart';

/// A [SettingsStore] that forgets everything when the app closes. Used in
/// tests and when no persistent store is given.
class InMemorySettingsStore implements SettingsStore {
  InMemorySettingsStore([Map<String, bool> values = const {}])
    : _values = {...values};

  final Map<String, bool> _values;

  @override
  bool? getBool(String key) => _values[key];

  @override
  Future<void> setBool(String key, bool value) async => _values[key] = value;
}
