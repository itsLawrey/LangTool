import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:langtool/data/services/loopback_oauth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  /// Simulates the browser being sent to [redirect] with [params], after the
  /// sign-in page "opens". Returns the browser's response.
  Future<String> Function(Uri redirect) browserReturns(
    Map<String, String> params, {
    required Completer<http.Response> response,
  }) => (redirect) async {
    final target = redirect.replace(queryParameters: params);
    // Not awaited: the server answers only after the call returns.
    unawaited(http.get(target).then(response.complete));
    return '';
  };

  test(
    'returns the code from the redirect and confirms in the browser',
    () async {
      final response = Completer<http.Response>();
      Uri? opened;

      final code = await receiveOAuthRedirect(
        port: 0,
        open: (redirect) async {
          opened = redirect;
          await browserReturns({'code': 'abc123'}, response: response)(
            redirect,
          );
        },
      );

      expect(code, 'abc123');
      expect(opened!.host, '127.0.0.1');
      expect(opened!.path, '/auth-callback');
      expect((await response.future).body, contains('Signed in'));
    },
  );

  test('reports the provider error', () async {
    final response = Completer<http.Response>();

    await expectLater(
      receiveOAuthRedirect(
        port: 0,
        open: browserReturns({
          'error': 'access_denied',
          'error_description': 'User denied access',
        }, response: response),
      ),
      throwsA(
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          'User denied access',
        ),
      ),
    );
    expect((await response.future).body, contains('Sign-in failed'));
  });

  test('ignores unrelated requests such as the favicon', () async {
    final response = Completer<http.Response>();

    final code = await receiveOAuthRedirect(
      port: 0,
      open: (redirect) async {
        unawaited(
          http
              .get(redirect.replace(path: '/favicon.ico'))
              .catchError((_) => http.Response('', 500)),
        );
        await browserReturns({'code': 'xyz'}, response: response)(redirect);
      },
    );

    expect(code, 'xyz');
  });

  test('times out if the browser never comes back', () async {
    await expectLater(
      receiveOAuthRedirect(
        port: 0,
        timeout: const Duration(milliseconds: 50),
        open: (_) async {},
      ),
      throwsA(
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Sign-in timed out.',
        ),
      ),
    );
  });

  test('fails cleanly if opening the browser fails', () async {
    await expectLater(
      receiveOAuthRedirect(
        port: 0,
        open: (_) async =>
            throw const AuthException('Could not open the browser.'),
      ),
      throwsA(isA<AuthException>()),
    );
  });
}
