import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../routing/routes.dart';
import '../../../../../utils/result.dart';
import '../../../../core/error_message.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../view_models/deck_detail_view_model.dart';
import 'deck_overview.dart';

class DeckDetailScreen extends StatelessWidget {
  const DeckDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DeckDetailViewModel>();
    final deck = viewModel.deck;

    return Scaffold(
      appBar: AppBar(
        title: Text(deck?.name ?? ''),
        actions: [
          if (deck != null) ...[
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(
                Routes.editDeck(viewModel.packId, viewModel.deckId),
              ),
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, viewModel),
            ),
          ],
        ],
      ),
      body: switch (viewModel) {
        DeckDetailViewModel(loading: true) => const Center(
          child: CircularProgressIndicator(),
        ),
        DeckDetailViewModel(deck: null) => const Center(
          child: Text('This deck no longer exists.'),
        ),
        _ => DeckOverview(viewModel: viewModel),
      },
    );
  }

  Future<void> _delete(
    BuildContext context,
    DeckDetailViewModel viewModel,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete "${viewModel.deck!.name}"?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    switch (await viewModel.delete()) {
      case Ok():
        if (context.mounted) context.pop();
      case Err(:final error):
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(errorMessage(error))));
        }
    }
  }
}
