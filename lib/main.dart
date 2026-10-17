import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_scope.dart';
import 'config/app_config.dart';
import 'data/local/connection.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/shared_preferences_settings_store.dart';
import 'data/services/supabase_sync_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  await Supabase.initialize(
    url: config.supabaseUrl,
    publishableKey: config.supabasePublishableKey,
  );
  final client = Supabase.instance.client;
  final settingsStore = await SharedPreferencesSettingsStore.create(
    allowList: SettingsRepository.keys,
  );

  runApp(
    AppScope(
      dependencies: AppDependencies(
        database: openAppDatabase(),
        authService: AuthService(client.auth),
        syncApi: SupabaseSyncApi(client),
        settingsStore: settingsStore,
      ),
    ),
  );
}
