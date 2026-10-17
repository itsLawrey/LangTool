# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

LangTool: a Flutter app with a Supabase backend for building vocabulary dictionaries. A signed-in user owns language packs, and a pack contains searchable entries. The cloud only backs up and syncs the user's data across devices. German is the only language for now, but the data model must allow other languages with different grammar to be added later.

Development proceeds in stages defined by the user. Implement only the current stage's spec. Don't add features, UI copy or flavour text that wasn't specified.

## Commands

```sh
flutter run -d linux --dart-define-from-file=env/dev.json   # app needs env/dev.json (copy env/dev.example.json)
flutter pub get
flutter analyze
flutter test                          # all tests
flutter test test/widget_test.dart    # single file
flutter test --name "<test name>"     # single test by name
flutter test --coverage               # writes coverage/lcov.info
flutter test integration_test -d linux   # end-to-end flows (opens a window)
dart format .
dart run build_runner build --delete-conflicting-outputs   # regenerate *.freezed.dart / *.g.dart
```

Generated files are committed. Re-run build_runner after changing any `@freezed` class.

## Architecture

Layered per Flutter's official architecture guide (MVVM with `provider` and `go_router`). Development focuses on Linux desktop first, then Android and web.

- `lib/main.dart`: initializes Supabase from `AppConfig` (dart-defines), opens the DB and provides the repositories via `MultiProvider`.
- `lib/routing/router.dart`: redirects to `/login` when signed out. Each `GoRoute` creates its ViewModel in a `ChangeNotifierProvider`, so it's disposed with the route. Screens read it with `context.watch`.
- `lib/ui/features/<feature>/{view_models,views}/`: auth, packs, timeline, entry_detail and entry_form.
  - `ui/core/` holds shared labels, display helpers, dialogs and the theme.
  - Keep files small and split widgets into their own files.
  - UI strings live in the UI layer: `labels.dart` (field and word-type labels, validation messages) and `error_message.dart` (maps repository exceptions).
- Timeline: `TimelineViewModel` watches `EntryRepository.watchTimeline(limit)` and grows `limit` by `pageSize` as `TimelineList` nears the end. `ListView.builder` builds rows lazily, so both DB reads and rendering are paged. A search query switches the source to `search()` hits, still shown day-grouped and newest first. It re-runs on `watchChanges()`.
- Entry form: the view owns the text controllers and builds an `EntryDraft`. Before saving it calls `findSimilar` and shows the confirm/dismiss dialog. A `DuplicateEntryException` result offers to open the existing entry.
- Auth (`data/services/auth_service.dart`, `data/repositories/auth_repository.dart`): Supabase email/password, plus Google.
  - Google on desktop uses a loopback PKCE flow (`loopback_oauth.dart`, port 3693, redirect `http://127.0.0.1:3693/auth-callback` must be allowed in Supabase Auth URL config).
  - Google on the web uses the normal redirect.
  - Mobile Google sign-in isn't wired up yet (needs deep-link setup).
  - `Profile` is derived from the Supabase user, and `profile.id` is the `ownerId`.

- `lib/domain/models/`: immutable `freezed` models: `Profile` → `LanguagePack` → `Entry`, plus `Deck` (per pack). They're storage-agnostic, with JSON only (snake_case keys via `build.yaml`, matching Postgres columns). Every synced record has a client-generated UUID `id`, UTC `createdAt`/`updatedAt` and a nullable `deletedAt` (soft delete, so deletions sync). Packs, entries and decks carry `ownerId`.
- `lib/domain/languages/`: language-specific grammar. An `Entry` stores a `term` (headword) plus a free-form `forms` map. A `LanguageSchema` (e.g. `german.dart`) declares, per `WordType`, which form keys exist, whether they're required and their allowed values, and validates entries against that. Adding a language means adding a schema and registering it in `language_registry.dart`, with no model changes. Bump the schema `version` when its fields change; entries record the version they were written against in `schemaVersion`.
- `lib/domain/search/`: pure Dart search logic with no DB.
  - `text_normalizer.dart` defines two keys:
    - `duplicateKey`: case and whitespace folded, umlauts kept, so "schon" ≠ "schön";
    - `normalizeForSearch`: also folds German and Hungarian diacritics.
  - `fuzzy.dart`: edit distance (optimal string alignment) with a length-scaled typo tolerance.
  - `entry_ranker.dart`: classifies matches (exact > prefix > contains > fuzzy, term before translation) and orders results.
  - `similar_entries.dart`: the "did you mean an existing entry?" check before adding.
- `lib/domain/recap/`: recap decks and sessions.
  - A `Deck` stores only filter rules, never entry ids; its entries are resolved at query time.
  - `deck_filter.dart`: sealed `DeckFilter` (`addedBetween`, `addedInLastDays`, `wordTypes`), combined with AND, stored as JSON with a `type` discriminator. A type this version doesn't know becomes `unknown`: it's kept verbatim (so it survives sync) and matches nothing. Adding a filter type means a new union case plus its SQL condition in `data/local/deck_filter_query.dart`.
  - Date filters use the device's local calendar days, converted to UTC bounds.
  - `recap_session.dart`: pure session logic (shuffle, direction, reveal/answer, counts). Nothing is persisted.
- No UI strings (e.g. field labels) belong in the domain layer.
- `lib/data/local/`: Drift (SQLite) database.
  - `entries` rows carry derived columns written by `mappers.dart`: `search_term`, `search_translations` (newline-joined) and `duplicate_key`.
  - A partial unique index on `(pack_id, word_type, duplicate_key) WHERE deleted_at IS NULL` enforces the no-duplicates rule at the DB level.
  - `decks.filters` is JSON text (`DeckFilterListConverter`).
  - `deck_filter_query.dart` turns deck filters into a Drift `Expression<bool>` on `entries`, so matching runs in SQL. Drift compares text-stored dates via `julianday`, so instants compare correctly whatever offset they were stored with.
  - Dates are stored as ISO-8601 text (`build.yaml`).
  - Schema changes follow this workflow:
    1. change the tables and bump `schemaVersion`;
    2. run `dart run drift_dev make-migrations`, which snapshots the schema into `drift_schemas/`, regenerates `app_database.steps.dart` and creates tests in `test/drift/`;
    3. add the `fromNToM` step to `stepByStep` in `AppDatabase.migration`;
    4. extend the generated data-integrity test.
  - Never edit an existing version's snapshot.
- `lib/data/repositories/`: an abstract interface plus a `Local…` Drift implementation per aggregate.
  - Writes return `Result<T>` (`lib/utils/result.dart`: `Ok`/`Err`) carrying the exceptions in `lib/domain/exceptions.dart`.
  - `EntryRepository.add`/`update` validate against the pack's `LanguageSchema`, then the duplicate rule.
  - `search` runs a SQL `LIKE` on the normalized columns for direct matches. Only if there are none, it scores a lightweight `(id, keys)` projection in Dart for fuzzy matches.
  - `DeckRepository.watchMatchCount` is a live SQL `count()` for the deck editor; `matchingEntries` loads a deck's entries, oldest first.
  - Deletes are soft. Deleting a pack soft-deletes its entries and decks.
  - Clock and id generator are injectable (`lib/utils/clock.dart`; ids are UUID v7).
- Tests use an in-memory DB: `AppDatabase(NativeDatabase.memory())`.

## Testing

- **Layout:**
  - `test/domain` and `test/data`: logic, repositories, sync and the Supabase adapter contract;
  - `test/ui`: view models and messages;
  - `test/widget`: screens;
  - `test/drift`: generated schema-migration tests;
  - `integration_test/`: end-to-end on a real device, with faked auth and cloud.
- **`test/helpers/`:**
  - `TestRepositories`: repositories over an in-memory DB, with a controllable clock and per-device id prefixes;
  - `FakeRemoteSyncApi`: the server write rules (last write wins, server timestamps, FK on entries and decks). It can fail specific operations, hold `fetchPacks` with a gate, and place rows at chosen server times;
  - `SyncDevice`: one simulated installation;
  - `FakeAuthService`: sign-in controlled by the test;
  - `widget_harness.dart`: `pumpRoutes`, `signedInProviders`, `settle`, `disposeAndClose`, `useTallWindow`.
- **Widget tests with drift:**
  - Run DB setup and assertions inside `tester.runAsync`. Drift needs real asynchrony.
  - Use `settle(tester)`, not `pumpAndSettle`. Progress indicators (the sync spinner, the timeline's load-more row) keep animating, so `pumpAndSettle` would never return.
  - Finish with `disposeAndClose(tester, db)`. It flushes drift's stream clean-up timers, which run on the fake clock, before closing; otherwise the test hangs on shutdown.
- **`SupabaseSyncApi` is tested against a `MockClient`** that pins the exact PostgREST requests and real-shaped responses. The responses must carry the `request`, which the postgrest client reads back.
- **Google sign-in on desktop** (`loopback_oauth.dart`): `receiveOAuthRedirect` is tested with a real local server on port 0.

## Cloud sync (Supabase)

Offline-first, automatic two-way sync, last write wins per row.

- **Server schema** lives only in `supabase/migrations/<version>_<name>.sql`.
  - Apply new migrations with the Supabase MCP `apply_migration`, then rename the file to the version `list_migrations` reports.
  - Afterwards, run `get_advisors` (security and performance).
  - Tables `public.language_packs`, `public.entries` and `public.decks` mirror the local tables (JSON fields are `jsonb`).
  - RLS limits rows to `owner_id = (select auth.uid())`, and entries and decks may only reference the user's own packs.
  - `anon` has no access, and `authenticated` has no `DELETE` (deletions are soft, via `deleted_at`).
  - The trigger `private.apply_sync_write()` stamps `server_updated_at` and ignores updates whose `updated_at` is older than the stored row. It also keeps `owner_id` and `created_at` immutable.
  - When adding a `WordType`, also extend the `entries.word_type` check constraint with a migration, applied before the app release.
- **Local:**
  - Every app write sets `needs_push` on its row. `mappers.dart`'s `toCompanion(needsPush:)` defaults to true; only rows applied from the server pass false.
  - `sync_states` stores the per-account pull cursors (`packs_pulled_until`, `entries_pulled_until`, `decks_pulled_until`) and `last_synced_at`.
- **`SyncEngine.run(ownerId)`** (`data/repositories/sync_engine.dart`):
  1. Push dirty packs, then dirty entries, then dirty decks, in batches, via `RemoteSyncApi` upserts (`data/services/supabase_sync_api.dart`). A row is marked clean only if `updated_at` is unchanged since it was read.
  2. Pull packs, then entries, then decks, keyset-paged by (`server_updated_at`, `id`), starting `overlap` (1 min) before the stored cursor so late commits aren't missed. `LocalSyncStore.applyRemote*` keeps only versions not older than the local one.
  3. Push again to upload any conflict deletions.
- **Duplicate across devices** (same pack, word type and duplicate key, different ids): `LocalSyncStore` keeps the entry created first (ties go to the smaller id) and soft-deletes the other, marked dirty.
- **Unknown pack:** an entry or deck whose pack isn't known locally yet stops the page. It's retried on the next sync.
- **`SyncRepository`** (ChangeNotifier) triggers syncs:
  - on sign-in;
  - `debounce` after local dirty writes (it ignores writes made by sync itself);
  - every `interval`;
  - on app resume (`app.dart`);
  - via `SyncButton` in the app bars.

  It exposes `phase` (idle, syncing, offline, failed), `lastSyncedAt` and `error`. Network errors (`http.ClientException`, timeouts) count as offline.
- Web: SQLite runs from `web/sqlite3.wasm` + `web/drift_worker.js`, taken from the drift GitHub release matching `pubspec.lock`'s drift version (currently `drift-2.35.2`). Replace both whenever drift is upgraded: `gh release download drift-<version> -R simolus3/drift -p drift_worker.js -p sqlite3.wasm -D web --clobber`. For the fastest browser storage (OPFS), serve with `Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp`. In dev: `flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp`. Without them it falls back to slower storage. Production hosting must serve `.wasm` as `application/wasm`.

## Supabase

- Project: `langtool`, ref `gdduanyobtuqplhknxss`, region `eu-west-1`.
- The Supabase MCP server (`.mcp.json`) has access to the whole organization. Only operate on `langtool`.
- Never commit keys. Local config goes in `env/*.json` (gitignored), passed with `--dart-define-from-file`.

## Hot reload

After editing `.dart` files under `lib/` (not comment-only changes), discover the running app with the Dart MCP `dtd` tool. Then call `hot_reload` for UI or simple method changes, or `hot_restart` for changes to `main()`, `initState`, or global/static state. Skip this for files outside `lib/`.
