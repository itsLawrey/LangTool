import '../exceptions.dart';
import '../languages/language_registry.dart';
import '../languages/language_schema.dart';
import '../search/text_normalizer.dart';
import 'pack_file_pack.dart';

/// Returns why [pack] cannot be imported, or `null` if it can: its name and
/// deck names must not be blank, its language must be supported, and its
/// entries must satisfy the language's schema without duplicating each other
/// (same word type and [duplicateKey]).
PackFileException? checkPackFilePack(
  PackFilePack pack, {
  LanguageSchema? Function(String code) schemaFor = languageSchemaFor,
}) {
  if (pack.name.trim().isEmpty) {
    return const PackFileException(PackFileProblem.notLangTool);
  }
  if (pack.decks.any((deck) => deck.name.trim().isEmpty)) {
    return const PackFileException(PackFileProblem.notLangTool);
  }
  final schema = schemaFor(pack.languageCode);
  if (schema == null) {
    return PackFileException(
      PackFileProblem.unsupportedLanguage,
      languageCode: pack.languageCode,
    );
  }

  final seen = <(Object, String)>{};
  for (final fileEntry in pack.entries) {
    final entry = fileEntry.toEntry(
      id: '',
      ownerId: '',
      packId: '',
      schemaVersion: schema.version,
      updatedAt: fileEntry.createdAt,
    );
    final issues = schema.validate(entry);
    if (issues.isNotEmpty) {
      return PackFileException(
        PackFileProblem.invalidEntry,
        term: entry.term,
        issues: issues,
      );
    }
    if (!seen.add((entry.wordType, duplicateKey(entry.term)))) {
      return PackFileException(
        PackFileProblem.duplicateEntry,
        term: entry.term,
      );
    }
  }
  return null;
}
