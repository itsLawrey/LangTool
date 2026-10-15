import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'data/local/app_database.dart';
import 'data/local/connection.dart';
import 'data/local/sync_store.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/entry_repository.dart';
import 'data/repositories/language_pack_repository.dart';
import 'data/repositories/sync_engine.dart';
import 'data/repositories/sync_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/supabase_sync_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  await Supabase.initialize(
    url: config.supabaseUrl,
    publishableKey: config.supabasePublishableKey,
  );
  final database = openAppDatabase();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        ChangeNotifierProvider(
          create: (_) =>
              AuthRepository(AuthService(Supabase.instance.client.auth)),
        ),
        Provider<LanguagePackRepository>(
          create: (_) => LocalLanguagePackRepository(database),
        ),
        Provider<EntryRepository>(
          create: (_) => LocalEntryRepository(database),
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) {
            final store = LocalSyncStore(database);
            return SyncRepository(
              engine: SyncEngine(
                api: SupabaseSyncApi(Supabase.instance.client),
                store: store,
              ),
              store: store,
              auth: context.read<AuthRepository>(),
              database: database,
            );
          },
        ),
      ],
      child: const LangToolApp(),
    ),
  );
}
