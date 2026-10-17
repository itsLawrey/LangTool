import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/ui/features/transfer/view_models/import_view_model.dart';
import 'package:langtool/ui/features/transfer/views/import_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;

  setUp(() => repos = TestRepositories());

  /// Opens the import preview of [bytes] over a placeholder packs screen.
  Future<void> openImport(WidgetTester tester, Uint8List bytes) async {
    final router = await pumpRoutes(
      tester,
      repos: repos,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('packs')),
          routes: [
            GoRoute(
              path: 'import',
              builder: (_, state) => ChangeNotifierProvider(
                create: (_) => ImportViewModel(
                  transferRepository: repos.transfer,
                  ownerId: 'user-1',
                  bytes: state.extra! as Uint8List,
                ),
                child: const ImportScreen(),
              ),
            ),
          ],
        ),
      ],
    );
    router.push('/import', extra: bytes);
    await settle(tester);
  }

  /// A file with Alltag (2 entries, 1 deck) and Reise (1 entry, 2 decks).
  Future<Uint8List> twoPackFile() async {
    final alltag = await repos.createPack('Alltag');
    await repos.addNoun(alltag, 'Haus');
    await repos.addNoun(alltag, 'Auto');
    await repos.createDeck(alltag, 'Nouns');
    final reise = await repos.createPack('Reise');
    await repos.addNoun(reise, 'Ticket');
    await repos.createDeck(reise, 'A');
    await repos.createDeck(reise, 'B');
    return repos.transfer.export([alltag.id, reise.id]);
  }

  Future<List<String>> packNames() async => [
    for (final pack in await repos.packs.watchPacks('user-1').first) pack.name,
  ];

  FilledButton importButton(WidgetTester tester) =>
      tester.widget(find.widgetWithText(FilledButton, 'Import'));

  testWidgets('previews the packs with their counts, all selected', (
    tester,
  ) async {
    final file = (await tester.runAsync(twoPackFile))!;
    await openImport(tester, file);

    expect(find.widgetWithText(AppBar, 'Import'), findsOneWidget);
    expect(find.text('Alltag'), findsOneWidget);
    expect(find.text('German · 2 entries · 1 deck'), findsOneWidget);
    expect(find.text('Reise'), findsOneWidget);
    expect(find.text('German · 1 entry · 2 decks'), findsOneWidget);
    final boxes = tester.widgetList<CheckboxListTile>(
      find.byType(CheckboxListTile),
    );
    expect([for (final box in boxes) box.value], [true, true]);
    expect(importButton(tester).onPressed, isNotNull);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('imports only the checked packs and reports them', (
    tester,
  ) async {
    final file = (await tester.runAsync(twoPackFile))!;
    await openImport(tester, file);

    await tester.tap(find.text('Reise'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Import'));
    await settle(tester);

    expect(find.text('packs'), findsOneWidget);
    expect(find.text('Imported 1 pack with 2 entries.'), findsOneWidget);
    expect(await tester.runAsync(packNames), ['Alltag', 'Alltag', 'Reise']);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('reports several imported packs', (tester) async {
    final file = (await tester.runAsync(twoPackFile))!;
    await openImport(tester, file);

    await tester.tap(find.widgetWithText(FilledButton, 'Import'));
    await settle(tester);

    expect(find.text('Imported 2 packs with 3 entries.'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('cannot import with nothing checked', (tester) async {
    final file = (await tester.runAsync(twoPackFile))!;
    await openImport(tester, file);

    await tester.tap(find.text('Alltag'));
    await tester.tap(find.text('Reise'));
    await settle(tester);

    expect(importButton(tester).onPressed, isNull);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('shows why a file cannot be imported', (tester) async {
    await openImport(tester, Uint8List.fromList([1, 2, 3]));

    expect(find.text('This is not a LangTool file.'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('says when the file has no packs', (tester) async {
    final file = (await tester.runAsync(() => repos.transfer.export([])))!;
    await openImport(tester, file);

    expect(find.text('No language packs in this file.'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });
}
