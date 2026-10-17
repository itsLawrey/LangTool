import 'entry.dart';

/// Trims [entry]'s text fields and drops blank list items, forms and
/// examples. A blank note or example translation becomes `null`.
Entry cleanEntry(Entry entry) {
  List<String> cleanList(List<String> items) => [
    for (final item in items)
      if (item.trim().isNotEmpty) item.trim(),
  ];
  final notes = entry.notes?.trim();

  return entry.copyWith(
    term: entry.term.trim(),
    forms: {
      for (final MapEntry(:key, :value) in entry.forms.entries)
        if (value.trim().isNotEmpty) key: value.trim(),
    },
    translations: cleanList(entry.translations),
    examples: [
      for (final example in entry.examples)
        if (example.text.trim().isNotEmpty)
          Example(
            text: example.text.trim(),
            translation: switch (example.translation?.trim()) {
              final t? when t.isNotEmpty => t,
              _ => null,
            },
          ),
    ],
    tags: cleanList(entry.tags),
    notes: notes == null || notes.isEmpty ? null : notes,
  );
}
