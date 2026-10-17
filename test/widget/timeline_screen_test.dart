import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/ui/features/timeline/view_models/timeline_view_model.dart';
import 'package:langtool/ui/core/widgets/entry_card.dart';
import 'package:langtool/ui/features/timeline/views/timeline_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;

  Future<GoRouter> openTimeline(WidgetTester tester, {int pageSize = 50}) =>
      pumpRoutes(
        tester,
        repos: repos,
        providers: signedInProviders(repos),
        initialLocation: '/packs/${pack.id}',
        routes: [
          GoRoute(
            path: '/packs/:packId',
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) => TimelineViewModel(
                entryRepository: repos.entries,
                packRepository: repos.packs,
                packId: state.pathParameters['packId']!,
                pageSize: pageSize,
              ),
              child: const TimelineScreen(),
            ),
            routes: [
              GoRoute(
                path: 'entries/new',
                builder: (_, _) => const Scaffold(body: Text('new entry form')),
              ),
              GoRoute(
                path: 'entries/:entryId',
                builder: (_, state) => Scaffold(
                  body: Text('detail ${state.pathParameters['entryId']}'),
                ),
              ),
            ],
          ),
        ],
      );

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack('Wortschatz');
  });

  testWidgets('shows an empty pack', (tester) async {
    await openTimeline(tester);

    expect(find.text('Wortschatz'), findsOneWidget);
    expect(find.text('No entries yet.'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('loads older entries while scrolling to the end', (tester) async {
    await tester.runAsync(() async {
      for (var i = 0; i < 30; i++) {
        await repos.addNoun(pack, 'Wort${i.toString().padLeft(2, '0')}');
      }
    });
    await openTimeline(tester, pageSize: 10);

    expect(find.text('das Wort29'), findsOneWidget);
    expect(find.text('das Wort00'), findsNothing);

    for (var i = 0; i < 40 && find.text('das Wort00').evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await settle(tester);
    }

    expect(find.text('das Wort00'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('search shows best matches first and clearing restores all', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await repos.addNoun(pack, 'Haus');
      await repos.addNoun(pack, 'Krankenhaus');
      await repos.addNoun(pack, 'Baum', article: 'der');
    });
    await openTimeline(tester);

    await tester.enterText(find.byType(SearchBar), 'haus');
    await tester.pump(const Duration(milliseconds: 300));
    await settle(tester);

    final cards = tester.widgetList<EntryCard>(find.byType(EntryCard));
    expect([for (final c in cards) c.entry.term], ['Haus', 'Krankenhaus']);

    await tester.tap(find.byTooltip('Clear'));
    await settle(tester);
    expect(find.byType(EntryCard), findsNWidgets(3));
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('says when only similar entries match', (tester) async {
    await tester.runAsync(() => repos.addNoun(pack, 'Haus'));
    await openTimeline(tester);

    await tester.enterText(find.byType(SearchBar), 'hasu');
    await tester.pump(const Duration(milliseconds: 300));
    await settle(tester);

    expect(
      find.text('No exact matches. Showing similar entries.'),
      findsOneWidget,
    );
    expect(find.text('das Haus'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('opens an entry and the new-entry form', (tester) async {
    final haus = (await tester.runAsync(() => repos.addNoun(pack, 'Haus')))!;
    final router = await openTimeline(tester);

    await tester.tap(find.text('das Haus'));
    await settle(tester);
    expect(find.text('detail ${haus.id}'), findsOneWidget);

    router.pop();
    await settle(tester);
    await tester.tap(find.text('New entry'));
    await settle(tester);
    expect(find.text('new entry form'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });
}
