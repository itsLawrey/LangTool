import '../domain/recap/recap_session.dart';

/// Route paths.
abstract final class Routes {
  static const login = '/login';
  static const packs = '/';

  /// The preview of a pack file to import. Its bytes are passed as the
  /// route's `extra`.
  static const importPacks = '/import';
  static const exportPacks = '/export';
  static const mergePacks = '/merge';

  /// The pack's Note tab (entry timeline).
  static String pack(String packId) => '/packs/$packId';
  static String newEntry(String packId) => '/packs/$packId/entries/new';
  static String entry(String packId, String entryId) =>
      '/packs/$packId/entries/$entryId';
  static String editEntry(String packId, String entryId) =>
      '/packs/$packId/entries/$entryId/edit';

  /// The pack's Recap tab (deck list).
  static String recap(String packId) => '/packs/$packId/recap';
  static String newDeck(String packId) => '/packs/$packId/recap/decks/new';
  static String deck(String packId, String deckId) =>
      '/packs/$packId/recap/decks/$deckId';
  static String editDeck(String packId, String deckId) =>
      '/packs/$packId/recap/decks/$deckId/edit';

  /// A recap session over the deck's entries; [direction] is passed as the
  /// `direction` query parameter (its enum name).
  static String recapSession(
    String packId,
    String deckId,
    RecapDirection direction,
  ) => '/packs/$packId/recap/decks/$deckId/session?direction=${direction.name}';
}
