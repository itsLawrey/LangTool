import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../routing/routes.dart';
import '../../../core/widgets/sync_button.dart';
import '../../pack_shell/views/back_to_packs_button.dart';
import '../view_models/timeline_view_model.dart';
import 'entry_search_bar.dart';
import 'timeline_list.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TimelineViewModel>();

    if (viewModel.packMissing) {
      return Scaffold(
        appBar: AppBar(leading: const BackToPacksButton()),
        body: const Center(child: Text('This pack no longer exists.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackToPacksButton(),
        title: Text(viewModel.pack?.name ?? ''),
        actions: const [SyncButton()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.newEntry(viewModel.packId)),
        icon: const Icon(Icons.add),
        label: const Text('New entry'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: EntrySearchBar(onChanged: viewModel.search),
          ),
          if (viewModel.showingSimilar)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('No exact matches. Showing similar entries.'),
            ),
          Expanded(child: TimelineList(viewModel: viewModel)),
        ],
      ),
    );
  }
}
