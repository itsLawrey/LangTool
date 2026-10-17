import '../../domain/search/text_normalizer.dart';

/// Joins the normalized translations in the `search_translations` column.
/// Normalization collapses whitespace, so it never occurs inside one.
const translationSeparator = '\n';

/// The `search_term` column of an entry with [term].
String searchTermColumn(String term) => normalizeForSearch(term);

/// The `search_translations` column of an entry with [translations].
String searchTranslationsColumn(Iterable<String> translations) =>
    translations.map(normalizeForSearch).join(translationSeparator);

/// Wraps each key in the `tag_keys` column, so a `LIKE '%\nkey\n%'` matches
/// whole tags only.
const tagKeySeparator = '\n';

/// The `tag_keys` column of an entry with [tags]: each tag's [duplicateKey]
/// (case and spacing ignored, diacritics kept), each wrapped in
/// [tagKeySeparator], e.g. `\na1\nmöbel\n`. Empty without tags.
String tagKeysColumn(Iterable<String> tags) => tags.isEmpty
    ? ''
    : '$tagKeySeparator'
          '${tags.map(duplicateKey).join(tagKeySeparator)}'
          '$tagKeySeparator';

/// The escape character of [escapeLike]'s patterns.
const likeEscapeChar = r'\';

/// [text] with the `LIKE` wildcards `%` and `_` (and the escape character
/// itself) escaped by [likeEscapeChar], so they match literally.
String escapeLike(String text) =>
    text.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '$likeEscapeChar${m[0]}');
