import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/entry_draft.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/ui/features/entry_detail/view_models/entry_detail_view_model.dart';
import 'package:langtool/ui/features/entry_detail/views/entry_detail_screen.dart';
import 'package:langtool/utils/result.dart';
import 'package:provider/provider.dart';

import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;
  late Entry haus;

  Future<void> openDetail(WidgetTester tester) async {
    useTallWindow(tester);
    final router = await pumpRoutes(
      tester,
      repos: repos,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('timeline')),
          routes: [
            GoRoute(
              path: 'packs/:packId/entries/:entryId',
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => EntryDetailViewModel(
                  entryRepository: repos.entries,
                  packRepository: repos.packs,
                  packId: state.pathParameters['packId']!,
                  entryId: state.pathParameters['entryId']!,
                ),
                child: const EntryDetailScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, _) => const Scaffold(body: Text('edit form')),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    router.push('/packs/${pack.id}/entries/${haus.id}');
    await settle(tester);
  }

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack();
    final result = await repos.entries.add(
      EntryDraft(
        packId: pack.id,
        wordType: WordType.noun,
        term: 'Haus',
        forms: {'article': 'das', 'plural': 'Häuser'},
        translations: ['house'],
        examples: [
          const Example(text: 'Das Haus ist groß.', translation: 'It is big.'),
        ],
        tags: ['A1'],
        notes: 'neuter',
      ),
    );
    haus = (result as Ok<Entry>).value;
  });

  testWidgets('shows every field, including examples', (tester) async {
    await openDetail(tester);

    for (final text in [
      'Noun',
      'Plural: Häuser',
      'house',
      'Das Haus ist groß.',
      'It is big.',
      'A1',
      'neuter',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('das Haus'), findsNWidgets(2)); // App bar and heading.
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('opens the edit form', (tester) async {
    await openDetail(tester);

    await tester.tap(find.byTooltip('Entry actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await settle(tester);

    expect(find.text('edit form'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('deletes after confirmation and goes back', (tester) async {
    await openDetail(tester);

    await tester.tap(find.byTooltip('Entry actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete "das Haus"?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settle(tester);

    expect(find.text('timeline'), findsOneWidget);
    final remaining = await tester.runAsync(
      () => repos.entries.watchEntries(pack.id).first,
    );
    expect(remaining, isEmpty);
    await disposeAndClose(tester, repos.db);
  });

  Future<void> chooseAction(WidgetTester tester, String action) async {
    await tester.tap(find.byTooltip('Entry actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(action));
    await settle(tester);
  }

  testWidgets('Move to… moves the entry to the picked pack and goes back', (
    tester,
  ) async {
    final reise = (await tester.runAsync(() => repos.createPack('Reise')))!;
    await openDetail(tester);

    await chooseAction(tester, 'Move to…');
    expect(find.text('Move to'), findsOneWidget);
    await tester.tap(find.text('Reise'));
    await settle(tester);

    expect(find.text('timeline'), findsOneWidget);
    expect(find.text('Moved to "Reise".'), findsOneWidget);
    final moved = await tester.runAsync(
      () => repos.entries.watchEntries(reise.id).first,
    );
    expect(moved!.single.id, haus.id);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('Copy to… asks before combining with an existing entry', (
    tester,
  ) async {
    final reise = (await tester.runAsync(() async {
      final reise = await repos.createPack('Reise');
      await repos.addNoun(reise, 'Haus', article: 'der');
      return reise;
    }))!;
    await openDetail(tester);

    await chooseAction(tester, 'Copy to…');
    await tester.tap(find.text('Reise'));
    await settle(tester);
    expect(find.text('"der Haus" is already in Reise'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Combine'));
    await settle(tester);

    expect(find.text('Copied to "Reise" and combined.'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'das Haus'), findsOneWidget);
    final [combined] = (await tester.runAsync(
      () => repos.entries.watchEntries(reise.id).first,
    ))!;
    expect(combined.translations, ['house']);
    expect(combined.notes, contains('Article (from Deutsch): das'));
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('says when there is no other pack of the language', (
    tester,
  ) async {
    await openDetail(tester);

    await chooseAction(tester, 'Copy to…');

    expect(find.text('There is no other German pack.'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });
}
