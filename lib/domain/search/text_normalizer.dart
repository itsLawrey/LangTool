final _whitespace = RegExp(r'\s+');

const _diacriticFolds = {
  'ä': 'a',
  'ö': 'o',
  'ü': 'u',
  'ß': 'ss',
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ő': 'o',
  'ú': 'u',
  'ű': 'u',
};

/// Key used to detect duplicate terms: case and whitespace are ignored, but
/// diacritics are kept, because e.g. `schon` and `schön` are different words.
String duplicateKey(String text) =>
    text.trim().replaceAll(_whitespace, ' ').toLowerCase();

/// Marks that only show how a word is put together, such as the separable
/// prefix in `hin|sehen` or a hyphen. Searching ignores them.
final _separators = RegExp('[|¦·\\-\u2010-\u2014]');

/// Form used for searching: like [duplicateKey], with diacritics also folded
/// so that typing without them still matches (`schon` → `schön`, `haz` →
/// `ház`), and without separators (`hinseh` → `hin|sehen`).
String normalizeForSearch(String text) {
  final key = duplicateKey(text.replaceAll(_separators, ''));
  final buffer = StringBuffer();
  for (final char in key.split('')) {
    buffer.write(_diacriticFolds[char] ?? char);
  }
  return buffer.toString();
}
