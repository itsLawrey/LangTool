import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:langtool/data/local/sync_store.dart';
import 'package:langtool/data/repositories/auth_repository.dart';
import 'package:langtool/data/repositories/sync_engine.dart';
import 'package:langtool/data/repositories/sync_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_remote_sync_api.dart';
import '../helpers/test_repositories.dart';

void main() {
  late TestRepositories repos;
  late FakeRemoteSyncApi server;
  late FakeAuthService authService;
  late AuthRepository auth;
  late SyncRepository sync;

  Future<void> settle(bool Function() condition) async {
    for (var i = 0; i < 200 && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(condition(), isTrue, reason: 'condition not reached');
  }

  SyncRepository createSync({Duration interval = const Duration(minutes: 5)}) {
    final store = LocalSyncStore(repos.db, clock: repos.clock);
    return SyncRepository(
      engine: SyncEngine(api: server, store: store, clock: repos.clock),
      store: store,
      auth: auth,
      database: repos.db,
      debounce: Duration.zero,
      interval: interval,
    );
  }

  setUp(() {
    repos = TestRepositories();
    server = FakeRemoteSyncApi();
    authService = FakeAuthService();
    auth = AuthRepository(authService);
    sync = createSync();
  });

  tearDown(() async {
    sync.dispose();
    auth.dispose();
    await repos.close();
  });

  test('syncs when an account signs in', () async {
    final pack = await repos.createPack();
    await repos.addNoun(pack, 'Haus');

    authService.emitSignedIn();

    await settle(() => sync.lastSyncedAt != null);
    expect(sync.phase, SyncPhase.idle);
    expect(server.entries, hasLength(1));
  });

  test('uploads local edits shortly after they are made', () async {
    authService.emitSignedIn();
    await settle(() => sync.lastSyncedAt != null);

    final pack = await repos.createPack();
    await repos.addNoun(pack, 'Haus');

    await settle(() => server.entries.length == 1);
  });

  test('uploads deck edits shortly after they are made', () async {
    final pack = await repos.createPack();
    authService.emitSignedIn();
    await settle(() => sync.lastSyncedAt != null && server.packs.length == 1);
    await settle(() => sync.phase == SyncPhase.idle);

    await repos.createDeck(pack, 'Nouns');

    await settle(() => server.decks.length == 1);
  });

  test('reports offline on network errors and recovers', () async {
    server.failure = http.ClientException('Connection refused');
    authService.emitSignedIn();
    await settle(() => sync.phase == SyncPhase.offline);
    expect(sync.lastSyncedAt, isNull);

    server.failure = null;
    await sync.sync();

    expect(sync.phase, SyncPhase.idle);
    expect(sync.lastSyncedAt, isNotNull);
  });

  test('reports other errors as failed', () async {
    server.failure = const PostgrestException(message: 'permission denied');
    authService.emitSignedIn();

    await settle(() => sync.phase == SyncPhase.failed);
    expect(sync.error, 'permission denied');
  });

  test('stops syncing on sign-out', () async {
    authService.emitSignedIn();
    await settle(() => sync.lastSyncedAt != null);

    authService.emitSignedOut();
    await settle(() => sync.lastSyncedAt == null);
    await sync.sync();

    expect(sync.lastSyncedAt, isNull);
  });

  test('a sync requested while one runs runs once more afterwards', () async {
    authService.emitSignedIn();
    await settle(() => sync.lastSyncedAt != null);
    final before = server.fetchPacksCalls;

    server.fetchPacksGate = Completer<void>();
    final first = sync.sync();
    await settle(() => server.fetchPacksCalls == before + 1);
    expect(sync.phase, SyncPhase.syncing);

    // Both requests arrive while the first sync is held.
    await sync.sync();
    await sync.sync();
    server.fetchPacksGate!.complete();
    await first;

    expect(server.fetchPacksCalls, before + 2);
    expect(sync.phase, SyncPhase.idle);
  });

  test('syncs periodically while signed in', () async {
    sync.dispose();
    sync = createSync(interval: const Duration(milliseconds: 20));

    authService.emitSignedIn();

    await settle(() => server.fetchPacksCalls >= 4);
  });
}
