import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/routing/routes.dart';
import 'package:langtool/ui/features/recap/decks/view_models/decks_view_model.dart';
import 'package:langtool/ui/features/recap/decks/views/deck_card.dart';
import 'package:langtool/ui/features/recap/decks/views/decks_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;

  Future<GoRouter> openDecks(WidgetTester tester) => pumpRoutes(
    tester,
    repos: repos,
    providers: signedInProviders(repos),
    initialLocation: Routes.recap(pack.id),
    routes: [
      GoRoute(
        path: '/packs/:packId/recap',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => DecksViewModel(
            deckRepository: repos.decks,
            packRepository: repos.packs,
            packId: state.pathParameters['packId']!,
          ),
          child: const DecksScreen(),
        ),
        routes: [
          GoRoute(
            path: 'decks/new',
            builder: (_, _) => const Scaffold(body: Text('new deck form')),
          ),
          GoRoute(
            path: 'decks/:deckId',
            builder: (_, state) =>
                Scaffold(body: Text('deck ${state.pathParameters['deckId']}')),
          ),
        ],
      ),
    ],
  );

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack('Wortschatz');
  });

  testWidgets('shows an empty deck list', (tester) async {
    await openDecks(tester);

    expect(find.text('Wortschatz'), findsOneWidget);
    expect(find.text('No decks yet.'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('shows deck cards with filters and live counts', (tester) async {
    await tester.runAsync(() async {
      await repos.addNoun(pack, 'Haus');
      await repos.createDeck(pack, 'All');
      await repos.createDeck(pack, 'Verbs', const [
        DeckFilter.wordTypes({WordType.verb}),
      ]);
    });
    await openDecks(tester);

    expect(find.byType(DeckCard), findsNWidgets(2));
    expect(find.text('All entries'), findsOneWidget);
    expect(find.text('Verb'), findsOneWidget);
    expect(find.text('1 entry'), findsOneWidget);
    expect(find.text('0 entries'), findsOneWidget);

    await tester.runAsync(() => repos.addNoun(pack, 'Baum', article: 'der'));
    await settle(tester);

    expect(find.text('2 entries'), findsOneWidget);
    expect(find.text('0 entries'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('opens a deck and the new-deck form', (tester) async {
    final deck = (await tester.runAsync(() => repos.createDeck(pack, 'All')))!;
    final router = await openDecks(tester);

    await tester.tap(find.text('All'));
    await settle(tester);
    expect(find.text('deck ${deck.id}'), findsOneWidget);

    router.pop();
    await settle(tester);
    await tester.tap(find.text('New deck'));
    await settle(tester);
    expect(find.text('new deck form'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });
}
