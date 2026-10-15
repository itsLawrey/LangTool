/// Build-time configuration, passed with `--dart-define-from-file`
/// (see `env/dev.example.json`).
final class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
  });

  factory AppConfig.fromEnvironment() {
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (url.isEmpty || key.isEmpty) {
      throw StateError(
        'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are not set. '
        'Run with --dart-define-from-file=env/dev.json.',
      );
    }
    return const AppConfig(supabaseUrl: url, supabasePublishableKey: key);
  }

  final String supabaseUrl;
  final String supabasePublishableKey;
}
