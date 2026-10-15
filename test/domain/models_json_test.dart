import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/profile.dart';
import 'package:langtool/domain/models/word_type.dart';

/// Passes [json] through a real JSON string, as storage or the network would.
Map<String, Object?> _roundTrip(Map<String, Object?> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, Object?>;

void main() {
  final createdAt = DateTime.utc(2026, 10, 15, 12);
  final updatedAt = DateTime.utc(2026, 10, 15, 13);

  test('Profile round-trips through JSON', () {
    final profile = Profile(
      id: 'user-1',
      displayName: 'Lawrey',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final json = profile.toJson();

    expect(json.keys, containsAll(['display_name', 'created_at']));
    expect(Profile.fromJson(_roundTrip(json)), profile);
  });

  test('LanguagePack round-trips through JSON', () {
    final pack = LanguagePack(
      id: 'pack-1',
      ownerId: 'user-1',
      name: 'Deutsch B1',
      languageCode: 'de',
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: updatedAt,
    );

    final json = pack.toJson();

    expect(json['owner_id'], 'user-1');
    expect(json['language_code'], 'de');
    expect(LanguagePack.fromJson(_roundTrip(json)), pack);
  });

  test('Entry round-trips through JSON including examples', () {
    final entry = Entry(
      id: 'entry-1',
      ownerId: 'user-1',
      packId: 'pack-1',
      wordType: WordType.noun,
      term: 'Haus',
      forms: {'article': 'das', 'plural': 'Häuser'},
      translations: ['house', 'ház'],
      examples: [
        const Example(
          text: 'Das Haus ist groß.',
          translation: 'The house is big.',
        ),
        const Example(text: 'Ich gehe nach Hause.'),
      ],
      tags: ['A1'],
      notes: 'nach Hause = home (direction)',
      schemaVersion: 1,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final json = entry.toJson();

    expect(json['word_type'], 'noun');
    expect(json['schema_version'], 1);
    expect(json['examples'], isA<List<Object?>>());
    expect((json['examples']! as List).first, isA<Map<String, Object?>>());
    expect(Entry.fromJson(_roundTrip(json)), entry);
  });

  test('Entry list fields default to empty when absent from JSON', () {
    final entry = Entry.fromJson({
      'id': 'entry-1',
      'owner_id': 'user-1',
      'pack_id': 'pack-1',
      'word_type': 'adverb',
      'term': 'gern',
      'schema_version': 1,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    });

    expect(entry.forms, isEmpty);
    expect(entry.translations, isEmpty);
    expect(entry.examples, isEmpty);
    expect(entry.tags, isEmpty);
    expect(entry.notes, isNull);
    expect(entry.deletedAt, isNull);
  });
}
