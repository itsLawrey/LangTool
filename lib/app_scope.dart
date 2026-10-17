import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/local/app_database.dart';
import 'data/local/sync_store.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/deck_repository.dart';
import 'data/repositories/entry_repository.dart';
import 'data/repositories/language_pack_repository.dart';
import 'data/repositories/pack_merge_repository.dart';
import 'data/repositories/pack_transfer_repository.dart';
import 'data/repositories/sync_engine.dart';
import 'data/repositories/sync_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/file_picker_file_service.dart';
import 'data/services/file_service.dart';
import 'data/services/remote_sync_api.dart';

/// The app's external dependencies. `main.dart` passes the real ones;
/// integration tests pass in-memory and fake ones.
final class AppDependencies {
  const AppDependencies({
    required this.database,
    required this.authService,
    required this.syncApi,
    this.fileService = const FilePickerFileService(),
  });

  final AppDatabase database;
  final AuthService authService;
  final RemoteSyncApi syncApi;
  final FileService fileService;
}

/// The app with its repositories provided to the widget tree.
class AppScope extends StatelessWidget {
  const AppScope({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    final database = dependencies.database;
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        ChangeNotifierProvider(
          create: (_) => AuthRepository(dependencies.authService),
        ),
        Provider<LanguagePackRepository>(
          create: (_) => LocalLanguagePackRepository(database),
        ),
        Provider<EntryRepository>(
          create: (_) => LocalEntryRepository(database),
        ),
        Provider<DeckRepository>(create: (_) => LocalDeckRepository(database)),
        Provider<PackMergeRepository>(
          create: (_) => LocalPackMergeRepository(database),
        ),
        Provider<PackTransferRepository>(
          create: (_) => LocalPackTransferRepository(database),
        ),
        Provider<FileService>.value(value: dependencies.fileService),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) {
            final store = LocalSyncStore(database);
            return SyncRepository(
              engine: SyncEngine(api: dependencies.syncApi, store: store),
              store: store,
              auth: context.read<AuthRepository>(),
              database: database,
            );
          },
        ),
      ],
      child: const LangToolApp(),
    );
  }
}
