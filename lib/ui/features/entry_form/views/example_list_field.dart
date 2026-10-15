import 'package:flutter/material.dart';

import 'list_controllers.dart';

/// Edits an [ExampleListController]: a sentence and an optional translation
/// per example.
class ExampleListField extends StatelessWidget {
  const ExampleListField({super.key, required this.controller});

  final ExampleListController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text('Examples', style: Theme.of(context).textTheme.titleSmall),
        for (final (index, example) in controller.items.indexed)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  spacing: 4,
                  children: [
                    TextField(
                      controller: example.text,
                      decoration: const InputDecoration(labelText: 'Sentence'),
                      maxLines: null,
                    ),
                    TextField(
                      controller: example.translation,
                      decoration: const InputDecoration(
                        labelText: 'Translation (optional)',
                      ),
                      maxLines: null,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => controller.removeAt(index),
              ),
            ],
          ),
        TextButton.icon(
          onPressed: controller.add,
          icon: const Icon(Icons.add),
          label: const Text('Add example'),
        ),
      ],
    ),
  );
}
