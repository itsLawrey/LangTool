import 'package:drift/drift.dart';

import '../../domain/exceptions.dart';
import '../../domain/languages/language_registry.dart';
import '../../domain/models/language_pack.dart';
import '../../domain/transfer/pack_bundle.dart';
import '../../domain/transfer/pack_file_check.dart';
import '../../domain/transfer/pack_file_pack.dart';
import '../../utils/clock.dart';
import '../../utils/result.dart';
import '../local/app_database.dart';
import '../local/mappers.dart';
import '../transfer/pack_file_codec.dart';

/// Exports language packs to pack files and imports them as new packs.
abstract interface class PackTransferRepository {
  /// A pack file (see [encodePackFile]) holding the active packs [packIds],
  /// in that order, with their active entries and decks. Deleted or missing
  /// packs are skipped.
  Future<Uint8List> export(List<String> packIds);

  /// Reads and validates the pack file [bytes] (see [decodePackFile]).
  /// Fails with a [PackFileException].
  Result<List<PackFilePack>> decode(Uint8List bytes);

  /// Saves [packs] as new packs of [ownerId], with new ids, their entries
  /// and decks. Creation times are kept from the file. Either every pack is
  /// saved or, on failure, none is. Fails with a [PackFileException] if a
  /// pack cannot be imported (see [checkPackFilePack]).
  Future<Result<List<LanguagePack>>> import(
    List<PackFilePack> packs, {
    required String ownerId,
  });
}

class LocalPackTransferRepository implements PackTransferRepository {
  LocalPackTransferRepository(
    this._db, {
    this._clock = systemClockUtc,
    this._newId = uuidV7,
  });

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _newId;

  @override
  Future<Uint8List> export(List<String> packIds) async {
    final bundles = <PackBundle>[];
    for (final id in packIds) {
      final bundle = await _bundle(id);
      if (bundle != null) bundles.add(bundle);
    }
    return encodePackFile(bundles, exportedAt: _clock());
  }

  @override
  Result<List<PackFilePack>> decode(Uint8List bytes) => decodePackFile(bytes);

  @override
  Future<Result<List<LanguagePack>>> import(
    List<PackFilePack> packs, {
    required String ownerId,
  }) async {
    for (final pack in packs) {
      if (checkPackFilePack(pack) case final problem?) {
        return Result.error(problem);
      }
    }

    final now = _clock();
    try {
      final created = await _db.transaction(() async {
        return [for (final pack in packs) await _insert(pack, ownerId, now)];
      });
      return Result.ok(created);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<LanguagePack> _insert(
    PackFilePack filePack,
    String ownerId,
    DateTime now,
  ) async {
    final schemaVersion = languageSchemaFor(filePack.languageCode)!.version;
    final pack = LanguagePack(
      id: _newId(),
      ownerId: ownerId,
      name: filePack.name,
      languageCode: filePack.languageCode,
      createdAt: filePack.createdAt,
      updatedAt: now,
    );
    await _db.into(_db.languagePacks).insert(pack.toCompanion());
    await _db.batch((batch) {
      batch.insertAll(_db.entries, [
        for (final entry in filePack.entries)
          entry
              .toEntry(
                id: _newId(),
                ownerId: ownerId,
                packId: pack.id,
                schemaVersion: schemaVersion,
                updatedAt: now,
              )
              .toCompanion(),
      ]);
      batch.insertAll(_db.decks, [
        for (final deck in filePack.decks)
          deck
              .toDeck(
                id: _newId(),
                ownerId: ownerId,
                packId: pack.id,
                updatedAt: now,
              )
              .toCompanion(),
      ]);
    });
    return pack;
  }

  Future<PackBundle?> _bundle(String packId) async {
    final pack =
        await (_db.select(_db.languagePacks)
              ..where((p) => p.id.equals(packId) & p.deletedAt.isNull()))
            .getSingleOrNull();
    if (pack == null) return null;

    final entries =
        await (_db.select(_db.entries)
              ..where((e) => e.packId.equals(packId) & e.deletedAt.isNull())
              ..orderBy([
                (e) => OrderingTerm.asc(e.createdAt),
                (e) => OrderingTerm.asc(e.id),
              ]))
            .get();
    final decks =
        await (_db.select(_db.decks)
              ..where((d) => d.packId.equals(packId) & d.deletedAt.isNull())
              ..orderBy([
                (d) => OrderingTerm.asc(d.createdAt),
                (d) => OrderingTerm.asc(d.id),
              ]))
            .get();
    return PackBundle(
      pack: pack.toDomain(),
      entries: [for (final row in entries) row.toDomain()],
      decks: [for (final row in decks) row.toDomain()],
    );
  }
}
