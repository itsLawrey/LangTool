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

    await tester.tap(find.byTooltip('Edit'));
    await settle(tester);

    expect(find.text('edit form'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('deletes after confirmation and goes back', (tester) async {
    await openDetail(tester);

    await tester.tap(find.byTooltip('Delete'));
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
}
