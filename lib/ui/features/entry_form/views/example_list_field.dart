import 'package:flutter/material.dart';

import 'list_controllers.dart';

/// Edits an [ExampleListController]: a sentence and an optional translation
/// per example. Enter moves to the next field; in the last example's
/// translation it adds an example and focuses its sentence. The buttons are
/// skipped by keyboard focus traversal.
class ExampleListField extends StatelessWidget {
  const ExampleListField({super.key, required this.controller});

  final ExampleListController controller;

  void _addAndFocus() {
    controller.add();
    final node = controller.items.last.textFocusNode;
    WidgetsBinding.instance.addPostFrameCallback((_) => node.requestFocus());
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final items = controller.items;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text('Examples', style: Theme.of(context).textTheme.titleSmall),
          for (final (index, example) in items.indexed)
            Row(
              key: ObjectKey(example),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    spacing: 4,
                    children: [
                      // Wrapping single-line input, so Enter moves on.
                      TextField(
                        controller: example.text,
                        focusNode: example.textFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Sentence',
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        maxLines: null,
                      ),
                      TextField(
                        controller: example.translation,
                        decoration: const InputDecoration(
                          labelText: 'Translation (optional)',
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        maxLines: null,
                        // The last example adds the next one instead of
                        // moving on.
                        onEditingComplete: index == items.length - 1
                            ? () {}
                            : null,
                        onSubmitted: index == items.length - 1
                            ? (_) => _addAndFocus()
                            : null,
                      ),
                    ],
                  ),
                ),
                ExcludeFocus(
                  child: IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => controller.removeAt(index),
                  ),
                ),
              ],
            ),
          ExcludeFocus(
            child: TextButton.icon(
              onPressed: controller.add,
              icon: const Icon(Icons.add),
              label: const Text('Add example'),
            ),
          ),
        ],
      );
    },
  );
}
