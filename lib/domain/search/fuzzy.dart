import 'dart:math' as math;

/// Optimal string alignment distance: the number of insertions, deletions,
/// substitutions and adjacent transpositions needed to turn [a] into [b].
int editDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  var twoBack = List<int>.filled(b.length + 1, 0);
  var previous = List<int>.generate(b.length + 1, (j) => j);
  var current = List<int>.filled(b.length + 1, 0);

  for (var i = 1; i <= a.length; i++) {
    current[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      var value = math.min(
        math.min(previous[j] + 1, current[j - 1] + 1),
        previous[j - 1] + cost,
      );
      if (i > 1 &&
          j > 1 &&
          a.codeUnitAt(i - 1) == b.codeUnitAt(j - 2) &&
          a.codeUnitAt(i - 2) == b.codeUnitAt(j - 1)) {
        value = math.min(value, twoBack[j - 2] + 1);
      }
      current[j] = value;
    }
    (twoBack, previous, current) = (previous, current, twoBack);
  }
  return previous[b.length];
}

/// The largest edit distance still considered a typo for a string of
/// [length]. Very short strings get no tolerance, otherwise everything would
/// match them.
int maxTypoDistance(int length) => switch (length) {
  <= 2 => 0,
  <= 5 => 1,
  _ => 2,
};

/// Whether [a] and [b] differ by no more than a typo.
bool isSimilar(String a, String b) =>
    editDistance(a, b) <= maxTypoDistance(math.min(a.length, b.length));

/// The smallest edit distance between [query] and either the whole [value]
/// or one of its words, or `null` if none is within typo tolerance of the
/// query. Both arguments must already be normalized.
int? fuzzyDistance(String query, String value) {
  final maxDistance = maxTypoDistance(query.length);
  int? best;
  for (final candidate in [value, ...value.split(' ')]) {
    if ((candidate.length - query.length).abs() > maxDistance) continue;
    final distance = editDistance(query, candidate);
    if (distance <= maxDistance && (best == null || distance < best)) {
      best = distance;
    }
  }
  return best;
}
