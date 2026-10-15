import 'package:freezed_annotation/freezed_annotation.dart';

import 'entry.dart';
import 'word_type.dart';

part 'entry_draft.freezed.dart';

/// The user-provided fields of a new [Entry]. Ids, ownership, schema version
/// and timestamps are assigned when the draft is saved.
@freezed
abstract class EntryDraft with _$EntryDraft {
  const factory EntryDraft({
    required String packId,
    required WordType wordType,
    required String term,
    @Default(<String, String>{}) Map<String, String> forms,
    @Default(<String>[]) List<String> translations,
    @Default(<Example>[]) List<Example> examples,
    @Default(<String>[]) List<String> tags,
    String? notes,
  }) = _EntryDraft;
}
