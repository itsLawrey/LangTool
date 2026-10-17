import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/routing/routes.dart';
import 'package:langtool/ui/features/recap/deck_editor/view_models/deck_editor_view_model.dart';
import 'package:langtool/ui/features/recap/deck_editor/views/deck_editor_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;

  Widget editor(GoRouterState state) => ChangeNotifierProvider(
    create: (_) => DeckEditorViewModel(
      deckRepository: repos.decks,
      packRepository: repos.packs,
      packId: state.pathParameters['packId']!,
      deckId: state.pathParameters['deckId'],
      now: () => DateTime(2026, 10, 15, 12),
    ),
    child: const DeckEditorScreen(),
  );

  /// Opens [location] over a placeholder deck list; the deck page is a
  /// placeholder too.
  Future<GoRouter> open(WidgetTester tester, String location) async {
    useTallWindow(tester);
    final router = await pumpRoutes(
      tester,
      repos: repos,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('decks')),
          routes: [
            GoRoute(
              path: 'packs/:packId/recap/decks/new',
              builder: (_, state) => editor(state),
            ),
            GoRoute(
              path: 'packs/:packId/recap/decks/:deckId',
              builder: (_, state) => Scaffold(
                body: Text('deck ${state.pathParameters['deckId']}'),
              ),
              routes: [
                GoRoute(path: 'edit', builder: (_, state) => editor(state)),
              ],
            ),
          ],
        ),
      ],
    );
    router.push(location);
    await settle(tester);
    return router;
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await settle(tester);
  }

  Future<List<Deck>> storedDecks(WidgetTester tester) async =>
      (await tester.runAsync(() => repos.decks.watchDecks(pack.id).first))!;

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack();
    repos.now = DateTime(2026, 10, 1, 12).toUtc();
    await repos.addNoun(pack, 'Haus');
    repos.now = DateTime(2026, 10, 15, 12).toUtc();
    await repos.addNoun(pack, 'Baum', article: 'der');
  });

  testWidgets('the count follows the word type chips', (tester) async {
    await open(tester, Routes.newDeck(pack.id));

    expect(find.text('New deck'), findsOneWidget);
    expect(find.text('2 entries match'), findsOneWidget);

    await tapAndSettle(tester, find.widgetWithText(FilterChip, 'Verb'));
    expect(find.text('0 entries match'), findsOneWidget);

    await tapAndSettle(tester, find.widgetWithText(FilterChip, 'Noun'));
    expect(find.text('2 entries match'), findsOneWidget);

    await tapAndSettle(tester, find.widgetWithText(FilterChip, 'Noun'));
    await tapAndSettle(tester, find.widgetWithText(FilterChip, 'Verb'));
    expect(find.text('2 entries match'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('date ranges: presets, clearing and picking', (tester) async {
    await open(tester, Routes.newDeck(pack.id));

    await tapAndSettle(tester, find.text('Between dates'));
    expect(find.text('From'), findsOneWidget);
    expect(find.text('2 entries match'), findsOneWidget);

    await tapAndSettle(tester, find.text('Today'));
    expect(find.text('15 Oct 2026'), findsNWidgets(2));
    expect(find.text('1 entry matches'), findsOneWidget);

    await tapAndSettle(tester, find.text('Last 30 days'));
    expect(find.text('16 Sep 2026'), findsOneWidget);
    expect(find.text('2 entries match'), findsOneWidget);

    await tapAndSettle(tester, find.text('Last 7 days'));
    expect(find.text('9 Oct 2026'), findsOneWidget);
    expect(find.text('1 entry matches'), findsOneWidget);

    await tapAndSettle(tester, find.byTooltip('Clear From'));
    expect(find.text('9 Oct 2026'), findsNothing);
    expect(find.text('2 entries match'), findsOneWidget);

    await tapAndSettle(tester, find.text('From'));
    await tapAndSettle(tester, find.text('10'));
    await tapAndSettle(tester, find.text('OK'));
    expect(find.text('10 Oct 2026'), findsOneWidget);
    expect(find.text('1 entry matches'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('in the last N days needs at least one day', (tester) async {
    await open(tester, Routes.newDeck(pack.id));
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Recent');

    await tapAndSettle(tester, find.text('In the last N days'));
    expect(find.widgetWithText(TextField, '7'), findsOneWidget);
    expect(find.text('1 entry matches'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Days'), '0');
    await settle(tester);
    expect(find.text('Enter 1 or more.'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
          .onPressed,
      isNull,
    );

    await tester.enterText(find.widgetWithText(TextField, 'Days'), '30');
    await settle(tester);
    expect(find.text('Enter 1 or more.'), findsNothing);
    expect(find.text('2 entries match'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('a blank name is reported', (tester) async {
    await open(tester, Routes.newDeck(pack.id));

    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Save'));

    expect(find.text('The deck name is required.'), findsOneWidget);
    expect(await storedDecks(tester), isEmpty);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'N');
    await settle(tester);
    expect(find.text('The deck name is required.'), findsNothing);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('creating a deck opens it in place of the editor', (
    tester,
  ) async {
    final router = await open(tester, Routes.newDeck(pack.id));

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Nouns');
    await tapAndSettle(tester, find.widgetWithText(FilterChip, 'Noun'));
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Save'));

    final [deck] = await storedDecks(tester);
    expect(deck.name, 'Nouns');
    expect(deck.filters, const [
      DeckFilter.wordTypes({WordType.noun}),
    ]);
    expect(find.text('deck ${deck.id}'), findsOneWidget);

    router.pop();
    await settle(tester);
    expect(find.text('decks'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('editing keeps all filters, including unknown ones', (
    tester,
  ) async {
    const unknown = DeckFilter.unknown({
      'type': 'tags',
      'values': ['a'],
    });
    final filters = [
      DeckFilter.addedBetween(from: DateTime(2026, 10, 1)),
      const DeckFilter.wordTypes({WordType.noun}),
      unknown,
    ];
    final deck = (await tester.runAsync(
      () => repos.createDeck(pack, 'Old', filters),
    ))!;
    final router = await open(tester, Routes.deck(pack.id, deck.id));
    router.push(Routes.editDeck(pack.id, deck.id));
    await settle(tester);

    expect(find.text('Edit deck'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Old'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Between dates'))
          .selected,
      isTrue,
    );
    expect(find.text('1 Oct 2026'), findsOneWidget);
    expect(
      tester
          .widget<FilterChip>(find.widgetWithText(FilterChip, 'Noun'))
          .selected,
      isTrue,
    );
    expect(find.text('Filter from a newer app version'), findsOneWidget);
    expect(find.text('0 entries match'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'New');
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Save'));

    expect(find.text('deck ${deck.id}'), findsOneWidget);
    expect(router.state.uri.path, Routes.deck(pack.id, deck.id));
    final [saved] = await storedDecks(tester);
    expect(saved.name, 'New');
    expect(saved.filters, filters);
    await disposeAndClose(tester, repos.db);
  });
}
