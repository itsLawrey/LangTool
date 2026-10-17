import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';
import '../../../core/widgets/entry_timeline_view.dart';
import '../view_models/timeline_view_model.dart';

/// The timeline rows, or the loading and empty states. Requests older
/// entries as the user scrolls towards the end.
class TimelineList extends StatelessWidget {
  const TimelineList({super.key, required this.viewModel});

  final TimelineViewModel viewModel;

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

    final packId = viewModel.packId;
    return EntryTimelineView(
      items: items,
      hasMore: viewModel.hasMore,
      onLoadMore: viewModel.loadMore,
      schema: viewModel.schema,
      onTapEntry: (entry) => context.push(Routes.entry(packId, entry.id)),
      // The bottom inset keeps the last card clear of the floating button.
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
    );
  }
}
