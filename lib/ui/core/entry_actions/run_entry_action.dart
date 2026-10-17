import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/entry_repository.dart';
import '../../../data/repositories/language_pack_repository.dart';
import '../../../domain/exceptions.dart';
import '../../../domain/models/entry.dart';
import '../../../routing/routes.dart';
import '../../../utils/result.dart';
import '../entry_display.dart';
import '../error_message.dart';
import '../labels.dart';
import '../merge_labels.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/pack_picker_dialog.dart';

/// What can be done to an entry from its ⋮ menu.
enum EntryAction { edit, move, copy, delete }

/// Runs [action] on [entry], with its dialogs and result messages.
/// [onGone] runs after the entry was deleted or moved to another pack.
Future<void> runEntryAction(
  BuildContext context,
  Entry entry,
  EntryAction action, {
  VoidCallback? onGone,
}) async {
  switch (action) {
    case EntryAction.edit:
      await context.push(Routes.editEntry(entry.packId, entry.id));
    case EntryAction.delete:
      await _delete(context, entry, onGone);
    case EntryAction.move || EntryAction.copy:
      await _transfer(context, entry, move: action == EntryAction.move, onGone);
  }
}

Future<void> _delete(
  BuildContext context,
  Entry entry,
  VoidCallback? onGone,
) async {
  final entries = context.read<EntryRepository>();
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showConfirmDialog(
    context,
    title: 'Delete "${headword(entry)}"?',
    confirmLabel: 'Delete',
    destructive: true,
  );
  if (!confirmed) return;

  switch (await entries.delete(entry.id)) {
    case Ok():
      onGone?.call();
    case Err(:final error):
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(error))));
  }
}

/// Moves or copies [entry] to a pack the user picks. If that pack already
/// has the entry, offers to combine the two.
Future<void> _transfer(
  BuildContext context,
  Entry entry,
  VoidCallback? onGone, {
  required bool move,
}) async {
  final entries = context.read<EntryRepository>();
  final packs = await context
      .read<LanguagePackRepository>()
      .watchPacks(entry.ownerId)
      .first;
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  void show(String message) =>
      messenger.showSnackBar(SnackBar(content: Text(message)));

  final source = packs.where((p) => p.id == entry.packId).firstOrNull;
  if (source == null) {
    return show(errorMessage(NotFoundException(entry.packId)));
  }
  final targets = [
    for (final pack in packs)
      if (pack.id != source.id && pack.languageCode == source.languageCode)
        pack,
  ];
  if (targets.isEmpty) {
    return show('There is no other ${languageName(source.languageCode)} pack.');
  }

  final target = await showPackPickerDialog(
    context,
    title: move ? 'Move to' : 'Copy to',
    packs: targets,
  );
  if (target == null || !context.mounted) return;

  var result = await entries.transfer(
    entry.id,
    targetPackId: target.id,
    move: move,
  );
  var combined = false;
  if (result case Err(error: DuplicateEntryException(:final existing))) {
    if (!context.mounted) return;
    final confirmed = await showConfirmDialog(
      context,
      title: '"${headword(existing)}" is already in ${target.name}',
      message:
          'Combine them into one entry? Unique translations, examples, tags '
          'and notes of both are kept.',
      confirmLabel: 'Combine',
    );
    if (!confirmed) return;
    combined = true;
    result = await entries.transfer(
      entry.id,
      targetPackId: target.id,
      move: move,
      combine: (clash) => clashNote(source.languageCode, clash),
    );
  }

  switch (result) {
    case Ok():
      show(transferredLabel(move: move, combined: combined, pack: target.name));
      if (move) onGone?.call();
    case Err(:final error):
      show(errorMessage(error, languageCode: source.languageCode));
  }
}

/// E.g. `Moved to "Reise".` or `Copied to "Reise" and combined.`
String transferredLabel({
  required bool move,
  required bool combined,
  required String pack,
}) =>
    '${move ? 'Moved' : 'Copied'} to "$pack"'
    '${combined ? ' and combined' : ''}.';
