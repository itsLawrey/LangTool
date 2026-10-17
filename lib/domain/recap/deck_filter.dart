import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/word_type.dart';

part 'deck_filter.freezed.dart';

/// A rule that selects entries of a pack for a deck. A deck's filters are
/// combined with AND; a deck without filters contains the whole pack.
///
/// Filters are stored as JSON with a `type` discriminator. New filter types
/// are added as new union cases. A filter written by a newer app version
/// that this version does not know is kept as [UnknownFilter] (so it
/// survives sync round-trips) and matches no entries.
@Freezed(fromJson: false, toJson: false)
sealed class DeckFilter with _$DeckFilter {
  const DeckFilter._();

  /// Entries added on or after [from] and on or before [to], both inclusive
  /// local calendar days (time of day is ignored). Either side may be open.
  const factory DeckFilter.addedBetween({DateTime? from, DateTime? to}) =
      AddedBetween;

  /// Entries added during the last [days] local calendar days, today
  /// included (`days: 1` means today only). Moves forward with time.
  const factory DeckFilter.addedInLastDays(int days) = AddedInLastDays;

  /// Entries whose word type is one of [types].
  const factory DeckFilter.wordTypes(Set<WordType> types) = WordTypesFilter;

  /// A filter type this app version does not know. Matches nothing.
  const factory DeckFilter.unknown(Map<String, Object?> json) = UnknownFilter;

  factory DeckFilter.fromJson(Map<String, Object?> json) =>
      switch (json['type']) {
        'added_between' => DeckFilter.addedBetween(
          from: _dateFromJson(json['from']),
          to: _dateFromJson(json['to']),
        ),
        'added_in_last_days' => DeckFilter.addedInLastDays(
          (json['days']! as num).toInt(),
        ),
        'word_types' => _wordTypesFromJson(json),
        _ => DeckFilter.unknown(json),
      };

  Map<String, Object?> toJson() => switch (this) {
    AddedBetween(:final from, :final to) => {
      'type': 'added_between',
      'from': _dateToJson(from),
      'to': _dateToJson(to),
    },
    AddedInLastDays(:final days) => {
      'type': 'added_in_last_days',
      'days': days,
    },
    WordTypesFilter(:final types) => {
      'type': 'word_types',
      'values': [
        for (final type in WordType.values)
          if (types.contains(type)) type.name,
      ],
    },
    UnknownFilter(:final json) => json,
  };
}

/// A word type written by a newer app version makes the whole filter
/// [UnknownFilter], so the deck still loads (and matches nothing) here.
DeckFilter _wordTypesFromJson(Map<String, Object?> json) {
  final known = {for (final type in WordType.values) type.name: type};
  final names = (json['values']! as List<Object?>).cast<String>();
  if (!names.every(known.containsKey)) return DeckFilter.unknown(json);
  return DeckFilter.wordTypes({for (final name in names) known[name]!});
}

/// Calendar dates are stored as `YYYY-MM-DD` and read back as local
/// midnight, so a range means the same days on every device.
DateTime? _dateFromJson(Object? value) {
  if (value == null) return null;
  final [year, month, day] = (value as String)
      .split('-')
      .map(int.parse)
      .toList();
  return DateTime(year, month, day);
}

String? _dateToJson(DateTime? date) => date == null
    ? null
    : '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
