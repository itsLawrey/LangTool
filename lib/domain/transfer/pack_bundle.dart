import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/deck.dart';
import '../models/entry.dart';
import '../models/language_pack.dart';

part 'pack_bundle.freezed.dart';

/// A language pack with its entries and decks: one pack to export.
@freezed
abstract class PackBundle with _$PackBundle {
  const factory PackBundle({
    required LanguagePack pack,
    @Default(<Entry>[]) List<Entry> entries,
    @Default(<Deck>[]) List<Deck> decks,
  }) = _PackBundle;
}
