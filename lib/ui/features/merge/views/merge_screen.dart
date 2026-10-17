import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../utils/result.dart';
import '../../../core/error_message.dart';
import '../../../core/labels.dart';
import '../../../core/merge_labels.dart';
import '../../../core/transfer_labels.dart';
import '../../../core/widgets/bottom_action_button.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../view_models/merge_view_model.dart';
import 'merge_options.dart';

/// Chooses packs to merge into a new pack, with a preview of the result.
class MergeScreen extends StatelessWidget {
  const MergeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MergeViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Merge packs')),
      body: switch (viewModel) {
        MergeViewModel(loading: true) => const Center(
          child: CircularProgressIndicator(),
        ),
        MergeViewModel(packs: []) => const Center(
          child: Text('No language packs yet.'),
        ),
        _ => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.packs.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) return MergeOptions(viewModel: viewModel);
                  final pack = viewModel.packs[index - 1];
                  return CheckboxListTile(
                    value: viewModel.selected.contains(pack.id),
                    onChanged: viewModel.canSelect(pack)
                        ? (_) => viewModel.toggle(pack.id)
                        : null,
                    title: Text(pack.name),
                    subtitle: Text(languageName(pack.languageCode)),
                  );
                },
              ),
            ),
            if (viewModel.preview case final preview?)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  mergeSummary(preview),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            BottomActionButton(
              label: 'Merge',
              onPressed: viewModel.canMerge
                  ? () => _merge(context, viewModel)
                  : null,
            ),
          ],
        ),
      },
    );
  }

  Future<void> _merge(BuildContext context, MergeViewModel viewModel) async {
    final count = viewModel.selected.length;
    if (viewModel.mode == MergeMode.delete &&
        !await showConfirmDialog(
          context,
          title: 'Delete the original packs?',
          message:
              'The ${packCountLabel(count)} you merge are deleted '
              'with their entries and decks.',
          confirmLabel: 'Merge and delete',
          destructive: true,
        )) {
      return;
    }
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final result = await viewModel.merge();
    if (!context.mounted) return;
    final message = switch (result) {
      Ok(:final value) => mergedLabel(packs: count, name: value.name),
      Err(:final error) => errorMessage(error),
    };
    if (result is Ok) context.pop();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
