import '../../domain/exceptions.dart';
import '../../domain/models/deck.dart';
import '../../domain/models/deck_draft.dart';
import '../../domain/models/entry.dart';
import '../../domain/recap/deck_filter.dart';
import '../../utils/result.dart';

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
