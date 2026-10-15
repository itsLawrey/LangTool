import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'loopback_oauth_stub.dart' if (dart.library.io) 'loopback_oauth.dart';

/// Thin wrapper around Supabase Auth.
class AuthService {
  AuthService(this._auth);

  final GoTrueClient _auth;

  User? get currentUser => _auth.currentUser;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// Google sign-in is wired up for the web and desktop. Mobile needs
  /// deep-link configuration that is not set up yet.
  bool get supportsGoogleSignIn =>
      kIsWeb ||
      switch (defaultTargetPlatform) {
        TargetPlatform.linux ||
        TargetPlatform.macOS ||
        TargetPlatform.windows => true,
        _ => false,
      };

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Uri.base.origin,
      );
    } else {
      await signInWithOAuthViaLoopback(_auth, OAuthProvider.google);
    }
  }

  Future<void> signInWithPassword(String email, String password) =>
      _auth.signInWithPassword(email: email, password: password);

  /// Returns whether the account still needs email confirmation before it
  /// can sign in.
  Future<bool> signUp(String email, String password) async {
    final response = await _auth.signUp(email: email, password: password);
    return response.session == null;
  }

  Future<void> signOut() => _auth.signOut();
}
