import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/entry_draft.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/routing/routes.dart';
import 'package:langtool/ui/core/widgets/entry_card.dart';
import 'package:langtool/ui/features/recap/deck_detail/view_models/deck_detail_view_model.dart';
import 'package:langtool/ui/features/recap/deck_detail/views/deck_detail_screen.dart';
import 'package:langtool/utils/result.dart';
import 'package:provider/provider.dart';

import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;
  late Deck deck;

  Future<GoRouter> openDeck(
    WidgetTester tester, {
    String? deckId,
    int pageSize = 50,
  }) async {
    final router = await pumpRoutes(
      tester,
      repos: repos,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('decks')),
          routes: [
            GoRoute(
              path: 'packs/:packId/entries/:entryId',
              builder: (_, state) => Scaffold(
                body: Text('detail ${state.pathParameters['entryId']}'),
              ),
            ),
            GoRoute(
              path: 'packs/:packId/recap/decks/:deckId',
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => DeckDetailViewModel(
                  deckRepository: repos.decks,
                  packRepository: repos.packs,
                  packId: state.pathParameters['packId']!,
                  deckId: state.pathParameters['deckId']!,
                  pageSize: pageSize,
                ),
                child: const DeckDetailScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, _) => const Scaffold(body: Text('edit form')),
                ),
                GoRoute(
                  path: 'session',
                  builder: (_, state) => Scaffold(
                    body: Text(
                      'session ${state.uri.queryParameters['direction']}',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    router.push(Routes.deck(pack.id, deckId ?? deck.id));
    await settle(tester);
    return router;
  }

  FilledButton startButton(WidgetTester tester) => tester.widget<FilledButton>(
    find.ancestor(of: find.text('Start'), matching: find.byType(FilledButton)),
  );

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack();
    deck = await repos.createDeck(pack, 'Nouns', const [
      DeckFilter.wordTypes({WordType.noun}),
    ]);
  });

  testWidgets('cannot start while no entries match', (tester) async {
    await openDeck(tester);

    expect(find.text('Nouns'), findsOneWidget);
    expect(find.text('Noun'), findsOneWidget);
    expect(find.text('No entries match.'), findsOneWidget);
    expect(find.byType(EntryCard), findsNothing);
    expect(startButton(tester).onPressed, isNull);

    await tester.runAsync(() => repos.addNoun(pack, 'Haus'));
    await settle(tester);

    expect(find.text('1 entry'), findsOneWidget);
    expect(find.byType(EntryCard), findsOneWidget);
    expect(startButton(tester).onPressed, isNotNull);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('starts a session with the chosen card side', (tester) async {
    await tester.runAsync(() => repos.addNoun(pack, 'Haus'));
    final router = await openDeck(tester);

    await tester.tap(find.text('Start'));
    await settle(tester);
    expect(find.text('German first'), findsOneWidget);
    expect(find.text('Translation first'), findsOneWidget);
    expect(find.text('Mixed'), findsOneWidget);

    await tester.tap(find.text('Translation first'));
    await settle(tester);

    expect(find.text('session translationFirst'), findsOneWidget);
    expect(
      router.state.uri.toString(),
      '/packs/${pack.id}/recap/decks/${deck.id}/session'
      '?direction=translationFirst',
    );
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('dismissing the card side choice stays on the deck', (
    tester,
  ) async {
    await tester.runAsync(() => repos.addNoun(pack, 'Haus'));
    await openDeck(tester);

    await tester.tap(find.text('Start'));
    await settle(tester);
    await tester.tapAt(const Offset(5, 5));
    await settle(tester);

    expect(find.text('German first'), findsNothing);
    expect(find.text('Start'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('opens the editor', (tester) async {
    await openDeck(tester);

    await tester.tap(find.byTooltip('Edit'));
    await settle(tester);

    expect(find.text('edit form'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('deletes the deck after confirming', (tester) async {
    await openDeck(tester);

    await tester.tap(find.byTooltip('Delete'));
    await settle(tester);
    expect(find.text('Delete "Nouns"?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Start'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settle(tester);

    expect(find.text('decks'), findsOneWidget);
    final result = await tester.runAsync(() => repos.decks.getDeck(deck.id));
    expect(result, isA<Err<Deck>>());
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('lists the matching entries below the overview', (tester) async {
    await tester.runAsync(() async {
      await repos.addNoun(pack, 'Haus');
      await repos.addNoun(pack, 'Auto');
      await repos.entries.add(
        EntryDraft(packId: pack.id, wordType: WordType.adverb, term: 'gern'),
      );
    });
    await openDeck(tester);

    final cards = tester.widgetList<EntryCard>(find.byType(EntryCard));
    expect([for (final card in cards) card.entry.term], ['Auto', 'Haus']);
    expect(find.text('gern'), findsNothing);
    expect(
      tester.getTopLeft(find.byType(EntryCard).first).dy,
      greaterThan(tester.getBottomLeft(find.text('Start')).dy),
    );
    expect(find.byType(SearchBar), findsNothing);
    expect(find.byType(TextField), findsNothing);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('loads older entries while scrolling to the end', (tester) async {
    await tester.runAsync(() async {
      for (var i = 0; i < 30; i++) {
        await repos.addNoun(pack, 'Wort${i.toString().padLeft(2, '0')}');
      }
    });
    await openDeck(tester, pageSize: 10);

    expect(find.text('30 entries'), findsOneWidget);
    expect(find.text('das Wort29'), findsOneWidget);
    expect(find.text('das Wort00'), findsNothing);

    for (var i = 0; i < 40 && find.text('das Wort00').evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await settle(tester);
    }

    expect(find.text('das Wort00'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('opens an entry', (tester) async {
    final haus = (await tester.runAsync(() => repos.addNoun(pack, 'Haus')))!;
    final router = await openDeck(tester);

    await tester.tap(find.text('das Haus'));
    await settle(tester);

    expect(find.text('detail ${haus.id}'), findsOneWidget);
    expect(router.state.uri.toString(), Routes.entry(pack.id, haus.id));
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('a missing deck is reported', (tester) async {
    await openDeck(tester, deckId: 'nope');

    expect(find.text('This deck no longer exists.'), findsOneWidget);
    expect(find.byTooltip('Edit'), findsNothing);
    await disposeAndClose(tester, repos.db);
  });
}
