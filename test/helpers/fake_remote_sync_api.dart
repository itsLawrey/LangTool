import 'package:langtool/data/services/remote_sync_api.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/language_pack.dart';

/// In-memory stand-in for the Supabase tables, with the same write rules as
/// the `apply_sync_write` trigger: an older `updatedAt` never overwrites a
/// newer one, `ownerId` and `createdAt` are immutable, and every accepted
/// write gets a fresh server time.
class FakeRemoteSyncApi implements RemoteSyncApi {
  final packs = <String, RemoteRecord<LanguagePack>>{};
  final entries = <String, RemoteRecord<Entry>>{};

  /// When set, every call throws it.
  Exception? failure;

  var _tick = 0;
  DateTime _serverNow() =>
      DateTime.utc(2030).add(Duration(microseconds: _tick++));

  @override
  Future<void> upsertPacks(List<LanguagePack> packs) async {
    _maybeFail();
    for (final pack in packs) {
      final existing = this.packs[pack.id]?.value;
      if (existing != null && pack.updatedAt.isBefore(existing.updatedAt)) {
        continue;
      }
      this.packs[pack.id] = RemoteRecord(
        existing == null
            ? pack
            : pack.copyWith(
                ownerId: existing.ownerId,
                createdAt: existing.createdAt,
              ),
        _serverNow(),
      );
    }
  }

  @override
  Future<void> upsertEntries(List<Entry> entries) async {
    _maybeFail();
    for (final entry in entries) {
      if (!packs.containsKey(entry.packId)) {
        throw StateError('Foreign key violation: pack ${entry.packId}');
      }
      final existing = this.entries[entry.id]?.value;
      if (existing != null && entry.updatedAt.isBefore(existing.updatedAt)) {
        continue;
      }
      this.entries[entry.id] = RemoteRecord(
        existing == null
            ? entry
            : entry.copyWith(
                ownerId: existing.ownerId,
                createdAt: existing.createdAt,
              ),
        _serverNow(),
      );
    }
  }

  @override
  Future<List<RemoteRecord<LanguagePack>>> fetchPacks({
    required String ownerId,
    required ChangeCursor? from,
    required int limit,
  }) async {
    _maybeFail();
    return _page(
      packs.values,
      (p) => p.ownerId == ownerId,
      (p) => p.id,
      from,
      limit,
    );
  }

  @override
  Future<List<RemoteRecord<Entry>>> fetchEntries({
    required String ownerId,
    required ChangeCursor? from,
    required int limit,
  }) async {
    _maybeFail();
    return _page(
      entries.values,
      (e) => e.ownerId == ownerId,
      (e) => e.id,
      from,
      limit,
    );
  }

  List<RemoteRecord<T>> _page<T>(
    Iterable<RemoteRecord<T>> records,
    bool Function(T) owned,
    String Function(T) idOf,
    ChangeCursor? from,
    int limit,
  ) {
    bool after(RemoteRecord<T> r) {
      if (from == null) return true;
      final byTime = r.serverUpdatedAt.compareTo(from.at);
      return switch (from.afterId) {
        null => byTime >= 0,
        final id =>
          byTime > 0 || byTime == 0 && idOf(r.value).compareTo(id) > 0,
      };
    }

    final matching = records.where((r) => owned(r.value) && after(r)).toList()
      ..sort((a, b) {
        final byTime = a.serverUpdatedAt.compareTo(b.serverUpdatedAt);
        return byTime != 0 ? byTime : idOf(a.value).compareTo(idOf(b.value));
      });
    return matching.take(limit).toList();
  }

  void _maybeFail() {
    if (failure case final error?) throw error;
  }
}
