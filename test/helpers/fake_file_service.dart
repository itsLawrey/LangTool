import 'dart:typed_data';

import 'package:langtool/data/services/file_service.dart';

/// [FileService] without dialogs: [pickFile] returns [nextPick], and
/// [saveFile] records the file in [saved] unless [cancelSave] is set.
class FakeFileService implements FileService {
  /// Returned by the next [pickFile]; `null` acts as a cancelled dialog.
  PickedFile? nextPick;

  /// Makes [saveFile] act as a cancelled dialog.
  bool cancelSave = false;

  /// Files saved so far, in order.
  final saved = <({String name, Uint8List bytes})>[];

  var pickCount = 0;

  @override
  Future<PickedFile?> pickFile() async {
    pickCount++;
    return nextPick;
  }

  @override
  Future<bool> saveFile({
    required String suggestedName,
    required Uint8List bytes,
  }) async {
    if (cancelSave) return false;
    saved.add((name: suggestedName, bytes: bytes));
    return true;
  }
}
