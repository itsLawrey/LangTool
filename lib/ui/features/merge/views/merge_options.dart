import 'package:flutter/material.dart';

import '../view_models/merge_view_model.dart';

/// The merged pack's name and whether the merged packs are kept.
class MergeOptions extends StatelessWidget {
  const MergeOptions({super.key, required this.viewModel});

  final MergeViewModel viewModel;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: viewModel.name,
          enabled: !viewModel.merging,
          decoration: const InputDecoration(labelText: 'Name'),
          textCapitalization: TextCapitalization.sentences,
          onChanged: viewModel.setName,
        ),
        const SizedBox(height: 16),
        SegmentedButton<MergeMode>(
          segments: const [
            ButtonSegment(value: MergeMode.keep, label: Text('Keep originals')),
            ButtonSegment(
              value: MergeMode.delete,
              label: Text('Delete originals'),
            ),
          ],
          selected: {viewModel.mode},
          onSelectionChanged: viewModel.merging
              ? null
              : (modes) => viewModel.setMode(modes.single),
        ),
      ],
    ),
  );
}
