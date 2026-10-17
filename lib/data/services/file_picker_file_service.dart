import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../domain/transfer/pack_file_format.dart';
import 'file_service.dart';
import 'saved_file_stub.dart' if (dart.library.io) 'saved_file_io.dart';

/// [FileService] using the `file_picker` plugin.
class FilePickerFileService implements FileService {
  const FilePickerFileService();

  /// Android and iOS have no MIME type for the pack file extension, so they
  /// cannot filter by it; the content is validated on import anyway.
  static bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows);

  @override
  Future<PickedFile?> pickFile() async {
    final file = await FilePicker.pickFile(
      type: _isMobile ? FileType.any : FileType.custom,
      allowedExtensions: _isMobile ? null : const [packFileExtension],
    );
    if (file == null) return null;
    return PickedFile(name: file.name, bytes: await file.readAsBytes());
  }

  /// The plugin writes [bytes] itself on every platform.
  @override
  Future<bool> saveFile({
    required String suggestedName,
    required Uint8List bytes,
  }) async {
    final uri = await FilePicker.saveFile(
      fileName: suggestedName,
      bytes: bytes,
    );
    // A browser download reports no location.
    if (kIsWeb) return true;
    if (uri == null) return false;
    if (_isDesktop && uri.scheme == 'file') {
      await ensureFileExtension(uri, packFileExtension);
    }
    return true;
  }
}
