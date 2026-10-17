import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/app_scope.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/data/local/app_database.dart';
import 'package:langtool/data/repositories/deck_repository.dart';
import 'package:langtool/data/repositories/entry_repository.dart';
import 'package:langtool/data/repositories/language_pack_repository.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/deck_draft.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/entry_draft.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/recap_session.dart';
import 'package:langtool/routing/routes.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_remote_sync_api.dart';
import '../helpers/widget_harness.dart';

void main() {
  late AppDatabase database;
  late FakeAuthService auth;
  late FakeRemoteSyncApi server;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    database = AppDatabase(NativeDatabase.memory());
    auth = FakeAuthService();
    server = FakeRemoteSyncApi();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      AppScope(
        dependencies: AppDependencies(
          database: database,
          authService: auth,
          syncApi: server,
        ),
      ),
    );
    await settle(tester);
  }

  testWidgets('signed out users see the login screen', (tester) async {
    await pumpApp(tester);

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);

    await disposeAndClose(tester, database);
  });

  testWidgets('signing in opens the packs, signing out returns to login', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'a@b.c',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret1',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Language packs'), findsOneWidget);
    expect(find.text('No language packs yet.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Continue with Google'), findsOneWidget);
    await disposeAndClose(tester, database);
  });

  testWidgets('a signed-in user starts on the packs screen and syncs', (
    tester,
  ) async {
    auth.emitSignedIn();

    await pumpApp(tester);

    expect(find.text('Language packs'), findsOneWidget);
    expect(server.fetchPacksCalls, 1);
    await disposeAndClose(tester, database);
  });

  testWidgets('returning to the app syncs', (tester) async {
    auth.emitSignedIn();
    await pumpApp(tester);
    final before = server.fetchPacksCalls;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(server.fetchPacksCalls, before + 1);
    await disposeAndClose(tester, database);
  });

  testWidgets('routes deep links to the entry detail and edit screens', (
    tester,
  ) async {
    auth.emitSignedIn();
    final ids = await tester.runAsync(() async {
      final repos = LocalLanguagePackRepository(database);
      final pack = (await repos.create(
        ownerId: 'user-1',
        name: 'Alltag',
        languageCode: 'de',
      ) as Ok<LanguagePack>).value;
      final entry = (await LocalEntryRepository(database).add(
        EntryDraft(
          packId: pack.id,
          wordType: WordType.noun,
          term: 'Haus',
          forms: {'article': 'das'},
        ),
      ) as Ok<Entry>).value;
      return (pack.id, entry.id);
    });
    final (packId, entryId) = ids!;
    await pumpApp(tester);
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));

    router.go(Routes.pack(packId));
    await settle(tester);
    expect(find.text('Alltag'), findsOneWidget);

    router.go(Routes.entry(packId, entryId));
    await settle(tester);
    expect(find.byTooltip('Edit'), findsOneWidget);

    router.go(Routes.editEntry(packId, entryId));
    await settle(tester);
    expect(find.text('Edit entry'), findsOneWidget);

    router.go(Routes.newEntry(packId));
    await settle(tester);
    expect(find.text('New entry'), findsWidgets);
    await disposeAndClose(tester, database);
  });

  testWidgets('routes deep links to the recap screens', (tester) async {
    auth.emitSignedIn();
    final ids = await tester.runAsync(() async {
      final pack = (await LocalLanguagePackRepository(database).create(
        ownerId: 'user-1',
        name: 'Alltag',
        languageCode: 'de',
      ) as Ok<LanguagePack>).value;
      final deck = (await LocalDeckRepository(database).create(
        DeckDraft(packId: pack.id, name: 'Everything'),
      ) as Ok<Deck>).value;
      return (pack.id, deck.id);
    });
    final (packId, deckId) = ids!;
    await pumpApp(tester);
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));

    router.go(Routes.recap(packId));
    await settle(tester);
    expect(find.text('Alltag'), findsOneWidget);
    expect(find.text('Everything'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    router.go(Routes.deck(packId, deckId));
    await settle(tester);
    expect(find.text('Start'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    router.go(Routes.editDeck(packId, deckId));
    await settle(tester);
    expect(find.text('Edit deck'), findsOneWidget);

    router.go(Routes.newDeck(packId));
    await settle(tester);
    expect(find.widgetWithText(AppBar, 'New deck'), findsOneWidget);

    router.go(Routes.recapSession(packId, deckId, RecapDirection.mixed));
    await settle(tester);
    expect(router.state.uri.queryParameters['direction'], 'mixed');
    expect(find.byType(NavigationBar), findsNothing);
    await disposeAndClose(tester, database);
  });

  testWidgets('routes to export, and to import only with a file', (
    tester,
  ) async {
    auth.emitSignedIn();
    await pumpApp(tester);
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));

    router.go(Routes.exportPacks);
    await settle(tester);
    expect(find.widgetWithText(AppBar, 'Export'), findsOneWidget);

    router.go(Routes.importPacks);
    await settle(tester);
    expect(find.text('Language packs'), findsOneWidget);

    router.push(Routes.importPacks, extra: Uint8List.fromList([1, 2, 3]));
    await settle(tester);
    expect(find.widgetWithText(AppBar, 'Import'), findsOneWidget);
    expect(find.text('This is not a LangTool file.'), findsOneWidget);
    await disposeAndClose(tester, database);
  });

  testWidgets('signed-out deep links go to the login screen', (tester) async {
    await pumpApp(tester);
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));

    router.go(Routes.pack('some-pack'));
    await settle(tester);

    expect(find.text('Continue with Google'), findsOneWidget);
    await disposeAndClose(tester, database);
  });
}
