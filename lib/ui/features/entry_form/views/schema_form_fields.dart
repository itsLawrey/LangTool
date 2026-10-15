import 'package:flutter/material.dart';

import '../../../../domain/languages/language_schema.dart';
import '../../../core/labels.dart';

/// The type-specific form fields of the selected word type, as defined by the
/// language schema. Fields with allowed values become dropdowns, the rest
/// free text.
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
        if (field.allowedValues case final allowed?)
          _ChoiceField(
            field: field,
            label: fieldLabel(languageCode, field.key),
            options: allowed.toList(),
            controller: controllerFor(field.key),
          )
        else
          TextFormField(
            controller: controllerFor(field.key),
            decoration: InputDecoration(
              labelText: fieldLabel(languageCode, field.key),
            ),
            validator: (value) => field.required && (value ?? '').trim().isEmpty
                ? 'Required.'
                : null,
          ),
    ],
  );
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
