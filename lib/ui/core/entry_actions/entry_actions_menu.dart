import 'package:flutter/material.dart';

import '../../../domain/models/entry.dart';
import 'run_entry_action.dart';

/// The ⋮ menu of an entry: Edit, Move to…, Copy to… and Delete.
/// [onGone] runs after the entry was deleted or moved to another pack.
class EntryActionsMenu extends StatelessWidget {
  const EntryActionsMenu({
    super.key,
    required this.entry,
    this.onGone,
    this.compact = false,
  });

  final Entry entry;
  final VoidCallback? onGone;

  /// A smaller button, for the corner of an entry card.
  final bool compact;

  @override
  Widget build(BuildContext context) => PopupMenuButton<EntryAction>(
    tooltip: 'Entry actions',
    icon: Icon(Icons.more_vert, size: compact ? 20 : null),
    padding: compact ? EdgeInsets.zero : const EdgeInsets.all(8),
    style: compact
        ? const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )
        : null,
    onSelected: (action) =>
        runEntryAction(context, entry, action, onGone: onGone),
    itemBuilder: (_) => const [
      PopupMenuItem(value: EntryAction.edit, child: Text('Edit')),
      PopupMenuItem(value: EntryAction.move, child: Text('Move to…')),
      PopupMenuItem(value: EntryAction.copy, child: Text('Copy to…')),
      PopupMenuItem(value: EntryAction.delete, child: Text('Delete')),
    ],
  );
}
