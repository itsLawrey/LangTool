import 'dart:typed_data';

/// A file the user picked to open.
final class PickedFile {
  const PickedFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

/// The platform's open and save file dialogs.
abstract interface class FileService {
  /// Lets the user pick a pack file. Returns `null` if they cancel.
  Future<PickedFile?> pickFile();

  /// Lets the user save [bytes], proposing [suggestedName]. On the web the
  /// file is downloaded. Returns `false` if the user cancels.
  Future<bool> saveFile({
    required String suggestedName,
    required Uint8List bytes,
  });
}
