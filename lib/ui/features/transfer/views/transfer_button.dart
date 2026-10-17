import 'package:flutter/material.dart';

/// The screen's full-width action button, below its list.
class TransferButton extends StatelessWidget {
  const TransferButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: FilledButton(onPressed: onPressed, child: Text(label)),
    ),
  );
}
