import 'package:flutter/material.dart';

import '../../../domain/languages/language_schema.dart';
import '../../../domain/models/entry.dart';
import '../entry_actions/entry_actions_menu.dart';
import '../timeline_items.dart';
import 'day_header.dart';
import 'entry_card.dart';

/// Distance from the end of the list, in pixels, at which the next page is
/// requested.
const _loadMoreThreshold = 800.0;

/// Day headers and entry cards, built lazily. Calls [onLoadMore] as the user
/// scrolls towards the end, and shows a progress row while [hasMore].
/// [header], if given, scrolls with the list as its first row.
class EntryTimelineView extends StatelessWidget {
  const EntryTimelineView({
    super.key,
    required this.items,
    required this.hasMore,
    required this.onLoadMore,
    required this.schema,
    required this.onTapEntry,
    this.header,
    this.padding = const EdgeInsets.all(16),
  });

  final List<TimelineItem> items;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final LanguageSchema? schema;
  final ValueChanged<Entry> onTapEntry;
  final Widget? header;
  final EdgeInsetsGeometry padding;

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < _loadMoreThreshold) onLoadMore();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final header = this.header;
    final offset = header == null ? 0 : 1;
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ListView.builder(
        padding: padding,
        itemCount: offset + items.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (header != null && index == 0) return header;
          final itemIndex = index - offset;
          if (itemIndex == items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return switch (items[itemIndex]) {
            DayHeaderItem(:final day) => DayHeader(day: day),
            EntryItem(:final entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: EntryCard(
                entry: entry,
                schema: schema,
                onTap: () => onTapEntry(entry),
                menu: EntryActionsMenu(entry: entry, compact: true),
              ),
            ),
          };
        },
      ),
    );
  }
}
