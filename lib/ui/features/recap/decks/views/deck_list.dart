import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../routing/routes.dart';
import '../view_models/decks_view_model.dart';
import 'deck_card.dart';

/// The pack's decks as cards, built lazily.
class DeckList extends StatelessWidget {
  const DeckList({super.key, required this.viewModel});

  final DecksViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final decks = viewModel.decks;
    if (decks.isEmpty) return const Center(child: Text('No decks yet.'));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final deck = decks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: DeckCard(
            deck: deck,
            count: viewModel.countFor(deck.id),
            onTap: () => context.push(Routes.deck(viewModel.packId, deck.id)),
          ),
        );
      },
    );
  }
}
