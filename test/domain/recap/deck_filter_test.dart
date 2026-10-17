import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';

/// Passes [json] through a real JSON string, as storage or the network would.
Map<String, Object?> _roundTrip(Map<String, Object?> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, Object?>;

void main() {
  group('DeckFilter JSON', () {
    test('addedBetween stores calendar dates', () {
      final filter = DeckFilter.addedBetween(
        from: DateTime(2026, 1, 5),
        to: DateTime(2026, 10, 15),
      );

      final json = filter.toJson();

      expect(json, {
        'type': 'added_between',
        'from': '2026-01-05',
        'to': '2026-10-15',
      });
      expect(DeckFilter.fromJson(_roundTrip(json)), filter);
    });

    test('addedBetween drops the time of day and reads local midnight', () {
      final json = DeckFilter.addedBetween(from: DateTime(2026, 3, 9, 18, 30))
          .toJson();

      expect(json, {'type': 'added_between', 'from': '2026-03-09', 'to': null});
      expect(
        DeckFilter.fromJson(_roundTrip(json)),
        DeckFilter.addedBetween(from: DateTime(2026, 3, 9)),
      );
    });

    test('addedBetween with both sides open', () {
      const filter = DeckFilter.addedBetween();

      expect(DeckFilter.fromJson(_roundTrip(filter.toJson())), filter);
    });

    test('addedInLastDays', () {
      const filter = DeckFilter.addedInLastDays(7);

      expect(filter.toJson(), {'type': 'added_in_last_days', 'days': 7});
      expect(DeckFilter.fromJson(_roundTrip(filter.toJson())), filter);
    });

    test('wordTypes lists names in a stable order', () {
      const filter = DeckFilter.wordTypes({WordType.verb, WordType.noun});

      expect(filter.toJson(), {
        'type': 'word_types',
        'values': ['noun', 'verb'],
      });
      expect(DeckFilter.fromJson(_roundTrip(filter.toJson())), filter);
    });

    test('an unknown type is kept verbatim', () {
      final json = {
        'type': 'tagged',
        'tags': ['A1', 'B2'],
        'nested': {'any': true},
      };

      final filter = DeckFilter.fromJson(_roundTrip(json));

      expect(filter, isA<UnknownFilter>());
      expect(filter.toJson(), json);
    });
  });

  test('Deck round-trips through JSON with its filters', () {
    final deck = Deck(
      id: 'deck-1',
      ownerId: 'user-1',
      packId: 'pack-1',
      name: 'Recent nouns',
      filters: [
        DeckFilter.addedBetween(from: DateTime(2026, 10, 1)),
        const DeckFilter.addedInLastDays(3),
        const DeckFilter.wordTypes({WordType.noun}),
        const DeckFilter.unknown({'type': 'tagged', 'tag': 'A1'}),
      ],
      createdAt: DateTime.utc(2026, 10, 15, 12),
      updatedAt: DateTime.utc(2026, 10, 15, 13),
      deletedAt: DateTime.utc(2026, 10, 15, 14),
    );

    final json = deck.toJson();

    expect(json['pack_id'], 'pack-1');
    expect(json['filters'], [
      {'type': 'added_between', 'from': '2026-10-01', 'to': null},
      {'type': 'added_in_last_days', 'days': 3},
      {
        'type': 'word_types',
        'values': ['noun'],
      },
      {'type': 'tagged', 'tag': 'A1'},
    ]);
    expect(Deck.fromJson(_roundTrip(json)), deck);
  });

  test('a Deck without filters reads as an empty list', () {
    final json = {
      'id': 'deck-1',
      'owner_id': 'user-1',
      'pack_id': 'pack-1',
      'name': 'All',
      'filters': null,
      'created_at': '2026-10-15T12:00:00.000Z',
      'updated_at': '2026-10-15T12:00:00.000Z',
      'deleted_at': null,
    };

    expect(Deck.fromJson(json).filters, isEmpty);
  });
}
