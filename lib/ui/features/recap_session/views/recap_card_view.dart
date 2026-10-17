import 'package:flutter/material.dart';

import '../view_models/recap_session_view_model.dart';
import 'recap_answer.dart';
import 'recap_card_front.dart';
import 'recap_frame.dart';

/// The current card with Reveal, or once revealed the answer with the
/// Didn't know / Knew it buttons.
class RecapCardView extends StatelessWidget {
  const RecapCardView({super.key, required this.viewModel});

  final RecapSessionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final card = viewModel.current!;
    final revealed = viewModel.revealed;

    return RecapFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  key: ValueKey((viewModel.position, revealed)),
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 48).clamp(
                        0,
                        double.infinity,
                      ),
                    ),
                    child: revealed
                        ? Align(
                            alignment: Alignment.topLeft,
                            child: RecapAnswer(
                              entry: card.entry,
                              schema: viewModel.schema,
                            ),
                          )
                        : Center(child: RecapCardFront(card: card)),
                  ),
                ),
              ),
            ),
          ),
          if (revealed)
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => viewModel.answer(knewIt: false),
                    child: const Text("Didn't know"),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () => viewModel.answer(knewIt: true),
                    child: const Text('Knew it'),
                  ),
                ),
              ],
            )
          else
            FilledButton(
              onPressed: viewModel.reveal,
              child: const Text('Reveal'),
            ),
        ],
      ),
    );
  }
}
