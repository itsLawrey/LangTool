import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/routing/pack_routes.dart';
import 'package:langtool/routing/routes.dart';
import 'package:langtool/ui/features/timeline/views/entry_card.dart';

import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;

  /// The app's pack routes under a placeholder packs screen.
  Future<GoRouter> open(WidgetTester tester, String location) {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    return pumpRoutes(
      tester,
      repos: repos,
      providers: signedInProviders(repos),
      navigatorKey: rootNavigatorKey,
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('packs')),
          routes: [packShellRoute(rootNavigatorKey)],
        ),
      ],
    );
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await settle(tester);
  }

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack('Alltag');
  });

  testWidgets('both tabs show the pack name and the bar', (tester) async {
    await open(tester, Routes.pack(pack.id));

    expect(find.text('Alltag'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('No entries yet.'), findsOneWidget);

    await tapTab(tester, 'Recap');

    expect(find.text('Alltag'), findsOneWidget);
    expect(find.text('No decks yet.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('switching tabs keeps each tab\'s state', (tester) async {
    await tester.runAsync(() async {
      await repos.addNoun(pack, 'Haus');
      await repos.addNoun(pack, 'Baum', article: 'der');
    });
    final router = await open(tester, Routes.pack(pack.id));

    await tester.enterText(find.byType(SearchBar), 'haus');
    await tester.pump(const Duration(milliseconds: 300));
    await settle(tester);
    expect(find.byType(EntryCard), findsOneWidget);

    await tapTab(tester, 'Recap');
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      Routes.recap(pack.id),
    );
    await tapTab(tester, 'Note');

    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      Routes.pack(pack.id),
    );
    expect(find.text('haus'), findsOneWidget);
    expect(find.byType(EntryCard), findsOneWidget);
    expect(find.text('das Haus'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('screens below the tabs are shown without the bar', (
    tester,
  ) async {
    await tester.runAsync(() => repos.createDeck(pack, 'Everything'));
    final router = await open(tester, Routes.pack(pack.id));

    await tester.tap(find.text('New entry'));
    await settle(tester);
    expect(find.widgetWithText(AppBar, 'New entry'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    router.pop();
    await settle(tester);
    await tapTab(tester, 'Recap');
    await tester.tap(find.text('New deck'));
    await settle(tester);
    expect(find.widgetWithText(AppBar, 'New deck'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    router.pop();
    await settle(tester);
    await tester.tap(find.text('Everything'));
    await settle(tester);
    expect(find.text('Start'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    router.pop();
    await settle(tester);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('No decks yet.'), findsNothing);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('back leaves the pack', (tester) async {
    await open(tester, Routes.recap(pack.id));

    await tester.tap(find.byType(BackButton));
    await settle(tester);

    expect(find.text('packs'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('a missing pack is reported on both tabs', (tester) async {
    await open(tester, Routes.pack('nope'));

    expect(find.text('This pack no longer exists.'), findsOneWidget);

    await tapTab(tester, 'Recap');
    expect(find.text('This pack no longer exists.'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });
}
