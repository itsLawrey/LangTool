import 'package:flutter/material.dart';

/// A titled part of the deck editor's filters.
class FilterSection extends StatelessWidget {
  const FilterSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 8,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleSmall),
      child,
    ],
  );
}
