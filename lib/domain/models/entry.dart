import 'package:freezed_annotation/freezed_annotation.dart';

import 'word_type.dart';

part 'entry.freezed.dart';
part 'entry.g.dart';

/// A dictionary entry in a [LanguagePack].
@freezed
abstract class Entry with _$Entry {
  const factory Entry({
    /// Client-generated UUID.
    required String id,

    /// Id of the owning [Profile].
    required String ownerId,
    required String packId,
    required WordType wordType,

    /// The headword, e.g. the singular of a noun or the infinitive of a verb.
    required String term,

    /// Type-specific fields keyed by field key (e.g. `article`, `plural`).
    /// Valid keys and values are defined by the pack language's schema.
    @Default(<String, String>{}) Map<String, String> forms,
    @Default(<String>[]) List<String> translations,
    @Default(<Example>[]) List<Example> examples,
    @Default(<String>[]) List<String> tags,
    String? notes,

    /// Version of the language schema the [forms] were written against.
    required int schemaVersion,

    /// UTC.
    required DateTime createdAt,

    /// UTC.
    required DateTime updatedAt,

    /// UTC. Set when soft-deleted, so the deletion can be synced.
    DateTime? deletedAt,
  }) = _Entry;

  factory Entry.fromJson(Map<String, Object?> json) => _$EntryFromJson(json);
}

/// An example sentence using an [Entry].
@freezed
abstract class Example with _$Example {
  const factory Example({required String text, String? translation}) = _Example;

  factory Example.fromJson(Map<String, Object?> json) =>
      _$ExampleFromJson(json);
}
