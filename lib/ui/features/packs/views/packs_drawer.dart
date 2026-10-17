import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/file_service.dart';
import '../../../../routing/routes.dart';
import '../../../core/error_message.dart';

/// The signed-in account, import, export, merge, options and sign out.
class PacksDrawer extends StatelessWidget {
  const PacksDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRepository>();

    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(auth.profile?.displayName ?? ''),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.file_open_outlined),
              title: const Text('Import'),
              onTap: () => _import(context),
            ),
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('Export'),
              onTap: () => _open(context, Routes.exportPacks),
            ),
            ListTile(
              leading: const Icon(Icons.merge),
              title: const Text('Merge packs'),
              onTap: () => _open(context, Routes.mergePacks),
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Options'),
              onTap: () => _open(context, Routes.options),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: auth.signOut,
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the file dialog straight from the tap: browsers only allow it
  /// during a user gesture.
  Future<void> _import(BuildContext context) async {
    final picking = context.read<FileService>().pickFile();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    try {
      final picked = await picking;
      if (picked != null) router.push(Routes.importPacks, extra: picked.bytes);
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(e))));
    }
  }

  /// Closes the drawer and opens [route].
  void _open(BuildContext context, String route) {
    final router = GoRouter.of(context);
    Navigator.pop(context);
    router.push(route);
  }
}
