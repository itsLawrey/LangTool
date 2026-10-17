import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/language_pack_repository.dart';
import '../../../../data/repositories/pack_transfer_repository.dart';
import '../../../../data/services/file_service.dart';
import '../../../../domain/models/language_pack.dart';
import '../../../../domain/transfer/pack_file_format.dart';
import '../../../../utils/result.dart';

/// The user's packs, of which they choose the ones to export to a pack
/// file. None are selected at first.
class ExportViewModel extends ChangeNotifier {
  ExportViewModel({
    required LanguagePackRepository packRepository,
    required PackTransferRepository transferRepository,
    required FileService fileService,
    required this.ownerId,
    this._clock = DateTime.now,
  }) : _transfer = transferRepository,
       _files = fileService {
    _subscription = packRepository.watchPacks(ownerId).listen((packs) {
      _items = packs;
      _selected.retainAll({for (final pack in packs) pack.id});
      _loading = false;
      notifyListeners();
    });
  }

  final PackTransferRepository _transfer;
  final FileService _files;
  final DateTime Function() _clock;
  final String ownerId;
  late final StreamSubscription<List<LanguagePack>> _subscription;

  List<LanguagePack> _items = const [];
  final _selected = <String>{};
  bool _loading = true;
  bool _exporting = false;
  bool _disposed = false;

  List<LanguagePack> get packs => _items;
  bool get loading => _loading;

  /// Ids of the packs to export.
  Set<String> get selected => Set.unmodifiable(_selected);

  bool get allSelected =>
      _items.isNotEmpty && _selected.length == _items.length;

  bool get exporting => _exporting;
  bool get canExport => _selected.isNotEmpty && !_exporting;

  void toggle(String packId) {
    if (!_selected.remove(packId)) _selected.add(packId);
    notifyListeners();
  }

  /// Selects every pack, or clears the selection if all are selected.
  void toggleAll() {
    if (allSelected) {
      _selected.clear();
    } else {
      _selected.addAll([for (final pack in _items) pack.id]);
    }
    notifyListeners();
  }

  /// Writes the selected packs, in list order, to a pack file and lets the
  /// user save it. The value is `false` if they cancelled.
  Future<Result<bool>> export() async {
    final packs = [
      for (final pack in _items)
        if (_selected.contains(pack.id)) pack,
    ];
    _exporting = true;
    notifyListeners();
    try {
      final bytes = await _transfer.export([for (final p in packs) p.id]);
      final saved = await _files.saveFile(
        suggestedName: suggestedFileName(packs, _clock()),
        bytes: bytes,
      );
      return Result.ok(saved);
    } on Exception catch (e) {
      return Result.error(e);
    } finally {
      _exporting = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }
}

/// The file name proposed when saving [packs]: `<pack name>.langtool` for
/// one pack, `langtool-packs-YYYY-MM-DD.langtool` (local date of [now]) for
/// several.
String suggestedFileName(List<LanguagePack> packs, DateTime now) {
  if (packs.length == 1) {
    final name = packs.single.name
        .replaceAll(RegExp(r'[/\\:*?"<>|\x00-\x1F\x7F]'), '_')
        .trim();
    return '${name.isEmpty ? 'langtool-pack' : name}.$packFileExtension';
  }
  final date = now.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'langtool-packs-${date.year}-${two(date.month)}-${two(date.day)}'
      '.$packFileExtension';
}
