import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:langtool/app_scope.dart';
import 'package:langtool/data/local/app_database.dart';
import 'package:langtool/data/services/file_service.dart';

import '../test/helpers/fake_auth_service.dart';
import '../test/helpers/fake_file_service.dart';
import '../test/helpers/fake_remote_sync_api.dart';

/// End-to-end flows through the real app on a device (run with
/// `flutter test integration_test -d linux`). Keep all flows in this one
/// file: on Linux desktop the runner cannot launch a second integration test
/// file in the same run. Sign-in and the cloud are
/// faked; everything else (UI, routing, view models, database, sync engine)
/// is the production code.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late FakeAuthService auth;
  late FakeRemoteSyncApi server;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    auth = FakeAuthService();
    server = FakeRemoteSyncApi();
  });

  /// Waits for real time to pass; `pumpAndSettle` would wait forever on the
  /// sync spinner while a sync runs.
  Future<void> wait(WidgetTester tester, [int steps = 10]) async {
    for (var i = 0; i < steps; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await wait(tester);
  }

  Future<void> enter(WidgetTester tester, String label, String text) =>
      tester.enterText(find.widgetWithText(TextField, label).first, text);

  Future<void> addNoun(
    WidgetTester tester,
    String term,
    String translation, {
    String article = 'das',
  }) async {
    await tapText(tester, 'New entry');
    await enter(tester, 'Term', term);
    await tapText(tester, 'Article');
    await tapText(tester, article);
    await enter(tester, 'Translation', translation);
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await wait(tester);
  }

  testWidgets('sign in, build a pack, search, edit, delete, sync', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppScope(
        dependencies: AppDependencies(
          database: database,
          authService: auth,
          syncApi: server,
        ),
      ),
    );
    await wait(tester);

    // Sign in.
    await enter(tester, 'Email', 'lorand@example.com');
    await enter(tester, 'Password', 'secret1');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await wait(tester);
    expect(find.text('Language packs'), findsOneWidget);

    // Create and open a pack.
    await tapText(tester, 'New pack');
    await tester.enterText(find.byType(TextField), 'Alltag');
    await tapText(tester, 'Create');
    await tapText(tester, 'Alltag');
    expect(find.text('No entries yet.'), findsOneWidget);

    // Add entries; a typo of an existing word asks first.
    await addNoun(tester, 'Haus', 'house');
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('das Haus'), findsOneWidget);

    await addNoun(tester, 'Hasu', 'typo');
    expect(find.text('Similar entries exist'), findsOneWidget);
    await tapText(tester, 'Cancel');
    await tester.pageBack();
    await wait(tester);
    await addNoun(tester, 'Auto', 'car');
    expect(find.text('das Auto'), findsOneWidget);

    // Search by translation.
    await tester.enterText(find.byType(SearchBar), 'car');
    await wait(tester, 5);
    expect(find.text('das Auto'), findsOneWidget);
    expect(find.text('das Haus'), findsNothing);
    await tester.tap(find.byTooltip('Clear'));
    await wait(tester, 5);
    expect(find.text('das Haus'), findsOneWidget);

    // Edit from the detail view.
    await tapText(tester, 'das Haus');
    await tester.tap(find.byTooltip('Entry actions').last);
    await wait(tester, 5);
    await tapText(tester, 'Edit');
    await enter(tester, 'Notes', 'neuter');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await wait(tester);
    expect(find.text('neuter'), findsOneWidget);

    // Delete it.
    await tester.tap(find.byTooltip('Entry actions').last);
    await wait(tester, 5);
    await tapText(tester, 'Delete');
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await wait(tester);
    expect(find.text('das Haus'), findsNothing);
    expect(find.text('das Auto'), findsOneWidget);

    // Sync uploads everything, including the deletion.
    await tester.tap(find.byType(IconButton).last);
    await wait(tester, 20);
    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    final serverTerms = {
      for (final r in server.entries.values)
        r.value.term: r.value.deletedAt != null,
    };
    expect(serverTerms, {'Haus': true, 'Auto': false});

    await tester.pumpWidget(const SizedBox());
    await database.close();
  });

  testWidgets('a second device signs in and gets the data', (tester) async {
    // Device one already uploaded a pack with an entry.
    final first = AppDatabase(NativeDatabase.memory());
    final firstAuth = FakeAuthService()..emitSignedIn();
    await tester.pumpWidget(
      AppScope(
        dependencies: AppDependencies(
          database: first,
          authService: firstAuth,
          syncApi: server,
        ),
      ),
    );
    await wait(tester);
    await tapText(tester, 'New pack');
    await tester.enterText(find.byType(TextField), 'Reise');
    await tapText(tester, 'Create');
    await tapText(tester, 'Reise');
    await addNoun(tester, 'Ticket', 'ticket');
    await wait(tester, 40); // Upload after the edit debounce.
    await tester.pumpWidget(const SizedBox());
    await first.close();
    expect(server.entries, hasLength(1));

    // Device two starts empty and signs in.
    await tester.pumpWidget(
      AppScope(
        key: UniqueKey(),
        dependencies: AppDependencies(
          database: database,
          authService: auth,
          syncApi: server,
        ),
      ),
    );
    await wait(tester);
    await enter(tester, 'Email', 'lorand@example.com');
    await enter(tester, 'Password', 'secret1');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await wait(tester, 20);

    await tapText(tester, 'Reise');
    expect(find.text('das Ticket'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await database.close();
  });

  testWidgets('build a word type deck, practise it, see the summary', (
    tester,
  ) async {
    auth.emitSignedIn();
    await tester.pumpWidget(
      AppScope(
        dependencies: AppDependencies(
          database: database,
          authService: auth,
          syncApi: server,
        ),
      ),
    );
    await wait(tester);

    // A pack with two nouns.
    await tapText(tester, 'New pack');
    await tester.enterText(find.byType(TextField), 'Alltag');
    await tapText(tester, 'Create');
    await tapText(tester, 'Alltag');
    await addNoun(tester, 'Haus', 'house');
    await addNoun(tester, 'Auto', 'car');

    // The Recap tab starts empty.
    await tapText(tester, 'Recap');
    expect(find.text('No decks yet.'), findsOneWidget);

    // Create a deck of nouns; the count follows the filters live.
    await tapText(tester, 'New deck');
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Nomen');
    await tester.tap(find.widgetWithText(FilterChip, 'Verb'));
    await wait(tester, 5);
    expect(find.text('0 entries match'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilterChip, 'Noun'));
    await wait(tester, 5);
    expect(find.text('2 entries match'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await wait(tester);

    // The deck page lists the deck's entries and starts a session after
    // choosing the card side.
    expect(find.text('Nomen'), findsWidgets);
    expect(find.text('das Haus'), findsOneWidget);
    expect(find.text('das Auto'), findsOneWidget);
    await tapText(tester, 'Start');
    expect(find.text('Card side'), findsOneWidget);
    await tapText(tester, 'German first');

    expect(find.text('1 / 2'), findsOneWidget);
    await tapText(tester, 'Reveal');
    await tapText(tester, 'Knew it');
    expect(find.text('2 / 2'), findsOneWidget);
    await tapText(tester, 'Reveal');
    await tapText(tester, "Didn't know");

    expect(find.text('Session complete'), findsOneWidget);
    expect(find.text('Knew 1 of 2'), findsOneWidget);
    expect(find.text("Didn't know 1"), findsOneWidget);
    await tapText(tester, 'Done');
    expect(find.text('Start'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await database.close();
  });

  testWidgets('export a pack with its deck and import it as a copy', (
    tester,
  ) async {
    auth.emitSignedIn();
    final files = FakeFileService();
    await tester.pumpWidget(
      AppScope(
        dependencies: AppDependencies(
          database: database,
          authService: auth,
          syncApi: server,
          fileService: files,
        ),
      ),
    );
    await wait(tester);

    // A pack with an entry and a deck.
    await tapText(tester, 'New pack');
    await tester.enterText(find.byType(TextField), 'Alltag');
    await tapText(tester, 'Create');
    await tapText(tester, 'Alltag');
    await addNoun(tester, 'Haus', 'house');
    await tapText(tester, 'Recap');
    await tapText(tester, 'New deck');
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Alle');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await wait(tester);
    await tester.pageBack();
    await wait(tester);
    await tester.pageBack();
    await wait(tester);
    expect(find.text('Language packs'), findsOneWidget);

    // Export it from the drawer.
    await tester.tap(find.byIcon(Icons.menu));
    await wait(tester, 5);
    await tapText(tester, 'Export');
    await tapText(tester, 'Alltag');
    await tester.tap(find.widgetWithText(FilledButton, 'Export'));
    await wait(tester);
    expect(find.text('Exported 1 pack.'), findsOneWidget);
    final file = files.saved.single;
    expect(file.name, 'Alltag.langtool');
    // Let the message time out, so the next one is shown right away.
    for (
      var i = 0;
      i < 100 && find.byType(SnackBar).evaluate().isNotEmpty;
      i++
    ) {
      await wait(tester, 1);
    }

    // Import the file: the preview lists the pack, importing adds a copy.
    files.nextPick = PickedFile(name: file.name, bytes: file.bytes);
    await tester.tap(find.byIcon(Icons.menu));
    await wait(tester, 5);
    await tapText(tester, 'Import');
    expect(find.text('German · 1 entry · 1 deck'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Import'));
    await wait(tester);
    expect(find.text('Imported 1 pack with 1 entry.'), findsOneWidget);
    expect(find.text('Alltag'), findsNWidgets(2));

    // Both packs, the original and the copy, hold the entry and the deck.
    for (final index in [0, 1]) {
      await tester.tap(find.text('Alltag').at(index));
      await wait(tester);
      expect(find.text('das Haus'), findsOneWidget);
      await tapText(tester, 'Recap');
      expect(find.text('Alle'), findsOneWidget);
      await tester.pageBack();
      await wait(tester);
    }

    await tester.pumpWidget(const SizedBox());
    await database.close();
  });

  testWidgets('merge two packs sharing an entry, deleting the originals', (
    tester,
  ) async {
    auth.emitSignedIn();
    await tester.pumpWidget(
      AppScope(
        dependencies: AppDependencies(
          database: database,
          authService: auth,
          syncApi: server,
        ),
      ),
    );
    await wait(tester);

    // Two packs that both have "Haus", with different articles and
    // translations.
    for (final (pack, article, translation) in [
      ('Alltag', 'das', 'house'),
      ('Reise', 'der', 'home'),
    ]) {
      await tapText(tester, 'New pack');
      await tester.enterText(find.byType(TextField), pack);
      await tapText(tester, 'Create');
      await tapText(tester, pack);
      await addNoun(tester, 'Haus', translation, article: article);
      await tester.pageBack();
      await wait(tester);
    }

    // Merge them from the drawer, deleting the originals.
    await tester.tap(find.byIcon(Icons.menu));
    await wait(tester, 5);
    await tapText(tester, 'Merge packs');
    await tapText(tester, 'Alltag');
    await tapText(tester, 'Reise');
    expect(
      find.text(
        '2 entries from 2 packs → 1 entry · 1 duplicate combined · 0 decks',
      ),
      findsOneWidget,
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Mix');
    await tapText(tester, 'Delete originals');
    await tester.tap(find.widgetWithText(FilledButton, 'Merge'));
    await wait(tester);
    await tapText(tester, 'Merge and delete');
    expect(find.text('Merged 2 packs into "Mix".'), findsOneWidget);
    expect(find.text('Alltag'), findsNothing);
    expect(find.text('Reise'), findsNothing);

    // One entry with both translations; the newer article wins and the
    // other is kept in the notes.
    await tapText(tester, 'Mix');
    expect(find.text('der Haus'), findsOneWidget);
    expect(find.text('house, home'), findsOneWidget);
    await tapText(tester, 'der Haus');
    expect(find.textContaining('Article (from Alltag): das'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await database.close();
  });

  testWidgets('move an entry to another pack from its card', (tester) async {
    auth.emitSignedIn();
    await tester.pumpWidget(
      AppScope(
        dependencies: AppDependencies(
          database: database,
          authService: auth,
          syncApi: server,
        ),
      ),
    );
    await wait(tester);

    for (final pack in ['Alltag', 'Reise']) {
      await tapText(tester, 'New pack');
      await tester.enterText(find.byType(TextField), pack);
      await tapText(tester, 'Create');
    }
    await tapText(tester, 'Alltag');
    await addNoun(tester, 'Haus', 'house');
    expect(find.text('Noun'), findsOneWidget);

    // The card's corner menu moves it to Reise.
    await tester.tap(find.byTooltip('Entry actions'));
    await wait(tester, 5);
    await tapText(tester, 'Move to…');
    await tapText(tester, 'Reise');
    expect(find.text('Moved to "Reise".'), findsOneWidget);
    expect(find.text('das Haus'), findsNothing);

    await tester.pageBack();
    await wait(tester);
    await tapText(tester, 'Reise');
    expect(find.text('das Haus'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await database.close();
  });
}
