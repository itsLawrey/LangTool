import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/data/local/app_database.dart';
import 'package:langtool/data/local/mappers.dart';
import 'package:langtool/data/repositories/entry_repository.dart';
import 'package:langtool/data/repositories/language_pack_repository.dart';
import 'package:langtool/domain/exceptions.dart';
import 'package:langtool/domain/languages/language_schema.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/entry_draft.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/search/search_result.dart';
import 'package:langtool/utils/result.dart';

T _ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final error) => throw TestFailure('Expected Ok, got $error'),
};

Exception _err<T>(Result<T> result) => switch (result) {
  Ok(:final value) => throw TestFailure('Expected Err, got $value'),
  Err(:final error) => error,
};

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late LanguagePackRepository packs;
  late EntryRepository entries;
  late LanguagePack pack;
  var tick = 0;
  var nextId = 0;

  DateTime clock() => DateTime.utc(2026, 10, 15).add(Duration(seconds: tick++));
  String newId() => 'id-${nextId++}';

  EntryDraft noun(
    String term, {
    String article = 'das',
    List<String> tr = const [],
  }) => EntryDraft(
    packId: pack.id,
    wordType: WordType.noun,
    term: term,
    forms: {'article': article},
    translations: tr,
  );

  Future<Entry> add(EntryDraft draft) async => _ok(await entries.add(draft));

  Future<List<String>> search(String query) async => [
    for (final r in await entries.search(pack.id, query)) r.entry.term,
  ];

  setUp(() async {
    tick = 0;
    nextId = 0;
    db = AppDatabase(NativeDatabase.memory());
    packs = LocalLanguagePackRepository(db, clock: clock, newId: newId);
    entries = LocalEntryRepository(db, clock: clock, newId: newId);
    pack = _ok(
      await packs.create(
        ownerId: 'user-1',
        name: 'Deutsch',
        languageCode: 'de',
      ),
    );
  });

  tearDown(() => db.close());

  group('LanguagePackRepository', () {
    test('creates, renames and lists packs by name', () async {
      _ok(
        await packs.create(
          ownerId: 'user-1',
          name: ' Alltag ',
          languageCode: 'de',
        ),
      );
      _ok(
        await packs.create(
          ownerId: 'user-2',
          name: 'Other',
          languageCode: 'de',
        ),
      );
      final renamed = _ok(await packs.rename(pack.id, 'Wortschatz'));

      expect(renamed.name, 'Wortschatz');
      expect(renamed.updatedAt.isAfter(pack.updatedAt), isTrue);
      expect(
        [for (final p in await packs.watchPacks('user-1').first) p.name],
        ['Alltag', 'Wortschatz'],
      );
    });

    test('rejects blank names and unsupported languages', () async {
      expect(
        _err(
          await packs.create(ownerId: 'user-1', name: '  ', languageCode: 'de'),
        ),
        isA<InvalidPackNameException>(),
      );
      expect(
        _err(
          await packs.create(ownerId: 'user-1', name: 'X', languageCode: 'xx'),
        ),
        isA<UnsupportedLanguageException>(),
      );
    });

    test('delete hides the pack and its entries', () async {
      final haus = await add(noun('Haus'));

      _ok(await packs.delete(pack.id));

      expect(_err(await packs.getPack(pack.id)), isA<NotFoundException>());
      expect(_err(await entries.getEntry(haus.id)), isA<NotFoundException>());
      expect(await packs.watchPacks('user-1').first, isEmpty);
    });
  });

  group('EntryRepository CRUD', () {
    test('add assigns id, owner, schema version and timestamps', () async {
      final entry = await add(noun('  Haus ', tr: ['house', ' ', 'ház']));

      expect(entry.id, isNotEmpty);
      expect(entry.ownerId, 'user-1');
      expect(entry.term, 'Haus');
      expect(entry.translations, ['house', 'ház']);
      expect(entry.schemaVersion, 1);
      expect(_ok(await entries.getEntry(entry.id)), entry);
    });

    test(
      'update keeps pack, owner and createdAt and bumps updatedAt',
      () async {
        final entry = await add(noun('Haus'));

        final updated = _ok(
          await entries.update(
            entry.copyWith(translations: ['house'], packId: 'elsewhere'),
          ),
        );

        expect(updated.translations, ['house']);
        expect(updated.packId, pack.id);
        expect(updated.createdAt, entry.createdAt);
        expect(updated.updatedAt.isAfter(entry.updatedAt), isTrue);
        expect(_ok(await entries.getEntry(entry.id)), updated);
      },
    );

    test('delete soft-deletes the entry', () async {
      final entry = await add(noun('Haus'));

      _ok(await entries.delete(entry.id));

      expect(_err(await entries.getEntry(entry.id)), isA<NotFoundException>());
      expect(_err(await entries.delete(entry.id)), isA<NotFoundException>());
      expect(await entries.watchEntries(pack.id).first, isEmpty);
    });

    test('rejects entries invalid for the pack language', () async {
      final error = _err(await entries.add(noun('Haus', article: 'den')));

      expect(error, isA<InvalidEntryException>());
      expect((error as InvalidEntryException).issues, [
        const ValidationIssue.disallowedValue('article', 'den'),
      ]);
    });

    test('rejects entries for a missing pack', () async {
      final draft = noun('Haus').copyWith(packId: 'missing');

      expect(_err(await entries.add(draft)), isA<NotFoundException>());
    });
  });

  group('duplicate rule', () {
    test('rejects the same term and type, ignoring case and spaces', () async {
      final haus = await add(noun('Haus'));

      final error = _err(await entries.add(noun('  haus ')));

      expect(error, isA<DuplicateEntryException>());
      expect((error as DuplicateEntryException).existing, haus);
    });

    test('allows the same term with another type or umlaut', () async {
      await add(noun('Essen'));
      await add(
        EntryDraft(packId: pack.id, wordType: WordType.verb, term: 'essen'),
      );
      await add(
        EntryDraft(packId: pack.id, wordType: WordType.adverb, term: 'schon'),
      );
      await add(
        EntryDraft(packId: pack.id, wordType: WordType.adverb, term: 'schön'),
      );

      expect(await entries.watchEntries(pack.id).first, hasLength(4));
    });

    test('applies per pack', () async {
      final other = _ok(
        await packs.create(
          ownerId: 'user-1',
          name: 'Other',
          languageCode: 'de',
        ),
      );
      await add(noun('Haus'));

      _ok(await entries.add(noun('Haus').copyWith(packId: other.id)));
    });

    test('allows re-adding a deleted entry', () async {
      final haus = await add(noun('Haus'));
      _ok(await entries.delete(haus.id));

      _ok(await entries.add(noun('Haus')));
    });

    test('is also enforced by the database unique index', () async {
      final haus = await add(noun('Haus'));
      final copy = haus.copyWith(id: 'bypass', term: 'HAUS');

      await expectLater(
        db.into(db.entries).insert(copy.toCompanion()),
        throwsA(anything),
      );
    });

    test('rejects renaming an entry into a duplicate', () async {
      await add(noun('Haus'));
      final hasu = await add(noun('Hasu'));

      expect(
        _err(await entries.update(hasu.copyWith(term: 'Haus'))),
        isA<DuplicateEntryException>(),
      );
      _ok(await entries.update(hasu.copyWith(notes: 'typo')));
    });
  });

  group('search', () {
    setUp(() async {
      await add(noun('Haus', tr: ['house', 'ház']));
      await add(noun('Hausaufgabe', article: 'die', tr: ['homework']));
      await add(noun('Krankenhaus', tr: ['hospital']));
      await add(noun('Maus', article: 'die', tr: ['mouse']));
      await add(
        EntryDraft(
          packId: pack.id,
          wordType: WordType.verb,
          term: 'sich auf etw. freuen',
          translations: ['to look forward to'],
        ),
      );
    });

    test('ranks exact, then prefix, then contains', () async {
      expect(await search('haus'), ['Haus', 'Hausaufgabe', 'Krankenhaus']);
    });

    test('matches translations, with or without diacritics', () async {
      expect(await search('ház'), ['Haus']);
      expect(await search('haz'), ['Haus']);
      expect(await search('hospital'), ['Krankenhaus']);
    });

    test('returns the full entry with how it matched', () async {
      final [result] = await entries.search(pack.id, 'house');

      expect(result.entry.forms, {'article': 'das'});
      expect(result.entry.translations, ['house', 'ház']);
      expect(
        result.match,
        const EntryMatch(MatchKind.exact, MatchField.translation),
      );
    });

    test('falls back to fuzzy only when nothing matches directly', () async {
      expect(await search('hasu'), ['Haus']);
      expect(await search('forwrd'), ['sich auf etw. freuen']);
      expect(await search('maus'), ['Maus']);
    });

    test('treats LIKE wildcards literally', () async {
      expect(await search('%'), isEmpty);

      // `_` must not match "a" directly; "h_us" is only a typo of "haus".
      final results = await entries.search(pack.id, 'h_us');
      expect([for (final r in results) r.match.kind], [MatchKind.fuzzy]);
    });

    test('ignores blank queries and deleted entries', () async {
      final [maus] = await entries.search(pack.id, 'maus');
      _ok(await entries.delete(maus.entry.id));

      expect(await search('  '), isEmpty);
      expect(await search('maus'), ['Haus']);
    });
  });

  group('findSimilar', () {
    test('finds likely typo duplicates, excluding the edited entry', () async {
      final haus = await add(noun('Haus'));
      await add(noun('Hund', article: 'der'));

      expect(
        [
          for (final e in await entries.findSimilar(
            pack.id,
            'Hasu',
            WordType.noun,
          ))
            e.term,
        ],
        ['Haus'],
      );
      expect(
        await entries.findSimilar(
          pack.id,
          'Hasu',
          WordType.noun,
          excludeId: haus.id,
        ),
        isEmpty,
      );
    });
  });
}
