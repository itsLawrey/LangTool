import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:langtool/data/repositories/entry_repository.dart';
import 'package:langtool/data/repositories/language_pack_repository.dart';
import 'package:langtool/ui/core/widgets/sync_button.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/fake_remote_sync_api.dart';
import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;
  late FakeRemoteSyncApi server;

  Future<void> pumpButton(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<LanguagePackRepository>.value(value: repos.packs),
          Provider<EntryRepository>.value(value: repos.entries),
          ...signedInProviders(repos, server: server),
        ],
        child: MaterialApp(
          home: Scaffold(appBar: AppBar(actions: const [SyncButton()])),
        ),
      ),
    );
    await settle(tester);
  }

  String tooltip(WidgetTester tester) =>
      tester.widget<IconButton>(find.byType(IconButton)).tooltip!;

  setUp(() {
    repos = TestRepositories();
    server = FakeRemoteSyncApi();
  });

  testWidgets('shows when the last sync finished', (tester) async {
    await pumpButton(tester);

    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    expect(tooltip(tester), startsWith('Last synced'));
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('shows offline', (tester) async {
    server.failure = http.ClientException('Connection refused');
    await pumpButton(tester);

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(tooltip(tester), 'Offline. Not synced yet');
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('shows the reason when a sync fails', (tester) async {
    server.failure = const PostgrestException(message: 'permission denied');
    await pumpButton(tester);

    expect(find.byIcon(Icons.sync_problem), findsOneWidget);
    expect(tooltip(tester), startsWith('Sync failed: permission denied'));
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('tapping it syncs now and recovers', (tester) async {
    server.failure = http.ClientException('Connection refused');
    await pumpButton(tester);
    final before = server.fetchPacksCalls;

    server.failure = null;
    await tester.tap(find.byType(IconButton));
    await settle(tester);

    expect(server.fetchPacksCalls, before + 1);
    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });
}
