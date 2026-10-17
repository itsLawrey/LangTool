import 'package:drift/drift.dart';

import '../../domain/models/deck.dart';
import '../../domain/models/entry.dart';
import '../../domain/models/language_pack.dart';
import '../../domain/search/text_normalizer.dart';
import '../../utils/clock.dart';
import 'app_database.dart';
import 'mappers.dart';

/// Local side of sync: finds rows waiting to be uploaded, applies rows
/// downloaded from the server and keeps per-account sync progress.
class LocalSyncStore {
  LocalSyncStore(this._db, {this._clock = systemClockUtc});

  final AppDatabase _db;
  final Clock _clock;

  /// Up to [limit] of [ownerId]'s packs with local changes not yet uploaded.
  Future<List<LanguagePack>> dirtyPacks(String ownerId, {required int limit}) =>
      (_db.select(_db.languagePacks)
            ..where((p) => p.ownerId.equals(ownerId) & p.needsPush)
            ..orderBy([(p) => OrderingTerm.asc(p.id)])
            ..limit(limit))
          .map((row) => row.toDomain())
          .get();

  /// Like [dirtyPacks], for entries.
  Future<List<Entry>> dirtyEntries(String ownerId, {required int limit}) =>
      (_db.select(_db.entries)
            ..where((e) => e.ownerId.equals(ownerId) & e.needsPush)
            ..orderBy([(e) => OrderingTerm.asc(e.id)])
            ..limit(limit))
          .map((row) => row.toDomain())
          .get();

  /// Like [dirtyPacks], for decks.
  Future<List<Deck>> dirtyDecks(String ownerId, {required int limit}) =>
      (_db.select(_db.decks)
            ..where((d) => d.ownerId.equals(ownerId) & d.needsPush)
            ..orderBy([(d) => OrderingTerm.asc(d.id)])
            ..limit(limit))
          .map((row) => row.toDomain())
          .get();

  /// Whether [ownerId] has any local changes not yet uploaded.
  Future<bool> hasDirty(String ownerId) async {
    final packs = _db.languagePacks;
    final entries = _db.entries;
    final decks = _db.decks;
    return await _anyDirty(
          packs,
          packs.id,
          packs.ownerId,
          packs.needsPush,
          ownerId,
        ) ||
        await _anyDirty(
          entries,
          entries.id,
          entries.ownerId,
          entries.needsPush,
          ownerId,
        ) ||
        await _anyDirty(
          decks,
          decks.id,
          decks.ownerId,
          decks.needsPush,
          ownerId,
        );
  }

  Future<bool> _anyDirty(
    TableInfo<Table, Object?> table,
    Expression<String> id,
    Expression<String> owner,
    Expression<bool> needsPush,
    String ownerId,
  ) async {
    final row =
        await (_db.selectOnly(table)
              ..addColumns([id])
              ..where(owner.equals(ownerId) & needsPush)
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  /// Marks [packs] as uploaded, unless they changed again since they were
  /// read (then they stay dirty for the next sync).
  Future<void> markPacksPushed(List<LanguagePack> packs) => _db.batch((batch) {
    for (final pack in packs) {
      batch.update(
        _db.languagePacks,
        const LanguagePacksCompanion(needsPush: Value(false)),
        where: (p) => p.id.equals(pack.id) & p.updatedAt.equals(pack.updatedAt),
      );
    }
  });

  /// Like [markPacksPushed], for entries.
  Future<void> markEntriesPushed(List<Entry> entries) => _db.batch((batch) {
    for (final entry in entries) {
      batch.update(
        _db.entries,
        const EntriesCompanion(needsPush: Value(false)),
        where: (e) =>
            e.id.equals(entry.id) & e.updatedAt.equals(entry.updatedAt),
      );
    }
  });

  /// Like [markPacksPushed], for decks.
  Future<void> markDecksPushed(List<Deck> decks) => _db.batch((batch) {
    for (final deck in decks) {
      batch.update(
        _db.decks,
        const DecksCompanion(needsPush: Value(false)),
        where: (d) => d.id.equals(deck.id) & d.updatedAt.equals(deck.updatedAt),
      );
    }
  });

  /// Applies downloaded packs that are newer than the local copy.
  Future<void> applyRemotePacks(List<LanguagePack> packs) =>
      _db.transaction(() async {
        for (final remote in packs) {
          final local = await (_db.select(
            _db.languagePacks,
          )..where((p) => p.id.equals(remote.id))).getSingleOrNull();
          if (local != null && remote.updatedAt.isBefore(local.updatedAt)) {
            continue;
          }
          await _db
              .into(_db.languagePacks)
              .insertOnConflictUpdate(remote.toCompanion(needsPush: false));
        }
      });

  /// Applies downloaded entries in order, skipping those older than the
  /// local copy. Returns how many were processed: it stops early at an entry
  /// whose pack is not known locally yet, so the caller can retry it after
  /// the next pack download.
  ///
  /// If an entry would duplicate another active entry (same pack, word type
  /// and term), the one created first is kept and the other is soft-deleted;
  /// that deletion is uploaded on the next push.
  Future<int> applyRemoteEntries(List<Entry> entries) =>
      _db.transaction(() async {
        for (final (index, remote) in entries.indexed) {
          final pack = await (_db.select(
            _db.languagePacks,
          )..where((p) => p.id.equals(remote.packId))).getSingleOrNull();
          if (pack == null) return index;

          final local = await (_db.select(
            _db.entries,
          )..where((e) => e.id.equals(remote.id))).getSingleOrNull();
          if (local != null && remote.updatedAt.isBefore(local.updatedAt)) {
            continue;
          }
          await _applyEntry(remote);
        }
        return entries.length;
      });

  /// Applies downloaded decks in order, skipping those older than the local
  /// copy. Like [applyRemoteEntries], stops early at a deck whose pack is not
  /// known locally yet and returns how many were processed.
  Future<int> applyRemoteDecks(List<Deck> decks) => _db.transaction(() async {
    for (final (index, remote) in decks.indexed) {
      final pack = await (_db.select(
        _db.languagePacks,
      )..where((p) => p.id.equals(remote.packId))).getSingleOrNull();
      if (pack == null) return index;

      final local = await (_db.select(
        _db.decks,
      )..where((d) => d.id.equals(remote.id))).getSingleOrNull();
      if (local != null && remote.updatedAt.isBefore(local.updatedAt)) {
        continue;
      }
      await _db
          .into(_db.decks)
          .insertOnConflictUpdate(remote.toCompanion(needsPush: false));
    }
    return decks.length;
  });

  Future<void> _applyEntry(Entry remote) async {
    final rival = remote.deletedAt != null
        ? null
        : await (_db.select(_db.entries)..where(
                (e) =>
                    e.packId.equals(remote.packId) &
                    e.wordType.equalsValue(remote.wordType) &
                    e.duplicateKey.equals(duplicateKey(remote.term)) &
                    e.deletedAt.isNull() &
                    e.id.equals(remote.id).not(),
              ))
              .getSingleOrNull();

    if (rival == null) {
      await _db
          .into(_db.entries)
          .insertOnConflictUpdate(remote.toCompanion(needsPush: false));
      return;
    }

    final now = _clock();
    if (_createdFirst(rival.toDomain(), remote)) {
      await _db
          .into(_db.entries)
          .insertOnConflictUpdate(
            remote.copyWith(deletedAt: now, updatedAt: now).toCompanion(),
          );
    } else {
      await (_db.update(
        _db.entries,
      )..where((e) => e.id.equals(rival.id))).write(
        EntriesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          needsPush: const Value(true),
        ),
      );
      await _db
          .into(_db.entries)
          .insertOnConflictUpdate(remote.toCompanion(needsPush: false));
    }
  }

  /// Sync progress of [ownerId], or `null` if it never synced.
  Future<SyncStateRow?> state(String ownerId) => (_db.select(
    _db.syncStates,
  )..where((s) => s.ownerId.equals(ownerId))).getSingleOrNull();

  Future<void> saveState(SyncStatesCompanion state) =>
      _db.into(_db.syncStates).insertOnConflictUpdate(state);
}

/// Whether [a] was created before [b]; ties go to the smaller id so every
/// device decides the same way.
bool _createdFirst(Entry a, Entry b) =>
    switch (a.createdAt.compareTo(b.createdAt)) {
      < 0 => true,
      > 0 => false,
      _ => a.id.compareTo(b.id) < 0,
    };
