/// Route paths.
abstract final class Routes {
  static const login = '/login';
  static const packs = '/';

  static String pack(String packId) => '/packs/$packId';
  static String newEntry(String packId) => '/packs/$packId/entries/new';
  static String entry(String packId, String entryId) =>
      '/packs/$packId/entries/$entryId';
  static String editEntry(String packId, String entryId) =>
      '/packs/$packId/entries/$entryId/edit';
}
