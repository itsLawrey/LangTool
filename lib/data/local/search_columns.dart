import '../../domain/search/text_normalizer.dart';

/// Joins the normalized translations in the `search_translations` column.
/// Normalization collapses whitespace, so it never occurs inside one.
const translationSeparator = '\n';

/// The `search_term` column of an entry with [term].
String searchTermColumn(String term) => normalizeForSearch(term);

/// The `search_translations` column of an entry with [translations].
String searchTranslationsColumn(Iterable<String> translations) =>
    translations.map(normalizeForSearch).join(translationSeparator);
