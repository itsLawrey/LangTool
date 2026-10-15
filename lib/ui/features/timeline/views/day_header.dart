import 'package:flutter/material.dart';

import '../../../core/date_labels.dart';

class DayHeader extends StatelessWidget {
  const DayHeader({super.key, required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        dayLabel(day, now: DateTime.now()),
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
