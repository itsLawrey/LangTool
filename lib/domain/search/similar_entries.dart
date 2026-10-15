import '../models/entry.dart';
import '../models/word_type.dart';
import 'fuzzy.dart';
import 'text_normalizer.dart';

/// Returns entries among [candidates] that look like a possible duplicate of
/// a new entry with [term] and [wordType], e.g. a typo (`Hasu` → `Haus`), a
/// missing umlaut (`schon` → `schön`) or the same word with another type.
///
/// An exact duplicate (same term and word type) is not included: that is
/// rejected outright when saving. Entries with the same word type come first,
/// then closer matches.
List<Entry> findSimilarEntries({
  required String term,
  required WordType wordType,
  required Iterable<Entry> candidates,
}) {
  final key = duplicateKey(term);
  final normalized = normalizeForSearch(term);
  if (normalized.isEmpty) return const [];

  final matches = <(Entry, int)>[];
  for (final candidate in candidates) {
    if (candidate.wordType == wordType && duplicateKey(candidate.term) == key) {
      continue;
    }
    final candidateNormalized = normalizeForSearch(candidate.term);
    if (isSimilar(normalized, candidateNormalized)) {
      matches.add((candidate, editDistance(normalized, candidateNormalized)));
    }
  }

  matches.sort((a, b) {
    final aSameType = a.$1.wordType == wordType ? 0 : 1;
    final bSameType = b.$1.wordType == wordType ? 0 : 1;
    if (aSameType != bSameType) return aSameType.compareTo(bSameType);
    if (a.$2 != b.$2) return a.$2.compareTo(b.$2);
    return a.$1.term.compareTo(b.$1.term);
  });
  return [for (final (entry, _) in matches) entry];
}
