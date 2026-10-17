import 'package:langtool/data/local/sync_store.dart';
import 'package:langtool/data/repositories/sync_engine.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/language_pack.dart';

import 'fake_remote_sync_api.dart';
import 'test_repositories.dart';

/// One app installation in a sync test: its own in-memory database, sharing
/// a [FakeRemoteSyncApi] server with other devices.
class SyncDevice {
  SyncDevice(String name, FakeRemoteSyncApi server, {int pageSize = 500})
    : repos = TestRepositories(idPrefix: name) {
    store = LocalSyncStore(repos.db, clock: repos.clock);
    engine = SyncEngine(
      api: server,
      store: store,
      pageSize: pageSize,
      clock: repos.clock,
    );
  }

  final TestRepositories repos;
  late final LocalSyncStore store;
  late final SyncEngine engine;

  Future<void> sync([String ownerId = 'user-1']) => engine.run(ownerId);

  Future<List<Entry>> entries(String packId) =>
      repos.entries.watchEntries(packId).first;

  Future<List<Deck>> decks(String packId) =>
      repos.decks.watchDecks(packId).first;

  Future<List<LanguagePack>> packs([String ownerId = 'user-1']) =>
      repos.packs.watchPacks(ownerId).first;

  Future<void> close() => repos.close();
}
