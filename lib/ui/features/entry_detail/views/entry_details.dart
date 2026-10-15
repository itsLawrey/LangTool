import 'package:flutter/material.dart';

import '../../../../domain/languages/language_schema.dart';
import '../../../../domain/models/entry.dart';
import '../../../core/date_labels.dart';
import '../../../core/entry_display.dart';
import '../../../core/labels.dart';
import 'detail_section.dart';

/// Every field of an entry, including examples and notes.
class EntryDetails extends StatelessWidget {
  const EntryDetails({super.key, required this.entry, required this.schema});

  final Entry entry;
  final LanguageSchema? schema;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageCode = schema?.code ?? '';
    final forms = displayForms(entry, schema);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(headword(entry), style: theme.textTheme.headlineSmall),
        Text(
          wordTypeLabel(entry.wordType),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (forms.isNotEmpty)
          DetailSection(
            title: 'Forms',
            children: [
              for (final (key, value) in forms)
                Text('${fieldLabel(languageCode, key)}: $value'),
            ],
          ),
        if (entry.translations.isNotEmpty)
          DetailSection(
            title: 'Translations',
            children: [for (final t in entry.translations) Text(t)],
          ),
        if (entry.examples.isNotEmpty)
          DetailSection(
            title: 'Examples',
            children: [
              for (final example in entry.examples)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(example.text),
                      if (example.translation case final translation?)
                        Text(
                          translation,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        if (entry.tags.isNotEmpty)
          DetailSection(
            title: 'Tags',
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final tag in entry.tags) Chip(label: Text(tag)),
                ],
              ),
            ],
          ),
        if (entry.notes case final notes?)
          DetailSection(title: 'Notes', children: [Text(notes)]),
        DetailSection(
          title: 'Added',
          children: [Text(dateTimeLabel(entry.createdAt))],
        ),
      ],
    );
  }
}
