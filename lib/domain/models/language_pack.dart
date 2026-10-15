import 'package:freezed_annotation/freezed_annotation.dart';

part 'language_pack.freezed.dart';
part 'language_pack.g.dart';

/// A user-named collection of entries in one language.
@freezed
abstract class LanguagePack with _$LanguagePack {
  const factory LanguagePack({
    /// Client-generated UUID.
    required String id,

    /// Id of the owning [Profile].
    required String ownerId,
    required String name,

    /// Language code of the pack's entries (e.g. `de`). Selects the
    /// `LanguageSchema` used for its entries.
    required String languageCode,

    /// UTC.
    required DateTime createdAt,

    /// UTC.
    required DateTime updatedAt,

    /// UTC. Set when soft-deleted, so the deletion can be synced.
    DateTime? deletedAt,
  }) = _LanguagePack;

  factory LanguagePack.fromJson(Map<String, Object?> json) =>
      _$LanguagePackFromJson(json);
}
