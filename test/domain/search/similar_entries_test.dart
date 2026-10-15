import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/search/similar_entries.dart';

Entry _entry(String term, WordType wordType) {
  final now = DateTime.utc(2026, 10, 15);
  return Entry(
    id: '$term-${wordType.name}',
    ownerId: 'user-1',
    packId: 'pack-1',
    wordType: wordType,
    term: term,
    schemaVersion: 1,
    createdAt: now,
    updatedAt: now,
  );
}

List<String> _similar(String term, WordType type, List<Entry> candidates) => [
  for (final e in findSimilarEntries(
    term: term,
    wordType: type,
    candidates: candidates,
  ))
    e.id,
];

void main() {
  final haus = _entry('Haus', WordType.noun);
  final schoen = _entry('schön', WordType.adjective);
  final essenNoun = _entry('Essen', WordType.noun);
  final hund = _entry('Hund', WordType.noun);

  test('catches a typo', () {
    expect(_similar('Hasu', WordType.noun, [haus, hund]), [haus.id]);
  });

  test('catches a missing umlaut', () {
    expect(_similar('schon', WordType.adjective, [schoen]), [schoen.id]);
  });

  test('flags the same word with another type, after same-type matches', () {
    final essenVerb = _entry('essen', WordType.verb);
    final essenTypo = _entry('Esen', WordType.verb);

    expect(
      _similar('essen', WordType.verb, [essenNoun, essenTypo, essenVerb]),
      [essenTypo.id, essenNoun.id],
    );
  });

  test('excludes the exact duplicate, which is rejected on save instead', () {
    expect(_similar(' haus ', WordType.noun, [haus]), isEmpty);
  });

  test('returns nothing for unrelated words or a blank term', () {
    expect(_similar('Baum', WordType.noun, [haus, hund]), isEmpty);
    expect(_similar('  ', WordType.noun, [haus]), isEmpty);
  });
}
