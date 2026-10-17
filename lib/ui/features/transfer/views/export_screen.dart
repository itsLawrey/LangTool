import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../utils/result.dart';
import '../../../core/error_message.dart';
import '../../../core/labels.dart';
import '../../../core/transfer_labels.dart';
import '../view_models/export_view_model.dart';
import 'transfer_button.dart';

/// The user's packs, to choose the ones to export to a file.
class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExportViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export'),
        actions: [
          if (viewModel.packs.isNotEmpty)
            TextButton(
              onPressed: viewModel.exporting ? null : viewModel.toggleAll,
              child: Text(viewModel.allSelected ? 'Clear' : 'Select all'),
            ),
        ],
      ),
      body: switch (viewModel) {
        ExportViewModel(loading: true) => const Center(
          child: CircularProgressIndicator(),
        ),
        ExportViewModel(packs: []) => const Center(
          child: Text('No language packs yet.'),
        ),
        _ => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.packs.length,
                itemBuilder: (context, index) {
                  final pack = viewModel.packs[index];
                  return CheckboxListTile(
                    value: viewModel.selected.contains(pack.id),
                    onChanged: viewModel.exporting
                        ? null
                        : (_) => viewModel.toggle(pack.id),
                    title: Text(pack.name),
                    subtitle: Text(languageName(pack.languageCode)),
                  );
                },
              ),
            ),
            TransferButton(
              label: 'Export',
              onPressed: viewModel.canExport
                  ? () => _export(context, viewModel)
                  : null,
            ),
          ],
        ),
      },
    );
  }

  Future<void> _export(BuildContext context, ExportViewModel viewModel) async {
    final count = viewModel.selected.length;
    final messenger = ScaffoldMessenger.of(context);
    final result = await viewModel.export();
    if (!context.mounted) return;
    switch (result) {
      case Ok(value: true):
        context.pop();
        messenger.showSnackBar(SnackBar(content: Text(exportedLabel(count))));
      case Ok():
        break;
      case Err(:final error):
        messenger.showSnackBar(SnackBar(content: Text(errorMessage(error))));
    }
  }
}
