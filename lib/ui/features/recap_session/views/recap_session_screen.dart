import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/confirm_dialog.dart';
import '../view_models/recap_session_view_model.dart';
import 'recap_card_view.dart';
import 'recap_message.dart';
import 'recap_summary.dart';

/// Practises a deck card by card, then shows how many were known. Leaving
/// mid-session asks for confirmation; nothing is saved.
class RecapSessionScreen extends StatelessWidget {
  const RecapSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecapSessionViewModel>();
    final status = viewModel.status;
    final inProgress = status == RecapSessionStatus.inProgress;

    return PopScope(
      canPop: !inProgress,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmEnd(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(viewModel.deck?.name ?? ''),
          actions: [
            if (inProgress)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('${viewModel.position + 1} / ${viewModel.total}'),
              ),
          ],
        ),
        body: switch (status) {
          RecapSessionStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          RecapSessionStatus.deckMissing => const RecapMessage(
            message: 'This deck no longer exists.',
          ),
          RecapSessionStatus.empty => RecapMessage(
            message: 'No entries match this deck.',
            onBack: () => context.pop(),
          ),
          RecapSessionStatus.inProgress => RecapCardView(viewModel: viewModel),
          RecapSessionStatus.finished => RecapSummary(
            knownCount: viewModel.knownCount,
            unknownCount: viewModel.unknownCount,
            total: viewModel.total,
            onPractiseAgain: viewModel.restart,
            onDone: () => context.pop(),
          ),
        },
      ),
    );
  }

  Future<void> _confirmEnd(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'End this session?',
      confirmLabel: 'End',
    );
    if (confirmed && context.mounted) context.pop();
  }
}
