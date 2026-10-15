import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/sync_repository.dart';
import '../date_labels.dart';

/// Shows the sync state of the signed-in account; tapping it syncs now.
class SyncButton extends StatelessWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncRepository>();
    final colors = Theme.of(context).colorScheme;
    final last = switch (sync.lastSyncedAt) {
      final at? => 'Last synced ${dateTimeLabel(at)}',
      null => 'Not synced yet',
    };

    final (Widget icon, String tooltip) = switch (sync.phase) {
      SyncPhase.syncing => (
        const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        'Syncing…',
      ),
      SyncPhase.offline => (const Icon(Icons.cloud_off), 'Offline. $last'),
      SyncPhase.failed => (
        Icon(Icons.sync_problem, color: colors.error),
        'Sync failed: ${sync.error}\n$last',
      ),
      SyncPhase.idle => (
        Icon(sync.lastSyncedAt == null ? Icons.cloud_queue : Icons.cloud_done),
        last,
      ),
    };

    return IconButton(
      tooltip: tooltip,
      icon: icon,
      onPressed: sync.phase == SyncPhase.syncing ? null : sync.sync,
    );
  }
}
