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
  final code = await receiveOAuthRedirect(
    open: (redirect) async {
      final response = await auth.getOAuthSignInUrl(
        provider: provider,
        redirectTo: redirect.toString(),
      );
      final launched = await launchUrl(
        Uri.parse(response.url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) throw const AuthException('Could not open the browser.');
    },
  );
  await auth.exchangeCodeForSession(code);
}

/// Starts a local server, calls [open] with its redirect URL, and returns the
/// `code` parameter of the first request to it. Throws an [AuthException] if
/// the provider reports an error or nothing arrives within [timeout].
Future<String> receiveOAuthRedirect({
  required Future<void> Function(Uri redirect) open,
  int port = loopbackOAuthPort,
  Duration timeout = const Duration(minutes: 5),
}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  try {
    await open(Uri.parse('http://127.0.0.1:${server.port}$_callbackPath'));

    final request = await server
        .firstWhere((r) => r.uri.path == _callbackPath)
        .timeout(timeout);
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
    return code;
  } on TimeoutException {
    throw const AuthException('Sign-in timed out.');
  } finally {
    await server.close(force: true);
  }
}
