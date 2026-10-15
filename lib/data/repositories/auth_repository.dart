import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/profile.dart';
import '../../utils/result.dart';
import '../services/auth_service.dart';

/// The signed-in [Profile], derived from the Supabase Auth user. Notifies
/// listeners when the user signs in or out.
class AuthRepository extends ChangeNotifier {
  AuthRepository(this._service) {
    _profile = _toProfile(_service.currentUser);
    _subscription = _service.authStateChanges.listen((state) {
      final profile = _toProfile(state.session?.user);
      if (profile != _profile) {
        _profile = profile;
        notifyListeners();
      }
    });
  }

  final AuthService _service;
  late final StreamSubscription<AuthState> _subscription;
  Profile? _profile;

  Profile? get profile => _profile;
  bool get isSignedIn => _profile != null;
  bool get supportsGoogleSignIn => _service.supportsGoogleSignIn;

  Future<Result<void>> signInWithGoogle() => _guard(_service.signInWithGoogle);

  Future<Result<void>> signInWithPassword(String email, String password) =>
      _guard(() => _service.signInWithPassword(email.trim(), password));

  /// On success, the value tells whether email confirmation is required.
  Future<Result<bool>> signUp(String email, String password) =>
      _guard(() => _service.signUp(email.trim(), password));

  Future<Result<void>> signOut() => _guard(_service.signOut);

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.ok(await action());
    } on AuthException catch (e) {
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

Profile? _toProfile(User? user) {
  if (user == null) return null;
  final metadata = user.userMetadata ?? const {};
  final name = metadata['full_name'] ?? metadata['name'];
  final createdAt = DateTime.parse(user.createdAt).toUtc();
  return Profile(
    id: user.id,
    displayName: name is String && name.isNotEmpty
        ? name
        : (user.email ?? '').split('@').first,
    createdAt: createdAt,
    updatedAt: switch (user.updatedAt) {
      final updated? => DateTime.parse(updated).toUtc(),
      null => createdAt,
    },
  );
}
