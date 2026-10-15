import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth_repository.dart';
import '../ui/features/auth/view_models/login_view_model.dart';
import '../ui/features/auth/views/login_screen.dart';
import '../ui/features/entry_detail/view_models/entry_detail_view_model.dart';
import '../ui/features/entry_detail/views/entry_detail_screen.dart';
import '../ui/features/entry_form/view_models/entry_form_view_model.dart';
import '../ui/features/entry_form/views/entry_form_screen.dart';
import '../ui/features/packs/view_models/packs_view_model.dart';
import '../ui/features/packs/views/packs_screen.dart';
import '../ui/features/timeline/view_models/timeline_view_model.dart';
import '../ui/features/timeline/views/timeline_screen.dart';
import 'routes.dart';

/// Signed-out users are sent to the login screen, signed-in users away from
/// it. Each route creates its view model, which is disposed with the route.
GoRouter buildRouter(AuthRepository auth) => GoRouter(
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
        GoRoute(
          path: 'packs/:packId',
          builder: (context, state) => ChangeNotifierProvider(
            create: (context) => TimelineViewModel(
              entryRepository: context.read(),
              packRepository: context.read(),
              packId: state.pathParameters['packId']!,
            ),
            child: const TimelineScreen(),
          ),
          routes: [
            GoRoute(
              path: 'entries/new',
              builder: (context, state) =>
                  _entryForm(context, state.pathParameters['packId']!),
            ),
            GoRoute(
              path: 'entries/:entryId',
              builder: (context, state) => ChangeNotifierProvider(
                create: (context) => EntryDetailViewModel(
                  entryRepository: context.read(),
                  packRepository: context.read(),
                  packId: state.pathParameters['packId']!,
                  entryId: state.pathParameters['entryId']!,
                ),
                child: const EntryDetailScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => _entryForm(
                    context,
                    state.pathParameters['packId']!,
                    entryId: state.pathParameters['entryId'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

Widget _entryForm(BuildContext context, String packId, {String? entryId}) =>
    ChangeNotifierProvider(
      create: (context) => EntryFormViewModel(
        entryRepository: context.read(),
        packRepository: context.read(),
        packId: packId,
        entryId: entryId,
      ),
      child: const EntryFormScreen(),
    );
