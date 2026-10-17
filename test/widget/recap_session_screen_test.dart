import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/entry_draft.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/domain/recap/recap_session.dart';
import 'package:langtool/routing/routes.dart';
import 'package:langtool/ui/features/recap_session/view_models/recap_direction_param.dart';
import 'package:langtool/ui/features/recap_session/view_models/recap_session_view_model.dart';
import 'package:langtool/ui/features/recap_session/views/recap_session_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;
  late Deck nouns;
  late Deck all;

  Future<void> openSession(
    WidgetTester tester,
    Deck deck, {
    RecapDirection direction = RecapDirection.foreignFirst,
  }) async {
    useTallWindow(tester);
    final router = await pumpRoutes(
      tester,
      repos: repos,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('deck page')),
          routes: [
            GoRoute(
              path: 'packs/:packId/recap/decks/:deckId/session',
              builder: (context, state) => ChangeNotifierProvider(
                create: (context) => RecapSessionViewModel(
                  deckRepository: context.read(),
                  packRepository: context.read(),
                  packId: state.pathParameters['packId']!,
                  deckId: state.pathParameters['deckId']!,
                  direction: recapDirectionFromParam(
                    state.uri.queryParameters['direction'],
                  ),
                ),
                child: const RecapSessionScreen(),
              ),
            ),
          ],
        ),
      ],
    );
    router.push(Routes.recapSession(pack.id, deck.id, direction));
    await settle(tester);
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await settle(tester);
  }

  Future<void> answerCard(WidgetTester tester, {required bool knewIt}) async {
    await tapText(tester, 'Reveal');
    await tapText(tester, knewIt ? 'Knew it' : "Didn't know");
  }

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack();
    for (final draft in [
      EntryDraft(
        packId: pack.id,
        wordType: WordType.noun,
        term: 'Haus',
        forms: {'article': 'das', 'plural': 'Häuser'},
        translations: ['house', 'home'],
        examples: [
          const Example(text: 'Das Haus ist groß.', translation: 'It is big.'),
        ],
        notes: 'neuter',
      ),
      EntryDraft(
        packId: pack.id,
        wordType: WordType.verb,
        term: 'laufen',
        translations: ['run'],
      ),
    ]) {
      await repos.entries.add(draft);
    }
    nouns = await repos.createDeck(pack, 'Nouns', [
      const DeckFilter.wordTypes({WordType.noun}),
    ]);
    all = await repos.createDeck(pack, 'All');
  });

  testWidgets('shows the foreign side first', (tester) async {
    await openSession(tester, nouns);

    expect(find.text('Nouns'), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text('das Haus'), findsOneWidget);
    expect(find.text('Noun'), findsOneWidget);
    expect(find.text('house, home'), findsNothing);
    expect(find.text('Reveal'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('shows the translations first', (tester) async {
    await openSession(
      tester,
      nouns,
      direction: RecapDirection.translationFirst,
    );

    expect(find.text('house, home'), findsOneWidget);
    expect(find.text('Noun'), findsOneWidget);
    expect(find.text('das Haus'), findsNothing);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('reveal shows the whole entry and the answer buttons', (
    tester,
  ) async {
    await openSession(tester, nouns);

    await tapText(tester, 'Reveal');

    for (final text in [
      'das Haus',
      'Noun',
      'Plural: Häuser',
      'house',
      'home',
      'Das Haus ist groß.',
      'It is big.',
      "Didn't know",
      'Knew it',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('Reveal'), findsNothing);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('answers advance the progress up to the summary', (tester) async {
    await openSession(tester, all);
    expect(find.text('1 / 2'), findsOneWidget);

    await answerCard(tester, knewIt: true);
    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('Reveal'), findsOneWidget);

    await answerCard(tester, knewIt: false);
    expect(find.text('Session complete'), findsOneWidget);
    expect(find.text('Knew 1 of 2'), findsOneWidget);
    expect(find.text("Didn't know 1"), findsOneWidget);
    expect(find.text('2 / 2'), findsNothing);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('practise again starts over', (tester) async {
    await openSession(tester, all);
    await answerCard(tester, knewIt: true);
    await answerCard(tester, knewIt: true);

    await tapText(tester, 'Practise again');

    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('Reveal'), findsOneWidget);
    await answerCard(tester, knewIt: false);
    await answerCard(tester, knewIt: false);
    expect(find.text('Knew 0 of 2'), findsOneWidget);
    expect(find.text("Didn't know 2"), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('done goes back', (tester) async {
    await openSession(tester, nouns);
    await answerCard(tester, knewIt: true);

    await tapText(tester, 'Done');

    expect(find.text('deck page'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('closing mid-session asks for confirmation', (tester) async {
    await openSession(tester, all);

    await tester.tap(find.byTooltip('Close'));
    await settle(tester);
    expect(find.text('End this session?'), findsOneWidget);
    await tapText(tester, 'Cancel');
    expect(find.text('1 / 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await settle(tester);
    await tapText(tester, 'End');

    expect(find.text('deck page'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('closing on the summary goes back directly', (tester) async {
    await openSession(tester, nouns);
    await answerCard(tester, knewIt: true);

    await tester.tap(find.byTooltip('Close'));
    await settle(tester);

    expect(find.text('End this session?'), findsNothing);
    expect(find.text('deck page'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('a deck without matching entries offers to go back', (
    tester,
  ) async {
    final adjectives = await tester.runAsync(
      () => repos.createDeck(pack, 'Adjectives', [
        const DeckFilter.wordTypes({WordType.adjective}),
      ]),
    );
    await openSession(tester, adjectives!);

    expect(find.text('No entries match this deck.'), findsOneWidget);
    await tapText(tester, 'Back');

    expect(find.text('deck page'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('fits a phone screen', (tester) async {
    await openSession(tester, nouns);
    tester.view.physicalSize = const Size(360, 560);
    await settle(tester);

    await tapText(tester, 'Reveal');
    expect(find.text('Knew it'), findsOneWidget);
    await tapText(tester, 'Knew it');
    expect(find.text('Session complete'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('a deleted deck is reported', (tester) async {
    await tester.runAsync(() => repos.decks.delete(all.id));

    await openSession(tester, all);

    expect(find.text('This deck no longer exists.'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });
}
