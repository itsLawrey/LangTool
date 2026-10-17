import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/clean_entry.dart';
import '../models/deck.dart';
import '../models/entry.dart';
import '../models/word_type.dart';
import '../recap/deck_filter.dart';

part 'pack_file_pack.freezed.dart';

/// A pack read from a pack file, ready to import. It has no ids or owner:
/// importing creates a new pack.
@freezed
abstract class PackFilePack with _$PackFilePack {
  const factory PackFilePack({
    required String name,
    required String languageCode,

    /// UTC.
    required DateTime createdAt,
    @Default(<PackFileEntry>[]) List<PackFileEntry> entries,
    @Default(<PackFileDeck>[]) List<PackFileDeck> decks,
  }) = _PackFilePack;
}

/// An entry of a [PackFilePack]. Its forms match the current version of the
/// pack language's schema.
@freezed
abstract class PackFileEntry with _$PackFileEntry {
  const PackFileEntry._();

  const factory PackFileEntry({
    required WordType wordType,
    required String term,
    @Default(<String, String>{}) Map<String, String> forms,
    @Default(<String>[]) List<String> translations,
    @Default(<Example>[]) List<Example> examples,
    @Default(<String>[]) List<String> tags,
    String? notes,

    /// UTC.
    required DateTime createdAt,
  }) = _PackFileEntry;

  /// The fields of [entry] that a pack file carries.
  factory PackFileEntry.fromEntry(Entry entry) => PackFileEntry(
    wordType: entry.wordType,
    term: entry.term,
    forms: entry.forms,
    translations: entry.translations,
    examples: entry.examples,
    tags: entry.tags,
    notes: entry.notes,
    createdAt: entry.createdAt,
  );

  /// This entry as a stored [Entry], cleaned like entries saved in the app.
  Entry toEntry({
    required String id,
    required String ownerId,
    required String packId,
    required int schemaVersion,
    required DateTime updatedAt,
  }) => cleanEntry(
    Entry(
      id: id,
      ownerId: ownerId,
      packId: packId,
      wordType: wordType,
      term: term,
      forms: forms,
      translations: translations,
      examples: examples,
      tags: tags,
      notes: notes,
      schemaVersion: schemaVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
  );
}

/// A deck of a [PackFilePack].
@freezed
abstract class PackFileDeck with _$PackFileDeck {
  const PackFileDeck._();

  const factory PackFileDeck({
    required String name,
    @Default(<DeckFilter>[]) List<DeckFilter> filters,

    /// UTC.
    required DateTime createdAt,
  }) = _PackFileDeck;

  /// This deck as a stored [Deck].
  Deck toDeck({
    required String id,
    required String ownerId,
    required String packId,
    required DateTime updatedAt,
  }) => Deck(
    id: id,
    ownerId: ownerId,
    packId: packId,
    name: name,
    filters: filters,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
