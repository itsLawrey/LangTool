import 'package:drift_flutter/drift_flutter.dart';

import 'app_database.dart';

/// Opens the app's on-device database.
///
/// On the web, SQLite runs from `web/sqlite3.wasm` in `web/drift_worker.js`.
/// Both come from the drift GitHub release matching the drift version in
/// `pubspec.lock`, and must be replaced together when drift is upgraded.
AppDatabase openAppDatabase() => AppDatabase(
  driftDatabase(
    name: 'langtool',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  ),
);
