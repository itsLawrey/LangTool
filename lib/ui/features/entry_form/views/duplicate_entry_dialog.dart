import 'package:flutter/material.dart';

import '../../../../domain/models/entry.dart';
import '../../../core/entry_display.dart';
import '../../../core/labels.dart';

/// Tells the user [existing] already has this term and word type. Returns
/// `true` if they choose to open it.
Future<bool> showDuplicateEntryDialog(
  BuildContext context,
  Entry existing,
) async {
  final open = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Already in this pack'),
      content: Text(
        '${headword(existing)} (${wordTypeLabel(existing.wordType)}) '
        'already exists.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('OK'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Open existing'),
        ),
      ],
    ),
  );
  return open ?? false;
}
