import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';

/// Back button for a pack's tabs. They are the first page of their tab's
/// navigator, so the app bar does not add one by itself.
class BackToPacksButton extends StatelessWidget {
  const BackToPacksButton({super.key});

  @override
  Widget build(BuildContext context) =>
      BackButton(onPressed: () => context.go(Routes.packs));
}
