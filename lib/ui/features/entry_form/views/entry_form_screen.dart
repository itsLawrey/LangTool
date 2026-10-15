import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/entry_form_view_model.dart';
import 'entry_form.dart';

class EntryFormScreen extends StatelessWidget {
  const EntryFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EntryFormViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.isEditing ? 'Edit entry' : 'New entry'),
      ),
      body: switch (viewModel) {
        EntryFormViewModel(loading: true) => const Center(
          child: CircularProgressIndicator(),
        ),
        EntryFormViewModel(missing: true) => const Center(
          child: Text('This entry or pack no longer exists.'),
        ),
        _ => EntryForm(viewModel: viewModel),
      },
    );
  }
}
