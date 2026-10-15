import 'package:flutter/material.dart';

import 'list_controllers.dart';

/// Edits a [TextListController]: one text field per item, plus an add
/// button.
class TextListField extends StatelessWidget {
  const TextListField({
    super.key,
    required this.controller,
    required this.title,
    required this.itemLabel,
    required this.addLabel,
  });

  final TextListController controller;
  final String title;
  final String itemLabel;
  final String addLabel;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        for (final (index, item) in controller.items.indexed)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: item,
                  decoration: InputDecoration(labelText: itemLabel),
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
          label: Text(addLabel),
        ),
      ],
    ),
  );
}
