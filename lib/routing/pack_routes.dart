import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ui/features/entry_detail/view_models/entry_detail_view_model.dart';
import '../ui/features/entry_detail/views/entry_detail_screen.dart';
import '../ui/features/entry_form/view_models/entry_form_view_model.dart';
import '../ui/features/entry_form/views/entry_form_screen.dart';
import '../ui/features/pack_shell/views/pack_shell.dart';
import '../ui/features/recap/deck_detail/view_models/deck_detail_view_model.dart';
import '../ui/features/recap/deck_detail/views/deck_detail_screen.dart';
import '../ui/features/recap/deck_editor/view_models/deck_editor_view_model.dart';
import '../ui/features/recap/deck_editor/views/deck_editor_screen.dart';
import '../ui/features/recap/decks/view_models/decks_view_model.dart';
import '../ui/features/recap/decks/views/decks_screen.dart';
import '../ui/features/recap_session/view_models/recap_direction_param.dart';
import '../ui/features/recap_session/view_models/recap_session_view_model.dart';
import '../ui/features/recap_session/views/recap_session_screen.dart';
import '../ui/features/timeline/view_models/timeline_view_model.dart';
import '../ui/features/timeline/views/timeline_screen.dart';
import 'routes.dart';

/// The routes of an opened pack, relative to `/`: the Note and Recap tabs
/// in a shell with a bottom navigation bar, each keeping its state.
///
/// Screens below a tab (entries, decks, sessions) are placed on
/// [rootNavigatorKey]'s navigator, over the shell, so they are shown without
/// the bar.
RouteBase packShellRoute(GlobalKey<NavigatorState> rootNavigatorKey) {
  GoRoute fullScreen(
    String path,
    GoRouterWidgetBuilder builder, {
    List<RouteBase> routes = const [],
  }) => GoRoute(
    path: path,
    parentNavigatorKey: rootNavigatorKey,
    builder: builder,
    routes: routes,
  );

  return StatefulShellRoute.indexedStack(
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state, navigationShell) => PackShell(
      packId: state.pathParameters['packId']!,
      navigationShell: navigationShell,
    ),
    branches: [
      StatefulShellBranch(
        // go_router requires a fixed initial location for each branch, but
        // the tabs' paths contain the pack id. `PackShell` opens tabs by
        // location, so this placeholder is never navigated to.
        initialLocation: Routes.pack(':packId'),
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
              fullScreen(
                'entries/new',
                (context, state) => _entryForm(state.pathParameters['packId']!),
              ),
              fullScreen(
                'entries/:entryId',
                (context, state) => ChangeNotifierProvider(
                  create: (context) => EntryDetailViewModel(
                    entryRepository: context.read(),
                    packRepository: context.read(),
                    packId: state.pathParameters['packId']!,
                    entryId: state.pathParameters['entryId']!,
                  ),
                  child: const EntryDetailScreen(),
                ),
                routes: [
                  fullScreen(
                    'edit',
                    (context, state) => _entryForm(
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
      StatefulShellBranch(
        initialLocation: Routes.recap(':packId'),
        routes: [
          GoRoute(
            path: 'packs/:packId/recap',
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) => DecksViewModel(
                deckRepository: context.read(),
                packRepository: context.read(),
                packId: state.pathParameters['packId']!,
              ),
              child: const DecksScreen(),
            ),
            routes: [
              fullScreen(
                'decks/new',
                (context, state) =>
                    _deckEditor(state.pathParameters['packId']!),
              ),
              fullScreen(
                'decks/:deckId',
                (context, state) => ChangeNotifierProvider(
                  create: (context) => DeckDetailViewModel(
                    deckRepository: context.read(),
                    packRepository: context.read(),
                    packId: state.pathParameters['packId']!,
                    deckId: state.pathParameters['deckId']!,
                  ),
                  child: const DeckDetailScreen(),
                ),
                routes: [
                  fullScreen(
                    'edit',
                    (context, state) => _deckEditor(
                      state.pathParameters['packId']!,
                      deckId: state.pathParameters['deckId'],
                    ),
                  ),
                  // Query parameter `direction`: a `RecapDirection` name.
                  fullScreen(
                    'session',
                    (context, state) => ChangeNotifierProvider(
                      create: (context) => RecapSessionViewModel(
                        deckRepository: context.read(),
                        packRepository: context.read(),
                        packId: state.pathParameters['packId']!,
                        deckId: state.pathParameters['deckId']!,
                        direction: recapDirectionFromParam(
                          state.uri.queryParameters['direction'],
                        ),
                      ),
                      child: const RecapSessionScreen(),
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
}

Widget _entryForm(String packId, {String? entryId}) => ChangeNotifierProvider(
  create: (context) => EntryFormViewModel(
    entryRepository: context.read(),
    packRepository: context.read(),
    settingsRepository: context.read(),
    packId: packId,
    entryId: entryId,
  ),
  child: const EntryFormScreen(),
);

Widget _deckEditor(String packId, {String? deckId}) => ChangeNotifierProvider(
  create: (context) => DeckEditorViewModel(
    deckRepository: context.read(),
    packRepository: context.read(),
    packId: packId,
    deckId: deckId,
  ),
  child: const DeckEditorScreen(),
);
