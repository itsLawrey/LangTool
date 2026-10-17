import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';

/// A pack's tabs (Note and Recap) with the bottom navigation bar. Each tab
/// keeps its state while the other one is shown.
class PackShell extends StatelessWidget {
  const PackShell({
    super.key,
    required this.packId,
    required this.navigationShell,
  });

  final String packId;
  final StatefulNavigationShell navigationShell;

  /// Tabs are opened by location rather than `goBranch`: the branches'
  /// locations contain the pack id, so they have no fixed initial location.
  /// Screens deeper than a tab are on the root navigator, so a tab's
  /// location is always its root.
  void _select(BuildContext context, int index) {
    if (index == navigationShell.currentIndex) return;
    context.go(switch (index) {
      0 => Routes.pack(packId),
      _ => Routes.recap(packId),
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => _select(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.edit_note_outlined),
          selectedIcon: Icon(Icons.edit_note),
          label: 'Note',
        ),
        NavigationDestination(
          icon: Icon(Icons.style_outlined),
          selectedIcon: Icon(Icons.style),
          label: 'Recap',
        ),
      ],
    ),
  );
}
