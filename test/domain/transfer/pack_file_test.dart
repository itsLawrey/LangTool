import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/data/transfer/pack_file_codec.dart';
import 'package:langtool/domain/exceptions.dart';
import 'package:langtool/domain/languages/german.dart';
import 'package:langtool/domain/languages/language_schema.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/domain/transfer/pack_bundle.dart';
import 'package:langtool/domain/transfer/pack_file_format.dart';
import 'package:langtool/domain/transfer/pack_file_pack.dart';
import 'package:langtool/utils/result.dart';

final _created = DateTime.utc(2026, 9, 1, 8, 30, 15, 123);
final _updated = DateTime.utc(2026, 10, 2);
final _exportedAt = DateTime.utc(2026, 10, 17, 9);

final _pack = LanguagePack(
  id: 'pack-1',
  ownerId: 'user-1',
  name: 'Deutsch',
  languageCode: 'de',
  createdAt: _created,
  updatedAt: _updated,
);

Entry _entry(
  String id,
  WordType wordType,
  String term, {
  Map<String, String> forms = const {},
  DateTime? deletedAt,
}) => Entry(
  id: id,
  ownerId: 'user-1',
  packId: 'pack-1',
  wordType: wordType,
  term: term,
  forms: forms,
  schemaVersion: 1,
  createdAt: _created.add(Duration(days: id.length)),
  updatedAt: _updated,
  deletedAt: deletedAt,
);

final _haus = _entry('e-haus', WordType.noun, 'Haus').copyWith(
  forms: {'article': 'das', 'plural': 'Häuser'},
  translations: ['house', 'home'],
  examples: [
    const Example(text: 'Das Haus ist groß.', translation: 'The house is big.'),
    const Example(text: 'Zu Hause.'),
  ],
  tags: ['A1', 'home'],
  notes: 'Plural with umlaut.',
);
final _gehen = _entry('e-gehen-1', WordType.verb, 'gehen');
final _deletedEntry = _entry(
  'e-del',
  WordType.adverb,
  'gestern',
  deletedAt: _updated,
);

final _filters = [
  DeckFilter.addedBetween(
    from: DateTime(2026, 10, 1),
    to: DateTime(2026, 10, 9),
  ),
  const DeckFilter.addedInLastDays(7),
  const DeckFilter.wordTypes({WordType.noun, WordType.verb}),
  const DeckFilter.unknown({'type': 'tagged', 'tag': 'A1'}),
];

Deck _deck(
  String id,
  String name, {
  List<DeckFilter> filters = const [],
  DateTime? deletedAt,
}) => Deck(
  id: id,
  ownerId: 'user-1',
  packId: 'pack-1',
  name: name,
  filters: filters,
  createdAt: _created.add(const Duration(hours: 1)),
  updatedAt: _updated,
  deletedAt: deletedAt,
);

final _bundle = PackBundle(
  pack: _pack,
  entries: [_haus, _gehen, _deletedEntry],
  decks: [
    _deck('d-1', 'Recent', filters: _filters),
    _deck('d-2', 'Everything'),
    _deck('d-3', 'Gone', deletedAt: _updated),
  ],
);

Uint8List _gzipJson(Object? json) =>
    const GZipEncoder().encodeBytes(utf8.encode(jsonEncode(json)));

Map<String, Object?> _unzip(Uint8List bytes) =>
    jsonDecode(utf8.decode(const GZipDecoder().decodeBytes(bytes)))
        as Map<String, Object?>;

Map<String, Object?> _entryJson(
  String term, {
  String wordType = 'noun',
  Map<String, Object?>? forms,
  int schemaVersion = 1,
}) => {
  'word_type': wordType,
  'term': term,
  'forms': ?forms ?? (wordType == 'noun' ? {'article': 'das'} : null),
  'schema_version': schemaVersion,
  'created_at': '2026-09-01T08:00:00.000Z',
};

Map<String, Object?> _packJson({
  String name = 'Deutsch',
  String languageCode = 'de',
  List<Object?>? entries,
  List<Object?>? decks,
}) => {
  'name': name,
  'language_code': languageCode,
  'created_at': '2026-09-01T08:00:00.000Z',
  'entries': entries ?? [_entryJson('Haus')],
  'decks': ?decks,
};

Map<String, Object?> _fileJson({List<Object?>? packs, Object? version = 1}) => {
  'format': 'langtool-packs',
  'version': version,
  'exported_at': '2026-10-17T09:00:00.000Z',
  'packs': packs ?? [_packJson()],
};

List<PackFilePack> _ok(Result<List<PackFilePack>> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final error) => throw TestFailure('Expected Ok, got $error'),
};

PackFileException _err(Result<List<PackFilePack>> result) => switch (result) {
  Ok(:final value) => throw TestFailure('Expected Err, got $value'),
  Err(error: final PackFileException error) => error,
  Err(:final error) => throw TestFailure('Unexpected $error'),
};

PackFileProblem _problem(Uint8List bytes) => _err(decodePackFile(bytes)).reason;

PackFileProblem _jsonProblem(Object? json) => _problem(_gzipJson(json));

/// German with a version 2 that renamed the noun field `gender` to `article`.
class _UpgradedGerman extends LanguageSchema {
  _UpgradedGerman()
    : super(code: 'de', version: 2, wordTypes: german.wordTypes);

  final calls = <(Map<String, String>, WordType, int)>[];

  @override
  Map<String, String> migrateForms(
    Map<String, String> forms,
    WordType wordType,
    int fromVersion,
  ) {
    calls.add((forms, wordType, fromVersion));
    return {
      for (final MapEntry(:key, :value) in forms.entries)
        key == 'gender' ? 'article' : key: value,
    };
  }
}

void main() {
  group('round trip', () {
    test('keeps every field of active entries and decks', () {
      final bytes = encodePackFile([_bundle], exportedAt: _exportedAt);

      expect(_ok(decodePackFile(bytes)), [
        PackFilePack(
          name: 'Deutsch',
          languageCode: 'de',
          createdAt: _created,
          entries: [
            PackFileEntry.fromEntry(_haus),
            PackFileEntry.fromEntry(_gehen),
          ],
          decks: [
            PackFileDeck(
              name: 'Recent',
              filters: _filters,
              createdAt: _created.add(const Duration(hours: 1)),
            ),
            PackFileDeck(
              name: 'Everything',
              createdAt: _created.add(const Duration(hours: 1)),
            ),
          ],
        ),
      ]);
    });

    test('keeps several packs in order', () {
      final second = PackBundle(pack: _pack.copyWith(name: 'Zweites'));
      final bytes = encodePackFile([second, _bundle], exportedAt: _exportedAt);

      final packs = _ok(decodePackFile(bytes));
      expect([for (final p in packs) p.name], ['Zweites', 'Deutsch']);
      expect([for (final p in packs) p.entries.length], [0, 2]);
      expect([for (final p in packs) p.decks.length], [0, 2]);
    });

    test('leaves out ids, owners, update times and empty fields', () {
      final json = _unzip(encodePackFile([_bundle], exportedAt: _exportedAt));

      expect(json.keys, {'format', 'version', 'exported_at', 'packs'});
      expect(json['format'], 'langtool-packs');
      expect(json['version'], 1);
      expect(json['exported_at'], '2026-10-17T09:00:00.000Z');

      final [pack as Map<String, Object?>] = json['packs']! as List<Object?>;
      expect(pack.keys, {
        'name',
        'language_code',
        'created_at',
        'entries',
        'decks',
      });
      expect(pack['created_at'], _created.toIso8601String());

      final [haus, gehen] = (pack['entries']! as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(haus, {
        'word_type': 'noun',
        'term': 'Haus',
        'forms': {'article': 'das', 'plural': 'Häuser'},
        'translations': ['house', 'home'],
        'examples': [
          {'text': 'Das Haus ist groß.', 'translation': 'The house is big.'},
          {'text': 'Zu Hause.'},
        ],
        'tags': ['A1', 'home'],
        'notes': 'Plural with umlaut.',
        'schema_version': 1,
        'created_at': _haus.createdAt.toIso8601String(),
      });
      expect(gehen.keys, {'word_type', 'term', 'schema_version', 'created_at'});

      final [recent, everything] = (pack['decks']! as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(recent['filters'], [for (final f in _filters) f.toJson()]);
      expect(everything.keys, {'name', 'created_at'});
    });

    test('leaves out the entry and deck lists of an empty pack', () {
      final json = _unzip(
        encodePackFile([PackBundle(pack: _pack)], exportedAt: _exportedAt),
      );
      final [pack as Map<String, Object?>] = json['packs']! as List<Object?>;
      expect(pack.keys, {'name', 'language_code', 'created_at'});
    });

    test('dates are written in UTC', () {
      final local = DateTime(2026, 9, 1, 8);
      final json = _unzip(
        encodePackFile([
          PackBundle(pack: _pack.copyWith(createdAt: local)),
        ], exportedAt: local),
      );
      expect(json['exported_at'], local.toUtc().toIso8601String());
      expect(json['exported_at'], endsWith('Z'));
    });

    test('is compressed', () {
      final entries = [
        for (var i = 0; i < 200; i++)
          _entry(
            'e-$i',
            WordType.noun,
            'Wort $i',
          ).copyWith(forms: {'article': 'das'}, translations: ['word $i']),
      ];
      final bundle = PackBundle(pack: _pack, entries: entries);
      final bytes = encodePackFile([bundle], exportedAt: _exportedAt);
      final raw = utf8.encode(jsonEncode(_unzip(bytes)));

      expect(bytes.length, lessThan(raw.length ~/ 2));
      expect(_ok(decodePackFile(bytes)).single.entries, hasLength(200));
    });
  });

  group('decoding', () {
    test('cleans entries like the app does', () {
      final packs = _ok(
        decodePackFile(
          _gzipJson(
            _fileJson(
              packs: [
                _packJson(
                  name: '  Deutsch ',
                  entries: [
                    {
                      ..._entryJson(' Haus '),
                      'forms': {'article': ' das ', 'plural': ' '},
                      'translations': ['', ' house '],
                      'examples': [
                        {'text': ' Ein Haus. ', 'translation': ' '},
                        {'text': '  '},
                      ],
                      'tags': [' A1', ''],
                      'notes': '   ',
                    },
                  ],
                  decks: [
                    {'name': ' All ', 'created_at': '2026-09-01T08:00:00Z'},
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      final [pack] = packs;
      expect(pack.name, 'Deutsch');
      expect(pack.decks.single.name, 'All');
      expect(
        pack.entries.single,
        PackFileEntry(
          wordType: WordType.noun,
          term: 'Haus',
          forms: {'article': 'das'},
          translations: ['house'],
          examples: [const Example(text: 'Ein Haus.')],
          tags: ['A1'],
          createdAt: DateTime.utc(2026, 9, 1, 8),
        ),
      );
    });

    test('keeps deck filters of unknown types verbatim', () {
      const unknown = {'type': 'from_the_future', 'level': 3};
      final [pack] = _ok(
        decodePackFile(
          _gzipJson(
            _fileJson(
              packs: [
                _packJson(
                  decks: [
                    {
                      'name': 'Future',
                      'filters': [unknown],
                      'created_at': '2026-09-01T08:00:00Z',
                    },
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      expect(pack.decks.single.filters, [const DeckFilter.unknown(unknown)]);
    });

    test('accepts the same term with another word type or in another pack', () {
      final packs = _ok(
        decodePackFile(
          _gzipJson(
            _fileJson(
              packs: [
                _packJson(
                  entries: [
                    _entryJson('Laut'),
                    _entryJson('laut', wordType: 'adjective'),
                  ],
                ),
                _packJson(entries: [_entryJson('Laut')]),
              ],
            ),
          ),
        ),
      );
      expect([for (final p in packs) p.entries.length], [2, 1]);
    });

    test('upgrades an older file version step by step', () {
      // A made-up version 0 that called the pack list `language_packs`.
      final old = _fileJson(version: 0)
        ..['language_packs'] = [_packJson(name: 'Alt')]
        ..remove('packs');
      final migrations = <int, PackFileMigration>{
        0: (json) => {...json, 'version': 1, 'packs': json['language_packs']},
      };

      final [pack] = _ok(
        decodePackFile(_gzipJson(old), migrations: migrations),
      );
      expect(pack.name, 'Alt');
      expect(pack.entries.single.term, 'Haus');
    });

    test('upgrades forms of entries from an older schema version', () {
      final schema = _UpgradedGerman();
      final bytes = _gzipJson(
        _fileJson(
          packs: [
            _packJson(
              entries: [
                _entryJson('Haus', forms: {'gender': 'das'}),
                _entryJson('Baum', forms: {'article': 'der'}, schemaVersion: 2),
              ],
            ),
          ],
        ),
      );

      final [pack] = _ok(
        decodePackFile(
          bytes,
          schemaFor: (code) => code == 'de' ? schema : null,
        ),
      );
      expect(
        [for (final e in pack.entries) e.forms],
        [
          {'article': 'das'},
          {'article': 'der'},
        ],
      );
      final [(forms, wordType, fromVersion)] = schema.calls;
      expect(forms, {'gender': 'das'});
      expect(wordType, WordType.noun);
      expect(fromVersion, 1);
    });

    test('German has no form migrations', () {
      const forms = {'article': 'das'};
      expect(german.migrateForms(forms, WordType.noun, 0), forms);
    });
  });

  group('rejects', () {
    test('bytes that are not gzip', () {
      expect(_problem(Uint8List(0)), PackFileProblem.notLangTool);
      expect(
        _problem(Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])),
        PackFileProblem.notLangTool,
      );
      expect(
        _problem(utf8.encode(jsonEncode(_fileJson()))),
        PackFileProblem.notLangTool,
      );
    });

    test('a truncated file', () {
      final bytes = _gzipJson(_fileJson());
      expect(
        _problem(Uint8List.sublistView(bytes, 0, bytes.length - 12)),
        PackFileProblem.notLangTool,
      );
    });

    test('gzip that is not JSON', () {
      expect(
        _problem(const GZipEncoder().encodeBytes(utf8.encode('Hallo {'))),
        PackFileProblem.notLangTool,
      );
      expect(
        _problem(const GZipEncoder().encodeBytes([0xff, 0xfe, 0x00])),
        PackFileProblem.notLangTool,
      );
    });

    test('JSON that is not a pack file', () {
      expect(_jsonProblem([1, 2]), PackFileProblem.notLangTool);
      expect(_jsonProblem('langtool-packs'), PackFileProblem.notLangTool);
      expect(
        _jsonProblem({..._fileJson(), 'format': 'other'}),
        PackFileProblem.notLangTool,
      );
      expect(
        _jsonProblem(_fileJson()..remove('format')),
        PackFileProblem.notLangTool,
      );
      expect(
        _jsonProblem(_fileJson(version: '1')),
        PackFileProblem.notLangTool,
      );
    });

    test('malformed fields', () {
      final malformed = <Map<String, Object?>>[
        {..._packJson(), 'name': 3},
        {..._packJson(), 'created_at': 'yesterday'},
        _packJson()..remove('created_at'),
        {..._packJson(), 'entries': 'Haus'},
        _packJson(entries: ['Haus']),
        _packJson(entries: [_entryJson('Haus')..remove('term')]),
        _packJson(entries: [_entryJson('Haus')..remove('schema_version')]),
        _packJson(
          entries: [
            _entryJson('Haus', forms: {'article': 1}),
          ],
        ),
        _packJson(
          entries: [
            {
              ..._entryJson('Haus'),
              'translations': [1],
            },
          ],
        ),
        _packJson(
          entries: [
            {
              ..._entryJson('Haus'),
              'examples': [
                {'translation': 'house'},
              ],
            },
          ],
        ),
        _packJson(
          decks: [
            {
              'name': 'Week',
              'filters': [
                {'type': 'added_in_last_days'},
              ],
              'created_at': '2026-09-01T08:00:00Z',
            },
          ],
        ),
      ];
      for (final pack in malformed) {
        expect(
          _jsonProblem(_fileJson(packs: [pack])),
          PackFileProblem.notLangTool,
          reason: '$pack',
        );
      }
      expect(
        _jsonProblem(_fileJson()..remove('packs')),
        PackFileProblem.notLangTool,
      );
    });

    test('blank pack and deck names', () {
      expect(
        _jsonProblem(_fileJson(packs: [_packJson(name: '  ')])),
        PackFileProblem.notLangTool,
      );
      expect(
        _jsonProblem(
          _fileJson(
            packs: [
              _packJson(
                decks: [
                  {'name': ' ', 'created_at': '2026-09-01T08:00:00Z'},
                ],
              ),
            ],
          ),
        ),
        PackFileProblem.notLangTool,
      );
    });

    test('a newer file version', () {
      expect(_jsonProblem(_fileJson(version: 2)), PackFileProblem.newerVersion);
    });

    test('an older file version without a migration step', () {
      expect(_jsonProblem(_fileJson(version: 0)), PackFileProblem.notLangTool);
    });

    test('an unsupported language', () {
      final error = _err(
        decodePackFile(
          _gzipJson(_fileJson(packs: [_packJson(languageCode: 'xx')])),
        ),
      );
      expect(error.reason, PackFileProblem.unsupportedLanguage);
      expect(error.languageCode, 'xx');
    });

    test('an unknown word type', () {
      expect(
        _jsonProblem(
          _fileJson(
            packs: [
              _packJson(entries: [_entryJson('gehend', wordType: 'gerund')]),
            ],
          ),
        ),
        PackFileProblem.newerVersion,
      );
    });

    test('a newer schema version', () {
      expect(
        _jsonProblem(
          _fileJson(
            packs: [
              _packJson(entries: [_entryJson('Haus', schemaVersion: 2)]),
            ],
          ),
        ),
        PackFileProblem.newerVersion,
      );
    });

    test('an invalid entry', () {
      final error = _err(
        decodePackFile(
          _gzipJson(
            _fileJson(
              packs: [
                _packJson(
                  entries: [
                    _entryJson('Haus', forms: {'plural': 'Häuser'}),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      expect(error.reason, PackFileProblem.invalidEntry);
      expect(error.term, 'Haus');
      expect(error.issues, [
        const ValidationIssue.missingRequiredField('article'),
      ]);
    });

    test('a duplicate entry within a pack', () {
      final error = _err(
        decodePackFile(
          _gzipJson(
            _fileJson(
              packs: [
                _packJson(entries: [_entryJson('Haus'), _entryJson(' haus ')]),
              ],
            ),
          ),
        ),
      );
      expect(error.reason, PackFileProblem.duplicateEntry);
      expect(error.term, 'haus');
    });

    test('a file larger than the cap once decompressed', () {
      final bytes = encodePackFile([_bundle], exportedAt: _exportedAt);
      final size = const GZipDecoder().decodeBytes(bytes).length;

      expect(
        _err(decodePackFile(bytes, maxBytes: size - 1)).reason,
        PackFileProblem.tooLarge,
      );
      expect(_ok(decodePackFile(bytes, maxBytes: size)), hasLength(1));
    });

    test('a highly compressed oversized file', () {
      final bomb = const GZipEncoder().encodeBytes(Uint8List(5 * 1024 * 1024));
      expect(
        _err(decodePackFile(bomb, maxBytes: 1024 * 1024)).reason,
        PackFileProblem.tooLarge,
      );
    });
  });
}
