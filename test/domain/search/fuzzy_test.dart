import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/search/fuzzy.dart';

void main() {
  group('editDistance', () {
    test('counts insertions, deletions and substitutions', () {
      expect(editDistance('haus', 'haus'), 0);
      expect(editDistance('haus', 'hause'), 1);
      expect(editDistance('haus', 'has'), 1);
      expect(editDistance('haus', 'maus'), 1);
      expect(editDistance('', 'abc'), 3);
    });

    test('counts an adjacent transposition as one edit', () {
      expect(editDistance('haus', 'hasu'), 1);
    });
  });

  group('maxTypoDistance', () {
    test('scales with length', () {
      expect(maxTypoDistance(2), 0);
      expect(maxTypoDistance(5), 1);
      expect(maxTypoDistance(6), 2);
    });
  });

  group('fuzzyDistance', () {
    test('matches a typo against the whole value', () {
      expect(fuzzyDistance('hasu', 'haus'), 1);
    });

    test('matches a typo against a single word of the value', () {
      expect(fuzzyDistance('forwrd', 'to look forward to'), 1);
    });

    test('returns null beyond typo tolerance', () {
      expect(fuzzyDistance('hund', 'haus'), isNull);
    });

    test('gives very short queries no tolerance', () {
      expect(fuzzyDistance('ab', 'ac'), isNull);
    });
  });
}
