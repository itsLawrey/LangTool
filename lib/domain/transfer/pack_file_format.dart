/// Pack files: one or more language packs with their entries and decks, as
/// gzip-compressed UTF-8 JSON. See `pack_file_json.dart` for the layout.
library;

/// File name extension of pack files, without the dot.
const packFileExtension = 'langtool';

/// The `format` value identifying a pack file.
const packFileFormatId = 'langtool-packs';

/// The layout `version` this app writes. Files with a higher version are
/// rejected; files with a lower one are upgraded by [packFileMigrations].
///
/// Whenever the layout changes, bump this and add the step from the previous
/// version to [packFileMigrations]. Never change an existing step.
const packFileVersion = 1;

/// Upper limit of a pack file's decompressed size, guarding against files
/// that expand without limit.
const maxPackFileBytes = 20 * 1024 * 1024;

/// Upgrades the JSON of a pack file from one layout version to the next.
typedef PackFileMigration = Map<String, Object?> Function(
  Map<String, Object?> json,
);

/// `packFileMigrations[n]` upgrades a version `n` file to version `n + 1`.
const Map<int, PackFileMigration> packFileMigrations = {};
