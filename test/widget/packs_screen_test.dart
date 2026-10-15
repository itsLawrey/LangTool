import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/ui/features/packs/view_models/packs_view_model.dart';
import 'package:langtool/ui/features/packs/views/packs_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;

  Future<void> openPacks(WidgetTester tester) => pumpRoutes(
    tester,
    repos: repos,
    providers: signedInProviders(repos),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => ChangeNotifierProvider(
          create: (_) =>
              PacksViewModel(packRepository: repos.packs, ownerId: 'user-1'),
          child: const PacksScreen(),
        ),
        routes: [
          GoRoute(
            path: 'packs/:packId',
            builder: (_, state) =>
                Scaffold(body: Text('pack ${state.pathParameters['packId']}')),
          ),
        ],
      ),
    ],
  );

  Future<void> submitDialog(
    WidgetTester tester,
    String text,
    String button,
  ) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.tap(find.text(button));
    await settle(tester);
  }

  Future<void> openMenu(WidgetTester tester, String action) async {
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(action));
    await tester.pumpAndSettle();
  }

  setUp(() => repos = TestRepositories());

  testWidgets('creates a pack from the dialog', (tester) async {
    await openPacks(tester);
    expect(find.text('No language packs yet.'), findsOneWidget);

    await tester.tap(find.text('New pack'));
    await tester.pumpAndSettle();
    expect(find.text('New German pack'), findsOneWidget);
    await submitDialog(tester, 'Alltag', 'Create');

    expect(find.text('Alltag'), findsOneWidget);
    expect(find.text('German'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('shows an error for a blank name', (tester) async {
    await openPacks(tester);

    await tester.tap(find.text('New pack'));
    await tester.pumpAndSettle();
    await submitDialog(tester, '   ', 'Create');

    expect(find.text('The pack name is required.'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('renames a pack', (tester) async {
    await tester.runAsync(() => repos.createPack('Alt'));
    await openPacks(tester);

    await openMenu(tester, 'Rename');
    expect(find.widgetWithText(TextField, 'Alt'), findsOneWidget);
    await submitDialog(tester, 'Neu', 'Rename');

    expect(find.text('Neu'), findsOneWidget);
    expect(find.text('Alt'), findsNothing);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('deletes a pack only after confirmation', (tester) async {
    await tester.runAsync(() => repos.createPack('Alltag'));
    await openPacks(tester);

    await openMenu(tester, 'Delete');
    expect(find.text('Delete "Alltag"?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Alltag'), findsOneWidget);

    await openMenu(tester, 'Delete');
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settle(tester);

    expect(find.text('No language packs yet.'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('opens a pack', (tester) async {
    final pack = (await tester.runAsync(() => repos.createPack('Alltag')))!;
    await openPacks(tester);

    await tester.tap(find.text('Alltag'));
    await settle(tester);

    expect(find.text('pack ${pack.id}'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });
}
