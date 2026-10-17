import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../routing/routes.dart';
import '../../../../core/recap_labels.dart';
import '../view_models/deck_detail_view_model.dart';
import 'recap_direction_dialog.dart';

/// The deck's filters, its number of entries and the Start button.
class DeckOverview extends StatelessWidget {
  const DeckOverview({super.key, required this.viewModel});

  final DeckDetailViewModel viewModel;

  Future<void> _start(BuildContext context) async {
    final direction = await showRecapDirectionDialog(
      context,
      languageCode: viewModel.languageCode!,
    );
    if (direction == null || !context.mounted) return;
    context.push(
      Routes.recapSession(viewModel.packId, viewModel.deckId, direction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deck = viewModel.deck!;
    final count = viewModel.count;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          deckFiltersSummary(deck.filters),
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        if (count != null)
          Text(
            count == 0 ? 'No entries match.' : entryCountLabel(count),
            style: theme.textTheme.titleMedium,
          ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: viewModel.canStart ? () => _start(context) : null,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start'),
        ),
      ],
    );
  }
}
