import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/search/entry_ranker.dart';
import 'package:langtool/domain/search/search_result.dart';

Entry _entry(String term) {
  final now = DateTime.utc(2026, 10, 15);
  return Entry(
    id: term,
    ownerId: 'user-1',
    packId: 'pack-1',
    wordType: WordType.noun,
    term: term,
    schemaVersion: 1,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('matchSearchKeys', () {
    EntryMatch? direct(
      String query,
      String term, [
      List<String> tr = const [],
    ]) => matchSearchKeys(query, term: term, translations: tr, fuzzy: false);

    test('classifies direct matches on the term', () {
      expect(
        direct('haus', 'haus'),
        const EntryMatch(MatchKind.exact, MatchField.term),
      );
      expect(
        direct('hau', 'haus'),
        const EntryMatch(MatchKind.prefix, MatchField.term),
      );
      expect(
        direct('aus', 'haus'),
        const EntryMatch(MatchKind.contains, MatchField.term),
      );
      expect(direct('xyz', 'haus'), isNull);
    });

    test('matches translations', () {
      expect(
        direct('house', 'haus', ['house', 'home']),
        const EntryMatch(MatchKind.exact, MatchField.translation),
      );
    });

    test('prefers the best match across fields', () {
      expect(
        direct('haus', 'hausaufgabe', ['haus']),
        const EntryMatch(MatchKind.exact, MatchField.translation),
      );
    });

    test('fuzzy mode returns only typo matches with their distance', () {
      expect(
        matchSearchKeys(
          'hasu',
          term: 'haus',
          translations: const [],
          fuzzy: true,
        ),
        const EntryMatch(MatchKind.fuzzy, MatchField.term, 1),
      );
    });
  });

  test('compareSearchResults orders by kind, field, distance, then term', () {
    final results = [
      SearchResult(
        _entry('Zug'),
        const EntryMatch(MatchKind.fuzzy, MatchField.term, 2),
      ),
      SearchResult(
        _entry('Baum'),
        const EntryMatch(MatchKind.contains, MatchField.term),
      ),
      SearchResult(
        _entry('Ast'),
        const EntryMatch(MatchKind.fuzzy, MatchField.term, 1),
      ),
      SearchResult(
        _entry('Haus'),
        const EntryMatch(MatchKind.exact, MatchField.translation),
      ),
      SearchResult(
        _entry('Hut'),
        const EntryMatch(MatchKind.exact, MatchField.term),
      ),
      SearchResult(
        _entry('Auto'),
        const EntryMatch(MatchKind.contains, MatchField.term),
      ),
    ]..sort(compareSearchResults);

    expect(
      [for (final r in results) r.entry.term],
      ['Hut', 'Haus', 'Auto', 'Baum', 'Ast', 'Zug'],
    );
  });
}
