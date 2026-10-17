import 'package:flutter/material.dart';

import '../../../../domain/languages/language_schema.dart';
import 'schema_form_fields.dart';

/// The term together with the type-specific fields of a word type that has
/// an article (e.g. German nouns): article, term, then the other fields,
/// side by side, or stacked in the same order when narrower than
/// [minRowWidth].
class ArticleTermFields extends StatelessWidget {
  const ArticleTermFields({
    super.key,
    required this.languageCode,
    required this.fields,
    required this.controllerFor,
    required this.term,
  });

  static const articleKey = 'article';
  static const minRowWidth = 340.0;

  final String languageCode;

  /// The word type's fields, including [articleKey].
  final List<FieldDefinition> fields;

  /// The controller holding the value of the field with the given key.
  final TextEditingController Function(String key) controllerFor;

  /// The term field.
  final Widget term;

  /// Whether [fields] include an article, so this layout applies.
  static bool appliesTo(List<FieldDefinition> fields) =>
      fields.any((f) => f.key == articleKey);

  Widget _field(FieldDefinition field) => SchemaField(
    languageCode: languageCode,
    field: field,
    controller: controllerFor(field.key),
  );

  @override
  Widget build(BuildContext context) {
    final article = fields.firstWhere((f) => f.key == articleKey);
    final children = <(int, Widget)>[
      (2, _field(article)),
      (3, term),
      for (final field in fields)
        if (field.key != articleKey) (3, _field(field)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= minRowWidth
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                for (final (flex, child) in children)
                  Expanded(flex: flex, child: child),
              ],
            )
          : Column(
              spacing: 12,
              children: [for (final (_, child) in children) child],
            ),
    );
  }
}
