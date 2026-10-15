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

/// Form used for searching: like [duplicateKey], with diacritics also folded
/// so that typing without them still matches (`schon` → `schön`, `haz` →
/// `ház`).
String normalizeForSearch(String text) {
  final key = duplicateKey(text);
  final buffer = StringBuffer();
  for (final char in key.split('')) {
    buffer.write(_diacriticFolds[char] ?? char);
  }
  return buffer.toString();
}
