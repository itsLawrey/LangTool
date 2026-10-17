import 'package:drift/drift.dart' show Value;

import '../../utils/clock.dart';
import '../local/app_database.dart';
import '../local/sync_store.dart';
import '../services/remote_sync_api.dart';

/// Runs one sync of an account: uploads local changes, then downloads
/// changes made elsewhere.
///
/// Downloads restart a little before the last seen server time ([overlap]):
/// a write that committed late with an earlier server time is still picked
/// up. Re-applying a row is harmless, because only newer versions are kept.
class SyncEngine {
  SyncEngine({
    required this._api,
    required this._store,
    this.pageSize = 500,
    this.overlap = const Duration(minutes: 1),
    this._clock = systemClockUtc,
  });

  final RemoteSyncApi _api;
  final LocalSyncStore _store;
  final Clock _clock;
  final int pageSize;
  final Duration overlap;

  /// Returns when the sync finished.
  Future<DateTime> run(String ownerId) async {
    await _push(ownerId);

    final state = await _store.state(ownerId);
    final packsPulledUntil = await _pull(
      since: state?.packsPulledUntil,
      fetch: (from) =>
          _api.fetchPacks(ownerId: ownerId, from: from, limit: pageSize),
      apply: (packs) async {
        await _store.applyRemotePacks(packs);
        return packs.length;
      },
      idOf: (pack) => pack.id,
    );
    final entriesPulledUntil = await _pull(
      since: state?.entriesPulledUntil,
      fetch: (from) =>
          _api.fetchEntries(ownerId: ownerId, from: from, limit: pageSize),
      apply: _store.applyRemoteEntries,
      idOf: (entry) => entry.id,
    );
    final decksPulledUntil = await _pull(
      since: state?.decksPulledUntil,
      fetch: (from) =>
          _api.fetchDecks(ownerId: ownerId, from: from, limit: pageSize),
      apply: _store.applyRemoteDecks,
      idOf: (deck) => deck.id,
    );

    // Conflict resolution during the download may have soft-deleted entries.
    await _push(ownerId);

    final finishedAt = _clock();
    await _store.saveState(
      SyncStatesCompanion(
        ownerId: Value(ownerId),
        packsPulledUntil: Value(packsPulledUntil),
        entriesPulledUntil: Value(entriesPulledUntil),
        decksPulledUntil: Value(decksPulledUntil),
        lastSyncedAt: Value(finishedAt),
      ),
    );
    return finishedAt;
  }

  /// Uploads packs before entries and decks, so their packs exist remotely.
  Future<void> _push(String ownerId) async {
    while (true) {
      final packs = await _store.dirtyPacks(ownerId, limit: pageSize);
      if (packs.isEmpty) break;
      await _api.upsertPacks(packs);
      await _store.markPacksPushed(packs);
      if (packs.length < pageSize) break;
    }
    while (true) {
      final entries = await _store.dirtyEntries(ownerId, limit: pageSize);
      if (entries.isEmpty) break;
      await _api.upsertEntries(entries);
      await _store.markEntriesPushed(entries);
      if (entries.length < pageSize) break;
    }
    while (true) {
      final decks = await _store.dirtyDecks(ownerId, limit: pageSize);
      if (decks.isEmpty) break;
      await _api.upsertDecks(decks);
      await _store.markDecksPushed(decks);
      if (decks.length < pageSize) break;
    }
  }

  /// Downloads and applies changes page by page. Returns the server time up
  /// to which everything was applied.
  Future<DateTime?> _pull<T>({
    required DateTime? since,
    required Future<List<RemoteRecord<T>>> Function(ChangeCursor? from) fetch,
    required Future<int> Function(List<T> values) apply,
    required String Function(T value) idOf,
  }) async {
    var pulledUntil = since;
    ChangeCursor? cursor = since == null
        ? null
        : ChangeCursor(since.subtract(overlap));

    while (true) {
      final page = await fetch(cursor);
      if (page.isEmpty) break;

      final applied = await apply([for (final record in page) record.value]);
      if (applied > 0) {
        final last = page[applied - 1].serverUpdatedAt;
        if (pulledUntil == null || last.isAfter(pulledUntil)) {
          pulledUntil = last;
        }
      }
      if (applied < page.length || page.length < pageSize) break;

      final last = page.last;
      cursor = ChangeCursor(last.serverUpdatedAt, idOf(last.value));
    }
    return pulledUntil;
  }
}
