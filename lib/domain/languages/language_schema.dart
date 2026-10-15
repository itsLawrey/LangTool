import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/entry.dart';
import '../models/word_type.dart';

part 'language_schema.freezed.dart';

/// Defines which word types a language supports and which form fields each
/// word type has.
class LanguageSchema {
  const LanguageSchema({
    required this.code,
    required this.version,
    required this.wordTypes,
  });

  /// Language code (e.g. `de`), matching [LanguagePack.languageCode].
  final String code;

  /// Incremented whenever the field definitions change.
  final int version;
  final Map<WordType, WordTypeSchema> wordTypes;

  /// Returns every issue with [entry]'s word type and forms. An empty list
  /// means the entry is valid.
  List<ValidationIssue> validate(Entry entry) {
    final typeSchema = wordTypes[entry.wordType];
    if (typeSchema == null) {
      return [ValidationIssue.unsupportedWordType(entry.wordType)];
    }

    final issues = <ValidationIssue>[];
    final fieldsByKey = {for (final f in typeSchema.fields) f.key: f};

    for (final field in typeSchema.fields) {
      if (field.required && (entry.forms[field.key]?.trim() ?? '').isEmpty) {
        issues.add(ValidationIssue.missingRequiredField(field.key));
      }
    }

    for (final MapEntry(:key, :value) in entry.forms.entries) {
      final field = fieldsByKey[key];
      if (field == null) {
        issues.add(ValidationIssue.unknownField(key));
      } else if (field.allowedValues case final allowed?
          when !allowed.contains(value)) {
        issues.add(ValidationIssue.disallowedValue(key, value));
      }
    }

    return issues;
  }
}

/// The form fields of one word type in a language.
class WordTypeSchema {
  const WordTypeSchema({this.fields = const []});

  final List<FieldDefinition> fields;
}

/// One form field, e.g. a noun's `article`.
class FieldDefinition {
  const FieldDefinition(this.key, {this.required = false, this.allowedValues});

  /// Key in [Entry.forms].
  final String key;
  final bool required;

  /// If set, the field's value must be one of these. Otherwise free text.
  final Set<String>? allowedValues;
}

/// A problem found by [LanguageSchema.validate].
@freezed
sealed class ValidationIssue with _$ValidationIssue {
  const factory ValidationIssue.unsupportedWordType(WordType wordType) =
      UnsupportedWordType;
  const factory ValidationIssue.missingRequiredField(String key) =
      MissingRequiredField;
  const factory ValidationIssue.unknownField(String key) = UnknownField;
  const factory ValidationIssue.disallowedValue(String key, String value) =
      DisallowedValue;
}
