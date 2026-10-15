import '../models/entry.dart';

/// How a search query matched, from best to worst.
enum MatchKind { exact, prefix, contains, fuzzy }

/// Which part of the entry matched.
enum MatchField { term, translation }

/// How an entry's search keys matched a query.
final class EntryMatch {
  const EntryMatch(this.kind, this.field, [this.distance = 0]);

  final MatchKind kind;
  final MatchField field;

  /// Edit distance for [MatchKind.fuzzy], otherwise 0.
  final int distance;

  @override
  bool operator ==(Object other) =>
      other is EntryMatch &&
      other.kind == kind &&
      other.field == field &&
      other.distance == distance;

  @override
  int get hashCode => Object.hash(kind, field, distance);

  @override
  String toString() => 'EntryMatch($kind, $field, $distance)';
}

/// An entry found by a search, with how it matched.
final class SearchResult {
  const SearchResult(this.entry, this.match);

  final Entry entry;
  final EntryMatch match;

  @override
  String toString() => 'SearchResult(${entry.term}, $match)';
}
