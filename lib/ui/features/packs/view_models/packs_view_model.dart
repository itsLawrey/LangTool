import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/language_pack_repository.dart';
import '../../../../domain/models/language_pack.dart';
import '../../../../utils/result.dart';

class PacksViewModel extends ChangeNotifier {
  PacksViewModel({
    required LanguagePackRepository packRepository,
    required this.ownerId,
  }) : _packs = packRepository {
    _subscription = _packs.watchPacks(ownerId).listen((packs) {
      _items = packs;
      _loading = false;
      notifyListeners();
    });
  }

  final LanguagePackRepository _packs;
  final String ownerId;
  late final StreamSubscription<List<LanguagePack>> _subscription;

  List<LanguagePack> _items = const [];
  bool _loading = true;

  List<LanguagePack> get packs => _items;
  bool get loading => _loading;

  /// German is the only supported language for now.
  Future<Result<LanguagePack>> create(String name) =>
      _packs.create(ownerId: ownerId, name: name, languageCode: 'de');

  Future<Result<LanguagePack>> rename(LanguagePack pack, String name) =>
      _packs.rename(pack.id, name);

  Future<Result<void>> delete(LanguagePack pack) => _packs.delete(pack.id);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
