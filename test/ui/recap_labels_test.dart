import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/domain/recap/recap_session.dart';
import 'package:langtool/ui/core/recap_labels.dart';

void main() {
  group('deckFilterLabel', () {
    test('describes date ranges, open on either side', () {
      final from = DateTime(2026, 10, 1);
      final to = DateTime(2026, 10, 15);
      expect(
        deckFilterLabel(DeckFilter.addedBetween(from: from, to: to)),
        'Added 1 Oct 2026 – 15 Oct 2026',
      );
      expect(
        deckFilterLabel(DeckFilter.addedBetween(from: from)),
        'Added since 1 Oct 2026',
      );
      expect(
        deckFilterLabel(DeckFilter.addedBetween(to: to)),
        'Added until 15 Oct 2026',
      );
      expect(
        deckFilterLabel(DeckFilter.addedBetween(from: to, to: to)),
        'Added on 15 Oct 2026',
      );
      expect(
        deckFilterLabel(const DeckFilter.addedBetween()),
        'Added any time',
      );
    });

    test('describes the last days', () {
      expect(
        deckFilterLabel(const DeckFilter.addedInLastDays(7)),
        'Added in the last 7 days',
      );
      expect(
        deckFilterLabel(const DeckFilter.addedInLastDays(1)),
        'Added today',
      );
    });

    test('lists word types in a fixed order', () {
      expect(
        deckFilterLabel(
          const DeckFilter.wordTypes({WordType.verb, WordType.noun}),
        ),
        'Noun, Verb',
      );
      expect(deckFilterLabel(const DeckFilter.wordTypes({})), 'No word types');
    });

    test('names filters from a newer app version', () {
      expect(
        deckFilterLabel(const DeckFilter.unknown({'type': 'tags'})),
        'Filter from a newer app version',
      );
    });
  });

  test('deckFiltersSummary joins the filters', () {
    expect(deckFiltersSummary(const []), 'All entries');
    expect(
      deckFiltersSummary(const [
        DeckFilter.addedInLastDays(30),
        DeckFilter.wordTypes({WordType.adjective}),
      ]),
      'Added in the last 30 days · Adjective',
    );
  });

  test('counts use singular and plural', () {
    expect(entryCountLabel(0), '0 entries');
    expect(entryCountLabel(1), '1 entry');
    expect(entryCountLabel(12), '12 entries');
    expect(matchCountLabel(0), '0 entries match');
    expect(matchCountLabel(1), '1 entry matches');
    expect(matchCountLabel(2), '2 entries match');
  });

  test('recapDirectionLabel names the language', () {
    expect(
      recapDirectionLabel(RecapDirection.foreignFirst, 'de'),
      'German first',
    );
    expect(
      recapDirectionLabel(RecapDirection.translationFirst, 'de'),
      'Translation first',
    );
    expect(recapDirectionLabel(RecapDirection.mixed, 'de'), 'Mixed');
  });
}
