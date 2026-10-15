import 'package:drift/drift.dart';

import '../../domain/exceptions.dart';
import '../../domain/languages/language_registry.dart';
import '../../domain/models/entry.dart';
import '../../domain/models/entry_draft.dart';
import '../../domain/models/language_pack.dart';
import '../../domain/models/word_type.dart';
import '../../domain/search/entry_ranker.dart';
import '../../domain/search/search_result.dart';
import '../../domain/search/similar_entries.dart';
import '../../domain/search/text_normalizer.dart';
import '../../utils/clock.dart';
import '../../utils/result.dart';
import '../local/app_database.dart';
import '../local/mappers.dart';

/// Entries of a language pack. Deleted entries are soft-deleted and hidden.
abstract interface class EntryRepository {
  /// Active entries of [packId], ordered by term.
  Stream<List<Entry>> watchEntries(String packId);

  /// The newest [limit] active entries of [packId], newest first. Re-emits
  /// whenever they change; grow [limit] to load further back.
  Stream<List<Entry>> watchTimeline(String packId, {required int limit});

  /// Emits whenever any entry is written.
  Stream<void> watchChanges();

  Future<Result<Entry>> getEntry(String id);

  /// Saves a new entry. Fails with [NotFoundException] (pack),
  /// [InvalidEntryException] or [DuplicateEntryException].
  Future<Result<Entry>> add(EntryDraft draft);

  /// Saves changes to an existing entry. Its pack, owner and creation time
  /// cannot change. Fails like [add].
  Future<Result<Entry>> update(Entry entry);

  Future<Result<void>> delete(String id);

  /// Searches the term and translations of [packId]'s entries.
  ///
  /// Returns exact, prefix and substring matches, best first. Only if there
  /// are none, returns typo-tolerant (fuzzy) matches instead.
  Future<List<SearchResult>> search(String packId, String query);

  /// Entries of [packId] that a new entry with [term] and [wordType] may
  /// duplicate (see [findSimilarEntries]). [excludeId] skips the entry being
  /// edited.
  Future<List<Entry>> findSimilar(
    String packId,
    String term,
    WordType wordType, {
    String? excludeId,
  });
}

class LocalEntryRepository implements EntryRepository {
  LocalEntryRepository(
    this._db, {
    this._clock = systemClockUtc,
    this._newId = uuidV7,
  });

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _newId;

  static const _likeEscape = r'\';

  Expression<bool> _activeIn(String packId) =>
      _db.entries.packId.equals(packId) & _db.entries.deletedAt.isNull();

  @override
  Stream<List<Entry>> watchEntries(String packId) {
    final query = _db.select(_db.entries)
      ..where((_) => _activeIn(packId))
      ..orderBy([(e) => OrderingTerm.asc(e.searchTerm)]);
    return query.watch().map(
      (rows) => [for (final row in rows) row.toDomain()],
    );
  }

  @override
  Stream<List<Entry>> watchTimeline(String packId, {required int limit}) {
    final query = _db.select(_db.entries)
      ..where((_) => _activeIn(packId))
      ..orderBy([
        (e) => OrderingTerm.desc(e.createdAt),
        (e) => OrderingTerm.desc(e.id),
      ])
      ..limit(limit);
    return query.watch().map(
      (rows) => [for (final row in rows) row.toDomain()],
    );
  }

  @override
  Stream<void> watchChanges() =>
      _db.tableUpdates(TableUpdateQuery.onTable(_db.entries));

  @override
  Future<Result<Entry>> getEntry(String id) async {
    final row = await _activeById(id);
    return row == null
        ? Result.error(NotFoundException(id))
        : Result.ok(row.toDomain());
  }

  @override
  Future<Result<Entry>> add(EntryDraft draft) => _db.transaction(() async {
    final pack = await _activePack(draft.packId);
    if (pack == null) return Result.error(NotFoundException(draft.packId));

    final now = _clock();
    final entry = _clean(
      Entry(
        id: _newId(),
        ownerId: pack.ownerId,
        packId: pack.id,
        wordType: draft.wordType,
        term: draft.term,
        forms: draft.forms,
        translations: draft.translations,
        examples: draft.examples,
        tags: draft.tags,
        notes: draft.notes,
        schemaVersion: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return _save(entry, pack, insert: true);
  });

  @override
  Future<Result<Entry>> update(Entry entry) => _db.transaction(() async {
    final stored = await _activeById(entry.id);
    if (stored == null) return Result.error(NotFoundException(entry.id));
    final pack = await _activePack(stored.packId);
    if (pack == null) return Result.error(NotFoundException(stored.packId));

    final updated = _clean(
      entry.copyWith(
        ownerId: stored.ownerId,
        packId: stored.packId,
        createdAt: stored.createdAt,
        updatedAt: _clock(),
        deletedAt: null,
      ),
    );
    return _save(updated, pack, insert: false);
  });

  @override
  Future<Result<void>> delete(String id) async {
    final now = _clock();
    final updated =
        await (_db.update(
          _db.entries,
        )..where((e) => e.id.equals(id) & e.deletedAt.isNull())).write(
          EntriesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
    return updated == 0
        ? Result.error(NotFoundException(id))
        : const Result.ok(null);
  }

  @override
  Future<List<SearchResult>> search(String packId, String query) async {
    final normalized = normalizeForSearch(query);
    if (normalized.isEmpty) return const [];

    final direct = await _directSearch(packId, normalized);
    if (direct.isNotEmpty) return direct;
    return _fuzzySearch(packId, normalized);
  }

  @override
  Future<List<Entry>> findSimilar(
    String packId,
    String term,
    WordType wordType, {
    String? excludeId,
  }) async {
    final query = _db.select(_db.entries)..where((_) => _activeIn(packId));
    if (excludeId != null) query.where((e) => e.id.equals(excludeId).not());
    final rows = await query.get();
    return findSimilarEntries(
      term: term,
      wordType: wordType,
      candidates: [for (final row in rows) row.toDomain()],
    );
  }

  /// Validates [entry] against its pack's language and the duplicate rule,
  /// then writes it.
  Future<Result<Entry>> _save(
    Entry entry,
    LanguagePack pack, {
    required bool insert,
  }) async {
    final schema = languageSchemaFor(pack.languageCode);
    if (schema == null) {
      return Result.error(UnsupportedLanguageException(pack.languageCode));
    }
    final toSave = entry.copyWith(schemaVersion: schema.version);

    final issues = schema.validate(toSave);
    if (issues.isNotEmpty) return Result.error(InvalidEntryException(issues));

    final duplicate = await _findDuplicate(toSave);
    if (duplicate != null) {
      return Result.error(DuplicateEntryException(duplicate.toDomain()));
    }

    if (insert) {
      await _db.into(_db.entries).insert(toSave.toCompanion());
    } else {
      await _db.update(_db.entries).replace(toSave.toCompanion());
    }
    return Result.ok(toSave);
  }

  /// An active entry in the same pack with the same word type and duplicate
  /// key as [entry], other than [entry] itself.
  Future<EntryRow?> _findDuplicate(Entry entry) {
    final query = _db.select(_db.entries)
      ..where(
        (e) =>
            _activeIn(entry.packId) &
            e.wordType.equalsValue(entry.wordType) &
            e.duplicateKey.equals(duplicateKey(entry.term)) &
            e.id.equals(entry.id).not(),
      )
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<List<SearchResult>> _directSearch(
    String packId,
    String normalized,
  ) async {
    final pattern = '%${_escapeLike(normalized)}%';
    final rows =
        await (_db.select(_db.entries)..where(
              (e) =>
                  _activeIn(packId) &
                  (e.searchTerm.like(pattern, escapeChar: _likeEscape) |
                      e.searchTranslations.like(
                        pattern,
                        escapeChar: _likeEscape,
                      )),
            ))
            .get();
    return _rank(rows, normalized, fuzzy: false);
  }

  /// Scores a lightweight projection of the pack in Dart, then loads only
  /// the matching entries.
  Future<List<SearchResult>> _fuzzySearch(
    String packId,
    String normalized,
  ) async {
    final e = _db.entries;
    final keys =
        await (_db.selectOnly(e)
              ..addColumns([e.id, e.searchTerm, e.searchTranslations])
              ..where(_activeIn(packId)))
            .get();

    final matchingIds = [
      for (final row in keys)
        if (matchSearchKeys(
              normalized,
              term: row.read(e.searchTerm)!,
              translations: _splitTranslations(row.read(e.searchTranslations)!),
              fuzzy: true,
            ) !=
            null)
          row.read(e.id)!,
    ];
    if (matchingIds.isEmpty) return const [];

    final rows = await (_db.select(
      e,
    )..where((row) => row.id.isIn(matchingIds))).get();
    return _rank(rows, normalized, fuzzy: true);
  }

  List<SearchResult> _rank(
    List<EntryRow> rows,
    String normalized, {
    required bool fuzzy,
  }) {
    final results = <SearchResult>[];
    for (final row in rows) {
      final match = matchSearchKeys(
        normalized,
        term: row.searchTerm,
        translations: _splitTranslations(row.searchTranslations),
        fuzzy: fuzzy,
      );
      if (match != null) results.add(SearchResult(row.toDomain(), match));
    }
    return results..sort(compareSearchResults);
  }

  Future<EntryRow?> _activeById(String id) => (_db.select(
    _db.entries,
  )..where((e) => e.id.equals(id) & e.deletedAt.isNull())).getSingleOrNull();

  Future<LanguagePack?> _activePack(String id) async {
    final row = await (_db.select(
      _db.languagePacks,
    )..where((p) => p.id.equals(id) & p.deletedAt.isNull())).getSingleOrNull();
    return row?.toDomain();
  }
}

/// Trims text fields and drops blank list items and forms.
Entry _clean(Entry entry) {
  List<String> cleanList(List<String> items) => [
    for (final item in items)
      if (item.trim().isNotEmpty) item.trim(),
  ];
  final notes = entry.notes?.trim();

  return entry.copyWith(
    term: entry.term.trim(),
    forms: {
      for (final MapEntry(:key, :value) in entry.forms.entries)
        if (value.trim().isNotEmpty) key: value.trim(),
    },
    translations: cleanList(entry.translations),
    examples: [
      for (final example in entry.examples)
        if (example.text.trim().isNotEmpty)
          Example(
            text: example.text.trim(),
            translation: switch (example.translation?.trim()) {
              final t? when t.isNotEmpty => t,
              _ => null,
            },
          ),
    ],
    tags: cleanList(entry.tags),
    notes: notes == null || notes.isEmpty ? null : notes,
  );
}

List<String> _splitTranslations(String joined) =>
    joined.isEmpty ? const [] : joined.split(translationSeparator);

String _escapeLike(String text) => text.replaceAllMapped(
  RegExp(r'[\\%_]'),
  (m) => '${LocalEntryRepository._likeEscape}${m[0]}',
);
