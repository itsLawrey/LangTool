import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/languages/german.dart';
import 'package:langtool/domain/languages/language_registry.dart';
import 'package:langtool/domain/languages/language_schema.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/word_type.dart';

Entry _entry(
  WordType wordType,
  String term, [
  Map<String, String> forms = const {},
]) {
  final now = DateTime.utc(2026, 10, 15);
  return Entry(
    id: 'entry-1',
    ownerId: 'user-1',
    packId: 'pack-1',
    wordType: wordType,
    term: term,
    forms: forms,
    schemaVersion: german.version,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  test('registry resolves German by code', () {
    expect(languageSchemaFor('de'), same(german));
    expect(languageSchemaFor('xx'), isNull);
  });

  test('valid noun has no issues', () {
    final entry = _entry(WordType.noun, 'Haus', {
      'article': 'das',
      'plural': 'Häuser',
    });

    expect(german.validate(entry), isEmpty);
  });

  test('valid verb with free-text infinitive has no issues', () {
    final entry = _entry(WordType.verb, 'sich auf etw. freuen', {
      'present': 'freut sich',
      'preterite': 'freute sich',
      'perfect': 'hat sich gefreut',
    });

    expect(german.validate(entry), isEmpty);
  });

  test('term-only word type has no issues', () {
    expect(german.validate(_entry(WordType.adverb, 'gern')), isEmpty);
  });

  test('noun without article reports missing required field', () {
    final entry = _entry(WordType.noun, 'Haus', {'plural': 'Häuser'});

    expect(german.validate(entry), [
      const ValidationIssue.missingRequiredField('article'),
    ]);
  });

  test('blank article counts as missing', () {
    final entry = _entry(WordType.noun, 'Haus', {'article': '  '});

    expect(
      german.validate(entry),
      contains(const ValidationIssue.missingRequiredField('article')),
    );
  });

  test('invalid article reports disallowed value', () {
    final entry = _entry(WordType.noun, 'Haus', {'article': 'den'});

    expect(german.validate(entry), [
      const ValidationIssue.disallowedValue('article', 'den'),
    ]);
  });

  test('unknown form key reports unknown field', () {
    final entry = _entry(WordType.verb, 'gehen', {'genitive': 'x'});

    expect(german.validate(entry), [
      const ValidationIssue.unknownField('genitive'),
    ]);
  });

  test('blank term reports blank term', () {
    expect(german.validate(_entry(WordType.adverb, '  ')), [
      const ValidationIssue.blankTerm(),
    ]);
  });

  test('word type missing from schema reports unsupported word type', () {
    const schema = LanguageSchema(code: 'xx', version: 1, wordTypes: {});

    expect(schema.validate(_entry(WordType.noun, 'Haus')), [
      const ValidationIssue.unsupportedWordType(WordType.noun),
    ]);
  });
}
