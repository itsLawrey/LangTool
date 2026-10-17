import 'package:flutter/material.dart';

import '../../../../../core/labels.dart';
import '../../view_models/filters/word_type_filter_editor.dart';
import 'filter_section.dart';

/// Filter on word types. Selecting none includes all types.
class WordTypeFilterSection extends StatelessWidget {
  const WordTypeFilterSection({super.key, required this.editor});

  final WordTypeFilterEditor editor;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: editor,
    builder: (context, _) => FilterSection(
      title: 'Word type',
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final type in editor.types)
            FilterChip(
              label: Text(wordTypeLabel(type)),
              selected: editor.isSelected(type),
              onSelected: (selected) => editor.setSelected(type, selected),
            ),
        ],
      ),
    ),
  );
}
