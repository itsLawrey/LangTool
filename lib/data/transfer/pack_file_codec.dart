import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../domain/exceptions.dart';
import '../../domain/languages/language_registry.dart';
import '../../domain/languages/language_schema.dart';
import '../../domain/transfer/pack_bundle.dart';
import '../../domain/transfer/pack_file_format.dart';
import '../../domain/transfer/pack_file_json.dart';
import '../../domain/transfer/pack_file_pack.dart';
import '../../utils/result.dart';

/// The bytes of a pack file holding [bundles]: gzip-compressed UTF-8 JSON
/// as described at [packFileToJson].
Uint8List encodePackFile(
  List<PackBundle> bundles, {
  required DateTime exportedAt,
}) {
  final json = jsonEncode(packFileToJson(bundles, exportedAt: exportedAt));
  return const GZipEncoder().encodeBytes(utf8.encode(json));
}

/// Reads and validates the pack file [bytes] (see [packFileFromJson]).
///
/// Fails with a [PackFileException]: [PackFileProblem.notLangTool] if the
/// bytes are not gzip-compressed JSON of a pack file,
/// [PackFileProblem.tooLarge] if they decompress to more than [maxBytes].
Result<List<PackFilePack>> decodePackFile(
  Uint8List bytes, {
  Map<int, PackFileMigration> migrations = packFileMigrations,
  LanguageSchema? Function(String code) schemaFor = languageSchemaFor,
  int maxBytes = maxPackFileBytes,
}) {
  final output = _CappedOutput(maxBytes);
  try {
    final complete = const GZipDecoder().decodeStream(
      InputMemoryStream(bytes),
      output,
      verify: true,
    );
    if (output.exceeded) return _error(PackFileProblem.tooLarge);
    if (!complete) return _error(PackFileProblem.notLangTool);
  } catch (_) {
    return _error(
      output.exceeded ? PackFileProblem.tooLarge : PackFileProblem.notLangTool,
    );
  }

  final Object? json;
  try {
    json = jsonDecode(utf8.decode(output.getBytes()));
  } on FormatException {
    return _error(PackFileProblem.notLangTool);
  }
  return packFileFromJson(json, migrations: migrations, schemaFor: schemaFor);
}

Result<List<PackFilePack>> _error(PackFileProblem reason) =>
    Result.error(PackFileException(reason));

/// Collects decompressed bytes, failing once more than [maxBytes] are
/// written.
class _CappedOutput extends OutputMemoryStream {
  _CappedOutput(this.maxBytes);

  final int maxBytes;
  var _written = 0;
  var exceeded = false;

  void _count(int bytes) {
    _written += bytes;
    if (_written > maxBytes) {
      exceeded = true;
      throw ArchiveException('Pack file larger than $maxBytes bytes');
    }
  }

  @override
  void writeByte(int value) {
    _count(1);
    super.writeByte(value);
  }

  @override
  void writeBytes(List<int> bytes, {int? length}) {
    _count(length ?? bytes.length);
    super.writeBytes(bytes, length: length);
  }

  @override
  void writeStream(InputStream stream) {
    _count(stream.length);
    super.writeStream(stream);
  }

  @override
  void writeBackReference(int distance, int count) {
    _count(count);
    super.writeBackReference(distance, count);
  }
}
