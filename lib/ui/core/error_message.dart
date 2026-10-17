import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../../domain/exceptions.dart';
import 'entry_display.dart';
import 'labels.dart';

/// User-facing text for an error returned by a repository.
String errorMessage(Exception error, {String languageCode = 'de'}) =>
    switch (error) {
      AuthException(:final message) => message,
      DuplicateEntryException(:final existing) =>
        '${headword(existing)} (${wordTypeLabel(existing.wordType)}) '
            'already exists in this pack.',
      InvalidEntryException(:final issues) =>
        issues
            .map((issue) => validationMessage(languageCode, issue))
            .join('\n'),
      InvalidDeckNameException() => 'The deck name is required.',
      InvalidPackNameException() => 'The pack name is required.',
      NotFoundException() => 'It no longer exists.',
      final PackFileException error => _packFileMessage(error),
      UnsupportedLanguageException(:final languageCode) =>
        '${languageName(languageCode)} is not supported.',
      _ => 'Something went wrong: $error',
    };

/// Why the pack file cannot be imported.
String _packFileMessage(PackFileException error) => switch (error.reason) {
  PackFileProblem.notLangTool => 'This is not a LangTool file.',
  PackFileProblem.newerVersion =>
    'This file was made by a newer version of LangTool. '
        'Update the app to import it.',
  PackFileProblem.unsupportedLanguage =>
    'This file contains a language this app does not support.',
  PackFileProblem.invalidEntry =>
    'The entry "${error.term}" in this file is invalid.',
  PackFileProblem.duplicateEntry =>
    'The entry "${error.term}" appears twice in one pack.',
  PackFileProblem.tooLarge => 'This file is too large.',
};
