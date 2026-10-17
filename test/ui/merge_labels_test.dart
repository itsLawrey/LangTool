import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/ui/core/merge_labels.dart';

void main() {
  test('mergeSummary counts entries, duplicates and decks', () {
    expect(
      mergeSummary((packs: 3, entries: 12, mergedEntries: 10, decks: 1)),
      '12 entries from 3 packs → 10 entries · 2 duplicates combined · 1 deck',
    );
    expect(
      mergeSummary((packs: 2, entries: 2, mergedEntries: 1, decks: 0)),
      '2 entries from 2 packs → 1 entry · 1 duplicate combined · 0 decks',
    );
  });

  test('clashNote names the form and the pack', () {
    expect(
      clashNote('de', (formKey: 'plural', value: 'Haeuser', packName: 'B')),
      'Plural (from B): Haeuser',
    );
  });

  test('mergedLabel names the new pack', () {
    expect(mergedLabel(packs: 2, name: 'Mix'), 'Merged 2 packs into "Mix".');
  });
}
