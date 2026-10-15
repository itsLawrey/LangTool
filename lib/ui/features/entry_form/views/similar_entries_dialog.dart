import 'package:flutter/material.dart';

import '../../../../domain/models/entry.dart';
import '../../../core/entry_display.dart';
import '../../../core/labels.dart';

/// Lists existing entries similar to the one being saved. Returns `true` if
/// the user chooses to save anyway.
Future<bool> showSimilarEntriesDialog(
  BuildContext context,
  List<Entry> similar,
) async {
  final saveAnyway = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Similar entries exist'),
      content: SizedBox(
        width: 360,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final entry in similar)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(headword(entry)),
                subtitle: Text(
                  [
                    wordTypeLabel(entry.wordType),
                    ...entry.translations,
                  ].join(' · '),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Save anyway'),
        ),
      ],
    ),
  );
  return saveAnyway ?? false;
}
