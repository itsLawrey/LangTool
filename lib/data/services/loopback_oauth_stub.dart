import 'package:supabase_flutter/supabase_flutter.dart';

/// Web build stand-in: the loopback flow needs `dart:io` and is never used
/// on the web.
Future<void> signInWithOAuthViaLoopback(
  GoTrueClient auth,
  OAuthProvider provider,
) => throw UnsupportedError('Loopback OAuth is not available on the web.');
