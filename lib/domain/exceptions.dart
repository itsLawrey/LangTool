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

/// A pack name is blank.
final class InvalidPackNameException implements Exception {
  const InvalidPackNameException();

  @override
  String toString() => 'InvalidPackNameException()';
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
