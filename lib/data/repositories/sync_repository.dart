import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/app_database.dart';
import '../local/sync_store.dart';
import 'auth_repository.dart';
import 'sync_engine.dart';

enum SyncPhase { idle, syncing, offline, failed }

/// Keeps the signed-in account in sync with the cloud and reports progress.
///
/// Syncs when an account signs in, [debounce] after local edits, every
/// [interval], and when [sync] is called (e.g. by a button or on app resume).
/// Only one sync runs at a time; requests during a sync run it once more.
class SyncRepository extends ChangeNotifier {
  SyncRepository({
    required this._engine,
    required this._store,
    required this._auth,
    required AppDatabase database,
    this.debounce = const Duration(seconds: 3),
    this.interval = const Duration(minutes: 5),
  }) {
    _auth.addListener(_onAuthChanged);
    _localChanges = database
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            database.languagePacks,
            database.entries,
          ]),
        )
        .listen((_) => _onLocalChange());
    _onAuthChanged();
  }

  final SyncEngine _engine;
  final LocalSyncStore _store;
  final AuthRepository _auth;
  final Duration debounce;
  final Duration interval;

  late final StreamSubscription<void> _localChanges;
  Timer? _debounceTimer;
  Timer? _intervalTimer;

  String? _ownerId;
  bool _running = false;
  bool _rerun = false;

  SyncPhase _phase = SyncPhase.idle;
  DateTime? _lastSyncedAt;
  String? _error;

  SyncPhase get phase => _phase;

  /// When the signed-in account last synced successfully.
  DateTime? get lastSyncedAt => _lastSyncedAt;

  /// Why the last sync failed, if it did.
  String? get error => _error;

  Future<void> sync() async {
    final ownerId = _ownerId;
    if (ownerId == null) return;
    if (_running) {
      _rerun = true;
      return;
    }
    _running = true;
    _debounceTimer?.cancel();
    _setPhase(SyncPhase.syncing);

    try {
      final finishedAt = await _engine.run(ownerId);
      if (ownerId != _ownerId) return;
      _lastSyncedAt = finishedAt;
      _error = null;
      _setPhase(SyncPhase.idle);
    } catch (error) {
      if (ownerId != _ownerId) return;
      debugPrint('Sync failed: $error');
      _error = _describe(error);
      _setPhase(_isNetworkError(error) ? SyncPhase.offline : SyncPhase.failed);
    } finally {
      _running = false;
    }

    if (_rerun) {
      _rerun = false;
      return sync();
    }
    // Picks up edits made while this sync was running.
    if (_phase == SyncPhase.idle && await _store.hasDirty(ownerId)) {
      _scheduleSync();
    }
  }

  Future<void> _onAuthChanged() async {
    final ownerId = _auth.profile?.id;
    if (ownerId == _ownerId) return;

    _ownerId = ownerId;
    _debounceTimer?.cancel();
    _intervalTimer?.cancel();
    _rerun = false;
    _lastSyncedAt = null;
    _error = null;
    _phase = SyncPhase.idle;
    notifyListeners();
    if (ownerId == null) return;

    _lastSyncedAt = (await _store.state(ownerId))?.lastSyncedAt;
    notifyListeners();
    _intervalTimer = Timer.periodic(interval, (_) => sync());
    await sync();
  }

  /// Local writes made by a running sync are ignored; edits the user makes
  /// meanwhile are caught by the dirty check after it.
  Future<void> _onLocalChange() async {
    final ownerId = _ownerId;
    if (ownerId == null || _running) return;
    if (await _store.hasDirty(ownerId)) _scheduleSync();
  }

  void _scheduleSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, sync);
  }

  void _setPhase(SyncPhase phase) {
    _phase = phase;
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _localChanges.cancel();
    _debounceTimer?.cancel();
    _intervalTimer?.cancel();
    _ownerId = null;
    super.dispose();
  }
}

bool _isNetworkError(Object error) =>
    error is http.ClientException ||
    error is TimeoutException ||
    error is AuthRetryableFetchException;

String _describe(Object error) => switch (error) {
  PostgrestException(:final message) => message,
  AuthException(:final message) => message,
  http.ClientException() => 'No connection to the server.',
  _ => '$error',
};
