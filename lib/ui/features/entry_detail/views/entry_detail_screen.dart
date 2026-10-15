import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../routing/routes.dart';
import '../../../../utils/result.dart';
import '../../../core/entry_display.dart';
import '../../../core/error_message.dart';
import '../../../core/widgets/confirm_dialog.dart';
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
          if (entry != null) ...[
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(
                Routes.editEntry(viewModel.packId, viewModel.entryId),
              ),
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, viewModel),
            ),
          ],
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

  Future<void> _delete(
    BuildContext context,
    EntryDetailViewModel viewModel,
  ) async {
    final entry = viewModel.entry!;
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete "${headword(entry)}"?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    switch (await viewModel.delete()) {
      case Ok():
        if (context.mounted) context.pop();
      case Err(:final error):
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(errorMessage(error))));
        }
    }
  }
}
