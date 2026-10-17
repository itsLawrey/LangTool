import 'package:flutter/foundation.dart';

import '../../../../data/repositories/pack_transfer_repository.dart';
import '../../../../domain/models/language_pack.dart';
import '../../../../domain/transfer/pack_file_pack.dart';
import '../../../../utils/result.dart';

/// The packs of a picked pack file, of which the user chooses the ones to
/// import. All are selected at first.
class ImportViewModel extends ChangeNotifier {
  ImportViewModel({
    required PackTransferRepository transferRepository,
    required this.ownerId,
    required Uint8List bytes,
  }) : _transfer = transferRepository {
    switch (_transfer.decode(bytes)) {
      case Ok(:final value):
        _packs = value;
        _selected = {for (var i = 0; i < value.length; i++) i};
      case Err(:final error):
        _error = error;
    }
  }

  final PackTransferRepository _transfer;
  final String ownerId;

  List<PackFilePack> _packs = const [];
  Set<int> _selected = {};
  Exception? _error;
  bool _importing = false;
  bool _disposed = false;

  /// Why the file cannot be imported, if it cannot.
  Exception? get error => _error;

  /// The packs in the file, in file order.
  List<PackFilePack> get packs => _packs;

  /// Indexes into [packs] of the packs to import.
  Set<int> get selected => Set.unmodifiable(_selected);

  bool get importing => _importing;
  bool get canImport => _selected.isNotEmpty && !_importing;

  /// The selected packs, in file order.
  List<PackFilePack> get selectedPacks => [
    for (var i = 0; i < _packs.length; i++)
      if (_selected.contains(i)) _packs[i],
  ];

  void toggle(int index) {
    if (!_selected.remove(index)) _selected.add(index);
    notifyListeners();
  }

  /// Saves the selected packs as new packs of [ownerId].
  Future<Result<List<LanguagePack>>> import() async {
    _importing = true;
    notifyListeners();
    final result = await _transfer.import(selectedPacks, ownerId: ownerId);
    _importing = false;
    if (!_disposed) notifyListeners();
    return result;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
