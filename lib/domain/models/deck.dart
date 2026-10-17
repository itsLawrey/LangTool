import 'package:freezed_annotation/freezed_annotation.dart';

import '../recap/deck_filter.dart';

part 'deck.freezed.dart';
part 'deck.g.dart';

/// A saved recap selection over one language pack.
///
/// A deck stores only its [filters], never entry ids: its entries are
/// resolved when it is shown or practised, so no entry is duplicated across
/// decks and newly added entries join matching decks automatically.
@freezed
abstract class Deck with _$Deck {
  const factory Deck({
    /// Client-generated UUID.
    required String id,

    /// Id of the owning [Profile].
    required String ownerId,
    required String packId,
    required String name,
    @JsonKey(fromJson: _filtersFromJson, toJson: _filtersToJson)
    @Default(<DeckFilter>[])
    List<DeckFilter> filters,

    /// UTC.
    required DateTime createdAt,

    /// UTC.
    required DateTime updatedAt,

    /// UTC. Set when soft-deleted, so the deletion can be synced.
    DateTime? deletedAt,
  }) = _Deck;

  factory Deck.fromJson(Map<String, Object?> json) => _$DeckFromJson(json);
}

List<DeckFilter> _filtersFromJson(List<Object?>? json) => [
  for (final item in json ?? const [])
    DeckFilter.fromJson((item! as Map).cast<String, Object?>()),
];

List<Map<String, Object?>> _filtersToJson(List<DeckFilter> filters) => [
  for (final filter in filters) filter.toJson(),
];
