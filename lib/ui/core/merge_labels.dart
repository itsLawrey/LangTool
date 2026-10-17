import '../../data/repositories/pack_merge_repository.dart';
import '../../domain/merge/entry_merge.dart';
import 'labels.dart';
import 'recap_labels.dart';
import 'transfer_labels.dart';

/// E.g. `12 entries from 2 packs → 10 entries · 2 duplicates combined ·
/// 1 deck`.
String mergeSummary(MergePreview preview) {
  final combined = preview.entries - preview.mergedEntries;
  return [
    '${entryCountLabel(preview.entries)} from '
        '${packCountLabel(preview.packs)} → '
        '${entryCountLabel(preview.mergedEntries)}',
    '${combined == 1 ? '1 duplicate' : '$combined duplicates'} combined',
    deckCountLabel(preview.decks),
  ].join(' · ');
}

/// The note line for a form value that lost in a merge, e.g.
/// `Plural (from Pack B): Haeuser`.
String clashNote(String languageCode, FormClash clash) =>
    '${fieldLabel(languageCode, clash.formKey)} '
    '(from ${clash.packName}): ${clash.value}';

/// E.g. `Merged 2 packs into "Alltag".`
String mergedLabel({required int packs, required String name}) =>
    'Merged ${packCountLabel(packs)} into "$name".';
