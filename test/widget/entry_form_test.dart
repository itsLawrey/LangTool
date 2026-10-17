import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/ui/features/entry_form/view_models/entry_form_view_model.dart';
import 'package:langtool/ui/features/entry_form/views/entry_form_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;
  late GoRouter router;

  Widget form(BuildContext context, String packId, {String? entryId}) =>
      ChangeNotifierProvider(
        create: (_) => EntryFormViewModel(
          entryRepository: repos.entries,
          packRepository: repos.packs,
          packId: packId,
          entryId: entryId,
        ),
        child: const EntryFormScreen(),
      );

  /// Opens the form on top of a placeholder home route, so `pop` works.
  Future<void> openForm(WidgetTester tester, {String? entryId}) async {
    useTallWindow(tester);
    router = await pumpRoutes(
      tester,
      repos: repos,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, _) => form(context, pack.id),
            ),
            GoRoute(
              path: 'edit/:entryId',
              builder: (context, state) => form(
                context,
                pack.id,
                entryId: state.pathParameters['entryId'],
              ),
            ),
            GoRoute(
              path: 'packs/:packId/entries/:entryId',
              builder: (_, state) => Scaffold(
                body: Text('detail ${state.pathParameters['entryId']}'),
              ),
            ),
          ],
        ),
      ],
    );
    unawaited(router.push(entryId == null ? '/new' : '/edit/$entryId'));
    await settle(tester);
  }

  /// Run with `tester.runAsync`: drift needs real asynchrony.
  Future<List<Entry>> saved() => repos.entries.watchEntries(pack.id).first;

  Future<void> choose(
    WidgetTester tester,
    String current,
    String option,
  ) async {
    await tester.tap(find.text(current).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  Future<void> enter(
    WidgetTester tester,
    String label,
    String text, {
    int index = 0,
  }) => tester.enterText(find.widgetWithText(TextField, label).at(index), text);

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await settle(tester);
  }

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack();
  });

  testWidgets('saves only the fields of the chosen word type', (tester) async {
    await openForm(tester);

    await enter(tester, 'Term', 'gehen');
    await choose(tester, 'Article', 'das');
    await choose(tester, 'Noun', 'Verb');
    expect(find.text('Article'), findsNothing);
    await enter(tester, 'Präteritum (er/sie/es)', 'ging');
    await enter(tester, 'Perfekt', 'ist gegangen');
    await save(tester);

    expect(find.text('home'), findsOneWidget);
    final [entry] = await tester.runAsync(saved) ?? [];
    expect(entry.wordType, WordType.verb);
    expect(entry.forms, {'preterite': 'ging', 'perfect': 'ist gegangen'});
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('requires the term and the article', (tester) async {
    await openForm(tester);

    await save(tester);

    expect(find.text('Required.'), findsNWidgets(2));
    expect(await tester.runAsync(saved), isEmpty);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('saves translations, examples, tags and notes', (tester) async {
    await openForm(tester);

    await enter(tester, 'Term', 'Haus');
    await choose(tester, 'Article', 'das');
    await enter(tester, 'Translation', 'house');
    await tester.tap(find.text('Add translation'));
    await tester.pumpAndSettle();
    await enter(tester, 'Translation', 'ház', index: 1);
    await tester.tap(find.text('Add example'));
    await tester.pumpAndSettle();
    await enter(tester, 'Sentence', 'Das Haus ist groß.');
    await enter(tester, 'Translation (optional)', 'The house is big.');
    await enter(tester, 'Tags', 'A1, food');
    await enter(tester, 'Notes', 'neuter');
    await save(tester);

    final [entry] = await tester.runAsync(saved) ?? [];
    expect(entry.translations, ['house', 'ház']);
    expect(entry.examples, [
      const Example(
        text: 'Das Haus ist groß.',
        translation: 'The house is big.',
      ),
    ]);
    expect(entry.tags, ['A1', 'food']);
    expect(entry.notes, 'neuter');
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('cancelling the similar-entries popup does not save', (
    tester,
  ) async {
    await tester.runAsync(() => repos.addNoun(pack, 'Haus'));
    await openForm(tester);

    await enter(tester, 'Term', 'Hasu');
    await choose(tester, 'Article', 'das');
    await save(tester);

    expect(find.text('Similar entries exist'), findsOneWidget);
    expect(find.text('das Haus'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('New entry'), findsOneWidget);
    expect(await tester.runAsync(saved), hasLength(1));

    await save(tester);
    await tester.tap(find.text('Save anyway'));
    await settle(tester);

    expect(find.text('home'), findsOneWidget);
    expect(await tester.runAsync(saved), hasLength(2));
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('a duplicate offers to open the existing entry', (tester) async {
    final haus = (await tester.runAsync(() => repos.addNoun(pack, 'Haus')))!;
    await openForm(tester);

    await enter(tester, 'Term', ' haus ');
    await choose(tester, 'Article', 'das');
    await save(tester);

    expect(find.text('Already in this pack'), findsOneWidget);
    await tester.tap(find.text('Open existing'));
    await settle(tester);

    expect(find.text('detail ${haus.id}'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('save and new saves, then starts a blank form', (tester) async {
    await openForm(tester);

    await choose(tester, 'Noun', 'Verb');
    await enter(tester, 'Term', 'gehen');
    await enter(tester, 'Translation', 'to go');
    await tester.tap(find.text('Save and new'));
    await settle(tester);

    expect(find.text('gehen saved.'), findsOneWidget);
    expect(find.text('New entry'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'gehen'), findsNothing);
    expect(find.widgetWithText(TextField, 'to go'), findsNothing);
    expect(find.text('Verb'), findsOneWidget);

    await enter(tester, 'Term', 'laufen');
    await tester.tap(find.text('Save and new'));
    await settle(tester);

    final entries = await tester.runAsync(saved) ?? [];
    expect(entries.map((e) => (e.term, e.wordType)), [
      ('gehen', WordType.verb),
      ('laufen', WordType.verb),
    ]);
    expect(entries.first.translations, ['to go']);
    expect(find.text('New entry'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('editing pre-fills the form and saves changes', (tester) async {
    final haus = (await tester.runAsync(
      () => repos.addNoun(pack, 'Haus', translations: ['house']),
    ))!;
    await openForm(tester, entryId: haus.id);

    expect(find.text('Edit entry'), findsOneWidget);
    expect(find.text('Save and new'), findsNothing);
    expect(find.widgetWithText(TextField, 'Haus'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'house'), findsOneWidget);
    await enter(tester, 'Notes', 'edited');
    await save(tester);

    // Keeping the term skips the similar-entries check, so it saves at once.
    expect(find.text('home'), findsOneWidget);
    final [entry] = await tester.runAsync(saved) ?? [];
    expect(entry.id, haus.id);
    expect(entry.notes, 'edited');
    await disposeAndClose(tester, repos.db);
  });
}
