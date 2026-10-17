import 'package:flutter/material.dart';

import 'recap_frame.dart';

/// Shown after the last card: how many were known and not known.
class RecapSummary extends StatelessWidget {
  const RecapSummary({
    super.key,
    required this.knownCount,
    required this.unknownCount,
    required this.total,
    required this.onPractiseAgain,
    required this.onDone,
  });

  final int knownCount;
  final int unknownCount;
  final int total;
  final VoidCallback onPractiseAgain;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RecapFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(
            'Session complete',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          Text(
            'Knew $knownCount of $total',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          Text(
            "Didn't know $unknownCount",
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onPractiseAgain,
            child: const Text('Practise again'),
          ),
          OutlinedButton(onPressed: onDone, child: const Text('Done')),
        ],
      ),
    );
  }
}
