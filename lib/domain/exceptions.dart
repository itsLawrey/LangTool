import 'languages/language_schema.dart';
import 'models/entry.dart';

/// An entry with the same term and word type already exists in the pack.
final class DuplicateEntryException implements Exception {
  const DuplicateEntryException(this.existing);

  final Entry existing;

  @override
  String toString() =>
      'DuplicateEntryException(${existing.term}, ${existing.wordType.name})';
}

/// The entry does not satisfy its language schema.
final class InvalidEntryException implements Exception {
  const InvalidEntryException(this.issues);

  final List<ValidationIssue> issues;

  @override
  String toString() => 'InvalidEntryException($issues)';
}

/// A deck name is blank.
final class InvalidDeckNameException implements Exception {
  const InvalidDeckNameException();

  @override
  String toString() => 'InvalidDeckNameException()';
}

/// A pack name is blank.
final class InvalidPackNameException implements Exception {
  const InvalidPackNameException();

  @override
  String toString() => 'InvalidPackNameException()';
}

/// The target pack is of a different language.
final class LanguageMismatchException implements Exception {
  const LanguageMismatchException();

  @override
  String toString() => 'LanguageMismatchException()';
}

/// Why the selected packs cannot be merged.
enum MergePacksProblem {
  /// Fewer than two packs are selected.
  tooFewPacks,

  /// The packs are of different languages.
  mixedLanguages,
}

/// The selected packs cannot be merged.
final class MergePacksException implements Exception {
  const MergePacksException(this.reason);

  final MergePacksProblem reason;

  @override
  String toString() => 'MergePacksException(${reason.name})';
}

/// No active (not soft-deleted) record has the given id.
final class NotFoundException implements Exception {
  const NotFoundException(this.id);

  final String id;

  @override
  String toString() => 'NotFoundException($id)';
}

/// No [LanguageSchema] is registered for the language code.
final class UnsupportedLanguageException implements Exception {
  const UnsupportedLanguageException(this.languageCode);

  final String languageCode;

  @override
  String toString() => 'UnsupportedLanguageException($languageCode)';
}

/// Why a pack file cannot be imported.
enum PackFileProblem {
  /// Not a LangTool pack file, or a damaged one.
  notLangTool,

  /// Written by a newer app version: a newer file format, language schema
  /// or word type.
  newerVersion,

  /// A pack's language has no registered [LanguageSchema]
  /// ([PackFileException.languageCode]).
  unsupportedLanguage,

  /// An entry ([PackFileException.term]) does not satisfy its language
  /// schema ([PackFileException.issues]).
  invalidEntry,

  /// Two entries of one pack have the same term
  /// ([PackFileException.term]) and word type.
  duplicateEntry,

  /// The decompressed file is larger than allowed.
  tooLarge,
}

/// A pack file cannot be imported, for [reason].
final class PackFileException implements Exception {
  const PackFileException(
    this.reason, {
    this.term,
    this.languageCode,
    this.issues = const [],
  });

  final PackFileProblem reason;

  /// The offending entry's term, for [PackFileProblem.invalidEntry] and
  /// [PackFileProblem.duplicateEntry].
  final String? term;

  /// For [PackFileProblem.unsupportedLanguage].
  final String? languageCode;

  /// For [PackFileProblem.invalidEntry].
  final List<ValidationIssue> issues;

  @override
  String toString() =>
      'PackFileException(${reason.name}'
      '${term == null ? '' : ', $term'}'
      '${languageCode == null ? '' : ', $languageCode'}'
      '${issues.isEmpty ? '' : ', $issues'})';
}
