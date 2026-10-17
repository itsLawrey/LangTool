import 'package:flutter/material.dart';

import '../../../../../../domain/recap/deck_filter.dart';
import '../../../../../core/recap_labels.dart';

/// A filter of the edited deck that this editor cannot change. It is saved
/// unchanged.
class KeptFilterTile extends StatelessWidget {
  const KeptFilterTile({super.key, required this.filter});

  final DeckFilter filter;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.lock_outline),
    title: Text(deckFilterLabel(filter)),
  );
}
