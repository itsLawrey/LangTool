import 'package:flutter/material.dart';

import '../../../../../../domain/recap/deck_filter.dart';
import '../../view_models/filters/tag_filter_editor.dart';
import 'filter_section.dart';

/// Filter on tags: entries with any or all of the selected tags. Selecting
/// none includes every entry.
class TagFilterSection extends StatelessWidget {
  const TagFilterSection({super.key, required this.editor});

  final TagFilterEditor editor;

  static String _matchLabel(TagMatch match) => switch (match) {
    TagMatch.any => 'Any tag',
    TagMatch.all => 'All tags',
  };

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: editor,
    builder: (context, _) {
      final tags = editor.tags;
      return FilterSection(
        title: 'Tags',
        child: switch (tags) {
          [] when !editor.ready => const SizedBox.shrink(),
          [] => const Text('No tags in this pack yet.'),
          _ => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final tag in tags)
                    FilterChip(
                      label: Text(tag),
                      selected: editor.isSelected(tag),
                      onSelected: (selected) =>
                          editor.setSelected(tag, selected),
                    ),
                ],
              ),
              SegmentedButton<TagMatch>(
                segments: [
                  for (final match in TagMatch.values)
                    ButtonSegment(
                      value: match,
                      label: Text(_matchLabel(match)),
                    ),
                ],
                selected: {editor.match},
                // The mode only matters with two or more tags.
                onSelectionChanged: editor.selectedCount < 2
                    ? null
                    : (selection) => editor.setMatch(selection.single),
              ),
            ],
          ),
        },
      );
    },
  );
}
