import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/search/text_normalizer.dart';

void main() {
  group('duplicateKey', () {
    test('ignores case and surrounding/repeated whitespace', () {
      expect(duplicateKey('  Das   Haus '), 'das haus');
      expect(duplicateKey('Haus'), duplicateKey(' haus'));
    });

    test('keeps umlauts, so different words stay different', () {
      expect(duplicateKey('schön'), isNot(duplicateKey('schon')));
    });
  });

  group('normalizeForSearch', () {
    test('folds German and Hungarian diacritics', () {
      expect(normalizeForSearch('Schön'), 'schon');
      expect(normalizeForSearch('Straße'), 'strasse');
      expect(normalizeForSearch('ÄÖÜ'), 'aou');
      expect(normalizeForSearch('ház'), 'haz');
      expect(normalizeForSearch('tűzőgép'), 'tuzogep');
    });

    test('collapses whitespace', () {
      expect(normalizeForSearch('  sich   freuen '), 'sich freuen');
    });
  });
}
