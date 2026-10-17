import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/exceptions.dart';
import '../../../../domain/models/entry_draft.dart';
import '../../../../domain/models/word_type.dart';
import '../../../../routing/routes.dart';
import '../../../../utils/result.dart';
import '../../../core/entry_display.dart';
import '../../../core/error_message.dart';
import '../../../core/labels.dart';
import '../view_models/entry_form_view_model.dart';
import 'duplicate_entry_dialog.dart';
import 'example_list_field.dart';
import 'list_controllers.dart';
import 'schema_form_fields.dart';
import 'similar_entries_dialog.dart';
import 'text_list_field.dart';

/// The entry form. Owns the text controllers; [viewModel] does the saving.
class EntryForm extends StatefulWidget {
  const EntryForm({super.key, required this.viewModel});

  final EntryFormViewModel viewModel;

  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _formKey = GlobalKey<FormState>();
  late final _initial = widget.viewModel.initial;
  late final _schema = widget.viewModel.schema!;

  late WordType _wordType =
      _initial?.wordType ??
      widget.viewModel.nextWordType ??
      _schema.wordTypes.keys.first;
  late final _term = TextEditingController(text: _initial?.term);
  late final _forms = {
    for (final MapEntry(:key, :value) in (_initial?.forms ?? {}).entries)
      key: TextEditingController(text: value),
  };
  late final _translations = TextListController(
    _initial?.translations ?? const [''],
  );
  late final _examples = ExampleListController(_initial?.examples ?? const []);
  late final _tags = TextEditingController(text: _initial?.tags.join(', '));
  late final _notes = TextEditingController(text: _initial?.notes);

  @override
  void dispose() {
    for (final controller in [_term, ..._forms.values, _tags, _notes]) {
      controller.dispose();
    }
    _translations.dispose();
    _examples.dispose();
    super.dispose();
  }

  TextEditingController _formController(String key) =>
      _forms.putIfAbsent(key, TextEditingController.new);

  /// Only the fields of the selected word type are saved; values typed for
  /// another type are kept in the form but dropped here.
  EntryDraft _draft() {
    final fields = _schema.wordTypes[_wordType]?.fields ?? const [];
    return EntryDraft(
      packId: widget.viewModel.packId,
      wordType: _wordType,
      term: _term.text,
      forms: {for (final f in fields) f.key: _formController(f.key).text},
      translations: _translations.values,
      examples: _examples.values,
      tags: _tags.text.split(','),
      notes: _notes.text,
    );
  }

  /// Saves the entry, then closes the form, or with [andNew] starts a blank
  /// one for the next entry.
  Future<void> _save({bool andNew = false}) async {
    if (!_formKey.currentState!.validate()) return;
    final draft = _draft();
    final viewModel = widget.viewModel;

    final similar = await viewModel.findSimilar(draft.term, draft.wordType);
    if (!mounted) return;
    if (similar.isNotEmpty &&
        !await showSimilarEntriesDialog(context, similar)) {
      return;
    }

    final result = await viewModel.save(draft);
    if (!mounted) return;
    switch (result) {
      case Ok(:final value) when andNew:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${headword(value)} saved.')));
        viewModel.startNext(draft.wordType);
      case Ok():
        context.pop();
      case Err(error: DuplicateEntryException(:final existing)):
        if (await showDuplicateEntryDialog(context, existing) && mounted) {
          context.pushReplacement(Routes.entry(viewModel.packId, existing.id));
        }
      case Err(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage(error, languageCode: _schema.code)),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = _schema.code;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<WordType>(
            initialValue: _wordType,
            decoration: const InputDecoration(labelText: 'Word type'),
            items: [
              for (final type in _schema.wordTypes.keys)
                DropdownMenuItem(value: type, child: Text(wordTypeLabel(type))),
            ],
            onChanged: (type) => setState(() => _wordType = type!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _term,
            autofocus: widget.viewModel.round > 0,
            decoration: const InputDecoration(labelText: 'Term'),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Required.' : null,
          ),
          const SizedBox(height: 12),
          SchemaFormFields(
            key: ValueKey(_wordType),
            languageCode: languageCode,
            fields: _schema.wordTypes[_wordType]?.fields ?? const [],
            controllerFor: _formController,
          ),
          const SizedBox(height: 24),
          TextListField(
            controller: _translations,
            title: 'Translations',
            itemLabel: 'Translation',
            addLabel: 'Add translation',
          ),
          const SizedBox(height: 16),
          ExampleListField(controller: _examples),
          const SizedBox(height: 16),
          TextField(
            controller: _tags,
            decoration: const InputDecoration(
              labelText: 'Tags',
              helperText: 'Separate with commas.',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Notes'),
            maxLines: null,
          ),
          const SizedBox(height: 24),
          if (widget.viewModel.isEditing)
            FilledButton(
              onPressed: widget.viewModel.saving ? null : _save,
              child: const Text('Save'),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.viewModel.saving
                        ? null
                        : () => _save(andNew: true),
                    child: const Text('Save and new'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: widget.viewModel.saving ? null : _save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
