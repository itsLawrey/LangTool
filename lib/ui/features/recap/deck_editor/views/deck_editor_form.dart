import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../domain/exceptions.dart';
import '../../../../../routing/routes.dart';
import '../../../../../utils/result.dart';
import '../../../../core/error_message.dart';
import '../../../../core/recap_labels.dart';
import '../view_models/deck_editor_view_model.dart';
import 'filters/added_filter_section.dart';
import 'filters/kept_filter_tile.dart';
import 'filters/tag_filter_section.dart';
import 'filters/word_type_filter_section.dart';

/// The deck name, its filters and the number of entries they match. Owns
/// the name's text controller; [viewModel] holds the filters and saves.
class DeckEditorForm extends StatefulWidget {
  const DeckEditorForm({super.key, required this.viewModel});

  final DeckEditorViewModel viewModel;

  @override
  State<DeckEditorForm> createState() => _DeckEditorFormState();
}

class _DeckEditorFormState extends State<DeckEditorForm> {
  late final _name = TextEditingController(
    text: widget.viewModel.initial?.name,
  );
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final viewModel = widget.viewModel;
    final result = await viewModel.save(_name.text);
    if (!mounted) return;
    switch (result) {
      case Ok(:final value) when !viewModel.isEditing:
        context.pushReplacement(Routes.deck(viewModel.packId, value.id));
      case Ok():
        context.pop();
      case Err(error: final InvalidDeckNameException error):
        setState(() => _nameError = errorMessage(error));
      case Err(:final error):
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final theme = Theme.of(context);
    final count = viewModel.count;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _name,
          decoration: InputDecoration(labelText: 'Name', errorText: _nameError),
          onChanged: (_) {
            if (_nameError != null) setState(() => _nameError = null);
          },
        ),
        const SizedBox(height: 24),
        Text('Filters', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        AddedFilterSection(editor: viewModel.added),
        const SizedBox(height: 24),
        WordTypeFilterSection(editor: viewModel.wordTypes),
        const SizedBox(height: 24),
        TagFilterSection(editor: viewModel.tags),
        for (final filter in viewModel.keptFilters)
          KeptFilterTile(filter: filter),
        const SizedBox(height: 24),
        Text(
          count == null ? '' : matchCountLabel(count),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: viewModel.canSave ? _save : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
