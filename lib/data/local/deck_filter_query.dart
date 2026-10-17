import 'package:drift/drift.dart';

import '../../domain/recap/deck_filter.dart';
import '../../domain/search/text_normalizer.dart';
import 'app_database.dart';
import 'search_columns.dart';

/// The SQL condition on [entries] that selects the rows matching every one of
/// [filters] (all rows if there are none). [now] is the current time, for
/// filters relative to today.
///
/// Calendar days are the device's local days. Their bounds are compared as
/// instants, so entries are matched by when they were added, whatever the
/// time zone they were stored in.
Expression<bool> deckFiltersCondition(
  List<DeckFilter> filters,
  $EntriesTable entries, {
  required DateTime now,
}) => Expression.and([
  for (final filter in filters) _condition(filter, entries, now),
]);

Expression<bool> _condition(
  DeckFilter filter,
  $EntriesTable entries,
  DateTime now,
) => switch (filter) {
  AddedBetween(:final from, :final to) => Expression.and([
    if (from != null) entries.createdAt.isBiggerOrEqualValue(_startOfDay(from)),
    if (to != null)
      entries.createdAt.isSmallerThanValue(_startOfDay(to, plusDays: 1)),
  ]),
  AddedInLastDays(:final days) =>
    days < 1
        ? const Constant(false)
        : entries.createdAt.isBiggerOrEqualValue(
            _startOfDay(now.toLocal(), plusDays: 1 - days),
          ),
  WordTypesFilter(:final types) =>
    types.isEmpty ? const Constant(false) : entries.wordType.isInValues(types),
  TagsFilter(:final tags) when tags.isEmpty => const Constant(false),
  TagsFilter(:final tags, match: TagMatch.any) => Expression.or([
    for (final tag in tags) _hasTag(entries, tag),
  ]),
  TagsFilter(:final tags, match: TagMatch.all) => Expression.and([
    for (final tag in tags) _hasTag(entries, tag),
  ]),
  UnknownFilter() => const Constant(false),
};

/// Whether the entry has [tag], ignoring case and spacing (see
/// [tagKeysColumn]).
Expression<bool> _hasTag($EntriesTable entries, String tag) =>
    entries.tagKeys.like(
      '%$tagKeySeparator${escapeLike(duplicateKey(tag))}$tagKeySeparator%',
      escapeChar: likeEscapeChar,
    );

/// Local midnight at the start of [day] + [plusDays], as a UTC instant.
DateTime _startOfDay(DateTime day, {int plusDays = 0}) =>
    DateTime(day.year, day.month, day.day + plusDays).toUtc();
