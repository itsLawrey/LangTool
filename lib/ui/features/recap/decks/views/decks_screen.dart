import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../routing/routes.dart';
import '../../../../core/widgets/sync_button.dart';
import '../../../pack_shell/views/back_to_packs_button.dart';
import '../view_models/decks_view_model.dart';
import 'deck_list.dart';

/// The pack's Recap tab.
class DecksScreen extends StatelessWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DecksViewModel>();

    if (viewModel.packMissing) {
      return Scaffold(
        appBar: AppBar(leading: const BackToPacksButton()),
        body: const Center(child: Text('This pack no longer exists.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackToPacksButton(),
        title: Text(viewModel.pack?.name ?? ''),
        actions: const [SyncButton()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // The Note tab's button stays in the tree while this tab is shown;
        // two buttons with the default hero tag would clash.
        heroTag: null,
        onPressed: () => context.push(Routes.newDeck(viewModel.packId)),
        icon: const Icon(Icons.add),
        label: const Text('New deck'),
      ),
      body: DeckList(viewModel: viewModel),
    );
  }
}
