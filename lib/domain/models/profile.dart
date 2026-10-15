import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// The user who owns all language packs and entries.
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    /// The Supabase Auth user id. Stable across devices and sign-in providers.
    required String id,
    required String displayName,

    /// UTC.
    required DateTime createdAt,

    /// UTC.
    required DateTime updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, Object?> json) =>
      _$ProfileFromJson(json);
}
