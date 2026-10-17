import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/data/repositories/auth_repository.dart';
import 'package:langtool/data/services/file_service.dart';
import 'package:langtool/ui/features/packs/view_models/packs_view_model.dart';
import 'package:langtool/ui/features/packs/views/packs_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/fake_file_service.dart';
import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;
  late FakeFileService files;

  setUp(() {
    repos = TestRepositories();
    files = FakeFileService();
  });

  Future<void> openDrawer(WidgetTester tester) async {
    await pumpRoutes(
      tester,
      repos: repos,
      providers: [
        ...signedInProviders(repos),
        Provider<FileService>.value(value: files),
      ],
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
              path: 'import',
              builder: (_, state) => Scaffold(
                body: Text('import ${(state.extra! as Uint8List).join(',')}'),
              ),
            ),
            GoRoute(
              path: 'export',
              builder: (_, _) => const Scaffold(body: Text('export')),
            ),
            GoRoute(
              path: 'merge',
              builder: (_, _) => const Scaffold(body: Text('merge')),
            ),
          ],
        ),
      ],
    );
    await tester.tap(find.byIcon(Icons.menu));
    await settle(tester);
  }

  testWidgets('shows the account, Import, Export and Sign out', (tester) async {
    await openDrawer(tester);

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('Import'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Merge packs'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('signs out', (tester) async {
    await openDrawer(tester);
    final auth = tester
        .element(find.byType(PacksScreen))
        .read<AuthRepository>();

    await tester.tap(find.text('Sign out'));
    await settle(tester);

    expect(auth.isSignedIn, isFalse);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('Import stays on the packs when the pick is cancelled', (
    tester,
  ) async {
    await openDrawer(tester);

    await tester.tap(find.text('Import'));
    await settle(tester);

    expect(files.pickCount, 1);
    expect(find.byType(Drawer), findsNothing);
    expect(find.text('Language packs'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('Import opens the preview with the picked bytes', (tester) async {
    files.nextPick = PickedFile(
      name: 'a.langtool',
      bytes: Uint8List.fromList([1, 2, 3]),
    );
    await openDrawer(tester);

    await tester.tap(find.text('Import'));
    await settle(tester);

    expect(find.text('import 1,2,3'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('Import shows an error when the file dialog fails', (
    tester,
  ) async {
    files.pickFailure = Exception('no file dialog');
    await openDrawer(tester);

    await tester.tap(find.text('Import'));
    await settle(tester);

    expect(
      find.text('Something went wrong: Exception: no file dialog'),
      findsOneWidget,
    );
    expect(find.text('Language packs'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('Merge packs opens the merge screen', (tester) async {
    await openDrawer(tester);

    await tester.tap(find.text('Merge packs'));
    await settle(tester);

    expect(find.text('merge'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('Export opens the export screen', (tester) async {
    await openDrawer(tester);

    await tester.tap(find.text('Export'));
    await settle(tester);

    expect(find.text('export'), findsOneWidget);
    await disposeAndClose(tester, repos.db);
  });
}
