import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../utils/result.dart';
import '../../../core/error_message.dart';
import '../../../core/transfer_labels.dart';
import '../view_models/import_view_model.dart';
import 'transfer_button.dart';

/// The packs in a picked file, to choose the ones to import.
class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ImportViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Import')),
      body: switch (viewModel) {
        ImportViewModel(:final error?) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(errorMessage(error), textAlign: TextAlign.center),
          ),
        ),
        ImportViewModel(packs: []) => const Center(
          child: Text('No language packs in this file.'),
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
                    value: viewModel.selected.contains(index),
                    onChanged: viewModel.importing
                        ? null
                        : (_) => viewModel.toggle(index),
                    title: Text(pack.name),
                    subtitle: Text(
                      packFileSummary(
                        languageCode: pack.languageCode,
                        entries: pack.entries.length,
                        decks: pack.decks.length,
                      ),
                    ),
                  );
                },
              ),
            ),
            TransferButton(
              label: 'Import',
              onPressed: viewModel.canImport
                  ? () => _import(context, viewModel)
                  : null,
            ),
          ],
        ),
      },
    );
  }

  Future<void> _import(BuildContext context, ImportViewModel viewModel) async {
    final selected = viewModel.selectedPacks;
    final messenger = ScaffoldMessenger.of(context);
    final result = await viewModel.import();
    if (!context.mounted) return;
    final message = switch (result) {
      Ok() => importedLabel(
        packs: selected.length,
        entries: selected.fold(0, (sum, pack) => sum + pack.entries.length),
      ),
      Err(:final error) => errorMessage(error),
    };
    if (result is Ok) context.pop();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
