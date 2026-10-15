import 'package:uuid/uuid.dart';

/// Returns the current time. Injected so tests are deterministic.
typedef Clock = DateTime Function();

/// Returns a new unique id. Injected so tests are deterministic.
typedef IdGenerator = String Function();

DateTime systemClockUtc() => DateTime.now().toUtc();

/// UUID v7: time-ordered, so new rows are appended to the primary key index.
String uuidV7() => const Uuid().v7();
