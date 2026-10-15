import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:langtool/data/local/sync_store.dart';
import 'package:langtool/data/repositories/auth_repository.dart';
import 'package:langtool/data/repositories/sync_engine.dart';
import 'package:langtool/data/repositories/sync_repository.dart';
import 'package:langtool/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/fake_remote_sync_api.dart';
import '../helpers/test_repositories.dart';

/// Signed-in state controlled by the test.
class _FakeAuthService implements AuthService {
  final _states = StreamController<AuthState>.broadcast();

  @override
  User? currentUser;

  @override
  Stream<AuthState> get authStateChanges => _states.stream;

  void emitSignedIn(String id) {
    currentUser = User(
      id: id,
      appMetadata: const {},
      userMetadata: const {'full_name': 'Test'},
      aud: 'authenticated',
      createdAt: '2026-10-15T12:00:00Z',
    );
    _states.add(
      AuthState(
        AuthChangeEvent.signedIn,
        Session(accessToken: 'token', tokenType: 'bearer', user: currentUser!),
      ),
    );
  }

  void emitSignedOut() {
    currentUser = null;
    _states.add(const AuthState(AuthChangeEvent.signedOut, null));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late TestRepositories repos;
  late FakeRemoteSyncApi server;
  late _FakeAuthService authService;
  late AuthRepository auth;
  late SyncRepository sync;

  Future<void> settle(bool Function() condition) async {
    for (var i = 0; i < 200 && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(condition(), isTrue, reason: 'condition not reached');
  }

  setUp(() {
    repos = TestRepositories();
    server = FakeRemoteSyncApi();
    authService = _FakeAuthService();
    auth = AuthRepository(authService);
    final store = LocalSyncStore(repos.db, clock: repos.clock);
    sync = SyncRepository(
      engine: SyncEngine(api: server, store: store, clock: repos.clock),
      store: store,
      auth: auth,
      database: repos.db,
      debounce: Duration.zero,
    );
  });

  tearDown(() async {
    sync.dispose();
    auth.dispose();
    await repos.close();
  });

  test('syncs when an account signs in', () async {
    final pack = await repos.createPack();
    await repos.addNoun(pack, 'Haus');

    authService.emitSignedIn('user-1');

    await settle(() => sync.lastSyncedAt != null);
    expect(sync.phase, SyncPhase.idle);
    expect(server.entries, hasLength(1));
  });

  test('uploads local edits shortly after they are made', () async {
    authService.emitSignedIn('user-1');
    await settle(() => sync.lastSyncedAt != null);

    final pack = await repos.createPack();
    await repos.addNoun(pack, 'Haus');

    await settle(() => server.entries.length == 1);
  });

  test('reports offline on network errors and recovers', () async {
    server.failure = http.ClientException('Connection refused');
    authService.emitSignedIn('user-1');
    await settle(() => sync.phase == SyncPhase.offline);
    expect(sync.lastSyncedAt, isNull);

    server.failure = null;
    await sync.sync();

    expect(sync.phase, SyncPhase.idle);
    expect(sync.lastSyncedAt, isNotNull);
  });

  test('reports other errors as failed', () async {
    server.failure = const PostgrestException(message: 'permission denied');
    authService.emitSignedIn('user-1');

    await settle(() => sync.phase == SyncPhase.failed);
    expect(sync.error, 'permission denied');
  });

  test('stops syncing on sign-out', () async {
    authService.emitSignedIn('user-1');
    await settle(() => sync.lastSyncedAt != null);

    authService.emitSignedOut();
    await settle(() => sync.lastSyncedAt == null);
    await sync.sync();

    expect(sync.lastSyncedAt, isNull);
  });
}
