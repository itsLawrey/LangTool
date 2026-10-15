import 'package:flutter/material.dart';

import '../../../../domain/models/language_pack.dart';
import '../../../core/labels.dart';

enum _PackAction { rename, delete }

class PackTile extends StatelessWidget {
  const PackTile({
    super.key,
    required this.pack,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  final LanguagePack pack;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(pack.name),
    subtitle: Text(languageName(pack.languageCode)),
    onTap: onOpen,
    trailing: PopupMenuButton<_PackAction>(
      onSelected: (action) => switch (action) {
        _PackAction.rename => onRename(),
        _PackAction.delete => onDelete(),
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: _PackAction.rename, child: Text('Rename')),
        PopupMenuItem(value: _PackAction.delete, child: Text('Delete')),
      ],
    ),
  );
}
