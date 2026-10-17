import 'package:flutter/material.dart';

import 'list_controllers.dart';

/// Edits a [TextListController]: one text field per item, plus an add
/// button. Enter moves to the next field; in the last one it adds an item
/// and focuses it. The buttons are skipped by keyboard focus traversal.
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

  void _addAndFocus() {
    controller.add();
    final node = controller.focusNodes.last;
    WidgetsBinding.instance.addPostFrameCallback((_) => node.requestFocus());
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final items = controller.items;
      final focusNodes = controller.focusNodes;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          for (final (index, item) in items.indexed)
            Row(
              key: ObjectKey(item),
              children: [
                Expanded(
                  child: TextField(
                    controller: item,
                    focusNode: focusNodes[index],
                    decoration: InputDecoration(labelText: itemLabel),
                    textInputAction: TextInputAction.next,
                    // The last field adds the next item instead of moving on,
                    // unless it is still empty.
                    onEditingComplete: index == items.length - 1 ? () {} : null,
                    onSubmitted: index == items.length - 1
                        ? (text) => text.trim().isEmpty
                              ? FocusScope.of(context).nextFocus()
                              : _addAndFocus()
                        : null,
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
              label: Text(addLabel),
            ),
          ),
        ],
      );
    },
  );
}
