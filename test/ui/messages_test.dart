import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:langtool/domain/exceptions.dart';
import 'package:langtool/domain/languages/language_schema.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/ui/core/error_message.dart';
import 'package:langtool/ui/core/labels.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('validationMessage', () {
    test('names the German field in every issue', () {
      expect(
        validationMessage('de', const ValidationIssue.blankTerm()),
        'The term is required.',
      );
      expect(
        validationMessage(
          'de',
          const ValidationIssue.missingRequiredField('article'),
        ),
        'Article is required.',
      );
      expect(
        validationMessage(
          'de',
          const ValidationIssue.disallowedValue('article', 'den'),
        ),
        '"den" is not a valid Article.',
      );
      expect(
        validationMessage('de', const ValidationIssue.unknownField('plural')),
        'Plural does not apply to this word type.',
      );
      expect(
        validationMessage(
          'de',
          const ValidationIssue.unsupportedWordType(WordType.pronoun),
        ),
        'Pronoun is not supported for German.',
      );
    });

    test('falls back to the raw key for unknown languages and fields', () {
      expect(fieldLabel('xx', 'case'), 'case');
      expect(languageName('xx'), 'xx');
    });
  });

  group('errorMessage', () {
    final now = DateTime.utc(2026, 10, 15);
    final haus = Entry(
      id: 'e1',
      ownerId: 'u1',
      packId: 'p1',
      wordType: WordType.noun,
      term: 'Haus',
      forms: {'article': 'das'},
      schemaVersion: 1,
      createdAt: now,
      updatedAt: now,
    );

    test('describes each repository error', () {
      expect(
        errorMessage(DuplicateEntryException(haus)),
        'das Haus (Noun) already exists in this pack.',
      );
      expect(
        errorMessage(
          const InvalidEntryException([
            ValidationIssue.blankTerm(),
            ValidationIssue.missingRequiredField('article'),
          ]),
        ),
        'The term is required.\nArticle is required.',
      );
      expect(
        errorMessage(const InvalidPackNameException()),
        'The pack name is required.',
      );
      expect(
        errorMessage(const NotFoundException('x')),
        'It no longer exists.',
      );
      expect(
        errorMessage(const UnsupportedLanguageException('fr')),
        'fr is not supported.',
      );
    });

    test('passes auth messages through and wraps anything else', () {
      expect(
        errorMessage(const AuthException('Invalid login credentials')),
        'Invalid login credentials',
      );
      expect(
        errorMessage(http.ClientException('boom')),
        startsWith('Something went wrong:'),
      );
    });
  });
}
