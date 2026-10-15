import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_scope.dart';
import 'config/app_config.dart';
import 'data/local/connection.dart';
import 'data/services/auth_service.dart';
import 'data/services/supabase_sync_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  await Supabase.initialize(
    url: config.supabaseUrl,
    publishableKey: config.supabasePublishableKey,
  );
  final client = Supabase.instance.client;

  runApp(
    AppScope(
      dependencies: AppDependencies(
        database: openAppDatabase(),
        authService: AuthService(client.auth),
        syncApi: SupabaseSyncApi(client),
      ),
    ),
  );
}
