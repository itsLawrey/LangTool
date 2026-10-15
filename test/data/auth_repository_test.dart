import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/data/repositories/auth_repository.dart';
import 'package:langtool/utils/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/fake_auth_service.dart';

void main() {
  late FakeAuthService service;
  late AuthRepository auth;

  setUp(() {
    service = FakeAuthService();
    auth = AuthRepository(service);
  });

  tearDown(() => auth.dispose());

  group('profile', () {
    test('uses the full name from the provider', () async {
      service.emitSignedIn(metadata: {'full_name': 'Lorand Dallos'});
      await pumpEventQueue();

      final profile = auth.profile!;
      expect(profile.id, 'user-1');
      expect(profile.displayName, 'Lorand Dallos');
      expect(profile.createdAt, DateTime.utc(2026, 10, 15, 12));
      expect(profile.updatedAt, DateTime.utc(2026, 10, 15, 13));
    });

    test('falls back to the name, then the email', () async {
      service.emitSignedIn(metadata: {'name': 'Lawrey'});
      await pumpEventQueue();
      expect(auth.profile!.displayName, 'Lawrey');

      service.emitSignedIn(metadata: {}, email: 'admin123@example.com');
      await pumpEventQueue();
      expect(auth.profile!.displayName, 'admin123');
    });

    test('is restored for a user already signed in at startup', () {
      service.emitSignedIn();
      final restored = AuthRepository(service);
      addTearDown(restored.dispose);

      expect(restored.isSignedIn, isTrue);
      expect(restored.profile!.id, 'user-1');
    });
  });

  test('notifies listeners on sign-in and sign-out only', () async {
    var notifications = 0;
    auth.addListener(() => notifications++);

    service.emitSignedIn();
    await pumpEventQueue();
    service.emitSignedIn(); // Same user, e.g. a token refresh.
    await pumpEventQueue();
    expect(notifications, 1);
    expect(auth.isSignedIn, isTrue);

    service.emitSignedOut();
    await pumpEventQueue();
    expect(notifications, 2);
    expect(auth.profile, isNull);
  });

  test('returns failures as results instead of throwing', () async {
    service.failure = const AuthException('Email not confirmed');
    expect(
      await auth.signInWithPassword('a@b.c', 'secret1'),
      isA<Err<void>>().having(
        (e) => (e.error as AuthException).message,
        'message',
        'Email not confirmed',
      ),
    );

    service.failure = Exception('offline');
    expect(await auth.signOut(), isA<Err<void>>());
  });
}
