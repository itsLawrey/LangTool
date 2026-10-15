import 'package:flutter/foundation.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../utils/result.dart';
import '../../../core/error_message.dart';

enum LoginMode { signIn, signUp }

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthRepository authRepository})
    : _auth = authRepository;

  final AuthRepository _auth;

  LoginMode _mode = LoginMode.signIn;
  bool _busy = false;
  String? _error;
  String? _info;

  LoginMode get mode => _mode;
  bool get busy => _busy;
  String? get error => _error;

  /// A non-error notice, e.g. that a confirmation email was sent.
  String? get info => _info;
  bool get supportsGoogleSignIn => _auth.supportsGoogleSignIn;

  void toggleMode() {
    _mode = _mode == LoginMode.signIn ? LoginMode.signUp : LoginMode.signIn;
    _error = null;
    _info = null;
    notifyListeners();
  }

  Future<void> signInWithGoogle() => _run(_auth.signInWithGoogle);

  Future<void> submitEmail(String email, String password) => _run(() async {
    if (_mode == LoginMode.signIn) {
      return _auth.signInWithPassword(email, password);
    }
    final result = await _auth.signUp(email, password);
    if (result case Ok(value: true)) {
      _info = 'Check your email to confirm the account, then sign in.';
      _mode = LoginMode.signIn;
    }
    return result;
  });

  Future<void> _run(Future<Result<Object?>> Function() action) async {
    _busy = true;
    _error = null;
    _info = null;
    notifyListeners();

    final result = await action();
    if (result case Err(:final error)) _error = errorMessage(error);
    _busy = false;
    notifyListeners();
  }
}
