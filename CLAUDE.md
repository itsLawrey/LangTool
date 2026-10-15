# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

LangTool: a Flutter app with a Supabase backend for building vocabulary dictionaries. A signed-in user owns language packs, and a pack contains searchable entries. The cloud only backs up and syncs the user's data across devices. German is the only language for now, but the data model must allow other languages with different grammar to be added later.

Development proceeds in stages defined by the user. Implement only the current stage's spec. Don't add features, UI copy or flavour text that wasn't specified.

## Commands

```sh
flutter pub get
flutter analyze
flutter test                          # all tests
flutter test test/widget_test.dart    # single file
flutter test --name "<test name>"     # single test by name
dart format .
dart run build_runner build --delete-conflicting-outputs   # regenerate *.freezed.dart / *.g.dart
```

Generated files are committed. Re-run build_runner after changing any `@freezed` class.

## Architecture

Layered per Flutter's official architecture guide. No UI layer yet (`lib/main.dart` is still the template).

- `lib/domain/models/`: immutable `freezed` models: `Profile` → `LanguagePack` → `Entry`. They're storage-agnostic, with JSON only (snake_case keys via `build.yaml`, matching Postgres columns). Every synced record has a client-generated UUID `id`, UTC `createdAt`/`updatedAt` and a nullable `deletedAt` (soft delete, so deletions sync). Packs and entries carry `ownerId`.
- `lib/domain/languages/`: language-specific grammar. An `Entry` stores a `term` (headword) plus a free-form `forms` map. A `LanguageSchema` (e.g. `german.dart`) declares, per `WordType`, which form keys exist, whether they're required and their allowed values, and validates entries against that. Adding a language means adding a schema and registering it in `language_registry.dart`, with no model changes. Bump the schema `version` when its fields change; entries record the version they were written against in `schemaVersion`.
- `lib/domain/search/`: pure Dart search logic with no DB.
  - `text_normalizer.dart` defines two keys:
    - `duplicateKey`: case and whitespace folded, umlauts kept, so "schon" ≠ "schön";
    - `normalizeForSearch`: also folds German and Hungarian diacritics.
  - `fuzzy.dart`: edit distance (optimal string alignment) with a length-scaled typo tolerance.
  - `entry_ranker.dart`: classifies matches (exact > prefix > contains > fuzzy, term before translation) and orders results.
  - `similar_entries.dart`: the "did you mean an existing entry?" check before adding.
- No UI strings (e.g. field labels) belong in the domain layer.
- `lib/data/local/`: Drift (SQLite) database.
  - `entries` rows carry derived columns written by `mappers.dart`: `search_term`, `search_translations` (newline-joined) and `duplicate_key`.
  - A partial unique index on `(pack_id, word_type, duplicate_key) WHERE deleted_at IS NULL` enforces the no-duplicates rule at the DB level.
  - Dates are stored as ISO-8601 text (`build.yaml`).
  - Schema changes need a `schemaVersion` bump plus a migration in `AppDatabase.migration`.
- `lib/data/repositories/`: an abstract interface plus a `Local…` Drift implementation per aggregate.
  - Writes return `Result<T>` (`lib/utils/result.dart`: `Ok`/`Err`) carrying the exceptions in `lib/domain/exceptions.dart`.
  - `EntryRepository.add`/`update` validate against the pack's `LanguageSchema`, then the duplicate rule.
  - `search` runs a SQL `LIKE` on the normalized columns for direct matches. Only if there are none, it scores a lightweight `(id, keys)` projection in Dart for fuzzy matches.
  - Deletes are soft. Deleting a pack soft-deletes its entries.
  - Clock and id generator are injectable (`lib/utils/clock.dart`; ids are UUID v7).
- Tests use an in-memory DB: `AppDatabase(NativeDatabase.memory())`.
- Web: SQLite runs from `web/sqlite3.wasm` + `web/drift_worker.js`, taken from the drift GitHub release matching `pubspec.lock`'s drift version (currently `drift-2.35.2`). Replace both whenever drift is upgraded: `gh release download drift-<version> -R simolus3/drift -p drift_worker.js -p sqlite3.wasm -D web --clobber`. For the fastest browser storage (OPFS), serve with `Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp`. In dev: `flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp`. Without them it falls back to slower storage. Production hosting must serve `.wasm` as `application/wasm`.

## Supabase

- Project: `langtool`, ref `gdduanyobtuqplhknxss`, region `eu-west-1`.
- The Supabase MCP server (`.mcp.json`) has access to the whole organization. Only operate on `langtool`.
- Never commit keys. Local config goes in `env/*.json` (gitignored), passed with `--dart-define-from-file`.

## Hot reload

After editing `.dart` files under `lib/` (not comment-only changes), discover the running app with the Dart MCP `dtd` tool. Then call `hot_reload` for UI or simple method changes, or `hot_restart` for changes to `main()`, `initState`, or global/static state. Skip this for files outside `lib/`.
