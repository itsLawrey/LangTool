import 'labels.dart';
import 'recap_labels.dart';

/// E.g. `1 deck`, `2 decks`.
String deckCountLabel(int count) => count == 1 ? '1 deck' : '$count decks';

/// E.g. `1 pack`, `2 packs`.
String packCountLabel(int count) => count == 1 ? '1 pack' : '$count packs';

/// A pack in a file to import, e.g. `German · 12 entries · 2 decks`.
String packFileSummary({
  required String languageCode,
  required int entries,
  required int decks,
}) => [
  languageName(languageCode),
  entryCountLabel(entries),
  deckCountLabel(decks),
].join(' · ');

/// E.g. `Imported 2 packs with 12 entries.`
String importedLabel({required int packs, required int entries}) =>
    'Imported ${packCountLabel(packs)} with ${entryCountLabel(entries)}.';

/// E.g. `Exported 2 packs.`
String exportedLabel(int packs) => 'Exported ${packCountLabel(packs)}.';
