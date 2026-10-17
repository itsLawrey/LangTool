import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/data/repositories/settings_repository.dart';
import 'package:langtool/data/services/in_memory_settings_store.dart';
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
  late SettingsRepository settings;
  late GoRouter router;

  Widget form(BuildContext context, String packId, {String? entryId}) =>
      ChangeNotifierProvider(
        create: (_) => EntryFormViewModel(
          entryRepository: repos.entries,
          packRepository: repos.packs,
          settingsRepository: settings,
          packId: packId,
          entryId: entryId,
        ),
        child: const EntryFormScreen(),
      );

  /// Opens the form on top of a placeholder home route, so `pop` works.
  Future<void> openForm(
    WidgetTester tester, {
    String? entryId,
    double width = 800,
  }) async {
    useTallWindow(tester);
    tester.view.physicalSize = Size(width, 2400);
    router = await pumpRoutes(
      tester,
      repos: repos,
      settings: settings,
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

  Future<void> ctrlEnter(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settle(tester);
  }

  /// The label of the focused field, or the text of the focused button.
  String? focused() {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) return null;
    final decorator = context.findAncestorWidgetOfExactType<InputDecorator>();
    if (decorator != null) return decorator.decoration.labelText;
    String? label;
    void visit(Element element) {
      if (label != null) return;
      switch (element.widget) {
        case InputDecorator(:final decoration):
          label = decoration.labelText;
        case Text(:final data):
          label = data;
        default:
          element.visitChildren(visit);
      }
    }

    context.visitChildElements(visit);
    return label;
  }

  /// Whether the [index]th text field labelled [label] has focus.
  bool hasFocus(WidgetTester tester, String label, {int index = 0}) {
    final field = tester.widget<TextField>(
      find.widgetWithText(TextField, label).at(index),
    );
    return field.focusNode!.hasFocus;
  }

  Offset topLeft(WidgetTester tester, Type type, String label) =>
      tester.getTopLeft(find.widgetWithText(type, label));

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack();
    settings = SettingsRepository(InMemorySettingsStore());
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

  testWidgets('comma mode saves the translations of one field', (tester) async {
    await settings.setCommaTranslations(true);
    await openForm(tester);

    expect(find.text('Add translation'), findsNothing);
    expect(find.text('Separate with commas.'), findsNWidgets(2));
    await enter(tester, 'Term', 'Haus');
    await choose(tester, 'Article', 'das');
    await enter(tester, 'Translations', 'house, home ,, ');
    await save(tester);

    final [entry] = await tester.runAsync(saved) ?? [];
    expect(entry.translations, ['house', 'home']);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('comma mode pre-fills the translations when editing', (
    tester,
  ) async {
    await settings.setCommaTranslations(true);
    final haus = (await tester.runAsync(
      () => repos.addNoun(pack, 'Haus', translations: ['house', 'home']),
    ))!;
    await openForm(tester, entryId: haus.id);

    expect(find.widgetWithText(TextField, 'house, home'), findsOneWidget);
    await enter(tester, 'Translations', 'home,building');
    await save(tester);

    final [entry] = await tester.runAsync(saved) ?? [];
    expect(entry.translations, ['home', 'building']);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('a noun shows article, term and plural in one row', (
    tester,
  ) async {
    await openForm(tester);

    final wordType = topLeft(
      tester,
      DropdownButtonFormField<WordType>,
      'Word type',
    );
    final article = topLeft(tester, DropdownButtonFormField<String>, 'Article');
    final term = topLeft(tester, TextFormField, 'Term');
    final plural = topLeft(tester, TextFormField, 'Plural');
    expect(wordType.dy, lessThan(article.dy));
    expect([term.dy, plural.dy], everyElement(article.dy));
    expect(article.dx, lessThan(term.dx));
    expect(term.dx, lessThan(plural.dx));

    // Other word types keep the term above their fields.
    await choose(tester, 'Noun', 'Verb');
    expect(
      topLeft(tester, TextFormField, 'Term').dy,
      lessThan(topLeft(tester, TextFormField, 'Present (er/sie/es)').dy),
    );
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('a narrow noun form stacks article, term and plural', (
    tester,
  ) async {
    await openForm(tester, width: 320);

    final article = topLeft(tester, DropdownButtonFormField<String>, 'Article');
    final term = topLeft(tester, TextFormField, 'Term');
    final plural = topLeft(tester, TextFormField, 'Plural');
    expect([term.dx, plural.dx], everyElement(article.dx));
    expect(article.dy, lessThan(term.dy));
    expect(term.dy, lessThan(plural.dy));
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('Tab skips the add and remove buttons', (tester) async {
    await openForm(tester);
    await tester.tap(find.text('Add example'));
    await tester.pump();

    await tester.tap(find.widgetWithText(TextField, 'Term'));
    await tester.pump();
    expect(focused(), 'Term');
    final order = <String?>[];
    for (var i = 0; i < 8; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      order.add(focused());
    }

    expect(order, [
      'Plural',
      'Translation',
      'Sentence',
      'Translation (optional)',
      'Tags',
      'Notes',
      'Save and new',
      'Save',
    ]);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('Enter moves on, and in the last item adds another', (
    tester,
  ) async {
    await openForm(tester);

    await tester.tap(find.widgetWithText(TextField, 'Term'));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(focused(), 'Plural');

    await tester.tap(find.widgetWithText(TextField, 'Translation'));
    await tester.enterText(find.widgetWithText(TextField, 'Translation'), 'a');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Translation'), findsNWidgets(2));
    expect(hasFocus(tester, 'Translation', index: 1), isTrue);

    await tester.tap(find.text('Add example'));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextField, 'Sentence'));
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(focused(), 'Translation (optional)');
    expect(find.widgetWithText(TextField, 'Sentence'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Sentence'), findsNWidgets(2));
    expect(hasFocus(tester, 'Sentence', index: 1), isTrue);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('Ctrl+Enter does nothing without quick add mode', (tester) async {
    await openForm(tester);

    await enter(tester, 'Term', 'Haus');
    await choose(tester, 'Article', 'das');
    await tester.tap(find.widgetWithText(TextField, 'Term'));
    await ctrlEnter(tester);

    expect(find.text('das Haus saved.'), findsNothing);
    expect(await tester.runAsync(saved), isEmpty);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('quick add mode: Ctrl+Enter saves and starts a new entry', (
    tester,
  ) async {
    await settings.setQuickAddMode(true);
    await openForm(tester);

    await enter(tester, 'Term', 'Haus');
    await choose(tester, 'Article', 'das');
    await enter(tester, 'Translation', 'house');
    await tester.tap(find.widgetWithText(TextField, 'Translation'));
    await ctrlEnter(tester);

    expect(find.text('das Haus saved.'), findsOneWidget);
    expect(find.text('New entry'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Haus'), findsNothing);
    expect(focused(), 'Term');

    await tester.enterText(find.widgetWithText(TextField, 'Term'), 'Auto');
    await choose(tester, 'Article', 'das');
    await tester.tap(find.widgetWithText(TextField, 'Term'));
    await ctrlEnter(tester);

    final entries = await tester.runAsync(saved) ?? [];
    expect(
      {for (final e in entries) e.term: e.translations},
      {
        'Haus': ['house'],
        'Auto': <String>[],
      },
    );
    expect(find.text('New entry'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('quick add mode: Ctrl+Enter saves an edit', (tester) async {
    await settings.setQuickAddMode(true);
    final haus = (await tester.runAsync(() => repos.addNoun(pack, 'Haus')))!;
    await openForm(tester, entryId: haus.id);

    await enter(tester, 'Notes', 'edited');
    await tester.tap(find.widgetWithText(TextField, 'Notes'));
    await ctrlEnter(tester);

    expect(find.text('home'), findsOneWidget);
    final [entry] = await tester.runAsync(saved) ?? [];
    expect(entry.notes, 'edited');
    await disposeAndClose(tester, repos.db);
  });
}
