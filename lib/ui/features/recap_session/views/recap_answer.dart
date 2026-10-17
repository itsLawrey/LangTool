import 'package:flutter/material.dart';

import '../../../../domain/languages/language_schema.dart';
import '../../../../domain/models/entry.dart';
import '../../../core/entry_display.dart';
import '../../../core/labels.dart';
import '../../entry_detail/views/detail_section.dart';

/// The revealed card: headword, word type, forms, translations and
/// examples.
class RecapAnswer extends StatelessWidget {
  const RecapAnswer({super.key, required this.entry, required this.schema});

  final Entry entry;
  final LanguageSchema? schema;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageCode = schema?.code ?? '';
    final forms = displayForms(entry, schema);
    final secondary = TextStyle(color: theme.colorScheme.onSurfaceVariant);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(headword(entry), style: theme.textTheme.headlineSmall),
        Text(
          wordTypeLabel(entry.wordType),
          style: theme.textTheme.labelLarge?.merge(secondary),
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
                        Text(translation, style: secondary),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
