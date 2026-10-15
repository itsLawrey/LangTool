import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/data/repositories/auth_repository.dart';
import 'package:langtool/ui/features/auth/view_models/login_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/fake_auth_service.dart';

void main() {
  late FakeAuthService service;
  late AuthRepository auth;
  late LoginViewModel viewModel;

  setUp(() {
    service = FakeAuthService();
    auth = AuthRepository(service);
    viewModel = LoginViewModel(authRepository: auth);
  });

  tearDown(() {
    viewModel.dispose();
    auth.dispose();
  });

  test('signs in with email and password', () async {
    final busyStates = <bool>[];
    viewModel.addListener(() => busyStates.add(viewModel.busy));

    await viewModel.submitEmail(' a@b.c ', 'secret1');
    await pumpEventQueue();

    expect(service.calls, ['signInWithPassword(a@b.c)']);
    expect(auth.isSignedIn, isTrue);
    expect(viewModel.error, isNull);
    expect(busyStates, [true, false]);
  });

  test('shows the server message when sign-in fails', () async {
    service.failure = const AuthException('Invalid login credentials');

    await viewModel.submitEmail('a@b.c', 'wrong12');

    expect(viewModel.error, 'Invalid login credentials');
    expect(viewModel.busy, isFalse);
    expect(auth.isSignedIn, isFalse);
  });

  test('sign-up that needs confirmation asks to check email', () async {
    service.requireEmailConfirmation = true;
    viewModel.toggleMode();
    expect(viewModel.mode, LoginMode.signUp);

    await viewModel.submitEmail('a@b.c', 'secret1');

    expect(service.calls, ['signUp(a@b.c)']);
    expect(viewModel.info, contains('Check your email'));
    expect(viewModel.mode, LoginMode.signIn);
    expect(auth.isSignedIn, isFalse);
  });

  test('sign-up without confirmation signs straight in', () async {
    viewModel.toggleMode();

    await viewModel.submitEmail('a@b.c', 'secret1');
    await pumpEventQueue();

    expect(viewModel.info, isNull);
    expect(auth.isSignedIn, isTrue);
  });

  test('switching mode clears messages', () async {
    service.failure = const AuthException('Invalid login credentials');
    await viewModel.submitEmail('a@b.c', 'wrong12');

    viewModel.toggleMode();

    expect(viewModel.error, isNull);
    expect(viewModel.info, isNull);
  });

  test('signs in with Google when supported', () async {
    expect(viewModel.supportsGoogleSignIn, isTrue);

    await viewModel.signInWithGoogle();
    await pumpEventQueue();

    expect(service.calls, ['signInWithGoogle']);
    expect(auth.isSignedIn, isTrue);
  });

  test('reports Google sign-in errors', () async {
    service.failure = const AuthException('Sign-in timed out.');

    await viewModel.signInWithGoogle();

    expect(viewModel.error, 'Sign-in timed out.');
  });

  test('hides Google sign-in where unsupported', () {
    service.supportsGoogleSignIn = false;

    expect(viewModel.supportsGoogleSignIn, isFalse);
  });
}
