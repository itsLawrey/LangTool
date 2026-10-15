import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/entry.dart';
import '../../domain/models/language_pack.dart';
import 'remote_sync_api.dart';

/// [RemoteSyncApi] over the `language_packs` and `entries` tables (see
/// `supabase/migrations/`). Row-level security limits every query to the
/// signed-in user's rows.
class SupabaseSyncApi implements RemoteSyncApi {
  SupabaseSyncApi(this._client);

  final SupabaseClient _client;

  static const _packs = 'language_packs';
  static const _entries = 'entries';
  static const _serverUpdatedAt = 'server_updated_at';

  @override
  Future<void> upsertPacks(List<LanguagePack> packs) =>
      _upsert(_packs, [for (final pack in packs) pack.toJson()]);

  @override
  Future<void> upsertEntries(List<Entry> entries) =>
      _upsert(_entries, [for (final entry in entries) entry.toJson()]);

  @override
  Future<List<RemoteRecord<LanguagePack>>> fetchPacks({
    required String ownerId,
    required ChangeCursor? from,
    required int limit,
  }) => _fetch(_packs, ownerId, from, limit, LanguagePack.fromJson);

  @override
  Future<List<RemoteRecord<Entry>>> fetchEntries({
    required String ownerId,
    required ChangeCursor? from,
    required int limit,
  }) => _fetch(_entries, ownerId, from, limit, Entry.fromJson);

  Future<void> _upsert(String table, List<Map<String, Object?>> rows) async {
    if (rows.isEmpty) return;
    await _client.from(table).upsert(rows, onConflict: 'id');
  }

  Future<List<RemoteRecord<T>>> _fetch<T>(
    String table,
    String ownerId,
    ChangeCursor? from,
    int limit,
    T Function(Map<String, Object?>) fromJson,
  ) async {
    var query = _client.from(table).select().eq('owner_id', ownerId);
    if (from != null) {
      final at = '"${from.at.toUtc().toIso8601String()}"';
      query = switch (from.afterId) {
        null => query.gte(_serverUpdatedAt, from.at.toUtc().toIso8601String()),
        final id => query.or(
          '$_serverUpdatedAt.gt.$at,'
          'and($_serverUpdatedAt.eq.$at,id.gt.$id)',
        ),
      };
    }
    final rows = await query
        .order(_serverUpdatedAt, ascending: true)
        .order('id', ascending: true)
        .limit(limit);
    return [
      for (final row in rows)
        RemoteRecord(
          fromJson(row),
          DateTime.parse(row[_serverUpdatedAt]! as String).toUtc(),
        ),
    ];
  }
}
