import 'dart:io';

/// Adds `.`[extension] to the saved [file]'s name if the user removed it in
/// the save dialog, so the open dialog, which filters by extension, finds
/// it. Keeps the name if a file with the extension already exists.
Future<void> ensureFileExtension(Uri file, String extension) async {
  final path = file.toFilePath();
  if (path.toLowerCase().endsWith('.$extension')) return;
  final target = File('$path.$extension');
  if (await target.exists()) return;
  await File(path).rename(target.path);
}
