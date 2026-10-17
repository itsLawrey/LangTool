import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:langtool/data/local/app_database.dart';
import 'package:langtool/data/repositories/deck_repository.dart';
import 'package:langtool/data/repositories/entry_repository.dart';
import 'package:langtool/data/repositories/language_pack_repository.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/deck_draft.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/entry_draft.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/utils/result.dart';

/// Repositories over an in-memory database with a controllable clock.
class TestRepositories {
  /// [idPrefix] keeps ids unique when several instances act as devices.
  TestRepositories({this.idPrefix = 'id'}) {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    packs = LocalLanguagePackRepository(db, clock: clock, newId: newId);
    entries = LocalEntryRepository(db, clock: clock, newId: newId);
    decks = LocalDeckRepository(db, clock: clock, newId: newId);
  }

  final String idPrefix;
  late final AppDatabase db;
  late final LanguagePackRepository packs;
  late final EntryRepository entries;
  late final DeckRepository decks;

  /// The time the next write is stamped with.
  DateTime now = DateTime.utc(2026, 10, 15, 12);
  var _nextId = 0;

  DateTime clock() => now = now.add(const Duration(seconds: 1));
  String newId() => '$idPrefix-${(_nextId++).toString().padLeft(4, '0')}';

  Future<LanguagePack> createPack([
    String name = 'Deutsch',
    String ownerId = 'user-1',
  ]) async =>
      _ok(await packs.create(ownerId: ownerId, name: name, languageCode: 'de'));

  Future<Entry> addNoun(
    LanguagePack pack,
    String term, {
    String article = 'das',
    List<String> translations = const [],
  }) async => _ok(
    await entries.add(
      EntryDraft(
        packId: pack.id,
        wordType: WordType.noun,
        term: term,
        forms: {'article': article},
        translations: translations,
      ),
    ),
  );

  Future<Deck> createDeck(
    LanguagePack pack,
    String name, [
    List<DeckFilter> filters = const [],
  ]) async => _ok(
    await decks.create(
      DeckDraft(packId: pack.id, name: name, filters: filters),
    ),
  );

  Future<void> close() => db.close();
}

T _ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final error) => throw StateError('Expected Ok, got $error'),
};
