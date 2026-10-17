import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth_repository.dart';
import '../ui/features/auth/view_models/login_view_model.dart';
import '../ui/features/auth/views/login_screen.dart';
import '../ui/features/packs/view_models/packs_view_model.dart';
import '../ui/features/packs/views/packs_screen.dart';
import '../ui/features/transfer/view_models/export_view_model.dart';
import '../ui/features/transfer/view_models/import_view_model.dart';
import '../ui/features/transfer/views/export_screen.dart';
import '../ui/features/transfer/views/import_screen.dart';
import 'pack_routes.dart';
import 'routes.dart';

/// Signed-out users are sent to the login screen, signed-in users away from
/// it. Each route creates its view model, which is disposed with the route.
GoRouter buildRouter(AuthRepository auth) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.packs,
    refreshListenable: auth,
    redirect: (context, state) {
      final onLogin = state.matchedLocation == Routes.login;
      if (!auth.isSignedIn) return onLogin ? null : Routes.login;
      return onLogin ? Routes.packs : null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => LoginViewModel(authRepository: auth),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: Routes.packs,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => PacksViewModel(
            packRepository: context.read(),
            ownerId: auth.profile!.id,
          ),
          child: const PacksScreen(),
        ),
        routes: [
          // Routes.importPacks. The picked file's bytes come as `extra`.
          // Without them (e.g. after a reload on the web) there is nothing
          // to preview.
          GoRoute(
            path: 'import',
            redirect: (context, state) =>
                state.extra is Uint8List ? null : Routes.packs,
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) => ImportViewModel(
                transferRepository: context.read(),
                ownerId: auth.profile!.id,
                bytes: state.extra! as Uint8List,
              ),
              child: const ImportScreen(),
            ),
          ),
          // Routes.exportPacks.
          GoRoute(
            path: 'export',
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) => ExportViewModel(
                packRepository: context.read(),
                transferRepository: context.read(),
                fileService: context.read(),
                ownerId: auth.profile!.id,
              ),
              child: const ExportScreen(),
            ),
          ),
          packShellRoute(rootNavigatorKey),
        ],
      ),
    ],
  );
}
