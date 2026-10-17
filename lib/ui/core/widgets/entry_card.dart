import 'package:flutter/material.dart';

import '../../../domain/languages/language_schema.dart';
import '../../../domain/models/entry.dart';
import '../entry_display.dart';
import '../labels.dart';

/// Summary of an entry: headword (with a noun's plural), word type, the
/// other forms' values, translations and tags.
/// Examples and notes are shown in the detail view.
class EntryCard extends StatelessWidget {
  const EntryCard({
    super.key,
    required this.entry,
    required this.schema,
    required this.onTap,
    this.menu,
  });

  final Entry entry;
  final LanguageSchema? schema;
  final VoidCallback onTap;

  /// Shown in the top-right corner, after the word type.
  final Widget? menu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final forms = compactForms(entry, schema);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 12, menu == null ? 12 : 4, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            cardHeadword(entry),
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          wordTypeLabel(entry.wordType),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ?menu,
                ],
              ),
              if (forms.isNotEmpty)
                Text(forms, style: theme.textTheme.bodySmall),
              if (entry.translations.isNotEmpty)
                Text(
                  entry.translations.join(', '),
                  style: theme.textTheme.bodyMedium,
                ),
              if (entry.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final tag in entry.tags)
                      Chip(
                        label: Text(tag),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
