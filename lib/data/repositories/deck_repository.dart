import 'package:drift/drift.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/deck.dart';
import '../../domain/models/deck_draft.dart';
import '../../domain/models/entry.dart';
import '../../domain/recap/deck_filter.dart';
import '../../utils/clock.dart';
import '../../utils/result.dart';
import '../local/app_database.dart';
import '../local/deck_filter_query.dart';
import '../local/mappers.dart';

/// Recap decks of a language pack. Deleted decks are soft-deleted and
/// hidden. A deck's entries are resolved from its filters at query time.
abstract interface class DeckRepository {
  /// Active decks of [packId], ordered by name.
  Stream<List<Deck>> watchDecks(String packId);

  /// The active deck [id]; emits `null` once it is deleted or missing.
  Stream<Deck?> watchDeck(String id);

  Future<Result<Deck>> getDeck(String id);

  /// Fails with [NotFoundException] (pack) or [InvalidDeckNameException].
  Future<Result<Deck>> create(DeckDraft draft);

  /// Saves name and filter changes. Pack, owner and creation time cannot
  /// change. Fails like [create].
  Future<Result<Deck>> update(Deck deck);

  Future<Result<void>> delete(String id);

  /// Number of active entries of [packId] matching all [filters], updated
  /// whenever entries change. Used for the live count while editing.
  Stream<int> watchMatchCount(String packId, List<DeckFilter> filters);

  /// Active entries of [packId] matching all [filters].
  Future<List<Entry>> matchingEntries(String packId, List<DeckFilter> filters);
}

class LocalDeckRepository implements DeckRepository {
  LocalDeckRepository(
    this._db, {
    this._clock = systemClockUtc,
    this._newId = uuidV7,
  });

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _newId;

  SimpleSelectStatement<$DecksTable, DeckRow> _active() =>
      _db.select(_db.decks)..where((d) => d.deletedAt.isNull());

  @override
  Stream<List<Deck>> watchDecks(String packId) {
    final query = _active()
      ..where((d) => d.packId.equals(packId))
      ..orderBy([
        (d) => OrderingTerm.asc(d.name.collate(Collate.noCase)),
        (d) => OrderingTerm.asc(d.id),
      ]);
    return query.watch().map(
      (rows) => [for (final row in rows) row.toDomain()],
    );
  }

  @override
  Stream<Deck?> watchDeck(String id) =>
      (_active()..where((d) => d.id.equals(id))).watchSingleOrNull().map(
        (row) => row?.toDomain(),
      );

  @override
  Future<Result<Deck>> getDeck(String id) async {
    final row = await (_active()..where((d) => d.id.equals(id)))
        .getSingleOrNull();
    return row == null
        ? Result.error(NotFoundException(id))
        : Result.ok(row.toDomain());
  }

  @override
  Future<Result<Deck>> create(DeckDraft draft) => _db.transaction(() async {
    final name = draft.name.trim();
    if (name.isEmpty) return const Result.error(InvalidDeckNameException());
    final pack = await _activePack(draft.packId);
    if (pack == null) return Result.error(NotFoundException(draft.packId));

    final now = _clock();
    final deck = Deck(
      id: _newId(),
      ownerId: pack.ownerId,
      packId: pack.id,
      name: name,
      filters: draft.filters,
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.decks).insert(deck.toCompanion());
    return Result.ok(deck);
  });

  @override
  Future<Result<Deck>> update(Deck deck) => _db.transaction(() async {
    final name = deck.name.trim();
    if (name.isEmpty) return const Result.error(InvalidDeckNameException());
    final stored = await (_active()..where((d) => d.id.equals(deck.id)))
        .getSingleOrNull();
    if (stored == null) return Result.error(NotFoundException(deck.id));
    final pack = await _activePack(stored.packId);
    if (pack == null) return Result.error(NotFoundException(stored.packId));

    final updated = deck.copyWith(
      ownerId: stored.ownerId,
      packId: stored.packId,
      name: name,
      createdAt: stored.createdAt,
      updatedAt: _clock(),
      deletedAt: null,
    );
    await _db.update(_db.decks).replace(updated.toCompanion());
    return Result.ok(updated);
  });

  @override
  Future<Result<void>> delete(String id) async {
    final now = _clock();
    final updated =
        await (_db.update(
          _db.decks,
        )..where((d) => d.id.equals(id) & d.deletedAt.isNull())).write(
          DecksCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            needsPush: const Value(true),
          ),
        );
    return updated == 0
        ? Result.error(NotFoundException(id))
        : const Result.ok(null);
  }

  @override
  Stream<int> watchMatchCount(String packId, List<DeckFilter> filters) {
    final count = _db.entries.id.count();
    final query = _db.selectOnly(_db.entries)
      ..addColumns([count])
      ..where(_matching(packId, filters));
    return query.map((row) => row.read(count)!).watchSingle();
  }

  @override
  Future<List<Entry>> matchingEntries(
    String packId,
    List<DeckFilter> filters,
  ) async {
    final query = _db.select(_db.entries)
      ..where((_) => _matching(packId, filters))
      ..orderBy([
        (e) => OrderingTerm.asc(e.createdAt),
        (e) => OrderingTerm.asc(e.id),
      ]);
    return [for (final row in await query.get()) row.toDomain()];
  }

  /// Active entries of [packId] matching every filter.
  Expression<bool> _matching(String packId, List<DeckFilter> filters) =>
      _db.entries.packId.equals(packId) &
      _db.entries.deletedAt.isNull() &
      deckFiltersCondition(filters, _db.entries, now: _clock());

  Future<LanguagePackRow?> _activePack(String id) => (_db.select(
    _db.languagePacks,
  )..where((p) => p.id.equals(id) & p.deletedAt.isNull())).getSingleOrNull();
}
