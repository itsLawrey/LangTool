import 'package:flutter/material.dart';

/// Centres [child] with a maximum width, so the session reads well on wide
/// and narrow screens alike.
class RecapFrame extends StatelessWidget {
  const RecapFrame({super.key, required this.child});

  static const maxWidth = 600.0;

  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}
