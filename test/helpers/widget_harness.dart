import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/data/local/app_database.dart';
import 'package:langtool/data/local/sync_store.dart';
import 'package:langtool/data/repositories/auth_repository.dart';
import 'package:langtool/data/repositories/deck_repository.dart';
import 'package:langtool/data/repositories/entry_repository.dart';
import 'package:langtool/data/repositories/language_pack_repository.dart';
import 'package:langtool/data/repositories/sync_engine.dart';
import 'package:langtool/data/repositories/sync_repository.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'fake_auth_service.dart';
import 'fake_remote_sync_api.dart';
import 'test_repositories.dart';

/// Pumps [routes] in a [MaterialApp.router] with [repos] and [providers]
/// provided, starting at [initialLocation].
Future<GoRouter> pumpRoutes(
  WidgetTester tester, {
  required TestRepositories repos,
  required List<RouteBase> routes,
  List<SingleChildWidget> providers = const [],
  String initialLocation = '/',
}) async {
  final router = GoRouter(initialLocation: initialLocation, routes: routes);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<LanguagePackRepository>.value(value: repos.packs),
        Provider<EntryRepository>.value(value: repos.entries),
        Provider<DeckRepository>.value(value: repos.decks),
        ...providers,
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await settle(tester);
  return router;
}

/// Lets database work and transitions finish. Drift does real asynchronous
/// work, so fake time alone is not enough. Advances fixed steps instead of
/// `pumpAndSettle`, which never returns while a progress indicator (e.g. the
/// timeline's load-more row) is animating.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Disposes the widget tree, flushes drift's stream clean-up timers (which
/// run on the test's fake clock) and closes [database].
Future<void> disposeAndClose(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(database.close);
}

/// [AuthRepository] signed in as `user-1` and a [SyncRepository] against
/// [server], as needed by screens with the account menu or sync button.
List<SingleChildWidget> signedInProviders(
  TestRepositories repos, {
  FakeRemoteSyncApi? server,
}) {
  final authService = FakeAuthService()..emitSignedIn();
  return [
    ChangeNotifierProvider(create: (_) => AuthRepository(authService)),
    ChangeNotifierProvider(
      create: (context) {
        final store = LocalSyncStore(repos.db, clock: repos.clock);
        return SyncRepository(
          engine: SyncEngine(
            api: server ?? FakeRemoteSyncApi(),
            store: store,
            clock: repos.clock,
          ),
          store: store,
          auth: context.read<AuthRepository>(),
          database: repos.db,
        );
      },
    ),
  ];
}

/// Makes the test window tall enough that long forms and lists build fully.
void useTallWindow(WidgetTester tester, {double height = 2400}) {
  tester.view
    ..physicalSize = Size(800, height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
