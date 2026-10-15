import 'german.dart';
import 'language_schema.dart';

/// All supported languages.
const supportedLanguages = <LanguageSchema>[german];

final _byCode = {for (final s in supportedLanguages) s.code: s};

/// Returns the schema for [code], or `null` if the language is not supported.
LanguageSchema? languageSchemaFor(String code) => _byCode[code];
