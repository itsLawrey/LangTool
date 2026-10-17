import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/options_view_model.dart';

/// Options stored on this device only.
class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OptionsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Options')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Comma-separated translations'),
            subtitle: const Text(
              'Type all translations in one field, separated by commas.',
            ),
            value: viewModel.commaTranslations,
            onChanged: viewModel.setCommaTranslations,
          ),
          SwitchListTile(
            title: const Text('Quick add mode'),
            subtitle: const Text(
              'Ctrl+Enter saves the entry and starts a new one.',
            ),
            value: viewModel.quickAddMode,
            onChanged: viewModel.setQuickAddMode,
          ),
        ],
      ),
    );
  }
}
