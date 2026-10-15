import 'fuzzy.dart';
import 'search_result.dart';

/// Matches a normalized [query] against an entry's normalized search keys and
/// returns the best match, or `null` if nothing matches.
///
/// Without [fuzzy], only exact, prefix and substring matches are considered.
/// With [fuzzy], only typo-tolerant matches are.
EntryMatch? matchSearchKeys(
  String query, {
  required String term,
  required Iterable<String> translations,
  required bool fuzzy,
}) {
  EntryMatch? best;
  void consider(String value, MatchField field) {
    final match = fuzzy
        ? _fuzzyMatch(query, value, field)
        : _directMatch(query, value, field);
    if (match != null && (best == null || _compareMatches(match, best!) < 0)) {
      best = match;
    }
  }

  consider(term, MatchField.term);
  for (final translation in translations) {
    consider(translation, MatchField.translation);
  }
  return best;
}

EntryMatch? _directMatch(String query, String value, MatchField field) {
  if (value == query) return EntryMatch(MatchKind.exact, field);
  if (value.startsWith(query)) return EntryMatch(MatchKind.prefix, field);
  if (value.contains(query)) return EntryMatch(MatchKind.contains, field);
  return null;
}

EntryMatch? _fuzzyMatch(String query, String value, MatchField field) {
  final distance = fuzzyDistance(query, value);
  return distance == null ? null : EntryMatch(MatchKind.fuzzy, field, distance);
}

int _compareMatches(EntryMatch a, EntryMatch b) {
  final byKind = a.kind.index.compareTo(b.kind.index);
  if (byKind != 0) return byKind;
  final byField = a.field.index.compareTo(b.field.index);
  if (byField != 0) return byField;
  return a.distance.compareTo(b.distance);
}

/// Orders results best first: by match kind, then matched field (term before
/// translation), then edit distance, then term alphabetically.
int compareSearchResults(SearchResult a, SearchResult b) {
  final byMatch = _compareMatches(a.match, b.match);
  if (byMatch != 0) return byMatch;
  return a.entry.term.toLowerCase().compareTo(b.entry.term.toLowerCase());
}
