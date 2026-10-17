import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/data/local/app_database.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/ui/features/merge/view_models/merge_view_model.dart';
import 'package:langtool/ui/features/merge/views/merge_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;

  setUp(() => repos = TestRepositories());

  /// Opens the merge screen over a placeholder packs screen.
  Future<void> openMerge(WidgetTester tester) async {
    useTallWindow(tester);
    final router = await pumpRoutes(
      tester,
      repos: repos,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('packs')),
          routes: [
            GoRoute(
              path: 'merge',
              builder: (_, _) => ChangeNotifierProvider(
                create: (_) => MergeViewModel(
                  packRepository: repos.packs,
                  mergeRepository: repos.merge,
                  ownerId: 'user-1',
                ),
                child: const MergeScreen(),
              ),
            ),
          ],
        ),
      ],
    );
    router.push('/merge');
    await settle(tester);
  }

  /// Two German packs sharing "Haus", and a third pack.
  Future<(LanguagePack, LanguagePack, LanguagePack)> createPacks() async {
    final alltag = await repos.createPack('Alltag');
    await repos.addNoun(alltag, 'Haus', translations: ['house']);
    await repos.addNoun(alltag, 'Baum', article: 'der');
    await repos.createDeck(alltag, 'All');
    final reise = await repos.createPack('Reise');
    await repos.addNoun(reise, 'Haus', translations: ['home']);
    final arbeit = await repos.createPack('Arbeit');
    return (alltag, reise, arbeit);
  }

  FilledButton mergeButton(WidgetTester tester) =>
      tester.widget(find.widgetWithText(FilledButton, 'Merge'));

  Future<void> tap(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await settle(tester);
  }

  Future<List<LanguagePack>> packs() => repos.packs.watchPacks('user-1').first;

  testWidgets('says when there are no packs', (tester) async {
    await openMerge(tester);

    expect(find.text('No language packs yet.'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('needs two packs and a name, and previews the result', (
    tester,
  ) async {
    await tester.runAsync(createPacks);
    await openMerge(tester);

    expect(find.widgetWithText(AppBar, 'Merge packs'), findsOneWidget);
    expect(find.text('Keep originals'), findsOneWidget);
    expect(find.text('Delete originals'), findsOneWidget);
    expect(mergeButton(tester).onPressed, isNull);

    await tap(tester, 'Alltag');
    expect(find.textContaining('duplicate'), findsNothing);
    await tap(tester, 'Reise');
    expect(
      find.text(
        '3 entries from 2 packs → 2 entries · 1 duplicate combined · 1 deck',
      ),
      findsOneWidget,
    );
    expect(mergeButton(tester).onPressed, isNull);

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Mix');
    await tester.pump();
    expect(mergeButton(tester).onPressed, isNotNull);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('packs of another language cannot be selected', (tester) async {
    await tester.runAsync(() async {
      final (_, _, arbeit) = await createPacks();
      await (repos.db.update(repos.db.languagePacks)
            ..where((p) => p.id.equals(arbeit.id)))
          .write(const LanguagePacksCompanion(languageCode: Value('hu')));
    });
    await openMerge(tester);

    CheckboxListTile tile(String name) =>
        tester.widget(find.widgetWithText(CheckboxListTile, name));
    expect(tile('Arbeit').onChanged, isNotNull);
    await tap(tester, 'Alltag');
    expect(tile('Arbeit').onChanged, isNull);
    expect(tile('Reise').onChanged, isNotNull);
    await tap(tester, 'Alltag');
    expect(tile('Arbeit').onChanged, isNotNull);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('keep mode merges without asking and keeps the packs', (
    tester,
  ) async {
    await tester.runAsync(createPacks);
    await openMerge(tester);

    await tap(tester, 'Alltag');
    await tap(tester, 'Reise');
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Mix');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Merge'));
    await settle(tester);

    expect(find.text('packs'), findsOneWidget);
    expect(find.text('Merged 2 packs into "Mix".'), findsOneWidget);
    final names = (await tester.runAsync(packs))!.map((p) => p.name);
    expect(names, unorderedEquals(['Alltag', 'Reise', 'Arbeit', 'Mix']));
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('delete mode asks first and deletes the merged packs', (
    tester,
  ) async {
    await tester.runAsync(createPacks);
    await openMerge(tester);

    await tap(tester, 'Alltag');
    await tap(tester, 'Reise');
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Mix');
    await tap(tester, 'Delete originals');
    await tester.tap(find.widgetWithText(FilledButton, 'Merge'));
    await settle(tester);

    expect(find.text('Delete the original packs?'), findsOneWidget);
    await tap(tester, 'Cancel');
    expect(find.widgetWithText(AppBar, 'Merge packs'), findsOneWidget);
    expect((await tester.runAsync(packs))!, hasLength(3));

    await tester.tap(find.widgetWithText(FilledButton, 'Merge'));
    await settle(tester);
    await tap(tester, 'Merge and delete');

    expect(find.text('Merged 2 packs into "Mix".'), findsOneWidget);
    final names = (await tester.runAsync(packs))!.map((p) => p.name);
    expect(names, unorderedEquals(['Arbeit', 'Mix']));
    await disposeAndClose(tester, repos.db);
  });
}
