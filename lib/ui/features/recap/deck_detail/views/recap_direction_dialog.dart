import 'package:flutter/material.dart';

import '../../../../../domain/recap/recap_session.dart';
import '../../../../core/recap_labels.dart';

/// Asks which card side to show first. Returns `null` if dismissed.
Future<RecapDirection?> showRecapDirectionDialog(
  BuildContext context, {
  required String languageCode,
}) => showDialog<RecapDirection>(
  context: context,
  builder: (context) => SimpleDialog(
    title: const Text('Card side'),
    children: [
      for (final direction in RecapDirection.values)
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, direction),
          child: Text(recapDirectionLabel(direction, languageCode)),
        ),
    ],
  ),
);
