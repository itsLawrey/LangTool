import 'package:flutter/material.dart';

import '../../../domain/models/language_pack.dart';

/// Lets the user pick one of [packs]. Returns `null` if dismissed.
Future<LanguagePack?> showPackPickerDialog(
  BuildContext context, {
  required String title,
  required List<LanguagePack> packs,
}) => showDialog<LanguagePack>(
  context: context,
  builder: (context) => SimpleDialog(
    title: Text(title),
    children: [
      for (final pack in packs)
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, pack),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(pack.name),
          ),
        ),
    ],
  ),
);
