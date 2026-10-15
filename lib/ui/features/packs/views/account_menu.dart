import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/auth_repository.dart';

/// Shows the signed-in profile and a sign-out action.
class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRepository>();
    final name = auth.profile?.displayName ?? '';

    return PopupMenuButton<void>(
      icon: const Icon(Icons.account_circle_outlined),
      tooltip: 'Account',
      itemBuilder: (context) => [
        PopupMenuItem(enabled: false, child: Text(name)),
        const PopupMenuDivider(),
        PopupMenuItem(onTap: auth.signOut, child: const Text('Sign out')),
      ],
    );
  }
}
