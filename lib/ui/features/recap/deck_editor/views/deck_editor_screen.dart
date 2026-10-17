import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/deck_editor_view_model.dart';
import 'deck_editor_form.dart';

class DeckEditorScreen extends StatelessWidget {
  const DeckEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DeckEditorViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.isEditing ? 'Edit deck' : 'New deck'),
      ),
      body: switch (viewModel) {
        DeckEditorViewModel(loading: true) => const Center(
          child: CircularProgressIndicator(),
        ),
        DeckEditorViewModel(missing: true) => const Center(
          child: Text('This deck or pack no longer exists.'),
        ),
        _ => DeckEditorForm(viewModel: viewModel),
      },
    );
  }
}
