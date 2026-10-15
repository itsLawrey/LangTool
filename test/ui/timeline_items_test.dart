import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/ui/features/timeline/view_models/timeline_items.dart';

Entry _entry(String term, DateTime createdAt) => Entry(
  id: term,
  ownerId: 'user-1',
  packId: 'pack-1',
  wordType: WordType.noun,
  term: term,
  schemaVersion: 1,
  createdAt: createdAt,
  updatedAt: createdAt,
);

void main() {
  test('inserts a header before the first entry of each local day', () {
    final today = DateTime(2026, 10, 15, 18);
    final entries = [
      _entry('c', today.toUtc()),
      _entry('b', today.subtract(const Duration(hours: 2)).toUtc()),
      _entry('a', today.subtract(const Duration(days: 2)).toUtc()),
    ];

    expect(buildTimeline(entries), [
      DayHeaderItem(DateTime(2026, 10, 15)),
      EntryItem(entries[0]),
      EntryItem(entries[1]),
      DayHeaderItem(DateTime(2026, 10, 13)),
      EntryItem(entries[2]),
    ]);
  });

  test('is empty without entries', () {
    expect(buildTimeline(const []), isEmpty);
  });
}
