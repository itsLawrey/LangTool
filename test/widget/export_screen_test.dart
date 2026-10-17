import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/domain/transfer/pack_file_pack.dart';
import 'package:langtool/ui/features/transfer/view_models/export_view_model.dart';
import 'package:langtool/ui/features/transfer/views/export_screen.dart';
import 'package:langtool/utils/result.dart';
import 'package:provider/provider.dart';

import '../helpers/fake_file_service.dart';
import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;
  late FakeFileService files;

  setUp(() {
    repos = TestRepositories();
    files = FakeFileService();
  });

  /// Opens the export screen over a placeholder packs screen.
  Future<void> openExport(WidgetTester tester) async {
    final router = await pumpRoutes(
      tester,
      repos: repos,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('packs')),
          routes: [
            GoRoute(
              path: 'export',
              builder: (_, _) => ChangeNotifierProvider(
                create: (_) => ExportViewModel(
                  packRepository: repos.packs,
                  transferRepository: repos.transfer,
                  fileService: files,
                  ownerId: 'user-1',
                ),
                child: const ExportScreen(),
              ),
            ),
          ],
        ),
      ],
    );
    router.push('/export');
    await settle(tester);
  }

  Future<void> createPacks() async {
    final alltag = await repos.createPack('Alltag');
    await repos.addNoun(alltag, 'Haus');
    await repos.createDeck(alltag, 'Nouns');
    final reise = await repos.createPack('Reise');
    await repos.addNoun(reise, 'Ticket');
  }

  FilledButton exportButton(WidgetTester tester) =>
      tester.widget(find.widgetWithText(FilledButton, 'Export'));

  Future<void> tapExport(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Export'));
    await settle(tester);
  }

  testWidgets('says when there are no packs', (tester) async {
    await openExport(tester);

    expect(find.text('No language packs yet.'), findsOneWidget);
    expect(find.text('Select all'), findsNothing);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('enables Export once a pack is checked', (tester) async {
    await tester.runAsync(createPacks);
    await openExport(tester);

    expect(find.widgetWithText(AppBar, 'Export'), findsOneWidget);
    expect(find.text('Alltag'), findsOneWidget);
    expect(find.text('Reise'), findsOneWidget);
    expect(find.text('German'), findsNWidgets(2));
    expect(exportButton(tester).onPressed, isNull);

    await tester.tap(find.text('Alltag'));
    await settle(tester);
    expect(exportButton(tester).onPressed, isNotNull);

    await tester.tap(find.text('Alltag'));
    await settle(tester);
    expect(exportButton(tester).onPressed, isNull);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('selects and clears all packs', (tester) async {
    await tester.runAsync(createPacks);
    await openExport(tester);

    await tester.tap(find.text('Select all'));
    await settle(tester);
    final boxes = tester.widgetList<CheckboxListTile>(
      find.byType(CheckboxListTile),
    );
    expect([for (final box in boxes) box.value], [true, true]);

    await tester.tap(find.text('Clear'));
    await settle(tester);
    expect(find.text('Select all'), findsOneWidget);
    expect(exportButton(tester).onPressed, isNull);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('saves the checked packs and returns', (tester) async {
    await tester.runAsync(createPacks);
    await openExport(tester);

    await tester.tap(find.text('Alltag'));
    await settle(tester);
    await tapExport(tester);

    expect(find.text('packs'), findsOneWidget);
    expect(find.text('Exported 1 pack.'), findsOneWidget);
    final saved = files.saved.single;
    expect(saved.name, 'Alltag.langtool');
    final packs =
        (repos.transfer.decode(saved.bytes) as Ok<List<PackFilePack>>).value;
    expect([for (final p in packs) p.name], ['Alltag']);
    expect(packs.single.entries.single.term, 'Haus');
    expect(packs.single.decks.single.name, 'Nouns');
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('reports several exported packs', (tester) async {
    await tester.runAsync(createPacks);
    await openExport(tester);

    await tester.tap(find.text('Select all'));
    await settle(tester);
    await tapExport(tester);

    expect(find.text('Exported 2 packs.'), findsOneWidget);
    final packs = (repos.transfer.decode(
      files.saved.single.bytes,
    ) as Ok<List<PackFilePack>>).value;
    expect([for (final p in packs) p.name], ['Alltag', 'Reise']);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('stays without a message when the save is cancelled', (
    tester,
  ) async {
    files.cancelSave = true;
    await tester.runAsync(createPacks);
    await openExport(tester);

    await tester.tap(find.text('Alltag'));
    await settle(tester);
    await tapExport(tester);

    expect(find.widgetWithText(AppBar, 'Export'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(exportButton(tester).onPressed, isNotNull);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('shows a failed save', (tester) async {
    files.saveFailure = Exception('disk full');
    await tester.runAsync(createPacks);
    await openExport(tester);

    await tester.tap(find.text('Alltag'));
    await settle(tester);
    await tapExport(tester);

    expect(find.widgetWithText(AppBar, 'Export'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });
}
