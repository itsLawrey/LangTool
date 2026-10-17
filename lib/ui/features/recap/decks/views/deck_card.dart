import 'package:flutter/material.dart';

import '../../../../../domain/models/deck.dart';
import '../../../../core/recap_labels.dart';

/// Summary of a deck: name, number of matching entries and its filters.
class DeckCard extends StatelessWidget {
  const DeckCard({
    super.key,
    required this.deck,
    required this.count,
    required this.onTap,
  });

  final Deck deck;

  /// Matching entries, or `null` while they are counted.
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(deck.name, style: theme.textTheme.titleMedium),
                  ),
                  if (count case final count?)
                    Text(
                      entryCountLabel(count),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              Text(
                deckFiltersSummary(deck.filters),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
