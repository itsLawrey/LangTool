import '../../../../domain/models/entry.dart';

/// A row of the timeline list: a day header or an entry.
sealed class TimelineItem {
  const TimelineItem();
}

final class DayHeaderItem extends TimelineItem {
  const DayHeaderItem(this.day);

  /// Local calendar day (time part is midnight).
  final DateTime day;

  @override
  bool operator ==(Object other) => other is DayHeaderItem && other.day == day;

  @override
  int get hashCode => day.hashCode;
}

final class EntryItem extends TimelineItem {
  const EntryItem(this.entry);

  final Entry entry;

  @override
  bool operator ==(Object other) => other is EntryItem && other.entry == entry;

  @override
  int get hashCode => entry.hashCode;
}

/// Inserts a [DayHeaderItem] before the first entry of each local day.
/// [entries] must already be ordered newest first.
List<TimelineItem> buildTimeline(Iterable<Entry> entries) {
  final items = <TimelineItem>[];
  DateTime? currentDay;
  for (final entry in entries) {
    final local = entry.createdAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    if (day != currentDay) {
      items.add(DayHeaderItem(day));
      currentDay = day;
    }
    items.add(EntryItem(entry));
  }
  return items;
}
