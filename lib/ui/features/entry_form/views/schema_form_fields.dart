import 'package:flutter/material.dart';

import '../../../../domain/languages/language_schema.dart';
import '../../../core/labels.dart';

/// The type-specific form fields of the selected word type, as defined by the
/// language schema, one below the other.
class SchemaFormFields extends StatelessWidget {
  const SchemaFormFields({
    super.key,
    required this.languageCode,
    required this.fields,
    required this.controllerFor,
  });

  final String languageCode;
  final List<FieldDefinition> fields;

  /// The controller holding the value of the field with the given key.
  final TextEditingController Function(String key) controllerFor;

  @override
  Widget build(BuildContext context) => Column(
    spacing: 12,
    children: [
      for (final field in fields)
        SchemaField(
          languageCode: languageCode,
          field: field,
          controller: controllerFor(field.key),
        ),
    ],
  );
}

/// One type-specific form field. A field with allowed values becomes a
/// dropdown, the rest free text.
class SchemaField extends StatelessWidget {
  const SchemaField({
    super.key,
    required this.languageCode,
    required this.field,
    required this.controller,
  });

  final String languageCode;
  final FieldDefinition field;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final label = fieldLabel(languageCode, field.key);
    if (field.allowedValues case final allowed?) {
      return _ChoiceField(
        field: field,
        label: label,
        options: allowed.toList(),
        controller: controller,
      );
    }
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      textInputAction: TextInputAction.next,
      validator: (value) =>
          field.required && (value ?? '').trim().isEmpty ? 'Required.' : null,
    );
  }
}

class _ChoiceField extends StatelessWidget {
  const _ChoiceField({
    required this.field,
    required this.label,
    required this.options,
    required this.controller,
  });

  final FieldDefinition field;
  final String label;
  final List<String> options;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final current = controller.text;
    return DropdownButtonFormField<String>(
      initialValue: options.contains(current) ? current : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        if (!field.required)
          const DropdownMenuItem(value: '', child: Text('—')),
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: (value) => controller.text = value ?? '',
      validator: (value) =>
          field.required && (value ?? '').isEmpty ? 'Required.' : null,
    );
  }
}
