import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/ui/core/transfer_labels.dart';

void main() {
  test('counts decks and packs in singular and plural', () {
    expect(deckCountLabel(0), '0 decks');
    expect(deckCountLabel(1), '1 deck');
    expect(deckCountLabel(2), '2 decks');
    expect(packCountLabel(1), '1 pack');
    expect(packCountLabel(3), '3 packs');
  });

  test('summarizes a pack in a file', () {
    expect(
      packFileSummary(languageCode: 'de', entries: 12, decks: 1),
      'German · 12 entries · 1 deck',
    );
  });

  test('reports imported and exported packs', () {
    expect(
      importedLabel(packs: 1, entries: 1),
      'Imported 1 pack with 1 entry.',
    );
    expect(
      importedLabel(packs: 2, entries: 0),
      'Imported 2 packs with 0 entries.',
    );
    expect(exportedLabel(1), 'Exported 1 pack.');
    expect(exportedLabel(4), 'Exported 4 packs.');
  });
}
