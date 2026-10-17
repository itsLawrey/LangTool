import 'package:flutter/material.dart';

import 'recap_frame.dart';

/// A centred message, optionally with a Back button.
class RecapMessage extends StatelessWidget {
  const RecapMessage({super.key, required this.message, this.onBack});

  final String message;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => RecapFrame(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Text(message, textAlign: TextAlign.center),
        if (onBack case final onBack?)
          OutlinedButton(onPressed: onBack, child: const Text('Back')),
      ],
    ),
  );
}
