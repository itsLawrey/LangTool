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

    expect(find.text('das Haus'), findsOneWidget);
    expect(find.text('Noun'), findsOneWidget);
    expect(find.text('Plural: Häuser'), findsOneWidget);
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
}
