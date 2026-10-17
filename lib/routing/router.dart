import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth_repository.dart';
import '../ui/features/auth/view_models/login_view_model.dart';
import '../ui/features/auth/views/login_screen.dart';
import '../ui/features/packs/view_models/packs_view_model.dart';
import '../ui/features/packs/views/packs_screen.dart';
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
        routes: [packShellRoute(rootNavigatorKey)],
      ),
    ],
  );
}
