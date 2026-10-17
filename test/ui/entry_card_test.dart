import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/languages/german.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/ui/core/widgets/entry_card.dart';

void main() {
  testWidgets('shows headword, type, forms, translations and tags', (
    tester,
  ) async {
    var tapped = false;
    final now = DateTime.utc(2026, 10, 15);
    final entry = Entry(
      id: 'entry-1',
      ownerId: 'user-1',
      packId: 'pack-1',
      wordType: WordType.noun,
      term: 'Haus',
      forms: {'article': 'das', 'plural': 'Häuser'},
      translations: ['house', 'ház'],
      examples: [const Example(text: 'Das Haus ist groß.')],
      tags: ['A1'],
      schemaVersion: 1,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EntryCard(
            entry: entry,
            schema: german,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('das Haus, Häuser'), findsOneWidget);
    expect(find.text('Noun'), findsOneWidget);
    expect(find.textContaining('Plural'), findsNothing);
    expect(find.text('house, ház'), findsOneWidget);
    expect(find.text('A1'), findsOneWidget);
    expect(find.text('Das Haus ist groß.'), findsNothing);

    await tester.tap(find.byType(EntryCard));
    expect(tapped, isTrue);
  });

  testWidgets('shows the menu in the corner next to the word type', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 10, 15);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EntryCard(
            entry: Entry(
              id: 'entry-1',
              ownerId: 'user-1',
              packId: 'pack-1',
              wordType: WordType.noun,
              term: 'Haus',
              forms: {'article': 'das'},
              schemaVersion: 1,
              createdAt: now,
              updatedAt: now,
            ),
            schema: german,
            onTap: () {},
            menu: const Icon(Icons.more_vert),
          ),
        ),
      ),
    );

    final type = tester.getRect(find.text('Noun'));
    final menu = tester.getRect(find.byIcon(Icons.more_vert));
    expect(type.right, lessThanOrEqualTo(menu.left));
    expect(
      menu.right,
      greaterThan(tester.getRect(find.text('das Haus')).right),
    );
  });

  Future<void> pumpCard(WidgetTester tester, Entry entry) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: EntryCard(entry: entry, schema: german, onTap: () {}),
      ),
    ),
  );

  Entry entry(WordType type, String term, Map<String, String> forms) => Entry(
    id: term,
    ownerId: 'user-1',
    packId: 'pack-1',
    wordType: type,
    term: term,
    forms: forms,
    schemaVersion: 1,
    createdAt: DateTime.utc(2026, 10, 15),
    updatedAt: DateTime.utc(2026, 10, 15),
  );

  testWidgets('shows verb forms as values only, joined with |', (tester) async {
    await pumpCard(
      tester,
      entry(WordType.verb, 'hin|sehen', {
        'present': 'sieht hin',
        'preterite': 'sah hin',
        'perfect': 'hat hingesehen',
      }),
    );

    expect(find.text('hin|sehen'), findsOneWidget);
    expect(find.text('sieht hin | sah hin | hat hingesehen'), findsOneWidget);
  });

  testWidgets('skips empty verb forms', (tester) async {
    await pumpCard(
      tester,
      entry(WordType.verb, 'gehen', {
        'present': 'geht',
        'perfect': 'ist gegangen',
      }),
    );

    expect(find.text('geht | ist gegangen'), findsOneWidget);
  });

  testWidgets('shows comparative and superlative of adjectives', (
    tester,
  ) async {
    await pumpCard(
      tester,
      entry(WordType.adjective, 'gut', {
        'comparative': 'besser',
        'superlative': 'am besten',
      }),
    );

    expect(find.text('gut'), findsOneWidget);
    expect(find.text('besser | am besten'), findsOneWidget);
  });

  testWidgets('puts a noun plural after the term, with no forms line', (
    tester,
  ) async {
    await pumpCard(
      tester,
      entry(WordType.noun, 'Wette', {'article': 'die', 'plural': '-n'}),
    );

    expect(find.text('die Wette, -n'), findsOneWidget);
    expect(find.textContaining('|'), findsNothing);
  });

  testWidgets('a noun without plural shows just the headword', (tester) async {
    await pumpCard(tester, entry(WordType.noun, 'Obst', {'article': 'das'}));

    expect(find.text('das Obst'), findsOneWidget);
  });
}
