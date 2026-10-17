import 'package:flutter/material.dart';

import '../../../../domain/recap/recap_session.dart';
import '../../../core/entry_display.dart';
import '../../../core/labels.dart';

/// The side of a card shown before it is revealed: the headword or the
/// translations, with the word type.
class RecapCardFront extends StatelessWidget {
  const RecapCardFront({super.key, required this.card});

  final RecapCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = card.entry;
    final text = switch (card.front) {
      CardSide.foreign => headword(entry),
      CardSide.translation => entry.translations.join(', '),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        Text(
          wordTypeLabel(entry.wordType),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
