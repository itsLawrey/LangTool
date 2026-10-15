import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/language_pack.dart';
import '../../../../routing/routes.dart';
import '../../../../utils/result.dart';
import '../../../core/error_message.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/text_input_dialog.dart';
import '../view_models/packs_view_model.dart';
import 'account_menu.dart';
import 'pack_tile.dart';

class PacksScreen extends StatelessWidget {
  const PacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PacksViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language packs'),
        actions: const [AccountMenu()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, viewModel),
        icon: const Icon(Icons.add),
        label: const Text('New pack'),
      ),
      body: switch (viewModel) {
        PacksViewModel(loading: true) => const Center(
          child: CircularProgressIndicator(),
        ),
        PacksViewModel(packs: []) => const Center(
          child: Text('No language packs yet.'),
        ),
        _ => ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: viewModel.packs.length,
          itemBuilder: (context, index) {
            final pack = viewModel.packs[index];
            return PackTile(
              pack: pack,
              onOpen: () => context.push(Routes.pack(pack.id)),
              onRename: () => _rename(context, viewModel, pack),
              onDelete: () => _delete(context, viewModel, pack),
            );
          },
        ),
      },
    );
  }

  Future<void> _create(BuildContext context, PacksViewModel viewModel) async {
    final name = await showTextInputDialog(
      context,
      title: 'New German pack',
      label: 'Name',
      confirmLabel: 'Create',
    );
    if (name == null || !context.mounted) return;
    final result = await viewModel.create(name);
    if (context.mounted) _showError(context, result);
  }

  Future<void> _rename(
    BuildContext context,
    PacksViewModel viewModel,
    LanguagePack pack,
  ) async {
    final name = await showTextInputDialog(
      context,
      title: 'Rename pack',
      label: 'Name',
      confirmLabel: 'Rename',
      initialValue: pack.name,
    );
    if (name == null || !context.mounted) return;
    final result = await viewModel.rename(pack, name);
    if (context.mounted) _showError(context, result);
  }

  Future<void> _delete(
    BuildContext context,
    PacksViewModel viewModel,
    LanguagePack pack,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete "${pack.name}"?',
      message: 'All entries in this pack will be deleted.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final result = await viewModel.delete(pack);
    if (context.mounted) _showError(context, result);
  }

  void _showError(BuildContext context, Result<Object?> result) {
    if (result case Err(:final error)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage(error))));
    }
  }
}
