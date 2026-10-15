import 'package:drift/drift.dart';

import '../../domain/exceptions.dart';
import '../../domain/languages/language_registry.dart';
import '../../domain/models/language_pack.dart';
import '../../utils/clock.dart';
import '../../utils/result.dart';
import '../local/app_database.dart';
import '../local/mappers.dart';

/// Language packs of a profile. Deleted packs are soft-deleted and hidden.
abstract interface class LanguagePackRepository {
  /// Active packs of [ownerId], ordered by name.
  Stream<List<LanguagePack>> watchPacks(String ownerId);

  Future<Result<LanguagePack>> getPack(String id);

  /// Fails with [InvalidPackNameException] or [UnsupportedLanguageException].
  Future<Result<LanguagePack>> create({
    required String ownerId,
    required String name,
    required String languageCode,
  });

  /// Fails with [InvalidPackNameException] or [NotFoundException].
  Future<Result<LanguagePack>> rename(String id, String name);

  /// Soft-deletes the pack and all of its entries.
  Future<Result<void>> delete(String id);
}

class LocalLanguagePackRepository implements LanguagePackRepository {
  LocalLanguagePackRepository(
    this._db, {
    this._clock = systemClockUtc,
    this._newId = uuidV7,
  });

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _newId;

  SimpleSelectStatement<$LanguagePacksTable, LanguagePackRow> _active() =>
      _db.select(_db.languagePacks)..where((p) => p.deletedAt.isNull());

  @override
  Stream<List<LanguagePack>> watchPacks(String ownerId) {
    final query = _active()
      ..where((p) => p.ownerId.equals(ownerId))
      ..orderBy([(p) => OrderingTerm.asc(p.name.collate(Collate.noCase))]);
    return query.watch().map(
      (rows) => [for (final row in rows) row.toDomain()],
    );
  }

  @override
  Future<Result<LanguagePack>> getPack(String id) async {
    final row = await (_active()..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row == null
        ? Result.error(NotFoundException(id))
        : Result.ok(row.toDomain());
  }

  @override
  Future<Result<LanguagePack>> create({
    required String ownerId,
    required String name,
    required String languageCode,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return const Result.error(InvalidPackNameException());
    if (languageSchemaFor(languageCode) == null) {
      return Result.error(UnsupportedLanguageException(languageCode));
    }

    final now = _clock();
    final pack = LanguagePack(
      id: _newId(),
      ownerId: ownerId,
      name: trimmed,
      languageCode: languageCode,
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.languagePacks).insert(pack.toCompanion());
    return Result.ok(pack);
  }

  @override
  Future<Result<LanguagePack>> rename(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return const Result.error(InvalidPackNameException());

    final current = await getPack(id);
    if (current case Ok(value: final pack)) {
      final renamed = pack.copyWith(name: trimmed, updatedAt: _clock());
      await _db.update(_db.languagePacks).replace(renamed.toCompanion());
      return Result.ok(renamed);
    }
    return current;
  }

  @override
  Future<Result<void>> delete(String id) => _db.transaction(() async {
    final now = _clock();
    final updated =
        await (_db.update(
          _db.languagePacks,
        )..where((p) => p.id.equals(id) & p.deletedAt.isNull())).write(
          LanguagePacksCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            needsPush: const Value(true),
          ),
        );
    if (updated == 0) return Result.error(NotFoundException(id));

    await (_db.update(
      _db.entries,
    )..where((e) => e.packId.equals(id) & e.deletedAt.isNull())).write(
      EntriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        needsPush: const Value(true),
      ),
    );
    return const Result.ok(null);
  });
}
