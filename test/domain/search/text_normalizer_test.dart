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

    test('drops separators such as | and dashes', () {
      expect(normalizeForSearch('hin|sehen'), 'hinsehen');
      expect(normalizeForSearch('sich gut an|hören'), 'sich gut anhoren');
      expect(normalizeForSearch('E-Mail'), 'email');
      expect(normalizeForSearch('hin¦sehen'), 'hinsehen');
      expect(normalizeForSearch('Sil·be'), 'silbe');
      expect(normalizeForSearch('hin – sehen'), 'hin sehen');
      expect(normalizeForSearch('|-'), '');
    });

    test('keeps separators in duplicate keys', () {
      expect(duplicateKey('hin|sehen'), isNot(duplicateKey('hinsehen')));
    });
  });
}
