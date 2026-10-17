import '../../domain/models/word_type.dart';
import '../../domain/recap/deck_filter.dart';
import '../../domain/recap/recap_session.dart';
import 'date_labels.dart';
import 'labels.dart';

/// Short description of all of a deck's [filters], e.g.
/// `Added in the last 7 days · Noun, Verb`.
String deckFiltersSummary(List<DeckFilter> filters) => filters.isEmpty
    ? 'All entries'
    : [for (final filter in filters) deckFilterLabel(filter)].join(' · ');

/// Short description of one deck filter.
String deckFilterLabel(DeckFilter filter) => switch (filter) {
  AddedBetween(from: null, to: null) => 'Added any time',
  AddedBetween(:final from?, to: null) => 'Added since ${dateLabel(from)}',
  AddedBetween(from: null, :final to?) => 'Added until ${dateLabel(to)}',
  AddedBetween(:final from?, :final to?) =>
    _sameDay(from, to)
        ? 'Added on ${dateLabel(from)}'
        : 'Added ${dateLabel(from)} – ${dateLabel(to)}',
  AddedInLastDays(days: 1) => 'Added today',
  AddedInLastDays(:final days) => 'Added in the last $days days',
  WordTypesFilter(:final types) when types.isEmpty => 'No word types',
  WordTypesFilter(:final types) => [
    for (final type in WordType.values)
      if (types.contains(type)) wordTypeLabel(type),
  ].join(', '),
  UnknownFilter() => 'Filter from a newer app version',
};

/// E.g. `1 entry`, `12 entries`.
String entryCountLabel(int count) => count == 1 ? '1 entry' : '$count entries';

/// E.g. `1 entry matches`, `12 entries match`.
String matchCountLabel(int count) =>
    count == 1 ? '1 entry matches' : '$count entries match';

/// The card side shown first, e.g. `German first`.
String recapDirectionLabel(RecapDirection direction, String languageCode) =>
    switch (direction) {
      RecapDirection.foreignFirst => '${languageName(languageCode)} first',
      RecapDirection.translationFirst => 'Translation first',
      RecapDirection.mixed => 'Mixed',
    };

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
