import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/language_pack_repository.dart';
import '../../../../data/repositories/pack_merge_repository.dart';
import '../../../../domain/models/language_pack.dart';
import '../../../../utils/result.dart';
import '../../../core/merge_labels.dart';

/// Whether merging keeps or deletes the merged packs.
enum MergeMode { keep, delete }

/// The user's packs, of which they choose the ones to merge into a new pack,
/// with a live preview of the result.
class MergeViewModel extends ChangeNotifier {
  MergeViewModel({
    required LanguagePackRepository packRepository,
    required PackMergeRepository mergeRepository,
    required this.ownerId,
  }) : _merges = mergeRepository {
    _packsSubscription = packRepository.watchPacks(ownerId).listen((packs) {
      _items = packs;
      final before = _selected.length;
      _selected.retainAll({for (final pack in packs) pack.id});
      _loading = false;
      if (_selected.length != before) _watchPreview();
      notifyListeners();
    });
  }

  final PackMergeRepository _merges;
  final String ownerId;
  late final StreamSubscription<List<LanguagePack>> _packsSubscription;
  StreamSubscription<MergePreview>? _previewSubscription;

  List<LanguagePack> _items = const [];
  final _selected = <String>{};
  MergePreview? _preview;
  String _name = '';
  MergeMode _mode = MergeMode.keep;
  bool _loading = true;
  bool _merging = false;
  bool _disposed = false;

  List<LanguagePack> get packs => _items;
  bool get loading => _loading;
  Set<String> get selected => Set.unmodifiable(_selected);
  String get name => _name;
  MergeMode get mode => _mode;
  bool get merging => _merging;

  /// The result of merging the selected packs, once two or more are
  /// selected.
  MergePreview? get preview => _selected.length < 2 ? null : _preview;

  /// The selected packs, in list order.
  List<LanguagePack> get selectedPacks => [
    for (final pack in _items)
      if (_selected.contains(pack.id)) pack,
  ];

  /// The language of the selected packs, if any are selected: only packs of
  /// the same language can be merged.
  String? get language => selectedPacks.firstOrNull?.languageCode;

  bool canSelect(LanguagePack pack) =>
      !_merging && (language == null || pack.languageCode == language);

  bool get canMerge =>
      _selected.length >= 2 && _name.trim().isNotEmpty && !_merging;

  void toggle(String packId) {
    if (!_selected.remove(packId)) _selected.add(packId);
    _watchPreview();
    notifyListeners();
  }

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setMode(MergeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  /// Merges the selected packs, in list order, into a new pack named
  /// [name].
  Future<Result<LanguagePack>> merge() async {
    final packs = selectedPacks;
    _merging = true;
    notifyListeners();
    final result = await _merges.merge(
      packIds: [for (final pack in packs) pack.id],
      name: _name,
      deleteOriginals: _mode == MergeMode.delete,
      describeClash: (clash) => clashNote(packs.first.languageCode, clash),
    );
    _merging = false;
    if (!_disposed) notifyListeners();
    return result;
  }

  void _watchPreview() {
    _previewSubscription?.cancel();
    _preview = null;
    _previewSubscription = _merges
        .watchPreview([for (final pack in selectedPacks) pack.id])
        .listen((preview) {
          _preview = preview;
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _disposed = true;
    _packsSubscription.cancel();
    _previewSubscription?.cancel();
    super.dispose();
  }
}
