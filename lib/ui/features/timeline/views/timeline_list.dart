import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';
import '../view_models/timeline_items.dart';
import '../view_models/timeline_view_model.dart';
import 'day_header.dart';
import 'entry_card.dart';

/// Distance from the end of the list, in pixels, at which the next page is
/// requested.
const _loadMoreThreshold = 800.0;

/// The timeline rows, built lazily. Requests older entries as the user
/// scrolls towards the end.
class TimelineList extends StatelessWidget {
  const TimelineList({super.key, required this.viewModel});

  final TimelineViewModel viewModel;

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < _loadMoreThreshold) {
      viewModel.loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (viewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final items = viewModel.items;
    if (items.isEmpty) {
      return Center(
        child: Text(viewModel.isSearching ? 'No matches.' : 'No entries yet.'),
      );
    }

    final schema = viewModel.schema;
    final packId = viewModel.packId;
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        itemCount: items.length + (viewModel.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return switch (items[index]) {
            DayHeaderItem(:final day) => DayHeader(day: day),
            EntryItem(:final entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: EntryCard(
                entry: entry,
                schema: schema,
                onTap: () => context.push(Routes.entry(packId, entry.id)),
              ),
            ),
          };
        },
      ),
    );
  }
}
