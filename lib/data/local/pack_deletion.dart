import 'package:drift/drift.dart';

import 'app_database.dart';

extension PackDeletion on AppDatabase {
  /// Soft-deletes the active pack [id] and its entries and decks at [now],
  /// marking them for upload. Returns `false` if no active pack has that id.
  ///
  /// Call it inside a transaction, so the pack and its contents are deleted
  /// together.
  Future<bool> softDeletePack(String id, DateTime now) async {
    final updated =
        await (update(
          languagePacks,
        )..where((p) => p.id.equals(id) & p.deletedAt.isNull())).write(
          LanguagePacksCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            needsPush: const Value(true),
          ),
        );
    if (updated == 0) return false;

    await (update(
      entries,
    )..where((e) => e.packId.equals(id) & e.deletedAt.isNull())).write(
      EntriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        needsPush: const Value(true),
      ),
    );
    await (update(
      decks,
    )..where((d) => d.packId.equals(id) & d.deletedAt.isNull())).write(
      DecksCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        needsPush: const Value(true),
      ),
    );
    return true;
  }
}
