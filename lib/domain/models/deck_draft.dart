import 'package:freezed_annotation/freezed_annotation.dart';

import '../recap/deck_filter.dart';

part 'deck_draft.freezed.dart';

/// The user-provided fields of a new [Deck]. Ids, ownership and timestamps
/// are assigned when the draft is saved.
@freezed
abstract class DeckDraft with _$DeckDraft {
  const factory DeckDraft({
    required String packId,
    required String name,
    @Default(<DeckFilter>[]) List<DeckFilter> filters,
  }) = _DeckDraft;
}
