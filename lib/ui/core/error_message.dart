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
      InvalidPackNameException() => 'The pack name is required.',
      NotFoundException() => 'It no longer exists.',
      UnsupportedLanguageException(:final languageCode) =>
        '${languageName(languageCode)} is not supported.',
      _ => 'Something went wrong: $error',
    };
