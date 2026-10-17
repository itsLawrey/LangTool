import 'dart:typed_data';

import 'package:langtool/data/services/file_service.dart';

/// [FileService] without dialogs: [pickFile] returns [nextPick], and
/// [saveFile] records the file in [saved] unless [cancelSave] is set.
class FakeFileService implements FileService {
  /// Returned by the next [pickFile]; `null` acts as a cancelled dialog.
  PickedFile? nextPick;

  /// Thrown by [pickFile] when set.
  Exception? pickFailure;

  /// Makes [saveFile] act as a cancelled dialog.
  bool cancelSave = false;

  /// Thrown by [saveFile] when set.
  Exception? saveFailure;

  /// Files saved so far, in order.
  final saved = <({String name, Uint8List bytes})>[];

  var pickCount = 0;

  @override
  Future<PickedFile?> pickFile() async {
    pickCount++;
    if (pickFailure case final error?) throw error;
    return nextPick;
  }

  @override
  Future<bool> saveFile({
    required String suggestedName,
    required Uint8List bytes,
  }) async {
    if (saveFailure case final error?) throw error;
    if (cancelSave) return false;
    saved.add((name: suggestedName, bytes: bytes));
    return true;
  }
}
