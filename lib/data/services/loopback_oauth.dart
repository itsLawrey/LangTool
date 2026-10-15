import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Port of the local callback server. The redirect URL
/// `http://127.0.0.1:3693/auth-callback` must be allowed in the Supabase
/// project's Auth URL configuration.
const loopbackOAuthPort = 3693;
const _callbackPath = '/auth-callback';

/// OAuth sign-in for desktop platforms, which cannot receive deep links
/// reliably: opens the provider's page in the system browser and receives
/// the redirect on a short-lived local HTTP server, then exchanges the code
/// for a session (PKCE).
Future<void> signInWithOAuthViaLoopback(
  GoTrueClient auth,
  OAuthProvider provider,
) async {
  final server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    loopbackOAuthPort,
  );
  try {
    final redirect = 'http://127.0.0.1:$loopbackOAuthPort$_callbackPath';
    final response = await auth.getOAuthSignInUrl(
      provider: provider,
      redirectTo: redirect,
    );
    final launched = await launchUrl(
      Uri.parse(response.url),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) throw const AuthException('Could not open the browser.');

    final request = await server
        .firstWhere((r) => r.uri.path == _callbackPath)
        .timeout(const Duration(minutes: 5));
    final params = request.uri.queryParameters;
    final code = params['code'];

    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..write(
        code == null
            ? '<p>Sign-in failed. You can close this tab.</p>'
            : '<p>Signed in. You can close this tab.</p>',
      );
    await request.response.close();

    if (code == null) {
      throw AuthException(
        params['error_description'] ?? 'Sign-in was cancelled.',
      );
    }
    await auth.exchangeCodeForSession(code);
  } on TimeoutException {
    throw const AuthException('Sign-in timed out.');
  } finally {
    await server.close(force: true);
  }
}
