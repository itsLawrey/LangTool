import '../models/word_type.dart';
import 'language_schema.dart';

/// German. Verb terms are free text so they can carry reflexive pronouns and
/// objects (e.g. `sich auf etw. freuen`).
const german = LanguageSchema(
  code: 'de',
  version: 1,
  wordTypes: {
    WordType.noun: WordTypeSchema(
      fields: [
        FieldDefinition(
          'article',
          required: true,
          allowedValues: {'der', 'die', 'das'},
        ),
        FieldDefinition('plural'),
      ],
    ),
    WordType.verb: WordTypeSchema(
      fields: [
        FieldDefinition('present'),
        FieldDefinition('preterite'),
        FieldDefinition('perfect'),
      ],
    ),
    WordType.adjective: WordTypeSchema(
      fields: [FieldDefinition('comparative'), FieldDefinition('superlative')],
    ),
    WordType.adverb: WordTypeSchema(),
    WordType.phrase: WordTypeSchema(),
    WordType.preposition: WordTypeSchema(),
    WordType.conjunction: WordTypeSchema(),
    WordType.pronoun: WordTypeSchema(),
    WordType.other: WordTypeSchema(),
  },
);
