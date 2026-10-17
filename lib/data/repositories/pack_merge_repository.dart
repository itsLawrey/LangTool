import 'dart:collection';

import 'package:drift/drift.dart';

import '../../domain/exceptions.dart';
import '../../domain/languages/language_registry.dart';
import '../../domain/merge/deck_merge.dart';
import '../../domain/merge/entry_merge.dart';
import '../../domain/models/deck.dart';
import '../../domain/models/entry.dart';
import '../../domain/models/language_pack.dart';
import '../../domain/models/word_type.dart';
import '../../utils/clock.dart';
import '../../utils/result.dart';
import '../local/app_database.dart';
import '../local/mappers.dart';
import '../local/pack_deletion.dart';

/// What merging the selected packs would give: [entries] entries from
/// [packs] packs become [mergedEntries] entries, with [decks] decks.
typedef MergePreview = ({int packs, int entries, int mergedEntries, int decks});

/// Merges language packs into a new pack.
abstract interface class PackMergeRepository {
  /// Live counts for merging the packs [packIds] (see [MergePreview]).
  Stream<MergePreview> watchPreview(List<String> packIds);

  /// Merges the packs [packIds] into a new pack [name] of the same owner and
  /// language. Matching entries are combined into one (see [mergeEntries];
  /// [describeClash] words the notes for differing forms) and repeated
  /// decks are kept once (see [uniqueDecks]). With [deleteOriginals] the
  /// merged packs are deleted with their entries and decks.
  ///
  /// Either everything is saved or, on failure, nothing. Fails with
  /// [InvalidPackNameException], [MergePacksException], [NotFoundException]
  /// (a pack doesn't exist), [UnsupportedLanguageException] or
  /// [InvalidEntryException].
  Future<Result<LanguagePack>> merge({
    required List<String> packIds,
    required String name,
    required bool deleteOriginals,
    required String Function(FormClash clash) describeClash,
  });
}

class LocalPackMergeRepository implements PackMergeRepository {
  LocalPackMergeRepository(
    this._db, {
    this._clock = systemClockUtc,
    this._newId = uuidV7,
  });

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _newId;

  @override
  Stream<MergePreview> watchPreview(List<String> packIds) {
    if (packIds.isEmpty) {
      return Stream.value((packs: 0, entries: 0, mergedEntries: 0, decks: 0));
    }
    final entries = _db.entries;
    final count = entries.id.count();
    final distinct =
        (entries.wordType + const Constant('\n') + entries.duplicateKey).count(
          distinct: true,
        );
    final counts = _db.selectOnly(entries)
      ..addColumns([count, distinct])
      ..where(entries.packId.isIn(packIds) & entries.deletedAt.isNull());

    // Re-reads the packs and decks whenever the entry counts are re-run,
    // which drift does on any change to the three tables.
    return counts.watchSingle().asyncMap(
      (row) async => (
        packs: (await _packs(packIds)).length,
        entries: row.read(count)!,
        mergedEntries: row.read(distinct)!,
        decks: uniqueDecks(await _decks(packIds)).length,
      ),
    );
  }

  @override
  Future<Result<LanguagePack>> merge({
    required List<String> packIds,
    required String name,
    required bool deleteOriginals,
    required String Function(FormClash clash) describeClash,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Result.error(InvalidPackNameException());
    }
    final ids = LinkedHashSet.of(packIds).toList();
    if (ids.length < 2) {
      return const Result.error(
        MergePacksException(MergePacksProblem.tooFewPacks),
      );
    }

    try {
      return await _db.transaction(
        () => _merge(ids, trimmed, deleteOriginals, describeClash),
      );
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<LanguagePack>> _merge(
    List<String> ids,
    String name,
    bool deleteOriginals,
    String Function(FormClash clash) describeClash,
  ) async {
    final byId = {for (final pack in await _packs(ids)) pack.id: pack};
    if (ids.where((id) => !byId.containsKey(id)).firstOrNull case final id?) {
      return Result.error(NotFoundException(id));
    }
    final packs = [for (final id in ids) byId[id]!];
    final languageCode = packs.first.languageCode;
    if (packs.any((pack) => pack.languageCode != languageCode)) {
      return const Result.error(
        MergePacksException(MergePacksProblem.mixedLanguages),
      );
    }
    final schema = languageSchemaFor(languageCode);
    if (schema == null) {
      return Result.error(UnsupportedLanguageException(languageCode));
    }

    final order = {for (final (i, id) in ids.indexed) id: i};
    final groups = <(WordType, String), List<MergeSource>>{};
    for (final entry in await _entries(ids)) {
      groups.putIfAbsent(mergeKey(entry), () => []).add((
        entry: entry,
        packName: byId[entry.packId]!.name,
        packOrder: order[entry.packId]!,
      ));
    }

    final now = _clock();
    final pack = LanguagePack(
      id: _newId(),
      ownerId: packs.first.ownerId,
      name: name,
      languageCode: languageCode,
      createdAt: now,
      updatedAt: now,
    );
    final merged = [
      for (final group in groups.values)
        mergeEntries(
          group,
          id: _newId(),
          ownerId: pack.ownerId,
          packId: pack.id,
          schemaVersion: schema.version,
          updatedAt: now,
          describeClash: describeClash,
        ),
    ];
    for (final entry in merged) {
      final issues = schema.validate(entry);
      if (issues.isNotEmpty) return Result.error(InvalidEntryException(issues));
    }
    final decks = [
      for (final deck in uniqueDecks(await _decks(ids)))
        deck.copyWith(
          id: _newId(),
          ownerId: pack.ownerId,
          packId: pack.id,
          updatedAt: now,
        ),
    ];

    await _db.into(_db.languagePacks).insert(pack.toCompanion());
    await _db.batch((batch) {
      batch.insertAll(_db.entries, [
        for (final entry in merged) entry.toCompanion(),
      ]);
      batch.insertAll(_db.decks, [
        for (final deck in decks) deck.toCompanion(),
      ]);
    });
    if (deleteOriginals) {
      for (final id in ids) {
        await _db.softDeletePack(id, now);
      }
    }
    return Result.ok(pack);
  }

  Future<List<LanguagePack>> _packs(List<String> ids) async => [
    for (final row in await (_db.select(
      _db.languagePacks,
    )..where((p) => p.id.isIn(ids) & p.deletedAt.isNull())).get())
      row.toDomain(),
  ];

  /// Oldest first, so merged lists keep the order the words were added.
  Future<List<Entry>> _entries(List<String> packIds) async => [
    for (final row
        in await (_db.select(_db.entries)
              ..where((e) => e.packId.isIn(packIds) & e.deletedAt.isNull())
              ..orderBy([
                (e) => OrderingTerm.asc(e.createdAt),
                (e) => OrderingTerm.asc(e.id),
              ]))
            .get())
      row.toDomain(),
  ];

  /// Oldest first, so the first of repeated decks is kept.
  Future<List<Deck>> _decks(List<String> packIds) async => [
    for (final row
        in await (_db.select(_db.decks)
              ..where((d) => d.packId.isIn(packIds) & d.deletedAt.isNull())
              ..orderBy([
                (d) => OrderingTerm.asc(d.createdAt),
                (d) => OrderingTerm.asc(d.id),
              ]))
            .get())
      row.toDomain(),
  ];
}
