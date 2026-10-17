import '../models/clean_entry.dart';
import '../models/entry.dart';
import '../models/word_type.dart';
import '../search/text_normalizer.dart';

/// An entry from one of the packs being merged. [packOrder] is the position
/// of its pack in the merge selection; it decides which entry counts as the
/// newest when their edit times are equal.
typedef MergeSource = ({Entry entry, String packName, int packOrder});

/// A form [value] from pack [packName] that lost to the newest entry's
/// differing value for [formKey].
typedef FormClash = ({String formKey, String value, String packName});

/// Entries with the same key are the same entry and are merged: the same
/// word type and [duplicateKey] of the term, as in the duplicate rule.
(WordType, String) mergeKey(Entry entry) =>
    (entry.wordType, duplicateKey(entry.term));

/// Combines the entries of [group], which share a [mergeKey], into one new
/// entry [id] of pack [packId].
///
/// - The term is the newest entry's (latest `updatedAt`, then the later
///   pack in the selection).
/// - Each form takes the newest entry's value; forms only older entries
///   have are kept. Every differing value that loses is described by
///   [describeClash] and added to the notes.
/// - Translations, examples, tags and notes keep every unique value, oldest
///   entry first. Values are compared with [duplicateKey], so case and
///   spacing don't make them different. An example without a translation
///   is dropped if the same sentence also has one.
/// - It keeps the earliest creation time.
Entry mergeEntries(
  List<MergeSource> group, {
  required String id,
  required String ownerId,
  required String packId,
  required int schemaVersion,
  required DateTime updatedAt,
  required String Function(FormClash clash) describeClash,
}) {
  final sources = [
    for (final source in group)
      (
        entry: cleanEntry(source.entry),
        packName: source.packName,
        packOrder: source.packOrder,
      ),
  ];
  final oldestFirst = [...sources]
    ..sort(
      (a, b) => switch (a.entry.createdAt.compareTo(b.entry.createdAt)) {
        0 => a.packOrder.compareTo(b.packOrder),
        final order => order,
      },
    );
  final newestFirst = [...sources]
    ..sort(
      (a, b) => switch (b.entry.updatedAt.compareTo(a.entry.updatedAt)) {
        0 => b.packOrder.compareTo(a.packOrder),
        final order => order,
      },
    );

  final forms = <String, String>{};
  final clashes = <FormClash>[];
  final seenClashes = <(String, String)>{};
  for (final source in newestFirst) {
    for (final MapEntry(:key, :value) in source.entry.forms.entries) {
      final kept = forms[key];
      if (kept == null) {
        forms[key] = value;
      } else if (duplicateKey(kept) != duplicateKey(value) &&
          seenClashes.add((key, duplicateKey(value)))) {
        clashes.add((formKey: key, value: value, packName: source.packName));
      }
    }
  }

  final entries = [for (final source in oldestFirst) source.entry];
  final notes = [
    ..._unique([for (final entry in entries) ?entry.notes]),
    if (clashes.isNotEmpty) clashes.map(describeClash).join('\n'),
  ];

  return Entry(
    id: id,
    ownerId: ownerId,
    packId: packId,
    wordType: newestFirst.first.entry.wordType,
    term: newestFirst.first.entry.term,
    forms: forms,
    translations: _unique([for (final e in entries) ...e.translations]),
    examples: _mergeExamples([for (final e in entries) ...e.examples]),
    tags: _unique([for (final e in entries) ...e.tags]),
    notes: notes.isEmpty ? null : notes.join('\n\n'),
    schemaVersion: schemaVersion,
    createdAt: entries.first.createdAt,
    updatedAt: updatedAt,
  );
}

/// [values] without repeats under [duplicateKey], keeping the first spelling.
List<String> _unique(Iterable<String> values) {
  final seen = <String>{};
  return [
    for (final value in values)
      if (seen.add(duplicateKey(value))) value,
  ];
}

List<Example> _mergeExamples(List<Example> examples) {
  final translated = {
    for (final example in examples)
      if (example.translation != null) duplicateKey(example.text),
  };
  final seen = <(String, String?)>{};
  return [
    for (final example in examples)
      if ((example.translation != null ||
              !translated.contains(duplicateKey(example.text))) &&
          seen.add((
            duplicateKey(example.text),
            example.translation == null
                ? null
                : duplicateKey(example.translation!),
          )))
        example,
  ];
}
