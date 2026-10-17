import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/entry_actions/entry_actions_menu.dart';
import '../../../core/entry_display.dart';
import '../view_models/entry_detail_view_model.dart';
import 'entry_details.dart';

class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EntryDetailViewModel>();
    final entry = viewModel.entry;

    return Scaffold(
      appBar: AppBar(
        title: Text(entry == null ? '' : headword(entry)),
        actions: [
          if (entry != null)
            EntryActionsMenu(entry: entry, onGone: () => context.pop()),
        ],
      ),
      body: switch (viewModel) {
        EntryDetailViewModel(loading: true) => const Center(
          child: CircularProgressIndicator(),
        ),
        EntryDetailViewModel(entry: null) => const Center(
          child: Text('This entry no longer exists.'),
        ),
        _ => EntryDetails(entry: entry!, schema: viewModel.schema),
      },
    );
  }
}
