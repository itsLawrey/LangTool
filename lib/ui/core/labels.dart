import '../../domain/languages/language_schema.dart';
import '../../domain/models/word_type.dart';

/// Display labels for domain values. Kept out of the domain layer so they can
/// later be localized.

const _languageNames = {'de': 'German'};

String languageName(String code) => _languageNames[code] ?? code;

String wordTypeLabel(WordType type) => switch (type) {
  WordType.noun => 'Noun',
  WordType.verb => 'Verb',
  WordType.adjective => 'Adjective',
  WordType.adverb => 'Adverb',
  WordType.phrase => 'Phrase',
  WordType.preposition => 'Preposition',
  WordType.conjunction => 'Conjunction',
  WordType.pronoun => 'Pronoun',
  WordType.other => 'Other',
};

const _fieldLabels = {
  'de': {
    'article': 'Article',
    'plural': 'Plural',
    'present': 'Present (er/sie/es)',
    'preterite': 'Präteritum (er/sie/es)',
    'perfect': 'Perfekt',
    'comparative': 'Comparative',
    'superlative': 'Superlative',
  },
};

String fieldLabel(String languageCode, String key) =>
    _fieldLabels[languageCode]?[key] ?? key;

String validationMessage(String languageCode, ValidationIssue issue) =>
    switch (issue) {
      BlankTerm() => 'The term is required.',
      UnsupportedWordType(:final wordType) =>
        '${wordTypeLabel(wordType)} is not supported for '
            '${languageName(languageCode)}.',
      MissingRequiredField(:final key) =>
        '${fieldLabel(languageCode, key)} is required.',
      UnknownField(:final key) =>
        '${fieldLabel(languageCode, key)} does not apply to this word type.',
      DisallowedValue(:final key, :final value) =>
        '"$value" is not a valid ${fieldLabel(languageCode, key)}.',
    };
