import '../../domain/models/entry.dart';
import '../../domain/models/language_pack.dart';

/// A record as stored on the server, with the time the server accepted its
/// latest write.
final class RemoteRecord<T> {
  const RemoteRecord(this.value, this.serverUpdatedAt);

  final T value;
  final DateTime serverUpdatedAt;
}

/// Position in the server's change feed, ordered by server write time, then
/// id. With an [afterId], returns records strictly after (`at`, `afterId`);
/// without, every record written at or after [at].
final class ChangeCursor {
  const ChangeCursor(this.at, [this.afterId]);

  final DateTime at;
  final String? afterId;
}

/// The cloud copy of a user's packs and entries.
///
/// Writes are upserts. The server keeps whichever version has the later
/// `updatedAt` and stamps every accepted write with its own time.
abstract interface class RemoteSyncApi {
  Future<void> upsertPacks(List<LanguagePack> packs);

  Future<void> upsertEntries(List<Entry> entries);

  /// [ownerId]'s packs changed from [from] on (all if `null`), oldest first,
  /// at most [limit].
  Future<List<RemoteRecord<LanguagePack>>> fetchPacks({
    required String ownerId,
    required ChangeCursor? from,
    required int limit,
  });

  /// Like [fetchPacks], for entries.
  Future<List<RemoteRecord<Entry>>> fetchEntries({
    required String ownerId,
    required ChangeCursor? from,
    required int limit,
  });
}
