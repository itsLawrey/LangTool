import 'dart:async';

import 'package:langtool/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [AuthService] controlled by the test: sign-ins succeed as [userId]
/// unless [failure] is set.
class FakeAuthService implements AuthService {
  FakeAuthService({this.userId = 'user-1'});

  final String userId;
  final _states = StreamController<AuthState>.broadcast();

  /// Thrown by every sign-in/sign-up/sign-out call when set.
  Exception? failure;

  /// Whether [signUp] reports that email confirmation is required.
  bool requireEmailConfirmation = false;

  @override
  bool supportsGoogleSignIn = true;

  /// Method calls received, e.g. `signInWithPassword(a@b.c)`.
  final calls = <String>[];

  @override
  User? currentUser;

  @override
  Stream<AuthState> get authStateChanges => _states.stream;

  /// Signs in as [id] (default [userId]) with optional user [metadata].
  void emitSignedIn({
    String? id,
    Map<String, Object?>? metadata,
    String? email,
  }) {
    currentUser = User(
      id: id ?? userId,
      appMetadata: const {},
      userMetadata: metadata ?? const {'full_name': 'Test User'},
      aud: 'authenticated',
      email: email,
      createdAt: '2026-10-15T12:00:00Z',
      updatedAt: '2026-10-15T13:00:00Z',
    );
    _states.add(
      AuthState(
        AuthChangeEvent.signedIn,
        Session(accessToken: 'token', tokenType: 'bearer', user: currentUser!),
      ),
    );
  }

  void emitSignedOut() {
    currentUser = null;
    _states.add(const AuthState(AuthChangeEvent.signedOut, null));
  }

  @override
  Future<void> signInWithGoogle() async {
    calls.add('signInWithGoogle');
    _maybeFail();
    emitSignedIn();
  }

  @override
  Future<void> signInWithPassword(String email, String password) async {
    calls.add('signInWithPassword($email)');
    _maybeFail();
    emitSignedIn(email: email);
  }

  @override
  Future<bool> signUp(String email, String password) async {
    calls.add('signUp($email)');
    _maybeFail();
    if (!requireEmailConfirmation) emitSignedIn(email: email);
    return requireEmailConfirmation;
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    _maybeFail();
    emitSignedOut();
  }

  void _maybeFail() {
    if (failure case final error?) throw error;
  }
}
